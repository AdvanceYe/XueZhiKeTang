//
//  BottomModel.m
//  公开课项目1
//
//  Created by AdvanceYe on 15/7/8.
//  Copyright (c) 2015年 AdvanceYe. All rights reserved.
//

#import "BottomModel.h"

@implementation BottomModel

+(CGFloat)cellHeight
{
    CGFloat widSpace = 15;
    return 5 + (SCREEN_WIDTH - widSpace * 3) / 2.0 * 0.75 + 5;
}

@end
