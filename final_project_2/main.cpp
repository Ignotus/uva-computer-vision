#include <iostream>
#include <boost/format.hpp>

#include <pcl/point_types.h>
#include <pcl/point_cloud.h>
#include <pcl/features/integral_image_normal.h>
#include <pcl/visualization/pcl_visualizer.h>
#include <pcl/common/transforms.h>
#include <pcl/kdtree/kdtree_flann.h>
#include <pcl/filters/passthrough.h>
#include <pcl/surface/poisson.h>
#include <pcl/surface/impl/texture_mapping.hpp>
#include <pcl/features/normal_3d_omp.h>

#include <eigen3/Eigen/Core>

#include <opencv2/opencv.hpp>
#include <opencv2/core/mat.hpp>
#include <opencv2/core/eigen.hpp>
    
#include "Frame3D/Frame3D.h"

pcl::PointCloud<pcl::PointXYZ>::Ptr mat2IntegralPointCloud(const cv::Mat& depth_mat, const float focal_length, const float max_depth) {
    assert(depth_mat.type() == CV_16U);
    pcl::PointCloud<pcl::PointXYZ>::Ptr point_cloud(new pcl::PointCloud<pcl::PointXYZ>());
    const int half_width = depth_mat.cols / 2;
    const int half_height = depth_mat.rows / 2;
    const float inv_focal_length = 1.0 / focal_length;
    point_cloud->points.reserve(depth_mat.rows * depth_mat.cols);
    for (int y = 0; y < depth_mat.rows; y++) {
        for (int x = 0; x < depth_mat.cols; x++) {
            float z = depth_mat.at<ushort>(cv:: Point(x, y)) * 0.001;
            if (z < max_depth && z > 0) {
                point_cloud->points.emplace_back(static_cast<float>(x - half_width)  * z * inv_focal_length,
                                                 static_cast<float>(y - half_height) * z * inv_focal_length,
                                                 z);
            } else {
                point_cloud->points.emplace_back(x, y, NAN);
            }
        }
    }
    point_cloud->width = depth_mat.cols;
    point_cloud->height = depth_mat.rows;
    return point_cloud;
}


pcl::PointCloud<pcl::PointNormal>::Ptr computeNormals(pcl::PointCloud<pcl::PointXYZ>::Ptr cloud) {
    pcl::PointCloud<pcl::PointNormal>::Ptr cloud_normals(new pcl::PointCloud<pcl::PointNormal>); // Output datasets
    pcl::IntegralImageNormalEstimation<pcl::PointXYZ, pcl::PointNormal> ne;
    ne.setNormalEstimationMethod(ne.AVERAGE_3D_GRADIENT);
    ne.setMaxDepthChangeFactor(0.02f);
    ne.setNormalSmoothingSize(10.0f);
    ne.setInputCloud(cloud);
    ne.compute(*cloud_normals);
    pcl::copyPointCloud(*cloud, *cloud_normals);
    return cloud_normals;
}

pcl::PointCloud<pcl::PointXYZRGB>::Ptr transformPointCloud(pcl::PointCloud<pcl::PointXYZRGB>::Ptr cloud, const Eigen::Matrix4f& transform) {
    pcl::PointCloud<pcl::PointXYZRGB>::Ptr transformed_cloud(new pcl::PointCloud<pcl::PointXYZRGB>());
    pcl::transformPointCloud(*cloud, *transformed_cloud, transform);
    return transformed_cloud;
}


template<class T>
typename pcl::PointCloud<T>::Ptr transformPointCloudNormals(typename pcl::PointCloud<T>::Ptr cloud, const Eigen::Matrix4f& transform) {
    typename pcl::PointCloud<T>::Ptr transformed_cloud(new typename pcl::PointCloud<T>());
    pcl::transformPointCloudWithNormals(*cloud, *transformed_cloud, transform);
    return transformed_cloud;
}

