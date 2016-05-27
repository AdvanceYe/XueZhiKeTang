//
//  MotherViewController.m
//  公开课项目1
//
//  Created by AdvanceYe on 15/7/15.
//  Copyright (c) 2015年 AdvanceYe. All rights reserved.
//

#import "MotherViewController.h"

@interface MotherViewController ()<UIScrollViewDelegate>

@end

@implementation MotherViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view addSubview:_leftViewController.view];
    
    _rightView = [[UIView alloc]initWithFrame:self.view.bounds];
    _rightView.backgroundColor = [UIColor whiteColor];
    [_rightView addSubview:_rightViewController.view];
    [self.view addSubview:_rightView];
}

@end
