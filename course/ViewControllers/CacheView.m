//
//  CacheView.m
//  公开课项目1
//
//  Created by AdvanceYe on 15/7/21.
//  Copyright (c) 2015年 AdvanceYe. All rights reserved.
//

#import "CacheView.h"
#import "ASIDownloadManager.h"
#import "CacheViewManager.h"
#import "ActiveCacheModelManager.h"
#import "ActiveCacheModel.h"

@implementation CacheView
{
    UILabel *_label;
    UILabel *_downloadLabel;
    ASIHTTPRequest *_request;
    LessonDownload *_lesson;
    //BOOL _isCourseExist;
    //BOOL _isLessonExist;
    BOOL _isCourseDownloading;
    BOOL _isCourseDownloaded;
    BOOL _isLessonDownloading;
    BOOL _isLessonDownloaded;
}

-(id)initWithFrame:(CGRect)frame lessonModal:(LessonModel *)model andCourseId:(NSString *)courseId
{
    self = [super initWithFrame:frame];
    _model = model;
    _courseId = courseId;
    if (self) {
        //先创建UI
        [self createUI];
        
        //判断是否存在
        //_isCourseExist = [[CoreDataDownloadManager manager]searchLessonByCourseId:_courseId];
        
        //判断是否已下载
        _isCourseDownloaded = [[CoreDataDownloadedManager manager]searchLessonByCourseId:_courseId];
        if (_isCourseDownloaded) {
            NSArray *arr = [[CoreDataDownloadedManager manager]returnLessonByCourseId:_courseId];
            for (LessonDownload *lesson in arr) {
                NSLog(@"lessonNum:%@",lesson.number);
                if ([lesson.vid isEqualToString:_model.vid]) {
                    _isLessonDownloaded = YES;
                    _lesson = lesson;
                    break;
                }
            }
        }
        
        //判断是否下载中
        _isCourseDownloading = [[CoreDataDownloadingManager manager]searchLessonByCourseId:_courseId];
        if (_isCourseDownloading) {
            NSArray *arr = [[CoreDataDownloadingManager manager]returnLessonByCourseId:_courseId];
            for (LessonDownload *lesson in arr) {
                NSLog(@"lessonNum:%@",lesson.number);
                if ([lesson.vid isEqualToString:_model.vid]) {
                    _isLessonDownloading = YES;
                    _lesson = lesson;
                    break;
                }
            }
        }
        
        if(_isLessonDownloading)//如果正在下载中
        {
#warning 这里要大改!
            //只放正在下载的:
            CacheView *cacheView = (CacheView *)[[CacheViewManager sharedManager]fetchCacheViewbyCourseId:_courseId andVid:_model.vid];
            ActiveCacheModel *activeCache = (ActiveCacheModel *)[[ActiveCacheModelManager sharedManager]fetchCacheModelbyCourseId:_courseId andVid:_model.vid];
            
            if (cacheView != nil) {//如果cacheView存在的话,就直接赋值
                self = cacheView;
            }
            else//如果不存在cacheView
            {
                if (activeCache != nil) {//如果不是从这个界面登录,而使从downloadingVC页面发起的,那么如果进入这个界面,要创建一个cacheView,并将其存起来
#warning 这里如果写以下代码,会崩溃,因为又赋的delegate没有存起来.
                    [self createDownloadLabelWithString:@"下载中"];
                    ASIHTTPRequest *request = activeCache.request;
                    request.delegate = self;
                    request.downloadProgressDelegate = self;
                    //将cacheView进行添加
                    [[CacheViewManager sharedManager]addCacheView:self];
                    _request = request;
                }
                else//
                {
                    [self createDownloadLabelWithString:@"下载中"];
                    _progressView.alpha = 1;//显示进度条
#warning 要找个地方存进度条进度(暂停的时候,或者退出程序的时候)
                    _progressView.progress = [_lesson.percentage floatValue];//定义进度条的进度
                }
            }
        }
        
        if (_isLessonDownloaded) {//如果已经下载
            [self createDownloadLabelWithString:nil];
            [self updateFinishLook];//刷新视图界面
        }
        NSLog(@"%@课程是否下载中?:%d",_model.number,_isLessonDownloading);
        NSLog(@"%@课程是否已下载?:%d",_model.number,_isLessonDownloaded);
        
    }
    return self;
}

