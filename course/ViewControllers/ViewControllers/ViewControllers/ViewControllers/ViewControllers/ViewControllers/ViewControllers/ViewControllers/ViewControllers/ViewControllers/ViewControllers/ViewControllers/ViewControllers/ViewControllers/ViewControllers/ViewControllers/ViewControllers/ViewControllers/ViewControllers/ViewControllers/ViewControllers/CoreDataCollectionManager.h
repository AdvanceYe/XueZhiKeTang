//
//  CoreDataCollectionManager.h
//  公开课项目1
//
//  Created by qianfeng on 15/7/13.
//  Copyright (c) 2015年 qianfeng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CollectionCourse.h"
@interface CoreDataCollectionManager : NSObject

@property (nonatomic,strong) NSManagedObjectContext *context;

+(id)manager;

-(void)addCourse:(void(^)(CollectionCourse *))fillcb;

-(void)deleteCourseById:(NSString *)courseId;

-(void)deleteCourse:(CollectionCourse *)course;

-(void)deleteCourses:(NSArray *)arr;

-(void)updateCourse:(CollectionCourse *)course;

//搜索是否存在
-(BOOL)searchCourseByID:(NSString *)courseId;
//返回course
-(CollectionCourse *)returnCourseByID:(NSString *)courseId;

-(NSArray *)fetchAll;

@end
