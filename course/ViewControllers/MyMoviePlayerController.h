//
//  MyMoviePlayerController.h
//  定制的playercontroller
//
//  Created by AdvanceYe on 15/7/18.
//  Copyright (c) 2015年 AdvanceYe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>

@interface MyMoviePlayerController : MPMoviePlayerController

-(void)createIndicator;

//indicator放大到全屏
-(void)changeIndicatorFrameToFullScreen;

//indicator回到原来位置
-(void)changeIndicatorFrameToOriginal;

@end