//创建UI,颜色啥的
-(void)createUI
{
    _label = [[UILabel alloc]initWithFrame:self.bounds];
    [self addSubview:_label];
    self.userInteractionEnabled = YES;
    self.backgroundColor = [UIColor whiteColor];
    //对齐方式
    _label.textAlignment = NSTextAlignmentCenter;
    //字体大小
    _label.font = [UIFont systemFontOfSize:FONT_MIDDLE];
    
    //生成进度条
    _progressView = [[UIProgressView alloc]initWithFrame:CGRectMake(0, self.frame.size.height - 9, self.frame.size.width, 9)];
    _progressView.progressTintColor = SET_COLOR;
    _progressView.alpha = 0;
    [self addSubview:_progressView];
    
}

//根据index来生成model
-(void)configureUI
{
    if (_isLessonDownloaded || _isLessonDownloading)
    {
        _label.text = [NSString stringWithFormat:@"第%@集",_model.number];
        _progressView.alpha = 1.0;
    }
    else{
        _label.text = [NSString stringWithFormat:@"第%@集",_model.number];
        
        //增加一个tap,点击了之后,就加入下载队列
        _tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(clickAction)];
        [self addGestureRecognizer:_tap];
    }
}

//点击了之后,将model加入队列.
-(void)clickAction
{
    NSLog(@"加入数据库");
    //将lesson加入下载数据库
    
    _progressView.alpha = 1.0;
    
    //判断是否已经在数据库中,如果已经在的话,不添加
    if (_model.vid) {
        //如果不存在,才添加进数据库
        
        //再次判断是否下载中
        _isCourseDownloading = [[CoreDataDownloadingManager manager]searchLessonByCourseId:_courseId];
        if (_isCourseDownloading) {
            NSArray *arr = [[CoreDataDownloadingManager manager]returnLessonByCourseId:_courseId];
            for (LessonDownload *lesson in arr) {
                NSLog(@"lessonNum:%@",lesson.number);
                if ([lesson.vid isEqualToString:_model.vid]) {
                    _isLessonDownloading = YES;
                    _lesson = lesson;
                    break;
                }
            }
        }
        
        //然后开始判断
        BOOL isLessonExist = _isLessonDownloaded || _isLessonDownloading;
        if (isLessonExist == NO) {
            [[CoreDataDownloadingManager manager]addLesson:^(LessonDownload * lesson) {
                lesson.courseId = _courseId;
                lesson.courseName = _courseName;
                lesson.downloadStatus = @(1);
                lesson.ipad_url = _model.ipad_url;
                lesson.lessonName = _model.short_name;
                lesson.number = _model.number;
                lesson.index = @(_model.index);
                lesson.vid = _model.vid;
                NSLog(@"index = %@",lesson.index);
            }];
            //_isLessonDownloading = YES;
            
            //做法一:
//            ASIHTTPRequest *request = [[ASIDownloadManager sharedManager]beginDownload1:_model.vid andURL:_model.ipad_url];
//            request.delegate=self;
//            request.downloadProgressDelegate = self;
//            [[CacheViewManager sharedManager]addCacheView:self];
//            //_request = request;

            //下载做法二:
            ASIHTTPRequest *request = [[ASIDownloadManager sharedManager]beginDownload:_model.vid andURL:_model.ipad_url];
            request.delegate=self;
            request.downloadProgressDelegate = self;
            //[[CacheViewManager sharedManager]addCacheView:self];
            _request = request;
            //---下载方法结束----
            
            //将其加入动态下载组中
            ActiveCacheModel *model = [[ActiveCacheModel alloc]init];
            model.courseId = _courseId;
            model.vid = _model.vid;
            model.request = request;
            model.urlStr = _model.ipad_url;
            [[ActiveCacheModelManager sharedManager]addCacheModel:model];
            
            //还是要存一下,否则会崩溃(因为self是代理)
            [[CacheViewManager sharedManager]addCacheView:self];
            
            //进度条
            _progressView.alpha = 1.0f;
            _progressView.progress=0;//赋值为0
            
            [self createDownloadLabelWithString:@"下载中"];
            
            //将是否下载改为YES
//            _isDownload = YES;
        }
        else//如果已经存在数据库
        {
            //判断下载状态,如果没下载完?
        }
    }
}

