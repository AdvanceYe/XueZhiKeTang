//
//  DisciplineModel.h
//  公开课项目1
//
//  Created by 叶栈仙 on 15/7/10.
//  Copyright (c) 2015年 AdvanceYe. All rights reserved.
//

#import "BasicModel.h"

@interface DisciplineModel : BasicModel

proStr(name);
proStr(d_id);
proStr(picture);
proStr(total_video);
proStr(brief);
@property(assign,nonatomic)NSInteger total_course;

+(CGFloat)cellHeight;

@end
