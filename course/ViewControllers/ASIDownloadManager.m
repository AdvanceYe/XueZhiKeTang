//
//  ASIDownloadManager.m
//  公开课项目1
//
//  Created by AdvanceYe on 15/7/20.
//  Copyright (c) 2015年 AdvanceYe. All rights reserved.
//

#import "ASIDownloadManager.h"

@implementation ASIDownloadManager
{
    
    NSString *_webPath;
    NSString *_cachePath;
    NSMutableArray *_requestArr;
}

+(id)sharedManager
{
    static ASIDownloadManager *_m = nil;
    if (!_m) {
        _m = [[ASIDownloadManager alloc]init];
    }
    return _m;
}

-(id)init
{
    self = [super init];
    
    if (self) {
        
        //首先开启下载队列
        _asiQueue = [[ASINetworkQueue alloc]init];//开启队列
        [_asiQueue reset];//nil
        _asiQueue.showAccurateProgress = YES;//进度
        [_asiQueue go];
        
        _requestArr = [[NSMutableArray alloc]init];
        
//        //如果不存在缓存目录地址,则创建缓存目录
//        //临时目录地址
//        _webPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Library/Private Documents/Temp"];
//        //缓存目录地址
//        _cachePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Library/Private Documents/Cache"];
//        //filemanager的设置
//        NSFileManager *fileManager=[NSFileManager defaultManager];
//        if(![fileManager fileExistsAtPath:_cachePath])
//        {
//            [fileManager createDirectoryAtPath:_cachePath withIntermediateDirectories:YES attributes:nil error:nil];
//        }
//        if(![fileManager fileExistsAtPath:_webPath])
//        {
//            [fileManager createDirectoryAtPath:_webPath withIntermediateDirectories:YES attributes:nil error:nil];
//        }
    }
    return self;
}

-(void)addRequest:(ASIHTTPRequest *)request withVid:(NSString *)vid
{
    NSDictionary *dict = [[NSDictionary alloc]initWithObjects:@[request,vid] forKeys:@[@"request",@"vid"]];
    [_requestArr addObject:dict];
}

-(ASIHTTPRequest *)beginDownload1:(NSString *)vid andURL:(NSString *)url
{
    //做法一:
    //开始下载
    //临时目录地址
    NSString *webPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/TempVideo"];
    //缓存目录地址
    NSString *cachePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/CacheVideo"];
    //filemanager的设置
    NSFileManager *fileManager=[NSFileManager defaultManager];
    
    //如果不存在缓存目录地址,则创建缓存目录
    if(![fileManager fileExistsAtPath:cachePath])
    {
        [fileManager createDirectoryAtPath:cachePath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    if(![fileManager fileExistsAtPath:webPath])
    {
        [fileManager createDirectoryAtPath:webPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    //如果缓存中不存在这个视频
    if (![fileManager fileExistsAtPath:[cachePath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.mp4",vid]]]) {
        //否则如果不存在这个视频,则开始下载视频
        ASIHTTPRequest *request=[[ASIHTTPRequest alloc] initWithURL:[NSURL URLWithString:url]];
        
        //下载完存储目录
        //设置存储地址
        [request setDownloadDestinationPath:[cachePath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.mp4",vid]]];
        //临时存储目录
        [request setTemporaryFileDownloadPath:[webPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.mp4",vid]]];
        //断点续载
        [request setAllowResumeForFileDownloads:YES];
        [request startAsynchronous];
        return request;
    }
    return nil;
}

-(ASIHTTPRequest *)beginDownload:(NSString *)vid andURL:(NSString *)url
{
    //临时目录地址
    NSString *webPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/TempVideo"];
    //缓存目录地址
    NSString *cachePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/CacheVideo"];
    //filemanager的设置
    NSFileManager *fileManager=[NSFileManager defaultManager];
    
    //如果不存在缓存目录地址,则创建缓存目录
    if(![fileManager fileExistsAtPath:cachePath])
    {
        [fileManager createDirectoryAtPath:cachePath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    if(![fileManager fileExistsAtPath:webPath])
    {
        [fileManager createDirectoryAtPath:webPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    //如果缓存中不存在这个视频
    if (![fileManager fileExistsAtPath:[cachePath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.mp4",vid]]])
    {
        //否则如果不存在这个视频,则开始下载视频
        ASIHTTPRequest *request=[[ASIHTTPRequest alloc] initWithURL:[NSURL URLWithString:url]];
        
        //request.delegate=self;
        //request.downloadProgressDelegate=self;//下载进度的代理，用于断点续传
        
        //下载完存储目录
        //设置存储地址
        [request setDownloadDestinationPath:[cachePath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.mp4",vid]]];
        //临时存储目录
        [request setTemporaryFileDownloadPath:[webPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.mp4",vid]]];
        //断点续载
        [request setAllowResumeForFileDownloads:YES];
        request.userInfo = [NSDictionary dictionaryWithObject:vid forKey:@"vid"];
        [_asiQueue addOperation:request];//加入队列
        //[request startAsynchronous];
        return request;
    }
    return nil;
}

//交给manager类去暂停
//暂停request
-(void)stopDownload:(NSString *)vid
{
    NSArray *queueArray =  [_asiQueue operations];
    for (ASIHTTPRequest *request in queueArray) {
        NSString *videoID = [request.userInfo objectForKey:@"vid"];
        if ([videoID isEqualToString:vid]) {
            [request clearDelegatesAndCancel];
            request = nil;
        }
    }
}

@end
