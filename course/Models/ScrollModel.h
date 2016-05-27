//
//  ScrollModel.h
//  公开课项目1
//
//  Created by AdvanceYe on 15/7/7.
//  Copyright (c) 2015年 AdvanceYe. All rights reserved.
//

#import "BasicModel.h"

@interface ScrollModel : BasicModel

//图片
proStr(img);
proStr(img_thumb);
proStr(img_ext);

proStr(img_short_desc);
proStr(title);
proStr(vid);
proStr(desc);
proDict(more);

+(CGFloat)cellHeight;

@end
