//
//  BaseViewController.m
//  公开课项目1
//
//  Created by AdvanceYe on 15/7/7.
//  Copyright (c) 2015年 AdvanceYe. All rights reserved.
//

#import "BaseViewController.h"

@interface BaseViewController ()<UITableViewDataSource,UITableViewDelegate,MJRefreshBaseViewDelegate>
{
    NSInteger _pageNumber;
    UITableView *_tableView;
    UIView *_hudView;
    
    BOOL _isLoadData;
    BOOL _isRefresh;
    
    MJRefreshHeaderView *_header;
    MJRefreshFooterView *_footer;
}
@end


@implementation BaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

#pragma mark - 检测网络设置情况
-(void)checkNetWorkStatus
{
    //先得到一个管理者单例
    AFNetworkReachabilityManager *manager = [AFNetworkReachabilityManager sharedManager];
    //打开监测
    [manager startMonitoring];
    //网络状态一旦发了变化 就会触发这个回调
    [manager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        switch (status) {
                //这个未知
            case AFNetworkReachabilityStatusUnknown:
            case AFNetworkReachabilityStatusReachableViaWWAN:
            case AFNetworkReachabilityStatusReachableViaWiFi:
            {
                if (!_isLoadData) {
                    [self loadData];
                }
            }
                break;
                //无网络
            case AFNetworkReachabilityStatusNotReachable:
            {
                UIAlertView *av = [[UIAlertView alloc]
                                   initWithTitle:@"提示" message:@"未检测到网络，请检查您的网络设置!" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                [av show];
            }
                break;
            default:
                break;
        }
    }];
}

#pragma mark - 显示hudView
-(void)showhudView
{
    _hudView = [[UIView alloc] initWithFrame:_tableView.frame];
    _hudView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_hudView];
}

#pragma mark - 创建上拉刷新和下拉刷新
-(void)createRefresh
{
    _header = [MJRefreshHeaderView header];
    _header.delegate = self;
    _header.scrollView = _tableView;
    
    _footer = [MJRefreshFooterView footer];
    _footer.delegate = self;
    _footer.scrollView = _tableView;
}

#pragma mark - 刷新加载控件进入开始的状态就会调用这个代理
- (void)refreshViewBeginRefreshing:(MJRefreshBaseView *)refreshView{
    if (refreshView == _header) {
        _pageNumber = 1;
        _isRefresh = NO;
        NSLog(@"下拉刷新%ld",_isRefresh);
        [self loadData];
        
    }else{
        //上拉加载
        _pageNumber++;
        _isRefresh = YES;
        [self loadData];
    }
}

-(void)loadData
{

}

//#pragma mark - 析构函数
//- (void)dealloc
//{
//    [_header free];
//    [_footer free];
//}



@end
