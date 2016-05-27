//
//  ASIDownloadManager.h
//  公开课项目1
//
//  Created by AdvanceYe on 15/7/20.
//  Copyright (c) 2015年 AdvanceYe. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ASIDownloadManager : NSObject<ASIProgressDelegate,ASIHTTPRequestDelegate>

@property(strong,nonatomic)ASINetworkQueue *asiQueue;

//单例
+(id)sharedManager;

-(ASIHTTPRequest *)beginDownload1:(NSString *)vid andURL:(NSString *)url;
-(ASIHTTPRequest *)beginDownload:(NSString *)vid andURL:(NSString *)url;


-(void)stopDownload:(NSString *)vid andURL:(NSString *)url;


@end
