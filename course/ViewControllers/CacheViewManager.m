//
//  CacheViewManager.m
//  公开课项目1
//
//  Created by AdvanceYe on 15/7/21.
//  Copyright (c) 2015年 AdvanceYe. All rights reserved.
//

#import "CacheViewManager.h"

@implementation CacheViewManager
{
    NSMutableArray *_cacheViewArr;
}
+(id)sharedManager
{
    static CacheViewManager *_m = nil;
    if (!_m) {
        _m = [[CacheViewManager alloc]init];
    }
    return _m;
}

-(id)init
{
    self = [super init];
    if (self) {
        _cacheViewArr = [[NSMutableArray alloc]init];
    }
    return self;
}

-(void)addCacheView:(CacheView *)cacheView
{
    [_cacheViewArr addObject:cacheView];
}

-(void)deleteCacheView:(CacheView *)cacheView
{
    [_cacheViewArr removeObject:cacheView];
}

-(void)deleteAllCacheView
{
    [_cacheViewArr removeAllObjects];
    NSLog(@"删除全部cacheView成功");
}

-(CacheView *)searchCacheViewByLesson:(LessonDownload *)lesson
{
    for (CacheView *cacheView in _cacheViewArr) {
        if ([cacheView.lessonDownloadModel.vid isEqualToString:lesson.vid]) {
            return cacheView;
        }
    }
    return nil;
}

-(void)deleteCacheViewsByLessonArray:(NSArray *)removeArray
{
    for (int i = 0; i < removeArray.count; i++) {
        LessonDownload *lesson = removeArray[i];
        CacheView *cacheView = [self searchCacheViewByLesson:lesson];
        if (cacheView != nil) {//如果存在
            [cacheView.request clearDelegatesAndCancel];
            //将cacheView删除
            [_cacheViewArr removeObject:cacheView];
        }
    }
}

-(CacheView *)fetchCacheViewbyCourseId:(NSString *)courseId andVid:(NSString *)vid
{
    for (CacheView *view in _cacheViewArr) {
        if ([view.courseId isEqualToString:courseId] && [view.model.vid isEqualToString:vid]) {
            return view;
        }
    }
    return nil;
}

-(NSArray *)fetchAllCacheView
{
    return _cacheViewArr;
}

@end
