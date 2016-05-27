//
//  MyMoviePlayerController.m
//  定制的playercontroller
//
//  Created by qianfeng on 15/7/18.
//  Copyright (c) 2015年 qianfeng. All rights reserved.
//

#import "MyMoviePlayerController.h"
#import "AppDelegate.h"

@implementation MyMoviePlayerController
{
    //NSURL *movieURL;                        //视频地址
    UIActivityIndicatorView *_indicator;    //加载动画
}

-(instancetype)initWithContentURL:(NSURL *)url
{
    self = [super initWithContentURL:url];
    if (self) {
        //将自己注册为观察者
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moviePlayerLoadStateChanged:) name:MPMoviePlayerLoadStateDidChangeNotification object:nil];
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moviePlayerWillEnterFullscreenNotification:) name:MPMoviePlayerWillEnterFullscreenNotification object:nil];
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moviePlayerWillExitFullscreenNotification:) name:MPMoviePlayerWillExitFullscreenNotification object:nil];
    }
    return self;
}

-(void)createIndicator
{
    _indicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake((self.view.frame.size.width - 37) /2.0 , (self.view.frame.size.height - 37) /2.0, 37, 37)];
    _indicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
    [self.view addSubview:_indicator];
    [_indicator startAnimating];
}

-(void)startIndicator
{
    [_indicator startAnimating];
}

-(void)stopIndicator
{
    [_indicator stopAnimating];
}

//indicator放大到全屏
-(void)changeIndicatorFrameToFullScreen
{
    CGFloat screenWidth = [[UIScreen mainScreen]bounds].size.width;
    CGFloat screenHeight = [[UIScreen mainScreen]bounds].size.height;
    CGRect frame = CGRectMake((screenWidth - 37) /2.0 , (screenHeight - 20 - 37) /2.0, 37, 37);
    _indicator.frame = frame;
}

//indicator回到原来位置
-(void)changeIndicatorFrameToOriginal
{
    CGRect frame = CGRectMake((self.view.frame.size.width - 37) /2.0 , (self.view.frame.size.height - 37) /2.0, 37, 37);
    _indicator.frame = frame;
}

#pragma mark - 观察者方法
- (void) moviePlayerLoadStateChanged:(NSNotification*)notification
{
    /*
     MPMovieLoadStateUnknown        = 0,
     MPMovieLoadStatePlayable       = 1 << 0,
     MPMovieLoadStatePlaythroughOK  = 1 << 1, // Playback will be automatically started in this state when shouldAutoplay is YES
     MPMovieLoadStateStalled        = 1 << 2, // Playback will be automatically paused in this state, if started
     */
    if (self.loadState == MPMovieLoadStateStalled || self.loadState == 5) {
        [self startIndicator];
    }
    else
    {
        [self stopIndicator];
    }
    NSLog(@"%ld",self.loadState);
}

//- (void)moviePlayerWillEnterFullscreenNotification:(NSNotification*)notify
//{
//    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
//    delegate.allowRotation = YES;
//    [self changeIndicatorFrameToFullScreen];
//    NSLog(@"moviePlayerWillEnterFullscreenNotification");
//}
//
//- (void)moviePlayerWillExitFullscreenNotification:(NSNotification*)notify
//{
//    
//    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
//    
//    delegate.allowRotation = NO;
//    
//    [self play];
//    [self changeIndicatorFrameToOriginal];
//    NSLog(@"moviePlayerWillExitFullscreenNotification");
//}

//dealloc的时候释放自己
-(void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:MPMoviePlayerLoadStateDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:MPMoviePlayerWillEnterFullscreenNotification object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:MPMoviePlayerWillExitFullscreenNotification object:nil];
}

@end
