/*
 * Frame3D.cpp
 *
 *  Created on: 15 Nov 2015
 *      Author: Morris Franken @ 3DUniversum
 */
#ifndef FRAME3D_H
#define FRAME3D_H

#define USE_EIGEN 1

#include <vector>
#include <opencv2/core/core.hpp>
#if USE_EIGEN
#include <Eigen/Core> // Eigen is not necessary
#endif

/* Storing a 3D frame, that includes all of the properties that have been captured by the camera.
 * It can be saved using JPG compression for the rgb image, and PNG compression for the depth map
 */
class Frame3D
{
protected:
	static std::vector<int> paramsJPG;  // Parameters for encoding JPG images
	static std::vector<int> paramsWEBP; // Parameters for encoding WEBP images
	static std::vector<int> paramsPNG;  // Parameters for encoding PNG images
	double version_;			   // version of the 3df file

	void syncTrans(cv::Mat &rotation, cv::Mat &translation);
	void syncTrans();
public:
	static std::string extension;	   // file extension (set to .3df)
	cv::Mat rgb_image_;
	cv::Mat depth_image_;
	cv::Mat rotation_;					// WARNING: DO not change these objects in full (such as rotation_ = mynewmatrix) because it is linked to transformation. Use the designated function for that
	cv::Mat translation_;				// ^^		it is allowed to change parts of it. such as rotation.at<float>(x,y) = 1
	cv::Mat transformation_;			// ^^
	double focal_length_;
	std::string device_name_;

	~Frame3D();
	Frame3D();
	Frame3D(std::string path);			// load 3df file on initialisation
	Frame3D(cv::Mat rgb_image, cv::Mat dept_image, cv::Mat rotation_translation, float focal_length, std::string device_name="");
	Frame3D(cv::Mat rgb_image, cv::Mat dept_image, cv::Mat rotation, cv::Mat translation, float focal_length, std::string device_name="");

	void setTranslation(cv::Mat &translation);
	void setRotation(cv::Mat &rotation);
	void setTranformation(cv::Mat &transformation);

#if USE_EIGEN
	Eigen::Matrix4f getEigenTransform() const;
#endif

	void save(std::string path, double version=1.3);
	void load(std::string path);
	static std::vector<Frame3D> loadFrames(std::string frame_dir_path);	// Load all .3df frames from a directory into a vector
};

#endif
