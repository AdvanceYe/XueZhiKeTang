//
//  CourseListCell.m
//  公开课项目1
//
//  Created by AdvanceYe on 15/7/11.
//  Copyright (c) 2015年 AdvanceYe. All rights reserved.
//

#import "CourseListCell.h"
#import "CourseModel.h"

@implementation CourseListCell
{
    UIImageView *_imageView;
    UILabel *_nameLabel;
    UILabel *_updateLabel;
    UILabel *_timeLabel;
    
    
    UIView *_grayView;
    UIImageView *_selectedImgv;
    UIImageView *_unselectedImgv;
}


-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self createUI];
    }
    return self;
}

-(void)createUI
{
    CGFloat width = SCREEN_WIDTH / 2.8;
    _imageView = [[UIImageView alloc]initWithFrame:CGRectMake(10, 5, width, width * 3.0 / 4)];
    _imageView.backgroundColor = [UIColor orangeColor];
    [self addSubview:_imageView];
    
    _nameLabel = [MyControl createLabelWithFrame:CGRectMake(CGRectGetMaxX(_imageView.frame)+10, _imageView.frame.origin.y+10, SCREEN_WIDTH - 10 - _imageView.frame.size.width - 10 - 10, 20) Font:FONT_MIDDLE Text:nil];
    _nameLabel.textAlignment = NSTextAlignmentLeft;
    _nameLabel.lineBreakMode = NSLineBreakByCharWrapping;
    [self addSubview:_nameLabel];
    
    
    _updateLabel = [MyControl createLabelWithFrame:CGRectMake(_nameLabel.frame.origin.x,CGRectGetMaxY(_nameLabel.frame)+6,_nameLabel.frame.size.width,15) Font:FONT_SMALL Text:nil];
    _updateLabel.textAlignment = NSTextAlignmentLeft;
    [self addSubview:_updateLabel];
    
    
    _timeLabel = [MyControl createLabelWithFrame:CGRectMake(_updateLabel.frame.origin.x,CGRectGetMaxY(_updateLabel.frame),_updateLabel.frame.size.width,15) Font:FONT_SMALL Text:nil];
    _timeLabel.textAlignment = NSTextAlignmentLeft;
    [self addSubview:_timeLabel];
    
    
    CGFloat cellHeight = [CourseModel cellHeight];
    
    _grayView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, cellHeight)];
    _grayView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.2];
    [self.contentView addSubview:_grayView];
    _grayView.hidden = YES;
    
    CGFloat imgWid = 36;
    _selectedImgv = [[UIImageView alloc]initWithFrame:CGRectMake(SCREEN_WIDTH - 30 - imgWid, (cellHeight - imgWid)/2.0, imgWid, imgWid)];
    UIImage *img = [UIImage imageNamed:@"select.png"];
    _selectedImgv.image = img;
    [self addSubview:_selectedImgv];
    _selectedImgv.hidden = YES;
    
    _unselectedImgv = [[UIImageView alloc]initWithFrame:_selectedImgv.frame];
    UIImage *unImg = [UIImage imageNamed:@"unselect.png"];
    _unselectedImgv.image = unImg;
    [self addSubview:_unselectedImgv];
    _unselectedImgv.hidden = YES;
    
}

-(void)updateHeightWithModel:(id)model
{
    //第三方库计算文本高度
    CGSize size = [Tool strSize:[model name] withMaxSize:CGSizeMake(_nameLabel.frame.size.width, MAXFLOAT) withFont:[UIFont systemFontOfSize:FONT_MIDDLE] withLineBreakMode:NSLineBreakByCharWrapping];
    CGRect frame = _nameLabel.frame;
    frame.size.height = size.height;
    _nameLabel.frame = frame;
    
    _updateLabel.frame = CGRectMake(_nameLabel.frame.origin.x,CGRectGetMaxY(_nameLabel.frame)+6,_nameLabel.frame.size.width,15);
    
    _timeLabel.frame = CGRectMake(_updateLabel.frame.origin.x,CGRectGetMaxY(_updateLabel.frame),_updateLabel.frame.size.width,15);
}

-(void)configUI:(CourseModel *)model
{
    [self updateHeightWithModel:model];
    [_imageView setImageWithURL:[NSURL URLWithString:model.picture] placeholderImage:[UIImage imageNamed:PLACEHOLDERIMG]];
    _nameLabel.text = model.name;
    
    _updateLabel.text = [NSString stringWithFormat:@"更新至第%ld节",[model lesson_count]];
    _timeLabel.text = model.modified_at;
}

-(void)configCollectionUI:(CollectionCourse *)model
{
    [self updateHeightWithModel:model];
    [_imageView setImageWithURL:[NSURL URLWithString:model.imgUrl] placeholderImage:[UIImage imageNamed:PLACEHOLDERIMG]];
    _nameLabel.text = model.name;
    
    _updateLabel.text = [NSString stringWithFormat:@"总集数:%@",model.totalPlayRow];
    //如果是0的话,就说未看过
    if ([model.currentPlayRow intValue] == 0 & [model.time floatValue] < 0.01) {
        _timeLabel.text = @"未观看";
    }
    else
    {
        NSLog(@"%f",[model.time floatValue]);
        NSLog(@"timeTransfer: %@",[self timeFormatTransfer:[model.time floatValue]]);
        _timeLabel.text = [NSString stringWithFormat:@"看到第%d集 %@",[model.currentPlayRow intValue] + 1, [self timeFormatTransfer:[model.time floatValue]]];
    }
}

//如果是历史记录的,未看过的话,就说看到0:00
-(void)configHistoryUI:(CollectionCourse *)model
{
    [self updateHeightWithModel:model];
    [_imageView setImageWithURL:[NSURL URLWithString:model.imgUrl] placeholderImage:[UIImage imageNamed:PLACEHOLDERIMG]];
    _nameLabel.text = model.name;
    
    _updateLabel.text = [NSString stringWithFormat:@"总集数:%@",model.totalPlayRow];
    
    NSLog(@"%f",[model.time floatValue]);
    NSLog(@"timeTransfer: %@",[self timeFormatTransfer:[model.time floatValue]]);
    _timeLabel.text = [NSString stringWithFormat:@"看到第%d集 %@",[model.currentPlayRow intValue] + 1, [self timeFormatTransfer:[model.time floatValue]]];
}

-(NSString *)timeFormatTransfer:(CGFloat)time
{
    int min = (int)time / 60;
    int second = (int)time % 60;
    return [NSString stringWithFormat:@"%02d:%02d",min,second];
}

-(void)addGrayImg
{
    _grayView.hidden = YES;
    _selectedImgv.hidden = YES;
    _unselectedImgv.hidden = NO;
}

-(void)addColorImg
{
    _grayView.hidden = NO;
    _selectedImgv.hidden = NO;
    _unselectedImgv.hidden = YES;
}

-(void)removeMarkImg
{
    _grayView.hidden = YES;
    _selectedImgv.hidden = YES;
    _unselectedImgv.hidden = YES;
}

@end