pcl::PointCloud<pcl::PointNormal>::Ptr merge(Frame3D frames[]) {
    pcl::PointCloud<pcl::PointNormal>::Ptr model_point_cloud_norm(new pcl::PointCloud<pcl::PointNormal>());
    for (int i = 0; i < 8; ++i) {
        pcl::PointCloud<pcl::PointXYZ>::Ptr point_cloud = mat2IntegralPointCloud(frames[i].depth_image_, frames[i].focal_length_, 1.3);
        std::cout << "Points obtained " << point_cloud->size() << std::endl;
        
        pcl::PointCloud<pcl::PointNormal>::Ptr point_cloud_with_normals = computeNormals(point_cloud);
        
        point_cloud_with_normals = transformPointCloudNormals<pcl::PointNormal>(point_cloud_with_normals, frames[i].getEigenTransform());
        *model_point_cloud_norm += *point_cloud_with_normals;
    }
    
    return model_point_cloud_norm;
}

pcl::PointCloud<pcl::PointNormal>::Ptr computeNormals(
                const pcl::PointCloud<pcl::PointXYZ>::Ptr & cloud,
                int normalKSearch)
{
    pcl::PointCloud<pcl::PointNormal>::Ptr cloud_with_normals(new pcl::PointCloud<pcl::PointNormal>);
    pcl::search::KdTree<pcl::PointXYZ>::Ptr tree (new pcl::search::KdTree<pcl::PointXYZ>);
    tree->setInputCloud (cloud);

    // Normal estimation*
    pcl::NormalEstimationOMP<pcl::PointXYZ, pcl::Normal> n;
    pcl::PointCloud<pcl::Normal>::Ptr normals(new pcl::PointCloud<pcl::Normal>);
    n.setInputCloud(cloud);
    n.setSearchMethod(tree);
    n.setKSearch(normalKSearch);
    n.compute(*normals);
    //* normals should not contain the point normals + surface curvatures
    
    pcl::PointCloud<pcl::PointNormal>::Ptr cloud_with_normals_filtered(new pcl::PointCloud<pcl::PointNormal>);
    cloud_with_normals_filtered->reserve(cloud_with_normals->size());
    for (int i = 0; i < cloud_with_normals->size(); ++i) {
        const pcl::PointNormal& p = cloud_with_normals->at(i);
        // Filter out nan
        if (p.normal_x != p.normal_x || p.normal_y != p.normal_y || p.normal_z != p.normal_z)
            continue;
        
        cloud_with_normals_filtered->push_back(p);
    }

    // Concatenate the XYZ and normal fields*
    pcl::concatenateFields(*cloud, *normals, *cloud_with_normals_filtered);
    //* cloud_with_normals = cloud + normals*/

    return cloud_with_normals;
}

