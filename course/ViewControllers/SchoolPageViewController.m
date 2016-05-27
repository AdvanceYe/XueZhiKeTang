//
//  SchoolPageViewController.m
//  公开课项目1
//
//  Created by AdvanceYe on 15/7/11.
//  Copyright (c) 2015年 AdvanceYe. All rights reserved.
//

#import "SchoolPageViewController.h"
#import "CourseModel.h"
#import "CourseListCell.h"
#import "CourseViewController.h"
#import "SearchViewController.h"
@interface SchoolPageViewController ()<UITableViewDataSource,UITableViewDelegate,MJRefreshBaseViewDelegate>

{
    UIImageView *_imgv;
    UILabel *_nameLabel;
    UIScrollView *_briefScrollView;
    UILabel *_briefLabel;
    UILabel *_barLabel;//课程列表条
    
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

@implementation SchoolPageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.navigationBar.translucent = NO;
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = _model.name;
    //在这里初始化容器
    _dataArray = [[NSMutableArray alloc]init];
    _pageNumber = 1;
    if (_isTED) {
//        _barLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 0, 0)];
//        [self.view addSubview:_barLabel];
        _barLabel = nil;
    }
    else
    {
        [self createUI];
    }
    [self createLeftBarBtn];
    [self createTB];
    [self showhudView];
    //[self loadData];
    [self checkNetWorkStatus];
    [self createRefresh];
    [self createSearchBtn];
}

#pragma 创建返回键
-(void)createLeftBarBtn
{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(0, 0, 33, 33);
    [btn setImage:[UIImage imageNamed:@"nav_back_white@3x.png"] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(popAction) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:btn];
}
-(void)popAction
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)createSearchBtn
{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(0, 0, 33, 33);
    [btn setImage:[UIImage imageNamed:@"nav_search_white@2x.png"] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(searchAction) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:btn];
}

-(void)searchAction
{
    NSLog(@"searchAction");
    SearchViewController *searchVC = [[SearchViewController alloc]init];
    [self.navigationController pushViewController:searchVC animated:YES];
}

#pragma mark - createUI
-(void)createUI
{
    _imgv = [MyControl createImageViewFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_WIDTH * 7 / 16.0) imageName:nil];
    [_imgv setImageWithURL:[NSURL URLWithString:[_model picture]] placeholderImage:[UIImage imageNamed:PLACEHOLDERIMG]];
    [self.view addSubview:_imgv];
    
    _nameLabel = [MyControl createLabelWithFrame:CGRectMake(10, CGRectGetMaxY(_imgv.frame) + 6, SCREEN_WIDTH - 10 - 10, FONT_MIDDLE) Font:FONT_MIDDLE Text:_model.name];
    [self.view addSubview:_nameLabel];
    
    _briefScrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(10, CGRectGetMaxY(_nameLabel.frame) + 6, SCREEN_WIDTH - 10 - 10, _imgv.frame.size.height * 0.6)];
    _briefScrollView.backgroundColor = LIGHT_SETCOLOR;
    //_briefScrollView.showsVerticalScrollIndicator = NO;
    [self.view addSubview:_briefScrollView];
    
    _briefLabel = [MyControl createLabelWithFrame:_briefScrollView.bounds Font:FONT_SMALL Text:_model.brief];
    _briefLabel.numberOfLines = 0;
    _briefLabel.lineBreakMode = NSLineBreakByCharWrapping;
    _briefLabel.textColor = [UIColor darkGrayColor];
    [_briefScrollView addSubview:_briefLabel];
    
    //第三方库计算文本高度-scrollView的contentSize
    CGSize size = [Tool strSize:_model.brief withMaxSize:CGSizeMake(_briefLabel.frame.size.width, MAXFLOAT) withFont:[UIFont systemFontOfSize:FONT_SMALL] withLineBreakMode:NSLineBreakByCharWrapping];
    CGRect frame = _briefLabel.frame;
    frame.size.height = size.height;
    
    if (frame.size.height > _briefScrollView.frame.size.height) {
        _briefLabel.frame = frame;
        _briefScrollView.contentSize = CGSizeMake(0, _briefLabel.frame.size.height);
    }
    else
    {
        _briefLabel.frame = frame;
        CGRect frame1 = _briefScrollView.frame;
        frame1.size.height = frame.size.height;
        _briefScrollView.frame = frame1;
        _briefScrollView.contentSize = CGSizeMake(0, 0);
    }
    
    _barLabel = [MyControl createLabelWithFrame:CGRectMake(0, CGRectGetMaxY(_briefScrollView.frame) + 6, SCREEN_WIDTH, FONT_MIDDLE + 8) Font:FONT_MIDDLE Text:@"  课程列表"];
    _barLabel.backgroundColor = SET_COLOR;
    _barLabel.textColor = [UIColor whiteColor];
    [self.view addSubview:_barLabel];
}

