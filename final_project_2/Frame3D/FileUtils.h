/*
 * FileUtils.h
 *
 *  Created on: 12 Nov 2015
 *      Author: Morris Franken @ 3DUniversum
 */

#ifndef FILEUTILS_H_
#define FILEUTILS_H_

#include <fstream>
#include <opencv2/core.hpp>
#include <string>
#include <vector>
#include <stdint.h>

char *readFile(char *filename, int &size);
bool fileExists (const std::string& name);
std::vector<std::string> ListFilesRecursive(std::string file_folder, std::string file_ext="");

class FileReader {
protected:
	char *data_begin_;
	char *data_;
	int size_;
public:
	~FileReader();
	FileReader(std::string path);

	uint32_t readInt32();
	double readDouble();
	std::vector<uchar> readBytes(bool copy=true);
	std::string readString();
	cv::Mat readImage();
	cv::Mat readMat();
	bool isEnd();
};

class FileWriter {
protected:
	std::ofstream output_stream_;
public:
	~FileWriter();
	FileWriter(std::string path);

	void appendInt32(const uint32_t &number);
	void appendDouble(const double &number);
	void appendBytes(const char* data, const uint32_t size);
	void appendString(std::string &str);
	void appendImage(cv::Mat &img, std::string format, std::vector<int> params = std::vector<int>());
	void appendMat(cv::Mat &mat);
};

#endif /* FILEUTILS_H_ */
