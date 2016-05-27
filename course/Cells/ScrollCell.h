//
//  ScrollCell.h
//  公开课项目1
//
//  Created by AdvanceYe on 15/7/7.
//  Copyright (c) 2015年 AdvanceYe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ScrollModel.h"

@interface ScrollCell : UITableViewCell <UIScrollViewDelegate>

@property(strong,nonatomic)NSMutableArray *dataArray;

//定义cell高度
@property(assign,nonatomic)CGFloat cellHeight;
@property(strong,nonatomic)ScrollModel *model;
@property(copy,nonatomic)void(^callback)(ScrollModel*);

-(void)configureUI;
-(void)autoSwitch;
-(void)startTimer;
@end
