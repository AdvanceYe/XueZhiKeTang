//
//  RecommendViewController.m
//  公开课项目1
//
//  Created by AdvanceYe on 15/7/7.
//  Copyright (c) 2015年 AdvanceYe. All rights reserved.
//

#import "RecommendViewController.h"
#import "ScrollModel.h"
#import "BottomModel.h"
#import "ScrollCell.h"
#import "BottomCell.h"
#import "CourseViewController.h"

@interface RecommendViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    NSMutableArray *_scrollData;
    NSMutableArray *_bottomData;
    UITableView *_tableView;
    UIView *_hudView;
    BOOL _isLoadData;
    BOOL _isLoadData1;
    BOOL _isLoadData2;
}
@end

@implementation RecommendViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.translucent = NO;
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    ScrollCell *_scrollCell = [[ScrollCell alloc]init];
    
    [self createTB];
    [self showhudView];
    //[self loadData];
    [self checkNetWorkStatus];
    
    
}

#pragma mark - 显示hudView
-(void)showhudView
{
    _hudView = [[UIView alloc] initWithFrame:_tableView.frame];
    _hudView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_hudView];
}

-(void)loadData
{
    //这个是指示器 类似系统菊花
    JGProgressHUD *hud = [[JGProgressHUD alloc] initWithStyle:JGProgressHUDStyleDark];
    hud.textLabel.text = @"正在加载...";
    hud.center = _tableView.center;
    [hud showInView:_hudView animated:YES];
    
    //////////////////////////////
    _scrollData = [[NSMutableArray alloc]init];
    
    //网易[看看是否可行]
    //NSString *url = @"http://mobile.open.163.com/movie/2/getPlaysForAndroid.htm";
    //@"http://c.open.163.com/opensg/mopensg.do?uuid=C7B73297-5380-75FB-62BC-D3F82EABBB37&ursid=rjoe.ye%40163.com&count=20"
    
    //新浪[已验证可以]
    //解析scrollUrl
    NSString *scrollUrl = @"http://platform.sina.com.cn/open_course/slide?app_key=1919446470&format=json&v=1&num=7";
    //新浪课程详情页 1027
    //http://platform.sina.com.cn/opencourse/get_lessons?course_id=1005&page=1&count_per_page=1000&app_key=1919446470
    
    _scrollData = [[NSMutableArray alloc]init];
#warning 还缺个hub..
#warning 还缺个mjrefresh?
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    [manager GET:scrollUrl parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        id jsonData = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        //NSLog(@"%@",jsonData);
        if([jsonData isKindOfClass:[NSArray class]])
        {
            NSLog(@"是array");
        }
        else if([jsonData isKindOfClass:[NSDictionary class]])
        {
            NSArray *arr = [jsonData objectForKey:@"data"];
            for (NSDictionary *d in arr) {
                ScrollModel *model = [[ScrollModel alloc]init];
                [model setValuesForKeysWithDictionary:d];
                [_scrollData addObject:model];
            }
            //NSLog(@"%@",[_scrollData[0] img_ext]);
            [_tableView reloadData];
            _isLoadData1 = YES;
            if (_isLoadData1 && _isLoadData2) {
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
            }
        }
        else
        {
            NSLog(@"啥都不是");
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"解析失败");
    }];
    
    
    //////////////////////////
    //解析bottomView[新浪]
    _bottomData = [[NSMutableArray alloc]init];
    NSString *bottomUrl = @"http://platform.sina.com.cn/opencourse/get_courses?order_by=week_click%20DESC&page=2&count_per_page=20&app_key=1919446470";
    [manager GET:bottomUrl parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        id jsonData = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        if([jsonData isKindOfClass:[NSArray class]])
        {
            NSLog(@"是array");
        }
        else if([jsonData isKindOfClass:[NSDictionary class]])
        {
            NSArray *arr = [[[jsonData objectForKey:@"result"] objectForKey:@"data"] objectForKey:@"courses"];
            for (NSDictionary *d in arr) {
                BottomModel *model = [[BottomModel alloc]init];
                [model setValuesForKeysWithDictionary:d];
                [_bottomData addObject:model];
                NSLog(@"%@",[model name]);
            }
            //NSLog(@"%@",[_bottomData[0] name]);
            [_tableView reloadData];
            _isLoadData2 = YES;
            if (_isLoadData1 && _isLoadData2) {
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
            }
        }
        else
        {
            NSLog(@"啥都不是");
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"请求数据失败");
    }];
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

-(void)createTB
{
    _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - NAV_HEIGHT - BAR_HEIGHT - TITLE_HEIGHT)];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.showsHorizontalScrollIndicator = NO;
    _tableView.showsVerticalScrollIndicator = NO;
    [self.view addSubview:_tableView];
    
    [_tableView registerClass:[ScrollCell class] forCellReuseIdentifier:@"scrollCellId"];
    [_tableView registerClass:[BottomCell class] forCellReuseIdentifier:@"bottomCellId"];
}
#pragma mark - tableView协议
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 1;
    }
    else
    {
        //return 10;
        if (_bottomData.count % 2 ==0) {
            return _bottomData.count/2;
        }
        else
        {
            return _bottomData.count/2 + 1;
        }
        
    }
}
-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 1) {
        return @"推荐课程";
    }
    return nil;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    //cell
    if(indexPath.section == 0)
    {
        ScrollCell *cell = [tableView dequeueReusableCellWithIdentifier:@"scrollCellId" forIndexPath:indexPath];
        cell.dataArray = [_scrollData mutableCopy];
        [cell configureUI];
        [cell setCallback:^(ScrollModel * model) {
            CourseViewController *vc = [[CourseViewController alloc]init];
            vc.courseId = model.vid;
            NSLog(@"%@",vc.courseId);
            UINavigationController *nav = self.parentViewController.parentViewController.navigationController;
            [nav pushViewController:vc animated:YES];
        }];
        return cell;
    }
    else
    {
        BottomCell *cell = [tableView dequeueReusableCellWithIdentifier:@"bottomCellId" forIndexPath:indexPath];
        BottomModel *leftModel = nil;
        if (indexPath.row * 2 <_bottomData.count) {
            leftModel = _bottomData[indexPath.row * 2];
        }

        BottomModel *rightModel = nil;
        if (indexPath.row * 2 + 1 < _bottomData.count) {
            rightModel = _bottomData[indexPath.row * 2 + 1];
        }
        [cell configUILeftModel:leftModel rightModel:rightModel];
        
        //设置block合并在一个里面写.
        //设置block.
        [cell setLeftCallback:^(BottomModel * model) {
            [self pushCourseVC:model];
        }];
        //设置block.
        [cell setRightCallback:^(BottomModel *model) {
            [self pushCourseVC:model];
        }];
        return cell;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return [ScrollModel cellHeight];
    }
    else
    {
        return [BottomModel cellHeight];
    }
}

//完成cell的display滞后,让scrollCell开始滑动
-(void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        [cell performSelector:@selector(startTimer) withObject:nil];
    }
}

#pragma 设置push的动作(通过APP的)
-(void)pushCourseVC:(BottomModel *)model
{
    CourseViewController *vc = [[CourseViewController alloc]init];
    vc.courseId = model.id;
    NSLog(@"%@",vc.courseId);
    UINavigationController *nav = self.parentViewController.parentViewController.navigationController;
//    UINavigationController *nav = (UINavigationController *)[[[[UIApplication sharedApplication] delegate]window]rootViewController];
    [nav pushViewController:vc animated:YES];
}


@end
