//
//  CoreDataHistoryManager.m
//  公开课项目1
//
//  Created by AdvanceYe on 15/7/16.
//  Copyright (c) 2015年 AdvanceYe. All rights reserved.
//

#import "CoreDataHistoryManager.h"

@implementation CoreDataHistoryManager

+(id)manager
{
    static CoreDataHistoryManager *_m = nil;
    if (!_m) {
        _m = [[CoreDataHistoryManager alloc]init];
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
    NSString *path = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/coredataHistory.sqlite"];
    NSError *err = nil;
    
    [coord addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:[NSURL fileURLWithPath:path] options:nil error:&err];
    
    if (err) {
        NSLog(@"打开数据库失败");
    }
    else
    {
        self.context = [[NSManagedObjectContext alloc]init];
        [self.context setPersistentStoreCoordinator:coord];
    }
}

@end
