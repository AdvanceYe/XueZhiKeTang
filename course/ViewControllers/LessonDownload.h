//
//  LessonDownload.h
//  公开课项目1
//
//  Created by 叶栈仙 on 15/7/24.
//  Copyright (c) 2015年 AdvanceYe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface LessonDownload : NSManagedObject

@property (nonatomic, retain) NSString * courseId;
@property (nonatomic, retain) NSString * courseName;
@property (nonatomic, retain) NSNumber * downloadStatus;
@property (nonatomic, retain) NSString * ipad_url;
@property (nonatomic, retain) NSString * lessonName;
@property (nonatomic, retain) NSString * number;
@property (nonatomic, retain) NSNumber * percentage;
@property (nonatomic, retain) NSNumber * totalSize;
@property (nonatomic, retain) NSString * vid;
@property (nonatomic, retain) NSNumber * index;

@end
