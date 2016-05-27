//
//  SchoolOrgViewController.m
//  公开课项目1
//
//  Created by AdvanceYe on 15/7/11.
//  Copyright (c) 2015年 AdvanceYe. All rights reserved.
//

#import "SchoolViewController.h"
#import "DisciplineModel.h"
#import "DisciplineTableViewCell.h"
#import "SchoolPageViewController.h"
/*
 加了mjrefresh(下拉上拉刷新)和jghud(正在加载)
 */
@interface SchoolViewController ()<UITableViewDataSource,UITableViewDelegate,MJRefreshBaseViewDelegate>
{
    UITableView *_tableView;
    NSMutableArray *_dataArray;
    NSInteger _pageNumber;
    
    UIView *_hudView;
    
    BOOL _isLoadData;
    BOOL _isRefresh;
    
    MJRefreshHeaderView *_header;
    MJRefreshFooterView *_footer;
}
@end

@implementation SchoolViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    
    //在这里初始化容器
    _dataArray = [[NSMutableArray alloc]init];
    _pageNumber = 1;
    [self createTB];
    [self showhudView];
    //[self loadData];
    [self checkNetWorkStatus];
    [self createRefresh];
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
        //当他等于_header的时候 他应该是下拉刷新
        _pageNumber = 1;
        //我们知道 我们有一个可变容器里面装了模型
        //如果我们下拉刷新的话
        //我们清空可变容器里面的数据(模型)
        //我们设置 当这个isRefresh 他是NO 的时候 我们去清空可变容器的数据
        _isRefresh = NO;
        [self loadData];
        
    }else{
        //上拉加载
        _pageNumber++;
        //加载更多的话 ->是追加
        //追加的话 我们不需要清空可变容器的数据
        //当开关等于YES的时候 我们应该追加模型数据
        _isRefresh = YES;
        [self loadData];
    }
}
#pragma mark - 加载数据
-(void)loadData
{
    //这个是指示器 类似系统菊花
    JGProgressHUD *hud = [[JGProgressHUD alloc] initWithStyle:JGProgressHUDStyleDark];
    hud.textLabel.text = @"正在加载...";
    hud.center = _tableView.center;
    [hud showInView:_hudView animated:YES];
    
    /*
     @"http://platform.sina.com.cn/opencourse/get_schools?type=university&page=1&count_per_page=10&app_key=1919446470",//大学课程(page要增加)
     @"http://platform.sina.com.cn/opencourse/get_courses?school_id=57&page=1&count_per_page=20&app_key=1919446470&order_by=modified_at%20DESC",//TED(刷新)
     */
    
    //http://platform.sina.com.cn/opencourse/get_disciplines?app_key=1919446470

    NSDictionary *parameter = @{
                                @"type":@"university",
                                @"page":[NSString stringWithFormat:@"%ld",_pageNumber],
                                @"count_per_page":@"10",
                                @"app_key":@"1919446470"
                                };
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    [manager GET:_urlStr parameters:parameter success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        id jsonData = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        
        if (_isRefresh == NO) {
            //开关他是NO的时候 我们知道 他是下拉刷新
            //应该清空所有数据 把第一页的新数据加进来
            [_dataArray removeAllObjects];
        }
        if([jsonData isKindOfClass:[NSArray class]])
        {
            NSLog(@"是array");
        }
        else if([jsonData isKindOfClass:[NSDictionary class]])
        {
            NSMutableArray *arr = [[NSMutableArray alloc]init];
            arr = [[[jsonData objectForKey:@"result"]objectForKey:@"data"]objectForKey:@"schools"];
            for (NSDictionary *d in arr) {
                DisciplineModel *model = [[DisciplineModel alloc]init];
                [model setValuesForKeysWithDictionary:d];
                [_dataArray addObject:model];
            }
            [_tableView reloadData];
            _isLoadData = YES;
            [hud dismissAnimated:YES];
            if (_hudView) {
                [UIView animateWithDuration:0.5 animations:^{
                    _hudView.alpha = 0;
                }completion:^(BOOL finished) {
                    [_hudView removeFromSuperview];
                    _hudView = nil;
                }];
            }
            //这里我们结束刷新
            [_footer endRefreshing];
            [_header endRefreshing];
        }
        else
        {
            NSLog(@"啥都不是");
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"解析失败");
    }];
}
#pragma mark -创建TB
-(void)createTB
{
    self.automaticallyAdjustsScrollViewInsets = NO;
    _tableView = [[UITableView alloc]initWithFrame:self.parentViewController.view.bounds];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    //_tableView.backgroundColor = [UIColor orangeColor];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:_tableView];
    //_tableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
    
    [_tableView registerClass:[DisciplineTableViewCell class] forCellReuseIdentifier:@"cell"];
}

//要写这句,否则页面高度会有问题
-(void)viewDidAppear:(BOOL)animated
{
    _tableView.frame = self.parentViewController.view.bounds;
}

#pragma mark - tableview的协议方法
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _dataArray.count;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [DisciplineModel cellHeight];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DisciplineTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    [cell configUI:_dataArray[indexPath.row]];
    
    return cell;
}
//点击cellpush一个schoolPageViewController页面
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    DisciplineModel *model = _dataArray[indexPath.row];
    SchoolPageViewController *vc = [[SchoolPageViewController alloc]init];
    vc.model = model;
    vc.urlStr = @"http://platform.sina.com.cn/opencourse/get_courses?";
    [self.parentViewController.parentViewController.navigationController pushViewController:vc animated:YES];
}

- (void)dealloc
{
    [_header free];
    [_footer free];
}

@end
