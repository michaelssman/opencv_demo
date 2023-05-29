//
//  ImageUtils.h
//  MyOpenCV
//
//  Created by 崔辉辉 on 2018/7/25.
//  Copyright © 2018年 huihui. All rights reserved.
//

#import <opencv2/opencv.hpp>
#import <UIKit/UIKit.h>

using namespace cv;
@interface ImageUtils : NSObject
Mat CustomImageToMat(const UIImage *image);

+ (UIImage *)imageToGray:(UIImage *)image;

//马赛克
+ (UIImage *)imageMosic:(UIImage *)image;

@end