-(void)createDownloadLabelWithString:(NSString *)str
{
    //添加downloadLabel
    _downloadLabel = [MyControl createLabelWithFrame:CGRectMake(self.frame.size.width - 3 * FONT_SMALL - 10, self.frame.size.height - FONT_SMALL - 10, 3 * FONT_SMALL, FONT_SMALL) Font:FONT_SMALL Text:str];
    _downloadLabel.textColor = [UIColor whiteColor];
    _downloadLabel.backgroundColor = SET_COLOR;
    _downloadLabel.layer.cornerRadius = 2.0;
    
    [self addSubview:_downloadLabel];
}

//接收HTTP头文件
-(void)request:(ASIHTTPRequest *)request didReceiveResponseHeaders:(NSDictionary *)responseHeaders
{
    NSLog(@"********接收HTTP头文件********");
    NSString *num = [responseHeaders valueForKey:@"Content-Length"];
    if (num) {
        //判断是否在downloading数据库里了，如果不在的话，更新
        if (!_isLessonDownloading){
            LessonDownload *lesson = [[CoreDataDownloadingManager manager]returnLessonByVid:_model.vid];
            lesson.totalSize = [NSNumber numberWithInteger:[num integerValue]];
            [[CoreDataDownloadingManager manager]updateLesson:lesson];
        }
    }
}

//下载协议
- (void)setProgress:(float)newProgress{
    NSLog(@"%@集下载比例%f",_model.number,newProgress);
    [_progressView setProgress:newProgress];//赋给进度条
    
    if (_downloadPageProgressView) {
        [_downloadPageProgressView setProgress:newProgress];
    }

#pragma 不知道为啥,这里有个bug...
    if (_progressLabel) {
        NSNumber *num = [[CoreDataDownloadingManager manager]returnLessonTotalSizeByVid:_model.vid];
        CGFloat size = [self transferFileSize:num];
        _progressLabel.text = [NSString stringWithFormat:@"%0.2fM/%0.2fM",size * newProgress,size];
    }
}

//计算文件大小
-(CGFloat)transferFileSize:(NSNumber *)size
{
    return [size floatValue]/1024/1024;
}

#pragma mark - 协议方法：下载结束后
- (void)requestFinished:(ASIHTTPRequest *)request
{
    NSLog(@"下载完成");
    //下载完成后:
    //1. 清除request
    [_request clearDelegatesAndCancel];
    NSLog(@"清除完毕");
    
    //2.更新coreData数据库中信息
    //加入loaded,并从loading中删除
    
    LessonDownload *lesson1 = [[CoreDataDownloadingManager manager]returnLessonByVid:_model.vid];
    [[CoreDataDownloadedManager manager]addLesson:^(LessonDownload * lesson) {
        lesson.courseId = _courseId;
        lesson.courseName = lesson1.courseName;
        lesson.downloadStatus = @(2);
        lesson.ipad_url = _model.ipad_url;
        lesson.lessonName = _model.short_name;
        lesson.number = _model.number;
        lesson.vid = _model.vid;
        lesson.index = @(_model.index);
        lesson.totalSize = lesson1.totalSize;
    }];
    
    [[CoreDataDownloadingManager manager]deleteLessonByVid:_model.vid];
    
    //3.将cacheView中的view清除
    [[CacheViewManager sharedManager]deleteCacheView:self];
    
    //更新label上的界面
    [self updateFinishLook];
}

#pragma mark - 下载结束后刷新视图
-(void)updateFinishLook
{
    //将progress清除掉,重置为nil.
    [_progressView removeFromSuperview];
    _progressView = nil;
    
    //label的字体变一下
    _label.textColor = SET_COLOR;
    _label.font = [UIFont boldSystemFontOfSize:FONT_MIDDLE];
    
    //右边添加一个已下载的label
    _downloadLabel.text = @"已下载";
}

-(void)dealloc
{
    [_request clearDelegatesAndCancel];
}

@end
