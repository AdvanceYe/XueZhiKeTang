//
//  BaseViewController.h
//  公开课项目1
//
//  Created by qianfeng on 15/7/7.
//  Copyright (c) 2015年 qianfeng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CourseModel.h"
#import "LessonModel.h"

@interface BaseViewController : UIViewController

@property(assign,nonatomic) NSInteger currentPage;
@property(strong,nonatomic) CourseModel *courseModel;
@property(strong,nonatomic) NSArray *lessonArray;

@property(assign,nonatomic) NSString *urlStr;

@property(assign,nonatomic) NSInteger pageNumber;
@property(strong,nonatomic) UITableView *tableView;
@property(strong,nonatomic)UIView *hudView;
@property(assign,nonatomic)BOOL isLoadData;
@property(assign,nonatomic)BOOL isRefresh;
@property(strong,nonatomic)MJRefreshHeaderView *header;
@property(strong,nonatomic)MJRefreshFooterView *footer;

-(void)checkNetWorkStatus;
-(void)showhudView;
-(void)createRefresh;
- (void)refreshViewBeginRefreshing:(MJRefreshBaseView *)refreshView;
-(void)loadData;

@end
