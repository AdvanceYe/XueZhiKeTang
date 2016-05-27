//
//  CoreDataDownloadedManager.m
//  公开课项目1
//
//  Created by AdvanceYe on 15/7/23.
//  Copyright (c) 2015年 AdvanceYe. All rights reserved.
//

#import "CoreDataDownloadedManager.h"

@implementation CoreDataDownloadedManager

+(id)manager
{
    static CoreDataDownloadedManager *_m = nil;
    if (!_m) {
        _m = [[CoreDataDownloadedManager alloc]init];
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
    NSString *path = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/coredataDownloaded.sqlite"];
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
    NSLog(@"%@",NSHomeDirectory());
    
    LessonDownload *lesson = [NSEntityDescription insertNewObjectForEntityForName:@"LessonDownload" inManagedObjectContext:_context];
    
    fillcb(lesson);
    
    [_context save:nil];
    NSLog(@"添加下载课程到数据库成功!");
}

-(void)deleteLessonByVid:(NSString *)vid
{
    NSLog(@"%@",NSHomeDirectory());
    NSFetchRequest *req = [NSFetchRequest fetchRequestWithEntityName:@"LessonDownload"];
    req.predicate = [NSPredicate predicateWithFormat:@"vid==%@",vid];
    NSArray *arr = [_context executeFetchRequest:req error:nil];
    for (NSInteger i = 0; i < arr.count; i++) {
        [_context deleteObject:arr[i]];
        NSLog(@"删除成功");
    }
    [_context save:nil];
}

-(void)deleteLesson:(LessonDownload *)lesson
{
    NSLog(@"%@",NSHomeDirectory());
    [_context deleteObject:lesson];
    [_context save:nil];
}

-(void)updateLesson:(LessonDownload *)lesson
{
    [_context save:nil];
    NSLog(@"更新成功");
    NSLog(@"lesson的status = %d",[lesson.downloadStatus intValue]);
}

//返回lesson
-(LessonDownload *)returnLessonByVid:(NSString *)vid
{
    NSLog(@"%@",NSHomeDirectory());
    NSFetchRequest *req = [NSFetchRequest fetchRequestWithEntityName:@"LessonDownload"];
    req.predicate = [NSPredicate predicateWithFormat:@"vid==%@",vid];
    
    NSArray *arr = [_context executeFetchRequest:req error:nil];
    
    if (arr.count > 0) {
        NSLog(@"&&&&&&count = %ld",arr.count);
        NSLog(@"存在1个?");
        return arr[0];
    }
    return nil;
}

-(NSArray *)returnLessonByCourseId:(NSString *)courseId
{
    NSFetchRequest *req = [NSFetchRequest fetchRequestWithEntityName:@"LessonDownload"];
    req.predicate = [NSPredicate predicateWithFormat:@"courseId==%@",courseId];
    
    NSArray *arr = [_context executeFetchRequest:req error:nil];
    
    if (arr.count > 0) {
        NSLog(@"&&&&&&count = %ld",arr.count);
        NSLog(@"存在课程");
        return arr;
    }
    else
    {
        return nil;
    }
}


-(BOOL)searchLessonByCourseId:(NSString *)courseId
{
    NSFetchRequest *req = [NSFetchRequest fetchRequestWithEntityName:@"LessonDownload"];
    req.predicate = [NSPredicate predicateWithFormat:@"courseId==%@",courseId];
    
    NSArray *arr = [_context executeFetchRequest:req error:nil];
    
    if (arr.count > 0) {
        NSLog(@"&&&&&&count = %ld",arr.count);
        NSLog(@"存在课程");
        return YES;
    }
    else
    {
        NSLog(@"&&&&&&count = %ld",arr.count);
        NSLog(@"不存在");
        return NO;
    }
}

-(NSArray *)fetchLessonByCourseId:(NSString *)courseId
{
    NSLog(@"%@",NSHomeDirectory());
    NSFetchRequest *req = [NSFetchRequest fetchRequestWithEntityName:@"LessonDownload"];
    req.predicate = [NSPredicate predicateWithFormat:@"courseId==%@",courseId];
    
    NSArray *arr = [_context executeFetchRequest:req error:nil];
    
    if (arr.count > 0) {
        return arr;
    }
    return nil;
}

@end
