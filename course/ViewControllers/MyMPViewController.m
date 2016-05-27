//
//  MyMPViewController.m
//  公开课项目1
//
//  Created by AdvanceYe on 15/7/22.
//  Copyright (c) 2015年 AdvanceYe. All rights reserved.
//

#import "MyMPViewController.h"
#import "AppDelegate.h"

@interface MyMPViewController ()

@end

@implementation MyMPViewController

//viewWillAppear的时候,容许旋转
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

//viewWillDisappear的时候,恢复不容许旋转
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
//    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
//    delegate.allowRotation = NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
//    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
//    delegate.allowRotation = YES;
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    BOOL isAutoPlay = [userDefaults boolForKey:@"isAutoPlay"];
    self.moviePlayer.shouldAutoplay = isAutoPlay;
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