cv::Mat computeZbuffer(const pcl::PointCloud<pcl::PointXYZRGB>& point_cloud, const Frame3D& frame,
                       int window_size = 2, double threshold = 0.2) {
    const double inf = std::numeric_limits< double >::infinity();
    cv::Mat zbuffer(frame.depth_image_.rows,
                    frame.depth_image_.cols,
                    CV_32FC3,
                    cv::Vec3f(inf, inf, inf));

    const double focal_length = frame.focal_length_;
    const double sizeX = frame.depth_image_.cols;
    const double sizeY = frame.depth_image_.rows;
    const double cx = sizeX / 2.0;
    const double cy = sizeY / 2.0;
    
    for (const pcl::PointXYZRGB& point : point_cloud) {
        const int u_unscaled = std::round(focal_length * (point.x / point.z) + cx);
        const int v_unscaled = std::round(focal_length * (point.y / point.z) + cy);
        
        if (u_unscaled < 0 || v_unscaled < 0 || u_unscaled >= sizeX || v_unscaled >= sizeY)
            continue;
        
        cv::Vec3f& uv_point = zbuffer.at<cv::Vec3f>(v_unscaled, u_unscaled);
        if (uv_point[2] > point.z) {
            uv_point[0] = point.x;
            uv_point[1] = point.y;
            uv_point[2] = point.z;
        }
    }
    
    for (const pcl::PointXYZRGB& point : point_cloud) {
        const int u_unscaled = std::round(focal_length * (point.x / point.z) + cx);
        const int v_unscaled = std::round(focal_length * (point.y / point.z) + cy);

        if (u_unscaled < 0 || v_unscaled < 0 || u_unscaled >= sizeX || v_unscaled >= sizeY)
            continue;
        
        const cv::Vec3f& uv_point = zbuffer.at<cv::Vec3f>(v_unscaled, u_unscaled);
        
        const int k_min = std::max(0, v_unscaled - window_size);
        const int k_max = std::min(frame.depth_image_.rows, v_unscaled + window_size + 1);
        
        const int l_min = std::max(0, u_unscaled - window_size);
        const int l_max = std::min(frame.depth_image_.cols, u_unscaled + window_size + 1);
        for (int k = k_min; k < k_max; ++k) {
            for (int l = l_min; l < l_max; ++l) {
                cv::Vec3f& second_point = zbuffer.at<cv::Vec3f>(k, l);
                if (uv_point[2] + threshold < second_point[2]) {
                    second_point = uv_point;
                }
            }
        }
    }
    
    return zbuffer;
}

