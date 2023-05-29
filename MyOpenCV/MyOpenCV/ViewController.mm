//
//  ViewController.m
//  MyOpenCV
//
//  Created by 崔辉辉 on 2018/7/25.
//  Copyright © 2018年 huihui. All rights reserved.
//

//导入头文件，把控制器改为.mm 因为是C++
//C++
#import <opencv2/opencv.hpp>
//对应的iOS处理模块
#import <opencv2/imgcodecs/ios.h>

#import "ViewController.h"
#import "ImageUtils.h"

//命名空间
using namespace cv;

@interface ViewController ()
@property (nonatomic, strong)UIImageView *imgV;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self setUpViews];
}
- (void)setUpViews {
    self.imgV = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"meinv"]];
    _imgV.frame = CGRectMake(0, 66, 300, 300);
    [self.view addSubview:_imgV];
    
    NSArray *titles = @[@"restore",@"grayAction",@"mosicAction"];
    for (int i = 0; i < titles.count; i++) {
        UIButton *testButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [testButton addTarget:self action:NSSelectorFromString(titles[i]) forControlEvents:UIControlEventTouchUpInside];
        testButton.frame = CGRectMake(80, 400 + i * 70, 100, 60);
        [testButton setTitle:titles[i] forState:UIControlStateNormal];
        testButton.backgroundColor = [UIColor cyanColor];
        [self.view addSubview:testButton];
    }
}

- (void)restore {
    _imgV.image = [UIImage imageNamed:@"meinv"];
}

- (void)grayAction {
    //彩色图标----灰色图片

    //opencv处理：
    /*


    //第一步：iOS平台 ----- OpenCV 图片 （C++/C）
    //Mat---核心数据结构， N维矩阵，图片几维，2（width/height）
    //Mat存储图片信息 主要是头
    Mat mat_image_src;

    //图片信息 解释

    //OpenCV方法：
//    UIImageToMat(_imgV.image, mat_image_src);
    //自己写的方法：
    mat_image_src = CustomImageToMat(_imgV.image);

    //第二步：彩色图片----灰色图片
    Mat mat_image_dest;
    cvtColor(mat_image_src, mat_image_dest, CV_BGR2GRAY);

    //第三步：转成iOS图片
    _imgV.image = MatToUIImage(mat_image_dest);


     */


    /*
     opencv就是干了这些事，已经帮我们处理好了。
     */


    //第二种 自己写的
    _imgV.image = [ImageUtils imageToGray:_imgV.image];

}


//打码功能
- (void)mosicAction {
    _imgV.image = [ImageUtils imageMosic:_imgV.image];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
