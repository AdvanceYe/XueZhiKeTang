//
//  LessonViewController.h
//  公开课项目1
//
//  Created by AdvanceYe on 15/7/9.
//  Copyright (c) 2015年 AdvanceYe. All rights reserved.
//

#import "BaseViewController.h"

@interface LessonViewController : BaseViewController

@property(copy,nonatomic)void(^callBack)(UITableView *,NSIndexPath *);

-(void)uiConfigure;

@end
