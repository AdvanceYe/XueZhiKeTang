//
//  BottomCell.h
//  公开课项目1
//
//  Created by AdvanceYe on 15/7/7.
//  Copyright (c) 2015年 AdvanceYe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BottomModel.h"

@interface BottomCell : UITableViewCell

//定义cell高度
@property(assign,nonatomic)CGFloat cellHeight;
@property(strong,nonatomic)BottomModel *leftModel;
@property(strong,nonatomic)BottomModel *rightModel;
@property(copy,nonatomic)void(^leftCallback)(BottomModel*);
@property(copy,nonatomic)void(^rightCallback)(BottomModel*);

-(void)configUILeftModel:(BottomModel *)leftModel rightModel:(BottomModel *)rightModel;

@end
