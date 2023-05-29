//
//  ImageUtils.m
//  MyOpenCV
//
//  Created by 崔辉辉 on 2018/7/25.
//  Copyright © 2018年 huihui. All rights reserved.
//

#import "ImageUtils.h"

@implementation ImageUtils
Mat CustomImageToMat(const UIImage *image) {
    Mat mat_image_src;
    
    /*
     描述一张图片 除了大小 还有色彩空间
     */
    
    //第一步：获取图片大小
    NSUInteger width = CGImageGetWidth(image.CGImage);
    NSUInteger height = CGImageGetHeight(image.CGImage);

    //第二步：获取颜色空间
    //一张图片-------像素点组成，jpg png 是位图， 还有矢量图
    
    //像素点------ARGB
    CGColorSpaceRef colorSpaceRef = CGImageGetColorSpace(image.CGImage);
    
    //第三步：构建Mat
    //参数三：表示规则类型
    //CV_[位数 (每个通道存储的位数)][是否带符号][类型前缀 （char类型）][通道数]
    //默认不透明 255
    mat_image_src = Mat(height, width, CV_8UC4);
    
    //第四步：创建图片上下文（存储图片信息 类似画板 可以画想要的东西）
    //参数一：数据源
    //参数四：每一个像素（通道 ARGB其中的一种）占用的空间是多大    R 8位 G 8位 ...
    //最后参数：排版信息 （ARGB）4个通道是怎么排列的
    CGContextRef contextRef = CGBitmapContextCreate(mat_image_src.data, width, height, 8, mat_image_src.step[0], colorSpaceRef, kCGImageAlphaNoneSkipLast | kCGBitmapByteOrderDefault);
    
    //已经存储了这个上下文 信息
    
    //第五步：图片信息保存到Mat上
    CGContextDrawImage(contextRef, CGRectMake(0, 0, width, height), image.CGImage);
    
    //第六步：释放内存空间
    //遵循先开辟后释放原则
    CGContextRelease(contextRef);
    CGColorSpaceRelease(colorSpaceRef);
    
    return mat_image_src;
}

+ (UIImage *)imageToGray:(UIImage *)image {
    
    //第一步：图片大小
    NSUInteger width = CGImageGetWidth(image.CGImage);
    NSUInteger height = CGImageGetHeight(image.CGImage);
    
    //第二步：颜色空间
    CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceRGB();

    //calloc分配内存大小 第一个参数 是大小。第二个参数是 类型大小
    //32位
    UInt32 *imagePiexl = (UInt32 *)calloc(width * height, sizeof(UInt32));
    //第三步：创建上下文
    CGContextRef contextRef = CGBitmapContextCreate(imagePiexl, width, height, 8, 4 * width, colorSpaceRef, kCGImageAlphaNoneSkipLast | kCGBitmapByteOrderDefault);

    //kCGImageAlphaNoneSkipLast 通道顺序：ARGB。RGBA
    
    //第四步：保存图片信息
    CGContextDrawImage(contextRef, CGRectMake(0, 0, width, height), image.CGImage);

    //第五步：将彩色图片------灰色图片
    //原理分析： 彩色图片（R/G/B三个数值不相等）  灰色图片：（R/G/B 相等）
    //灰色图片也就是灰度
    //两种算法
    //第一种算法：取平均值：R = G = B = (R + G + B) / 3
    //第二种算法：加权  R = G = B = (0.3 * R + 0.59 * G + 0.11 * B)
    
    //逐点操作 循环
    for (int y = 0; y < height; y++) {
        for (int x = 0; x < width; x++) {
            //取出像素点 RGB通道   8位 char类型
            uint8_t *rgbPiexl = (uint8_t *)&imagePiexl[y * width + x];
            //计算灰度
            uint32_t gray = (0.3 * rgbPiexl[0] + 0.59 * rgbPiexl[1] + 0.11 * rgbPiexl[2]);
            rgbPiexl[0] = gray;
            rgbPiexl[1] = gray;
            rgbPiexl[2] = gray;

        }
    }

    CGImageRef imageRef = CGBitmapContextCreateImage(contextRef);
    CGContextRelease(contextRef);
    CGColorSpaceRelease(colorSpaceRef);
    free(imagePiexl);
    
    UIImage *resultUIImage = [UIImage imageWithCGImage:imageRef scale:image.scale orientation:UIImageOrientationUp];
    CGImageRelease(imageRef);
    
    //Core Graphics --- 处理
    //GPUImage/OpenGL ES（跨平台的），
    
    
    return resultUIImage;
}

