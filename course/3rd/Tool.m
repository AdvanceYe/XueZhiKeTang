//
//  RootViewController.m
//  LimitFree_Demo
//
//  Created by LongHuanHuan on 15/4/12.
//  Copyright (c) 2015年 ___LongHuanHuan___. All rights reserved.
//

#import "Tool.h"

@implementation Tool

+(CGSize)strSize:(NSString *)str withMaxSize:(CGSize)size withFont:(UIFont *)font withLineBreakMode:(NSLineBreakMode)mode
{
    CGSize s;
    if (IOS7)
    {
        s = [str boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:font} context:nil].size;
    }
    else
    {
        s = [str sizeWithFont:font constrainedToSize:size lineBreakMode:mode];
    }
    return s;
}

@end








