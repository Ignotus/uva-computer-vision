# Computer Vision Team Project

[![License](http://img.shields.io/:license-mit-blue.svg)](LICENSE)

## Description

The following project contains matlab implementation of algorithms for:

### Computer Vision 1

- Photometric Stereo ([Assignment 1](assignment-1), [Report](assignment-1/report.pdf))
- Gaussian and Gaussian derivative filters ([Assignment 2](assignment-2), [Report](assignment-2/report.pdf))
- Harris Corner Detector and tracking with Optical Flow ([Assignment 3](assignment-3), [Report](assignment-3/report.pdf))
- Image Stitching and Alignment ([Assignment 4](assignment-4), [Report](assignment-4/report.pdf))
- Bag of words image classification ([Final Project](final-project), [Report](final-project/report.pdf))

### Computer Vision 2

- Iterative Closest Point ([Assignment 1](assignment-5))

## Dependencies

- [VLFeat](http://www.vlfeat.org/install-matlab.html)
- [libsvm](https://www.csie.ntu.edu.tw/~cjlin/libsvm/)

## Configuring

After building dependencies from Matlab:

```
addpath <path to the libsvm folder>/matlab/
run('<path to the vlfeat folder>/toolbox/vl_setup')
```


## Copyright

Copyright (c) 2016 Minh Ngo, Riaan Zoetmulder ^

<sup>^ These authors contributed equally to this work inspite of the fact that one doesn't use git :)</sup>

This project is distributed under the [MIT license](LICENSE). It's a part of the Computer Vision 1 and Computer Vision 2 courses taught by Theo Gevers and guest lectures at the University of Amsterdam. Please follow the [UvA regulations governing Fraud and Plagiarism](http://student.uva.nl/en/az/content/plagiarism-and-fraud/plagiarism-and-fraud.html) in the case if you are a student.

[fscatter3](assignment-5/fscatter3.m) is distributed under the BSD 2-Clause license. [VLFeat](http://www.vlfeat.org/license.html) is distributed under the BSD license. SIFT image descriptor used in our project is [patented](http://www.google.com/patents/US6711293) by David Lowe (University of British Columbia) and cannot be used for comercial purpose.

