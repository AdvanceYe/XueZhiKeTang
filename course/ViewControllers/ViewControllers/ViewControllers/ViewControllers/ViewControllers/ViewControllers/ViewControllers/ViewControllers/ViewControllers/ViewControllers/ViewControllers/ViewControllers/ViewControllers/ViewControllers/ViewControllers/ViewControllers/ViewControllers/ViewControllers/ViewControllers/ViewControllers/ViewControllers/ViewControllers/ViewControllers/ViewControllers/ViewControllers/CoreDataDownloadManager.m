//
//  CoreDataDownloadManager.m
//  公开课项目1
//
//  Created by qianfeng on 15/7/20.
//  Copyright (c) 2015年 qianfeng. All rights reserved.
//

#import "CoreDataDownloadManager.h"

@implementation CoreDataDownloadManager

+(id)manager
{
    static CoreDataDownloadManager *_m = nil;
    if (!_m) {
        _m = [[CoreDataDownloadManager alloc]init];
    }
    return _m;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self openDB];
    }
    return self;
}

-(void)openDB
{
    //把coredata里面的所有表实体打包成一个对象
    //后面的操作可以直接操作数据库里面的所有对象
    NSManagedObjectModel *model = [NSManagedObjectModel mergedModelFromBundles:nil];
    
    //创建数据库操作的缓存
    NSPersistentStoreCoordinator *coord = [[NSPersistentStoreCoordinator alloc]initWithManagedObjectModel:model];
    
    //指定本地持久化数据的数据库
    NSString *path = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/coredataDownload.sqlite"];
    NSError *err = nil;
    
    [coord addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:[NSURL fileURLWithPath:path] options:nil error:&err];
    
    if (err) {
        NSLog(@"打开数据库失败");
    }
    else
    {
        _context = [[NSManagedObjectContext alloc]init];
        [_context setPersistentStoreCoordinator:coord];
    }
}

-(void)addLesson:(void(^)(LessonDownload *))fillcb
{

}

-(void)deleteLessonByVid:(NSString *)vid
{

}

-(void)deleteLesson:(LessonDownload *)lesson
{

}

-(void)deleteLessons:(NSArray *)arr
{

}

-(void)updateLesson:(LessonDownload *)lesson
{

}

//搜索是否存在
-(BOOL)searchLessonByVid:(NSString *)vid
{
    return NO;
}

//返回course
-(LessonDownload *)returnLessonByVid:(NSString *)vid
{
    return nil;
}

-(NSArray *)fetchLessonByCourseId
{
    return nil;
}

-(NSArray *)fetchAll
{
    return nil;
}


@end
