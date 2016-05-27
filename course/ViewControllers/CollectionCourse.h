//
//  CollectionCourse.h
//  公开课项目1
//
//  Created by AdvanceYe on 15/7/20.
//  Copyright (c) 2015年 AdvanceYe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface CollectionCourse : NSManagedObject

@property (nonatomic, retain) NSNumber * currentPlayRow;
@property (nonatomic, retain) NSString * d_id;
@property (nonatomic, retain) NSString * imgUrl;
@property (nonatomic, retain) NSNumber * isInEditing;
@property (nonatomic, retain) NSNumber * isSelected;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * time;
@property (nonatomic, retain) NSNumber * totalPlayRow;
@property (nonatomic, retain) NSDate * updateDate;

@end