#pragma mark -创建TB
-(void)createTB
{
    self.automaticallyAdjustsScrollViewInsets = NO;
    _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(_barLabel.frame) + 8, SCREEN_WIDTH, SCREEN_HEIGHT - CGRectGetMaxY(_barLabel.frame) - 8 - NAV_HEIGHT - BAR_HEIGHT)];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    //_tableView.backgroundColor = [UIColor orangeColor];
    [self.view addSubview:_tableView];
    
    [_tableView registerClass:[CourseListCell class] forCellReuseIdentifier:@"cell"];
}

-(void)viewDidAppear:(BOOL)animated
{
    if(_isTED)
    {
        _tableView.frame = self.parentViewController.view.bounds;
    }
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
        [self loadData];
        
    }else{
        //上拉加载
        _pageNumber++;
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
    
    //school
    //http://platform.sina.com.cn/opencourse/get_courses?school_id=3&page=1&count_per_page=20&app_key=1919446470&order_by=total_click%20DESC
    
    //discipline
    //http://platform.sina.com.cn/opencourse/get_courses?discipline_id=2&page=1&count_per_page=20&app_key=1919446470&order_by=modified_at%20DESC
    
    //organizm:
    
    //TED
    //http://platform.sina.com.cn/opencourse/get_courses?school_id=57&page=1&count_per_page=20&app_key=1919446470&order_by=modified_at%20DESC
    
    NSDictionary *parameter = nil;
    if (_isDisipline) {
        parameter = @{
                      @"discipline_id":[NSString stringWithFormat:@"%@",_model.d_id],
                      @"page":[NSString stringWithFormat:@"%ld",_pageNumber],
                      @"count_per_page":@"20",
                      @"app_key":@"1919446470",
                      @"order_by":@"total_click%20DESC"
                      };
    }
    else if(_isTED){
        parameter = @{
                      @"school_id":@"57",
                      @"page":[NSString stringWithFormat:@"%ld",_pageNumber],
                      @"count_per_page":@"20",
                      @"app_key":@"1919446470",
                      @"order_by":@"total_click%20DESC"
                      };
    }
    else
    {
        parameter = @{
                      @"school_id":[NSString stringWithFormat:@"%@",_model.d_id],
                      @"page":[NSString stringWithFormat:@"%ld",_pageNumber],
                      @"count_per_page":@"20",
                      @"app_key":@"1919446470",
                      @"order_by":@"total_click%20DESC"
                      };
    }
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    [manager GET:_urlStr parameters:parameter success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        id jsonData = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        
        if (_isRefresh == NO) {
            [_dataArray removeAllObjects];
        }
        if([jsonData isKindOfClass:[NSArray class]])
        {
            NSLog(@"是array");
        }
        else if([jsonData isKindOfClass:[NSDictionary class]])
        {
            NSMutableArray *arr = [[NSMutableArray alloc]init];
            arr = [[[jsonData objectForKey:@"result"]objectForKey:@"data"]objectForKey:@"courses"];
            for (NSDictionary *d in arr) {
                CourseModel *model = [[CourseModel alloc]init];
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

#pragma mark - tableview的协议方法
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _dataArray.count;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [CourseModel cellHeight];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CourseListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
    [cell configUI:_dataArray[indexPath.row]];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    CourseModel *model = _dataArray[indexPath.row];
    CourseViewController *vc = [[CourseViewController alloc]init];
    vc.courseId = model.d_id;
    NSLog(@"%@",vc.courseId);
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - 析构函数
- (void)dealloc
{
    [_header free];
    [_footer free];
}

@end
