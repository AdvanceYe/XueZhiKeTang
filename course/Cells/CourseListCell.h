//
//  CourseListCell.h
//  公开课项目1
//
//  Created by AdvanceYe on 15/7/11.
//  Copyright (c) 2015年 AdvanceYe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CourseModel.h"
#import "CollectionCourse.h"

@interface CourseListCell : UITableViewCell

//course页的数据刷新
-(void)configUI:(CourseModel *)model;

//收藏页的数据刷新
-(void)configCollectionUI:(CollectionCourse *)model;
//历史页的数据刷新
-(void)configHistoryUI:(CollectionCourse *)model;

-(void)addGrayImg;

-(void)addColorImg;

-(void)removeMarkImg;

@end
