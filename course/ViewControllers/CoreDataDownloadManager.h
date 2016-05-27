//
//  CoreDataDownloadManager.h
//  公开课项目1
//
//  Created by AdvanceYe on 15/7/20.
//  Copyright (c) 2015年 AdvanceYe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LessonDownload.h"
@interface CoreDataDownloadManager : NSObject

@property (nonatomic,strong) NSManagedObjectContext *context;

+(id)manager;

-(void)addLesson:(void(^)(LessonDownload *))fillcb;

-(void)deleteLessonByVid:(NSString *)vid;

-(void)deleteLesson:(LessonDownload *)lesson;

-(void)deleteLessons:(NSArray *)arr;

-(void)updateLesson:(LessonDownload *)lesson;

//搜索是否存在
-(BOOL)searchLessonByVid:(NSString *)vid;
-(BOOL)searchLessonByCourseId:(NSString *)courseId;

//返回lesson
-(NSArray *)returnLessonByCourseId:(NSString *)courseId;
-(LessonDownload *)returnLessonByVid:(NSString *)vid;

-(NSArray *)fetchLessonSortByCourseId;
-(NSArray *)fetchLessonByCourseId:(NSString *)courseId;
-(NSArray *)fetchAll;

@end
