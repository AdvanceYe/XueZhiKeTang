//
//  CourseModel.h
//  公开课项目1
//
//  Created by AdvanceYe on 15/7/8.
//  Copyright (c) 2015年 AdvanceYe. All rights reserved.
//

#import "BasicModel.h"

@interface CourseModel : BasicModel

//本model用在两处:schoolPageViewController处和courseViewController处,可共用
proStr(picture);
proStr(name);
proStr(brief);
proStr(d_id);
proStr(school_id);
proStr(school_name);
proStr(total_click);
proStr(modified_at);
@property(assign,nonatomic)NSInteger lesson_count;
@property(assign,nonatomic)NSInteger translated_count;
@property(strong,nonatomic)NSArray *teachers;

+(CGFloat)cellHeight;

@end
