//
//  SchoolPageViewController.h
//  公开课项目1
//
//  Created by qianfeng on 15/7/11.
//  Copyright (c) 2015年 qianfeng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DisciplineModel.h"

@interface SchoolPageViewController : UIViewController

@property(copy,nonatomic)NSString *urlStr;
@property(strong,nonatomic)DisciplineModel *model;

@property(assign,nonatomic)BOOL isDisipline;
@property(assign,nonatomic)BOOL isTED;

@end