//马赛克
+ (UIImage *)imageMosic:(UIImage *)image {
    //第一步：确定图片大小
    NSUInteger width = CGImageGetWidth(image.CGImage);
    NSUInteger height = CGImageGetHeight(image.CGImage);
    
    //第二步：创建色彩空间
    CGColorSpaceRef colorSpaceRef = CGImageGetColorSpace(image.CGImage);

    //第三步：创建上下文
    //第三步的第一种情况。这种不需要第五步。
    /*
     unsigned char *bitmapPixels = (unsigned char *)calloc(width * height, sizeof(uint8_t));
    CGContextRef contextRef = CGBitmapContextCreate(bitmapPixels, width, height, 8, 4 * width, colorSpaceRef, kCGImageAlphaPremultipliedLast);
    */
    //第三步的第二种情况。这种需要第五步。
    CGContextRef contextRef = CGBitmapContextCreate(nil, width, height, 8, 4 * width, colorSpaceRef, kCGImageAlphaPremultipliedLast);
    
    //第四步：解析图片信息
    CGContextDrawImage(contextRef, CGRectMake(0, 0, width, height), image.CGImage);

    //第五步：获取指向图片的指针
    //图片信息存在于contextRef
    unsigned char *bitmapPixels = (unsigned char *)CGBitmapContextGetData(contextRef);
    
    //第六步：核心功能 打码
    //原理分析：像素点变少 显示信息就少。之前一个像素点是一个元素，现在3X3个像素当成一个像素点. 显示的颜色少了，看起来就像是马赛克。
    //两个for循环 从上到下 从左到右 遍历
    //把当前颜色值保存到 unsigned char *pixels[4]中。就是左上角的那个像素点。
    unsigned char *pixels[4] = {0};
    NSUInteger currentPixels = 0, mosaicSize = 20, preCurrentPiexl = 0;
    for (NSUInteger i = 0; i < height - 1; i++) {
        for (NSUInteger j = 0; j < width - 1; j++) {
            //取出当前像素点
            currentPixels = (i * width) + j;
            if (i % mosaicSize == 0) {
                if (j % mosaicSize == 0) {
                    //第一个像素点
                    memcpy(pixels, bitmapPixels + currentPixels * 4, 4);
                } else {
                    //处理的是第一行的其余像素点
                    memcpy(bitmapPixels + currentPixels * 4, pixels, 4);
                }
            } else {
                //除第一行的其他行
                preCurrentPiexl = (i - 1) * width + j;
                memcpy(bitmapPixels + currentPixels * 4, bitmapPixels + 4 * preCurrentPiexl, 4);
            }
        }
    }
    
    //图片显示出来
    //providerRef 一个数据集
    CGDataProviderRef providerRef = CGDataProviderCreateWithData(NULL, bitmapPixels, width * height * 4, NULL);
    CGImageRef mosaicImageRef = CGImageCreate(width, height, 8, 32, 4 * width, colorSpaceRef, kCGImageAlphaPremultipliedLast, providerRef, NULL, NULL, kCGRenderingIntentDefault);
    
    CGContextRef outContextRef = CGBitmapContextCreate(NULL, width, height, 8, 4 * width, colorSpaceRef, kCGImageAlphaPremultipliedLast);
    CGContextDrawImage(outContextRef, CGRectMake(0, 0, width, height), mosaicImageRef);
    CGImageRef resultImageRef = CGBitmapContextCreateImage(outContextRef);
    UIImage *resultImage = [UIImage imageWithCGImage:resultImageRef];
    
    CGImageRelease(resultImageRef);
    CGImageRelease(mosaicImageRef);
    CGColorSpaceRelease(colorSpaceRef);
    CGDataProviderRelease(providerRef);
    CGContextRelease(contextRef);
    CGContextRelease(outContextRef);
    
    return resultImage;
}

@end
