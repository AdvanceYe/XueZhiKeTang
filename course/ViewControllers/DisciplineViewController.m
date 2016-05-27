//
//  DisciplineViewController.m
//  公开课项目1
//
//  Created by AdvanceYe on 15/7/10.
//  Copyright (c) 2015年 AdvanceYe. All rights reserved.
//

#import "DisciplineViewController.h"
#import "DisciplineModel.h"
#import "DisciplineTableViewCell.h"
#import "SchoolPageViewController.h"
@interface DisciplineViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    UITableView *_tableView;
    NSMutableArray *_dataArray;
    UIView *_hudView;
    BOOL _isLoadData;
}
@end

@implementation DisciplineViewController

//-(void)loadView
//{
//    UIView *view = [[UIView alloc]initWithFrame:self.parentViewController.view.bounds];
//    self.view = view;
//}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self createTB];
    [self showhudView];
    [self checkNetWorkStatus];
}

#pragma mark - 显示hudView
-(void)showhudView
{
    _hudView = [[UIView alloc] initWithFrame:_tableView.frame];
    _hudView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_hudView];
}

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

#pragma mark - 加载数据
-(void)loadData
{
    //这个是指示器
    JGProgressHUD *hud = [[JGProgressHUD alloc] initWithStyle:JGProgressHUDStyleDark];
    hud.textLabel.text = @"正在加载...";
    [hud showInView:_hudView animated:YES];
    
    /*
    @"http://platform.sina.com.cn/opencourse/get_disciplines?app_key=1919446470",//学科分类(不刷新)
    @"http://platform.sina.com.cn/opencourse/get_schools?type=organization&page=0&count_per_page=20&app_key=1919446470",//机构(不刷新)
     */
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];

    [manager GET:_urlStr parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        id jsonData = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        if([jsonData isKindOfClass:[NSArray class]])
        {
            NSLog(@"是array");
        }
        else if([jsonData isKindOfClass:[NSDictionary class]])
        {
            _dataArray = [[NSMutableArray alloc]init];
            NSMutableArray *arr = [[NSMutableArray alloc]init];
            if (_isOrg == NO) {
                arr = [[[jsonData objectForKey:@"result"]objectForKey:@"data"]objectForKey:@"disciplines"];
            }
            else
            {
                arr = [[[jsonData objectForKey:@"result"]objectForKey:@"data"]objectForKey:@"schools"];
            }
            for (NSDictionary *d in arr) {
                DisciplineModel *model = [[DisciplineModel alloc]init];
                [model setValuesForKeysWithDictionary:d];
                [_dataArray addObject:model];
            }
            [_tableView reloadData];
            _isLoadData = YES;
            //当我们的数据完成了 我们应该取消指示器
            [hud dismissAnimated:YES];
            if (_hudView) {
                [UIView animateWithDuration:0.5 animations:^{
                    _hudView.alpha = 0;
                }completion:^(BOOL finished) {
                    [_hudView removeFromSuperview];
                    _hudView = nil;
                }];
            }
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
    //http://platform.sina.com.cn/opencourse/get_courses?school_id=1&page=1&count_per_page=20&app_key=1919446470&order_by=modified_at%20DESC
    
    DisciplineModel *model = _dataArray[indexPath.row];
    SchoolPageViewController *vc = [[SchoolPageViewController alloc]init];
    if(!_isOrg)
    {
        vc.isDisipline = YES;
    }
    vc.model = model;
    vc.urlStr = @"http://platform.sina.com.cn/opencourse/get_courses?";
    [self.parentViewController.parentViewController.navigationController pushViewController:vc animated:YES];
}

@end
