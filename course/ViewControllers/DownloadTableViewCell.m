//
//  DownloadTableViewCell.m
//  公开课项目1
//
//  Created by AdvanceYe on 15/7/23.
//  Copyright (c) 2015年 AdvanceYe. All rights reserved.
//

#import "DownloadTableViewCell.h"

@implementation DownloadTableViewCell
{
    UILabel *_downloadStatusLabel;
    CGFloat _cellHeight;
}

+(CGFloat)cellHeight
{
    return 55;
}

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        //放个图标上来？
        _cellHeight = 55;
        //self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.textLabel.font = [UIFont systemFontOfSize:FONT_MIDDLE];
    }
    return self;
}

-(void)configureUI
{
//    [_progressBG removeFromSuperview];
//    _progressBG = nil;
//    _progressBG = [[UIView alloc]initWithFrame:CGRectMake(_nameLabel.frame.origin.x, 2, 0, _cellHeight - 4)];
//    _progressBG.backgroundColor = LIGHT_SETCOLOR;
//    [self addSubview:_progressBG];
//    [self addSubview:_nameLabel];
    
    [_nameLabel removeFromSuperview];
    _nameLabel = nil;
    _nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(62, _cellHeight - FONT_SMALL - 6, 100, FONT_SMALL)];
    _nameLabel.font = [UIFont systemFontOfSize:FONT_SMALL];
    [self addSubview:_nameLabel];
    
    [_progressView removeFromSuperview];
    _progressView = nil;
    _progressView = [[UIProgressView alloc]initWithFrame:CGRectMake(0, _cellHeight - 4, SCREEN_WIDTH, 4)];
    _progressView.progressTintColor = SET_COLOR;
    [self addSubview:_progressView];
    _progressView.alpha = 1;
    
    [_downloadStatusLabel removeFromSuperview];
    _downloadStatusLabel = nil;
    CGFloat fontSize = FONT_SMALL;
    CGFloat labelY = (_cellHeight - fontSize) / 2.0;
    _downloadStatusLabel = [MyControl createLabelWithFrame:CGRectMake(SCREEN_WIDTH - 10 - 4 * fontSize, labelY, 4 * fontSize, FONT_SMALL) Font:fontSize Text:@"待定"];
    _downloadStatusLabel.textColor = [UIColor darkGrayColor];
    [self addSubview:_downloadStatusLabel];
}

-(void)configureProgress:(CGFloat)progress
{
//    CGRect frame = _progressBG.frame;
//    frame.size.width = SCREEN_WIDTH * progress;
//    _progressBG.frame = frame;
    _progressView.progress = progress;
}

-(void)showDownloadStatusLabel:(BOOL)isDownloading
{
    if (isDownloading) {
        _downloadStatusLabel.text = @"正在下载";
    }
    else
    {
        _downloadStatusLabel.text = @"已暂停";
    }
}

@end
