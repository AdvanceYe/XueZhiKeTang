//
//  ActiveCacheModel.h
//  公开课项目1
//
//  Created by AdvanceYe on 15/7/21.
//  Copyright (c) 2015年 AdvanceYe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ASIHTTPRequest.h"

@interface ActiveCacheModel : NSObject

@property(copy,nonatomic)NSString *courseId;
@property(copy,nonatomic)NSString *vid;
//@property(copy,nonatomic)NSString *number;
@property(copy,nonatomic)NSString *urlStr;
@property(strong,nonatomic)ASIHTTPRequest *request;

@end
