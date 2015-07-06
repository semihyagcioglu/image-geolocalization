# ![image-geolocalization](https://dl.dropboxusercontent.com/u/16169065/image-geolocalization-overview-wacv2015.png)

#### Introduction

This repository contains codes for the algorithms described in the study [City Scale Image Geolocalization via Dense Scene Alignment](http://www.semihyagcioglu.com/projects/image-geolocalization).

Please refer to project page for more details, which is avaliable at http://www.semihyagcioglu.com/projects/image-geolocalization

#### Requirements

- Matlab
- VLFeat library (vlfeat.org)

#### Installation

- For DSP (Deformable Spatial Pyramid Matching for Fast Dense Correspondences) code, you need to download the code from http://vision.cs.utexas.edu/projects/dsp/ and follow the installation instuctions.
- You can download San Francisco Landmark dataset from http://purl.stanford.edu/vn158kj2087

#### Notes

- lib folder holds external libraries used in the project
- data folder holds data files used in the project
- You may want change the default values in the LoadPreRequisities.m
- You can change algorithm parameters via settings.ini
- As a pre-processing step, you should extract image features via CreateAllImageFeaturesAtOnce.m
- We used a slightly modified version of gist code provided here http://people.csail.mit.edu/torralba/code/spatialenvelope/

#### Demo

	DemoApp('test', ~); % This will run demo app in test mode with the default settings.

#### Citing

If you find this package useful in your research, please consider citing:

    @inproceedings{yagcioglu2015city,
      title={City Scale Image Geolocalization via Dense Scene Alignment},
      author={Yagcioglu, Semih and Erdem, Erkut and Erdem, Aykut},
      booktitle={Applications of Computer Vision (WACV), 2015 IEEE Winter Conference on},
      pages={726–732},
      year={2015},
      organization={IEEE}
    }

#### Acknowledgment

We would like to thank to the following researchers, Kim et al. [1] for making DSP code, and Chen et al. [2] for making their dataset publicly available. 

1. DSP
	- Deformable Spatial Pyramid Matching for Fast Dense Correspondences, J. Kim, C. Liu, F. Sha, K. Grauman, CVPR 2013
2. San Francisco Landmark dataset
	- City-scale landmark identification on mobile devices, D. M. Chen, G. Baatz, K. Koser, S. S. Tsai, R. Vedantham, T. Pylvanainen, K. Roimela, X. Chen, J. Bach, M. Pollefeys, et al, CVPR 2011