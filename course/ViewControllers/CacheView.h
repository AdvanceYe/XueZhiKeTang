//
//  CacheView.h
//  公开课项目1
//
//  Created by AdvanceYe on 15/7/21.
//  Copyright (c) 2015年 AdvanceYe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LessonDownload.h"
#import "LessonModel.h"
#import "CoreDataDownloadedManager.h"
#import "CoreDataDownloadingManager.h"

@interface CacheView : UIView<ASIProgressDelegate,ASIHTTPRequestDelegate>

@property(copy,nonatomic)NSString *courseId;
@property(copy,nonatomic)NSString *courseName;
@property(assign,nonatomic)BOOL isDownload;
@property(strong,nonatomic)LessonDownload *lessonDownloadModel;
@property(strong,nonatomic)ASIHTTPRequest *request;
@property(strong,nonatomic)UITapGestureRecognizer *tap;
@property(strong,nonatomic)LessonModel *model;
@property(strong,nonatomic)UIProgressView *progressView;
//tableView界面上的
@property(strong,nonatomic)UIProgressView *downloadPageProgressView;
@property(strong,nonatomic)UIView *downloadPageProgressBGView;
@property(strong,nonatomic)UILabel *progressLabel;
@property(strong,nonatomic)NSNumber *totalsize;

//callback,让其监听别的操作

//根据index来生成model
-(void)configureUI;

-(id)initWithFrame:(CGRect)frame lessonModal:(LessonModel *)model andCourseId:(NSString *)courseId;

@end
