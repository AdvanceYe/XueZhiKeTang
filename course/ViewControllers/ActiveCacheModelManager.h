//
//  ActiveCacheModelManager.h
//  公开课项目1
//
//  Created by AdvanceYe on 15/7/21.
//  Copyright (c) 2015年 AdvanceYe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ActiveCacheModel.h"
#import "LessonDownload.h"

@interface ActiveCacheModelManager : NSObject

+(id)sharedManager;

-(void)addCacheModel:(ActiveCacheModel *)cacheModel;

-(void)deleteCacheModel:(ActiveCacheModel *)cacheModel;
-(void)deleteAllCacheModel;
-(void)deleteCacheModelByLessonArray:(NSArray *)removeArray;

-(ActiveCacheModel *)searchCacheModelByLesson:(LessonDownload *)lesson;
-(ActiveCacheModel *)fetchCacheModelbyCourseId:(NSString *)courseId andVid:(NSString *)vid;


@end