int main(int argc, char *argv[]) {
    if (argc != 2)
        return 0;
    
    Frame3D frames[8];
    
    for (int i = 0; i < 8; ++i) {
        frames[i].load(boost::str(boost::format("%s/%05d.3df") % argv[1] % i));
    }

    std::cout << "Merging point cloud" << std::endl;
    pcl::PointCloud<pcl::PointNormal>::Ptr model_point_cloud_norm = merge(frames);
    
    std::cout << "Got: " << model_point_cloud_norm->size() << " points" << std::endl;
    std::cout << "Generating mesh" << std::endl;

    pcl::PointCloud<pcl::PointNormal>::Ptr reduced_point_cloud(new pcl::PointCloud<pcl::PointNormal>());
    pcl::PassThrough<pcl::PointNormal> filter;

    filter.setInputCloud(model_point_cloud_norm);
    filter.filter(*reduced_point_cloud);
    std::cout << "Got: " << reduced_point_cloud->size() << " points" << std::endl;
    
    pcl::Poisson<pcl::PointNormal> rec;
    rec.setDepth(10);
    rec.setInputCloud(reduced_point_cloud);

    pcl::PolygonMesh triangles;
    rec.reconstruct(triangles);
    
    std::cout << "Finished" << std::endl;
    
    pcl::PointCloud<pcl::PointXYZRGB>::Ptr cloud(new pcl::PointCloud<pcl::PointXYZRGB>);
    pcl::fromPCLPointCloud2(triangles.cloud, *cloud);
    
    for (int i = 0; i < 8; ++i) {
        float focal_length = frames[i].focal_length_;
        
        // Camera width
        double sizeX = frames[i].depth_image_.cols;
        // Camera height
        double sizeY = frames[i].depth_image_.rows;
        
        // Centers
        double cx = sizeX / 2.0;
        double cy = sizeY / 2.0;
        
        pcl::PointCloud<pcl::PointXYZRGB>::Ptr transformed_cloud = transformPointCloud(cloud, frames[i].getEigenTransform().inverse());
        
        const cv::Mat& zbuffer = computeZbuffer(*transformed_cloud, frames[i]);
        
        int point_found = 0;
        for (const pcl::Vertices& polygon : triangles.polygons) {
            const pcl::PointXYZRGB& point = transformed_cloud->at(polygon.vertices[0]);
            
            int u_unscaled = std::round(focal_length * (point.x / point.z) + cx);
            int v_unscaled = std::round(focal_length * (point.y / point.z) + cy);
            
            const cv::Vec3f& zmap_point = zbuffer.at<cv::Vec3f>(v_unscaled, u_unscaled);
            
            const float eps = 0.000000001;
            // If not visible
            if (std::fabs(zmap_point[0] - point.x) > eps
                    || std::fabs(zmap_point[1] - point.y) > eps
                    || std::fabs(zmap_point[2] - point.z) > eps)
                continue;

            float u = static_cast<float>(u_unscaled / sizeX);
            float v = static_cast<float>(v_unscaled / sizeY);
            
            if (u < 0. || u >= 1 || v < 0. || v >= 1)
                continue;
            
            int x = std::floor(frames[i].rgb_image_.cols * u);
            int y = std::floor(frames[i].rgb_image_.rows * v);
            
            for (int h = 0; h < 3; ++h) {
                pcl::PointXYZRGB& original_point = cloud->at(polygon.vertices[h]);
                const cv::Vec3b& rgb = frames[i].rgb_image_.at<cv::Vec3b>(y, x);
                if (original_point.r != 0 && original_point.g != 0 && original_point.b != 0)
                    continue;
                original_point.b = rgb[0];
                original_point.g = rgb[1];
                original_point.r = rgb[2];
            }
            
            ++point_found;
        }
        
        std::cout << point_found << " points found" << std::endl;
    }
    
    pcl::PointCloud<pcl::PointXYZRGB>::Ptr textured_cloud(new pcl::PointCloud<pcl::PointXYZRGB>);
    textured_cloud->reserve(cloud->size());
    
    for (const pcl::PointXYZRGB& point : *cloud) {
        if (point.r != 0 || point.g != 0 || point.b != 0) {
            textured_cloud->push_back(point);
        }
    }
    
    // Filling gaps
    pcl::KdTreeFLANN<pcl::PointXYZRGB>::Ptr tree2(new pcl::KdTreeFLANN<pcl::PointXYZRGB>);
    tree2->setInputCloud(textured_cloud);
    for (pcl::PointXYZRGB& point : *cloud) {
        if (point.r != 0 || point.g != 0 || point.b != 0)
            continue;
        
        std::vector<int> k_indices;
        std::vector<float> k_dist;
        tree2->nearestKSearch(point, 1, k_indices, k_dist);
        
        const pcl::PointXYZRGB& textured_point = textured_cloud->at(k_indices[0]);
        point.r = textured_point.r;
        point.g = textured_point.g;
        point.b = textured_point.b;
    }
   
   // Smoothing
   tree2->setInputCloud(cloud);
   for (pcl::PointXYZRGB& point : *cloud) {
        if (point.r != 0 || point.g != 0 || point.b != 0)
            continue;
        
        std::vector<int> k_indices;
        std::vector<float> k_dist;
        tree2->nearestKSearch(point, 5, k_indices, k_dist);
        
        int r = 0;
        int g = 0;
        int b = 0;
        for (int i = 0; i < 5; ++i) {
            const pcl::PointXYZRGB& textured_point = textured_cloud->at(k_indices[i]);
            r += textured_point.r;
            g += textured_point.g;
            b += textured_point.b;
        }
        
        r /= 5;
        g /= 5;
        b /= 5;
        point.r = (uint8_t) r;
        point.g = (uint8_t) g;
        point.b = (uint8_t) b;
    }
    
    pcl::toPCLPointCloud2(*cloud, triangles.cloud);
    
    
    std::cout << "Finished texturing" << std::endl;
    
    boost::shared_ptr<pcl::visualization::PCLVisualizer> viewer(new pcl::visualization::PCLVisualizer("3D Viewer"));
    viewer->setBackgroundColor(1, 1, 1);
    
    viewer->addPolygonMesh(triangles, "meshes", 0);
    
    viewer->addCoordinateSystem(1.0);
    viewer->initCameraParameters();

    while (!viewer->wasStopped()) {
        viewer->spinOnce(100);
        boost::this_thread::sleep(boost::posix_time::microseconds(100000));
    }

    return 0;
}
