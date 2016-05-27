//
//  ClearBtnCell.m
//  公开课项目1
//
//  Created by AdvanceYe on 15/7/15.
//  Copyright (c) 2015年 AdvanceYe. All rights reserved.
//

#import "ClearBtnCell.h"

@implementation ClearBtnCell

- (void)awakeFromNib {
    // Initialization code
    _label.font = [UIFont systemFontOfSize:FONT_MIDDLE];
    _label.backgroundColor = [UIColor lightGrayColor];
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
