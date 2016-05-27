//
//  ActiveCacheModelManager.m
//  公开课项目1
//
//  Created by AdvanceYe on 15/7/21.
//  Copyright (c) 2015年 AdvanceYe. All rights reserved.
//

#import "ActiveCacheModelManager.h"

@implementation ActiveCacheModelManager
{
    NSMutableArray *_activeCacheModelArr;
}
+(id)sharedManager
{
    static ActiveCacheModelManager *_m = nil;
    if (!_m) {
        _m = [[ActiveCacheModelManager alloc]init];
    }
    return _m;
}

-(id)init
{
    self = [super init];
    if (self) {
        _activeCacheModelArr = [[NSMutableArray alloc]init];
    }
    return self;
}

-(void)addCacheModel:(ActiveCacheModel *)cacheModel
{
    [_activeCacheModelArr addObject:cacheModel];
}

-(void)deleteCacheModel:(ActiveCacheModel *)cacheModel
{
    [_activeCacheModelArr removeObject:cacheModel];
}

-(void)deleteAllCacheModel
{
    [_activeCacheModelArr removeAllObjects];
}

-(ActiveCacheModel *)searchCacheModelByLesson:(LessonDownload *)lesson
{
    for (ActiveCacheModel *cacheModel in _activeCacheModelArr) {
        if ([cacheModel.vid isEqualToString:lesson.vid]) {
            return cacheModel;
        }
    }
    return nil;
}

-(void)deleteCacheModelByLessonArray:(NSArray *)removeArray
{
    for (int i = 0; i < removeArray.count; i++) {
        LessonDownload *lesson = removeArray[i];
        ActiveCacheModel *cacheModel = [self searchCacheModelByLesson:lesson];
        if (cacheModel != nil) {//如果存在
            [cacheModel.request clearDelegatesAndCancel];
            //将cacheView删除
            [_activeCacheModelArr removeObject:cacheModel];
        }
    }
}

-(ActiveCacheModel *)fetchCacheModelbyCourseId:(NSString *)courseId andVid:(NSString *)vid
{
    for (ActiveCacheModel *model in _activeCacheModelArr) {
        if ([model.courseId isEqualToString:courseId] && [model.vid isEqualToString:vid]) {
            return model;
        }
    }
    return nil;
}

@end
