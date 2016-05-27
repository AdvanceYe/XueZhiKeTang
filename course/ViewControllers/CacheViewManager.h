//
//  CacheViewManager.h
//  公开课项目1
//
//  Created by AdvanceYe on 15/7/21.
//  Copyright (c) 2015年 AdvanceYe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CacheView.h"

@interface CacheViewManager : NSObject

+(id)sharedManager;

-(void)addCacheView:(CacheView *)cacheView;

-(void)deleteCacheView:(CacheView *)cacheView;
-(void)deleteAllCacheView;
-(void)deleteCacheViewsByLessonArray:(NSArray *)removeArray;

-(CacheView *)fetchCacheViewbyCourseId:(NSString *)courseId andVid:(NSString *)vid;
-(NSArray *)fetchAllCacheView;

@end
