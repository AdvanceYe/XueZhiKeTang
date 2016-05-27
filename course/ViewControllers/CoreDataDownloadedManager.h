//
//  CoreDataDownloadedManager.h
//  公开课项目1
//
//  Created by AdvanceYe on 15/7/23.
//  Copyright (c) 2015年 AdvanceYe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LessonDownload.h"

@interface CoreDataDownloadedManager : NSObject

@property (nonatomic,strong) NSManagedObjectContext *context;

+(id)manager;

-(void)addLesson:(void(^)(LessonDownload *))fillcb;

-(void)deleteLessonByVid:(NSString *)vid;
-(void)deleteLesson:(LessonDownload *)lesson;

-(void)updateLesson:(LessonDownload *)lesson;


-(LessonDownload *)returnLessonByVid:(NSString *)vid;
-(BOOL)searchLessonByCourseId:(NSString *)courseId;

-(NSArray *)returnLessonByCourseId:(NSString *)courseId;

@end
