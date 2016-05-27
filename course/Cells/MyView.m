//
//  MyView.m
//  公开课项目1
//
//  Created by AdvanceYe on 15/7/15.
//  Copyright (c) 2015年 AdvanceYe. All rights reserved.
//

#import "MyView.h"

@implementation MyView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
//    CGFloat components[] = {
//        1,0,0,1,
//        1,0,1,1,
//        0,1,0,1,
//        0,0,1,1};
    
//    CGFloat locations[] = {0,0.5,0.7,1};
    CGFloat components[] = {
        0,0,0,0,
        0,0,0,0.4,
        0,0,0,1,};
    
    CGFloat locations[] = {0,0.6,1};
    
    //参数1:颜色空间
    //参数2:表示颜色的数组
    //参数3:位置的数组
    //参数4:有效数量
    CGGradientRef gdr = CGGradientCreateWithColorComponents(colorSpace, components, locations, 3);
    
    //线性变化
    
    //从起点到终点进行颜色渐变填充
    //最后一个参数0:表示两侧不填充
    //1:表示在起点之前填充,纯色
    //2:表示在终点之后填充,纯色
    //3:两侧都填充
    CGContextDrawLinearGradient(ctx, gdr, CGPointMake(0, 0), CGPointMake(0, self.frame.size.height), 0);
}

@end
