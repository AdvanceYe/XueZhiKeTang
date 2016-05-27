//
//  leftViewController.h
//  公开课项目1
//
//  Created by qianfeng on 15/7/15.
//  Copyright (c) 2015年 qianfeng. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface leftViewController : UIViewController

@property(copy,nonatomic)void(^callBack0)(leftViewController *);
@property(copy,nonatomic)void(^callBack1)(leftViewController *);
@property(copy,nonatomic)void(^callBack2)(leftViewController *);
@property(copy,nonatomic)void(^callBack3)(leftViewController *);
@property(copy,nonatomic)void(^callBack4)(leftViewController *);
@property(assign,nonatomic)BOOL vcPushed;

@end
