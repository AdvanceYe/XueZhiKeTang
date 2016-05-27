//
//  LessonListCell.h
//  公开课项目1
//
//  Created by AdvanceYe on 15/7/9.
//  Copyright (c) 2015年 AdvanceYe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LessonModel.h"
@interface LessonListCell : UITableViewCell

@property (copy,nonatomic)void(^callBack)(LessonModel *);

@end
