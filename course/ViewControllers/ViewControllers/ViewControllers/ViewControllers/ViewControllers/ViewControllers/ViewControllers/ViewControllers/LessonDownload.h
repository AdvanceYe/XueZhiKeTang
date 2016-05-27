//
//  LessonDownload.h
//  公开课项目1
//
//  Created by qianfeng on 15/7/20.
//  Copyright (c) 2015年 qianfeng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface LessonDownload : NSManagedObject

@property (nonatomic, retain) NSString * lessonName;
@property (nonatomic, retain) NSString * vid;
@property (nonatomic, retain) NSString * ipad_url;
@property (nonatomic, retain) NSString * number;
@property (nonatomic, retain) NSString * courseId;
@property (nonatomic, retain) NSString * courseName;
@property (nonatomic, retain) NSNumber * downloadStatus;

@end
