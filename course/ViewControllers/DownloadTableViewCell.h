//
//  DownloadTableViewCell.h
//  公开课项目1
//
//  Created by AdvanceYe on 15/7/23.
//  Copyright (c) 2015年 AdvanceYe. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DownloadTableViewCell : UITableViewCell

@property(strong,nonatomic)UIView *progressBG;
@property(strong,nonatomic)UIProgressView *progressView;
@property(strong,nonatomic)UILabel *nameLabel;

+(CGFloat)cellHeight;

-(void)configureUI;
-(void)showDownloadStatusLabel:(BOOL)isDownloading;
-(void)configureProgress:(CGFloat)progress;

@end
