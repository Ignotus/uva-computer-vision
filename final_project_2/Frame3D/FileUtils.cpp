/*
 * FileUtils.cpp
 *
 *  Created on: 15 Nov 2015
 *      Author: Morris Franken @ 3DUniversum
 */

#include <fstream>
#include <stdexcept>
#include <opencv2/core.hpp>
#include <opencv2/imgcodecs/imgcodecs_c.h>
#include <opencv2/imgcodecs.hpp>
#include <boost/filesystem/operations.hpp>
#include <sys/stat.h>

#include "FileUtils.h"

using namespace std;
using namespace cv;

/* The following function are useful for saving multiple variables such as numbers, and matrices to a single file
 * The write-functions simply append the new data to a output_stream, therefore it is necessary to load the objects in the same order as they have been saved.
 *
 * Before the read functions can be called, the contents of the file should first be read to a char* (using readFile(...)),
 * which can then be used as input parameter for the read functions.
 *
 * The following functions are platform independent, meaning that the files produced on one system can always be read on a different system.
 */

char *readFile(char *filename, int &size) {
	ifstream file (filename, ios::in | ios::binary | ios::ate);
	size = (int)file.tellg()+1;
	file.seekg (0, ios::beg);
	char *txt = (char *)malloc(size);
	file.read (txt,size-1);
	file.close();
	txt[size-1] = 0;

	return txt;
}

bool fileExists (const std::string& name) {
  struct stat buffer;
  return (stat (name.c_str(), &buffer) == 0);
}

vector<string> ListFilesRecursive(string file_folder, string file_ext/*=""*/) {
	boost::filesystem::recursive_directory_iterator it(file_folder);
	boost::filesystem::recursive_directory_iterator endit;
	vector<string> file_names;
	bool noExtension = file_ext == "";
	for (;it != endit; it++) {
		if (is_regular_file(it->path()) && (noExtension || it->path().extension() == file_ext))
			file_names.emplace_back(it->path().string());
	}
	return file_names;
}

// FileReader
FileReader::~FileReader() {
	free(data_begin_);
}

FileReader::FileReader(string path) {
	data_begin_ = readFile(&path[0], size_);
	data_ = data_begin_;
	if (size_ == 0)
		throw(runtime_error("could not read "+ path));
}

uint32_t FileReader::readInt32() {
	uint32_t output = *((uint32_t *)data_);
	data_ += sizeof(uint32_t);
	return output;
}

double FileReader::readDouble() {
	double number = strtod(data_, &data_);
	data_++;
	return number;
}

vector<uchar> FileReader::readBytes(bool copy/*=true*/) {
	uint32_t size = *((uint32_t *)data_);
	data_ += sizeof(size) + size;
	vector<uchar> bytes;
	bytes.assign(data_ - size, data_);
	return copy? vector<uchar>(bytes) : bytes;
}

std::string FileReader::readString() {
	string output(data_);
	data_ += output.size() + 1; // TODO(morris): check this!
	return output;
}

Mat FileReader::readImage() {
	vector<uchar> image_data = readBytes(false);  // data will be copied in the imencode function
	return cv::imdecode(image_data, CV_LOAD_IMAGE_UNCHANGED);  		// image_data is copied
}

Mat FileReader::readMat() {
	uint32_t type = readInt32();
	uint32_t rows = readInt32();
	uint32_t cols = readInt32();

	Mat mat(rows, cols, type, data_);
	data_ = (char *)mat.dataend;

	return mat.clone();  // copy is necessary because we expect the bytes read from the file to be freed, otherwise it would result in memory leak
}

bool FileReader::isEnd() {
	int diff = (data_ - data_begin_) + 1;
	return diff >= size_;
}




// FileWriter
FileWriter::~FileWriter() {
	output_stream_.close();
}

FileWriter::FileWriter(string path) {
	output_stream_.open(&path[0], ios::binary);
}

void FileWriter::appendInt32(const uint32_t &number) {
	output_stream_.write((char *)&number, sizeof(number));
}

void FileWriter::appendDouble(const double &number) {
	output_stream_ << number << '\0';
}

void FileWriter::appendBytes(const char* data, const uint32_t size) {
	appendInt32(size);
	output_stream_.write(data, size);
}

void FileWriter::appendString(std::string &str) {
	output_stream_ << str << '\0';
}

void FileWriter::appendImage(Mat &img, string format, vector<int> params/* = vector<int>()*/) {
	vector<uchar> buff;
	cv::imencode(format, img, buff, params);

	appendBytes((char *)&buff[0], buff.size());
}

void FileWriter::appendMat(Mat &mat) {
	uint32_t type = mat.type();
	uint32_t rows = mat.rows;
	uint32_t cols = mat.cols;
	uint32_t sizeofMat = (mat.dataend - mat.data);

	appendInt32(type);
	appendInt32(rows);
	appendInt32(cols);
	output_stream_.write((char *)mat.data, sizeofMat); // elements from the OpenCV matrix are the same on all platforms: CV_8U, CV_32S, CV_32F, etc... all have a predefined size regardless of platform, therefore we can simply dump the memory to file and retrieve it later
}
