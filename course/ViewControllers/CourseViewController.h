//
//  CourseViewController.h
//  公开课项目1
//
//  Created by AdvanceYe on 15/7/7.
//  Copyright (c) 2015年 AdvanceYe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CourseModel.h"
#import "LessonModel.h"

@interface CourseViewController : UIViewController
#warning 播放页需要解决的问题
/*
 1. 自动续播?
 2. 下载?
 3. 全屏?
*/

/*
 @property (nonatomic, retain) NSString * name;
 @property (nonatomic, retain) NSString * imgUrl;
 @property (nonatomic, retain) NSString * d_id;
 @property (nonatomic, retain) NSNumber * totalPlayRow;
 @property (nonatomic, retain) NSNumber * currentPlayRow;
 @property (nonatomic, retain) NSNumber * time;
 
 */


@property(copy,nonatomic) NSString *courseId;
@property(strong,nonatomic) CourseModel *courseModel;
@property(strong,nonatomic) NSMutableArray *lessonArray;

@property(nonatomic,assign) NSInteger currentPlayRow;
@property(nonatomic,assign) CGFloat initialTime;
@property(nonatomic,assign) BOOL isPlayTimeArchive;

@property(copy,nonatomic)void(^callBack)(NSInteger);

-(void)transitPlayUrl:(NSString *)url withRow:(NSInteger)row;

@end
