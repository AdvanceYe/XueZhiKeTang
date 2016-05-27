//
//  BottomCell.m
//  公开课项目1
//
//  Created by AdvanceYe on 15/7/7.
//  Copyright (c) 2015年 AdvanceYe. All rights reserved.
//

#import "BottomCell.h"
@implementation BottomCell
{
    UIView *_leftView;
    UIView *_rightView;
    UIImageView *_leftImgv;
    UIImageView *_rightImgv;

    UIView *_leftLabelView;
    UIView *_rightLabelView;
    
    UILabel *_leftSchoolLabel;
    UILabel *_leftNameLabel;
    UILabel *_rightSchoolLabel;
    UILabel *_rightNameLabel;
    
}
- (void)awakeFromNib {
    // Initialization code
}

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _cellHeight = [BottomModel cellHeight];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self makeCellUI];
    }
    return self;
}

-(void)makeCellUI
{
    //CELL的高: 
    CGFloat widSpace = 15;
    CGFloat heightSpace = 5;
    CGFloat viewWidth = (SCREEN_WIDTH - widSpace * 3) / 2.0;
    CGFloat imgHeight = 0.75 * viewWidth;
    _leftView = [[UIView alloc]initWithFrame:CGRectMake(widSpace, heightSpace, viewWidth, _cellHeight - 2 * heightSpace)];
    _leftView.backgroundColor = [UIColor orangeColor];
    
    _leftImgv = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, viewWidth, imgHeight)];
    _leftImgv.backgroundColor = [UIColor lightGrayColor];
    _leftImgv.userInteractionEnabled = YES;
    [_leftView addSubview:_leftImgv];
    
    //添加一个View,挡住下面的字
    _leftLabelView = [[UIView alloc]initWithFrame:CGRectMake(0, imgHeight * 0.58 , viewWidth, imgHeight * 0.35)];
    _leftLabelView.backgroundColor = SET_COLOR;
    [_leftView addSubview:_leftLabelView];
    
    //添加两个label上去
    CGFloat labelViewHeight = _leftLabelView.bounds.size.height;
    _leftSchoolLabel = [MyControl createLabelWithFrame:CGRectMake(0, 0, viewWidth, labelViewHeight * 0.4) Font:FONT_SMALL Text:nil];
    _leftSchoolLabel.backgroundColor = [UIColor colorWithWhite:1 alpha:0.5];
    _leftSchoolLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    [_leftLabelView addSubview:_leftSchoolLabel];
    
    _leftNameLabel = [MyControl createLabelWithFrame:CGRectMake(0, labelViewHeight * 0.4, viewWidth, labelViewHeight * 0.6) Font:FONT_MIDDLE Text:nil];
    _leftNameLabel.textColor = [UIColor whiteColor];
    _leftNameLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    _leftNameLabel.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
    [_leftLabelView addSubview:_leftNameLabel];
    
    [self.contentView addSubview:_leftView];
    
    _rightView = [[UIView alloc]initWithFrame: CGRectMake(widSpace * 2 + viewWidth, heightSpace, viewWidth, _cellHeight - 2 * heightSpace)];
    _rightView.backgroundColor = [UIColor yellowColor];
    _rightImgv = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, viewWidth, imgHeight)];
    _rightImgv.backgroundColor = [UIColor lightGrayColor];
    _rightImgv.userInteractionEnabled = YES;
    [_rightView addSubview:_rightImgv];
    
    //添加一个View,挡住下面的字
    _rightLabelView = [[UIView alloc]initWithFrame:CGRectMake(0, imgHeight * 0.58 , viewWidth, imgHeight * 0.35)];
    _rightLabelView.backgroundColor = SET_COLOR;
    [_rightView addSubview:_rightLabelView];
    
    //添加两个label上去
    _rightSchoolLabel = [MyControl createLabelWithFrame:CGRectMake(0, 0, viewWidth, labelViewHeight * 0.4) Font:FONT_SMALL Text:@"  你好"];
    _rightSchoolLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    _rightSchoolLabel.backgroundColor = [UIColor colorWithWhite:1 alpha:0.5];
    [_rightLabelView addSubview:_rightSchoolLabel];
    
    _rightNameLabel = [MyControl createLabelWithFrame:CGRectMake(0, labelViewHeight * 0.4, viewWidth, labelViewHeight * 0.6) Font:FONT_MIDDLE Text:@"  课程名字"];
    _rightNameLabel.lineBreakMode=NSLineBreakByTruncatingTail;
    _rightNameLabel.textColor = [UIColor whiteColor];
    _rightNameLabel.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
    [_rightLabelView addSubview:_rightNameLabel];
    
    
    [self.contentView addSubview:_rightView];
    
    //加手势
    UITapGestureRecognizer *tap1 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapAction1)];
    [_leftView addGestureRecognizer:tap1];
    
    UITapGestureRecognizer *tap2 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapAction2)];
    [_rightView addGestureRecognizer:tap2];
    
    
}

-(void)tapAction1
{
    if (_leftCallback) {
        _leftCallback(_leftModel);
    }
    NSLog(@"tapAction1..");
}

-(void)tapAction2
{
    if (_rightCallback) {
        _rightCallback(_rightModel);
    }
    NSLog(@"tapAction2..");
}

-(void)configUILeftModel:(BottomModel *)leftModel rightModel:(BottomModel *)rightModel
{
    _leftModel = leftModel;
    _rightModel = rightModel;
    
    //设置leftModel
    if (leftModel) {
        [_leftImgv setImageWithURL:[NSURL URLWithString:[leftModel picture]] placeholderImage:[UIImage imageNamed:PLACEHOLDERIMG]];
        _leftSchoolLabel.text = [NSString stringWithFormat:@"  %@",[leftModel school_name]];
        _leftNameLabel.text = [NSString stringWithFormat:@"  %@",[leftModel name]];
    }
    //设置rightModel
    if(rightModel)
    {
        [_rightImgv setImageWithURL:[NSURL URLWithString:[rightModel picture]] placeholderImage:[UIImage imageNamed:PLACEHOLDERIMG]];
        _rightSchoolLabel.text = [NSString stringWithFormat:@"  %@",[rightModel school_name]];
        _rightNameLabel.text = [NSString stringWithFormat:@"  %@",[rightModel name]];
    }
  
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
