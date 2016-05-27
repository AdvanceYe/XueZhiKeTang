//
//  DisciplineTableViewCell.m
//  公开课项目1
//
//  Created by AdvanceYe on 15/7/11.
//  Copyright (c) 2015年 AdvanceYe. All rights reserved.
//

#import "DisciplineTableViewCell.h"

@implementation DisciplineTableViewCell
{
    UIImageView *_imgv;
    UILabel *_nameLabel;
    UILabel *_courseCountLabel;
}

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self createUI];
    }
    return self;
}

-(void)createUI
{
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    _imgv = [[UIImageView alloc]initWithFrame:CGRectMake(10, 5, SCREEN_WIDTH - 20, (SCREEN_WIDTH - 20) * 9 / 16.0 * 0.83)];
    _imgv.userInteractionEnabled = YES;
    _imgv.backgroundColor = [UIColor whiteColor];
    
    CGFloat labelHeight = (SCREEN_WIDTH - 20) * 9 / 16.0 * 0.17;
    _nameLabel = [MyControl createLabelWithFrame:CGRectMake(10, CGRectGetMaxY(_imgv.frame), _imgv.frame.size.width, labelHeight) Font:FONT_MIDDLE Text:@""];
    _nameLabel.backgroundColor = [UIColor colorWithWhite:0 alpha:0.2];
    [self addSubview:_nameLabel];
    
    _courseCountLabel = [MyControl createLabelWithFrame:CGRectMake(_imgv.frame.size.width - 75, CGRectGetMaxY(_imgv.frame), 60, labelHeight) Font:FONT_SMALL Text:@""];
    _courseCountLabel.textAlignment = NSTextAlignmentRight;
    _courseCountLabel.backgroundColor = [UIColor clearColor];
    _courseCountLabel.textColor = [UIColor darkGrayColor];
    [self addSubview:_courseCountLabel];
    
    [self addSubview:_imgv];
    
}

-(void)configUI:(DisciplineModel *)model
{
#warning 此处要自己做一张白图片,作为placeHolder,如果placeHolder设为空,则会串行
    [_imgv setImageWithURL:[NSURL URLWithString:[model picture]] placeholderImage:[UIImage imageNamed:PLACEHOLDERIMG]];
    _nameLabel.text = [NSString stringWithFormat:@"  %@",[model name]];
    _courseCountLabel.text = [NSString stringWithFormat:@"%ld门课程",model.total_course];
    
}


@end
