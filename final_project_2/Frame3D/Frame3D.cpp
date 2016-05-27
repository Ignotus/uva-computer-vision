/*
 * Frame3D.cpp
 *
 *  Created on: 15 Nov 2015
 *      Author: Morris Franken @ 3DUniversum
 */

#include <fstream>
#include <sstream>
#include <string>
#include <vector>
#include <iostream>
#include <stdexcept>
#include <opencv2/core/core.hpp>
#include <opencv2/highgui/highgui.hpp>
#include <opencv2/imgcodecs/imgcodecs_c.h>

#include "Frame3D.h"
#include "FileUtils.h"

#if USE_EIGEN
#include <Eigen/Core>
#include <opencv2/core/eigen.hpp>
#endif

using namespace std;
using namespace cv;

string Frame3D::extension = ".3df";
vector<int> Frame3D::paramsJPG  = {CV_IMWRITE_JPEG_QUALITY, 90};
vector<int> Frame3D::paramsWEBP = {CV_IMWRITE_WEBP_QUALITY, 90};
vector<int> Frame3D::paramsPNG  = {CV_IMWRITE_PNG_COMPRESSION, 3};

Frame3D::~Frame3D() {}
Frame3D::Frame3D() : version_(-1), focal_length_(0) {}
Frame3D::Frame3D(string path) : version_(-1), focal_length_(0) {
	load(path);
}
Frame3D::Frame3D(Mat rgb_image, Mat depth_image, Mat rotation_translation, float focal_length, std::string device_name/*=""*/) :
	version_(-1),
	rgb_image_(rgb_image),
	depth_image_(depth_image),
	transformation_(rotation_translation),
	focal_length_(focal_length),
	device_name_(device_name)
{
	assert(rgb_image.type() == CV_8UC3);
	assert(depth_image.type() == CV_16U);
	assert(transformation_.size() == Size(4,4));
	syncTrans();
}
Frame3D::Frame3D(Mat rgb_image, Mat depth_image, Mat rotation, Mat translation, float focal_length, std::string device_name/*=""*/) :
	version_(-1),
	rgb_image_(rgb_image),
	depth_image_(depth_image),
	focal_length_(focal_length),
	device_name_(device_name)
{
	assert(rgb_image.type() == CV_8UC3);
	assert(depth_image.type() == CV_16U);
	assert(rotation.size() == Size(3,3));
	assert(translation.size() == Size(1,3));
	syncTrans(rotation, translation);
}

void Frame3D::syncTrans(cv::Mat &rotation, cv::Mat &translation) {
	transformation_ = Mat::zeros(4,4,CV_32F);
	rotation.copyTo(transformation_(Rect(0,0,3,3)));
	translation.copyTo(transformation_(Rect(3,0,1,3)));
	syncTrans();
}

void Frame3D::syncTrans() {
	rotation_ = transformation_(Rect(0,0,3,3));
	translation_ = transformation_(Rect(3,0,1,3));
}

void Frame3D::setTranslation(cv::Mat &translation) {
	assert(translation.size() == Size(1,3));
	translation.copyTo(transformation_(Rect(3,0,1,3)));
	translation_ = transformation_(Rect(3,0,1,3));
}

void Frame3D::setRotation(cv::Mat &rotation) {
	assert(rotation.size() == Size(3,3));
	rotation.copyTo(transformation_(Rect(0,0,3,3)));
	rotation_ = transformation_(Rect(0,0,3,3));
}

void Frame3D::setTranformation(cv::Mat &transformation) {
	assert(transformation_.size() == Size(4,4));
	transformation_ = transformation;
	syncTrans();
}

/* Get Eigen Matrix format, convienient single matrix transformation in Eigen format. Enable it if you have Eigen installed
 */

#if USE_EIGEN
Eigen::Matrix4f Frame3D::getEigenTransform() const {
	Eigen::Matrix4f eigen_matrix;
	cv2eigen(transformation_, eigen_matrix);
        eigen_matrix(3, 3) = 1.;
	return eigen_matrix;
}
#endif

/* Save 3D frame to file. 2 options are available:
 *   - version 0.5		: Frame is saved without any compression, a simple memory dump
 *   - version 1		: Frame is saved using JPG compression (90%) on the rgb_image, and PNG compression(type 3) on the depth_image.
 *   					  This compression comes at a cost, since it is about 5 times slower to load than simple memory dump
 *   - version 1.2		: In addition to version 1, in version 1.2 the rotation and translation matrices are stored in 1 4x4 matrix
 *   - version 1.3		: Device name is added
 */
void Frame3D::save(string path, double version/*=1.3*/) {
	if (version != 0.5 && version != 1 && version != 1.2 && version != 1.3)
		throw(runtime_error("Frame3D::save : invalid version number!, currently only version 0.5, 1, 1.2 and 1.3 are supported"));

	FileWriter writer(path);
	writer.appendDouble(version);
	if (version >= 1) {
		writer.appendImage(rgb_image_, ".jpg", paramsJPG);
		writer.appendImage(depth_image_, ".png", paramsPNG);
	} else {
		writer.appendMat(rgb_image_);
		writer.appendMat(depth_image_);
	}
	if (version >= 1.2) {
		writer.appendMat(transformation_);
	} else {
		Mat temp1 = rotation_.clone();
		Mat temp2 = translation_.clone();
		writer.appendMat(temp1);
		writer.appendMat(temp2);
	}
	writer.appendDouble(focal_length_);
	if (version >= 1.3)
		writer.appendString(device_name_);
}

/* Load .3df file, the variables have to be loaded in the same order as they have been saved
 * TODO(morris) : make something like a header to check whether or not this is actually a legit .3DF file
 */
void Frame3D::load(string path) {
	int index = path.find_last_of('.');
	if (index > 0 && path.substr(index) == Frame3D::extension) {
		FileReader reader(path);

		version_ = reader.readDouble();
		if (version_ >= 1) {
			rgb_image_ 	 	 = reader.readImage();
			depth_image_ 	 = reader.readImage();
		} else {
			rgb_image_ 	 	 = reader.readMat();
			depth_image_  	 = reader.readMat();
		}
		if (version_ >= 1.2) {
			transformation_  = reader.readMat();
			syncTrans();
		} else {
			rotation_ 	 	 = reader.readMat();
			translation_ 	 = reader.readMat();
			syncTrans(rotation_, translation_);
		}
		focal_length_ = reader.readDouble();
		if (version_ >= 1.3)
			device_name_	 = reader.readString();
	} else {
		throw(runtime_error("this is not a valid " + Frame3D::extension + " file: " + path));
	}
}

vector<Frame3D> Frame3D::loadFrames(string frame_dir_path) {
	vector<Frame3D> frames;
	vector<string> file_paths = ListFilesRecursive(frame_dir_path, extension);
	frames.reserve(file_paths.size());
	for (const string &path : file_paths) {
		frames.emplace_back(Frame3D(path));
	}

	return frames;
}
