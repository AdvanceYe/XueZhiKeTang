//
//  CoreDataCollectionManager.m
//  公开课项目1
//
//  Created by qianfeng on 15/7/13.
//  Copyright (c) 2015年 qianfeng. All rights reserved.
//

#import "CoreDataCollectionManager.h"

@implementation CoreDataCollectionManager


+(id)manager
{
    static CoreDataCollectionManager *_m = nil;
    if (!_m) {
        _m = [[CoreDataCollectionManager alloc]init];
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
    NSString *path = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/coredataCollection.sqlite"];
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

//Blocks的这种用法,属于正向传值
//极其少见
//AFNetWorking 上传 图片的时候用的方法
-(void)addCourse:(void(^)(CollectionCourse *))fillcb
{                                      
    NSLog(@"%@",NSHomeDirectory());
    
    CollectionCourse *course = [NSEntityDescription insertNewObjectForEntityForName:@"CollectionCourse" inManagedObjectContext:_context];
    
    fillcb(course);
    
    [_context save:nil];
    NSLog(@"添加成功");
}

-(NSArray *)fetchAll
{
    NSLog(@"%@",NSHomeDirectory());
    NSFetchRequest *req = [NSFetchRequest fetchRequestWithEntityName:@"CollectionCourse"];
    
    NSArray *arr = [_context executeFetchRequest:req error:nil];
    
    return arr;
}

-(void)deleteCourseById:(NSString *)courseId
{
    NSLog(@"%@",NSHomeDirectory());
    NSFetchRequest *req = [NSFetchRequest fetchRequestWithEntityName:@"CollectionCourse"];
    req.predicate = [NSPredicate predicateWithFormat:@"d_id==%@",courseId];
    NSArray *arr = [_context executeFetchRequest:req error:nil];
    for (NSInteger i = 0; i < arr.count; i++) {
        [_context deleteObject:arr[i]];
        NSLog(@"删除成功");
    }
    [_context save:nil];
}

-(void)deleteCourse:(CollectionCourse *)course
{
    NSLog(@"%@",NSHomeDirectory());
    [_context deleteObject:course];
    [_context save:nil];
}

-(void)deleteCourses:(NSArray *)arr
{
    for (CollectionCourse * course in arr) {
        [_context deleteObject:course];
    }
    [_context save:nil];
}

//搜索是否存在
-(BOOL)searchCourseByID:(NSString *)courseId
{
    NSLog(@"%@",NSHomeDirectory());
    NSFetchRequest *req = [NSFetchRequest fetchRequestWithEntityName:@"CollectionCourse"];
    req.predicate = [NSPredicate predicateWithFormat:@"d_id==%@",courseId];
    
    NSArray *arr = [_context executeFetchRequest:req error:nil];

    if (arr.count > 0) {
        NSLog(@"&&&&&&count = %ld",arr.count);
        NSLog(@"已存在");
        return YES;
    }
    else
    {
        NSLog(@"&&&&&&count = %ld",arr.count);
        NSLog(@"不存在");
        return NO;
    }
}

//返回是否存在
-(CollectionCourse *)returnCourseByID:(NSString *)courseId
{
    NSLog(@"%@",NSHomeDirectory());
    NSFetchRequest *req = [NSFetchRequest fetchRequestWithEntityName:@"CollectionCourse"];
    req.predicate = [NSPredicate predicateWithFormat:@"d_id==%@",courseId];
    
    NSArray *arr = [_context executeFetchRequest:req error:nil];
    
    if (arr.count > 0) {
        NSLog(@"&&&&&&count = %ld",arr.count);
        NSLog(@"存在1个?");
        return arr[0];
    }
    return nil;
}

-(void)updateCourse:(CollectionCourse *)course
{
    [_context save:nil];
}

@end
