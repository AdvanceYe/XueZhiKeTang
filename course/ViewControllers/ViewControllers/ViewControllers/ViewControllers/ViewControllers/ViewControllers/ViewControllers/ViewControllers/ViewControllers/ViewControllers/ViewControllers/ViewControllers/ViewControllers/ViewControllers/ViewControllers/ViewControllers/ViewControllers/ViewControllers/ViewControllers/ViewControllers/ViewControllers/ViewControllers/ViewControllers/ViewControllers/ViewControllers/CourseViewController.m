//
//  CourseViewController.m
//  公开课项目1
//
//  Created by qianfeng on 15/7/7.
//  Copyright (c) 2015年 qianfeng. All rights reserved.

#import "CourseViewController.h"
#import "IntroductionViewController.h"
#import "LessonViewController.h"
#import "CacheViewController.h"
#import "CoreDataCollectionManager.h"
#import "CoreDataHistoryManager.h"
#import "MyMoviePlayerController.h"
#import "AppDelegate.h"

@interface CourseViewController ()<UIPageViewControllerDataSource,UIPageViewControllerDelegate,UIScrollViewDelegate>
{
    MyMoviePlayerController *_player;
    
    //多标签功能
    UIPageViewController *_pageViewController;
    IntroductionViewController *_introVC;
    LessonViewController *_lessonVC;
    CacheViewController *_cacheVC;
    NSMutableArray *_vcArray;
    NSArray *_tagArray;
    
    //btn的UI
    UIView *_btnView;
    //btn下面的slider
    UIView *_bottomSlider;
    //btnView添加一根灰色的线
    UIView *_grayLine;
    
    NSInteger _currentPage;
    BOOL _isBtnClicked;//用来控制pageViewController的事件
    
    NSString *_courseUrl;
    NSString *_lessonUrl;
    NSInteger _currentPlayRow;
    NSMutableArray *_array;
    
    //是否已经实现了收藏
    BOOL _isCollected;
    //是否已经观看过
    BOOL _isWatched;
    BOOL _isFullScreened;
    
    UIView *_hudView;
    BOOL _isLoadData;
}

@end

@implementation CourseViewController

#pragma mark - view disappear的时候处理事件(历史播放和收藏的数据库存储)
-(void)viewWillDisappear:(BOOL)animated
{
    if (_isFullScreened == NO) {
        NSLog(@"disappear");
        NSNumber *currentPlayRow = [NSNumber numberWithInteger:_currentPlayRow];
        NSNumber *currentPlaybackTime = [NSNumber numberWithFloat:_player.currentPlaybackTime];
        _isWatched = [[CoreDataHistoryManager manager]searchCourseByID:_courseModel.d_id];
        
        if (_isCollected) {//disAppear的时候,如果已经收藏的,要update一下
            CollectionCourse *course = [[CoreDataCollectionManager manager]returnCourseByID:_courseModel.d_id];
            course.currentPlayRow = currentPlayRow;
            course.time = currentPlaybackTime;
            course.updateDate = [NSDate date];
            [[CoreDataCollectionManager manager]updateCourse:course];
        }
        //disappear的时候,如果已经看过的,要update一下.
        if(_isWatched)//如果看过
        {
            CollectionCourse *course = [[CoreDataHistoryManager manager]returnCourseByID:_courseModel.d_id];
            course.currentPlayRow = currentPlayRow;
            course.time = currentPlaybackTime;
            course.updateDate = [NSDate date];
            [[CoreDataHistoryManager manager]updateCourse:course];
        }
        else//如果没有看过,要add一下
        {
            NSString *name = _courseModel.name;
            NSString *imgUrl = _courseModel.picture;
            NSString *d_id = _courseModel.d_id;
            NSNumber *totalPlayRow = [NSNumber numberWithInteger:_courseModel.lesson_count];
            //        NSNumber *currentPlayRow = [NSNumber numberWithInteger:_currentPlayRow];
            //        NSNumber *currentPlaybackTime = [NSNumber numberWithFloat:_player.currentPlaybackTime];
            if(_courseModel.d_id)
            {
                [[CoreDataHistoryManager manager]addCourse:^(CollectionCourse * course) {
                    course.name = name;
                    course.imgUrl = imgUrl;
                    course.d_id = d_id;
                    course.totalPlayRow = totalPlayRow;
                    course.currentPlayRow = currentPlayRow;
                    course.time = currentPlaybackTime;
                    course.updateDate = [NSDate date];
                }];
            }
        }
        
        [super viewWillDisappear:animated];
        //当前播放集数 = _currentPlayRow;
        NSLog(@"****%f",_player.currentPlaybackTime);
        NSLog(@"%f",NAN);
        [_player stop];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"courseid=%@",_courseId);
#warning 导航栏要弄弄
    self.navigationController.navigationBar.translucent = NO;
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.title = _courseModel.name;
    
    _courseUrl = [NSString stringWithFormat:@"http://platform.sina.com.cn/opencourse/get_course?id=%@&app_key=1919446470",_courseId];
    _lessonUrl = [NSString stringWithFormat:@"http://platform.sina.com.cn/opencourse/get_lessons?course_id=%@&page=1&count_per_page=1000&app_key=1919446470",_courseId];
    NSLog(@"courseurl=%@",_courseUrl);
    NSLog(@"lessonUrl=%@",_lessonUrl);
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self prepareVCData];
    [self createUI];
    [self showhudView];
    [self checkNetWorkStatus];
    //[self loadData];
}

#pragma - 创建hudview
-(void)showhudView
{
    NSLog(@"showHudView");
    _hudView = [[UIView alloc] initWithFrame:self.view.frame];
    _hudView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_hudView];
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

#pragma mark - 判断是否收藏过了,来更改右上角的item
-(void)addNavigationItemBtn
{
    //放一个收藏图标
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemBookmarks target:self action:@selector(collectionAction)];
    
    //判断是否已经收藏过了
    _isCollected = [[CoreDataCollectionManager manager]searchCourseByID:_courseModel.d_id];
    
    if (_isCollected) {
        self.navigationItem.rightBarButtonItem.tintColor = [UIColor yellowColor];
    }
    else
    {
        self.navigationItem.rightBarButtonItem.tintColor = [UIColor whiteColor];
    }
}

#pragma 实现收藏功能
-(void)collectionAction
{
    if(_isCollected)
    {
        //修改btn样式
        self.navigationItem.rightBarButtonItem.tintColor = [UIColor whiteColor];
        _isCollected = NO;
        //将其从数据库删除
        [[CoreDataCollectionManager manager]deleteCourseById:_courseModel.d_id];
        [self alertAction:@"已取消收藏"];
    }
    else
    {
        //修改btn样式
        self.navigationItem.rightBarButtonItem.tintColor = [UIColor yellowColor];
        _isCollected = YES;
        //将其添加至数据库
        [self addToCollectionDB];
        [self alertAction:@"收藏成功"];
    }
}
#pragma mark - 提示收藏成功/取消
-(void)alertAction:(NSString *)title
{
#warning - 不匹配?
    UIAlertView *av = [[UIAlertView alloc]initWithTitle:title message:nil delegate:nil cancelButtonTitle:nil otherButtonTitles:nil, nil];
    [av show];
    dispatch_time_t after = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC));
    //after时间点执行这个任务
    dispatch_after(after, dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:1 animations:^{
            av.alpha = 0;
        } completion:^(BOOL finished) {
            [av dismissWithClickedButtonIndex:0 animated:YES];
            __block av = nil;
        }];
    });
}

#pragma mark - 将课程存入收藏DB
-(void)addToCollectionDB
{
    NSString *name = _courseModel.name;
    NSString *imgUrl = _courseModel.picture;
    NSString *d_id = _courseModel.d_id;
    NSNumber *totalPlayRow = [NSNumber numberWithInteger:_courseModel.lesson_count];
    NSNumber *currentPlayRow = [NSNumber numberWithInteger:_currentPlayRow];
    NSNumber *currentPlaybackTime = [NSNumber numberWithFloat:_player.currentPlaybackTime];
    NSLog(@"playerTime = %f",_player.currentPlaybackTime);
    NSLog(@"playerTime = %@",currentPlaybackTime);
    
    if(_courseModel.d_id)
    {
        [[CoreDataCollectionManager manager]addCourse:^(CollectionCourse * course) {
            course.name = name;
            course.imgUrl = imgUrl;
            course.d_id = d_id;
            course.totalPlayRow = totalPlayRow;
            course.currentPlayRow = currentPlayRow;
            course.time = currentPlaybackTime;
            course.updateDate = [NSDate date];
            NSLog(@"收藏课程name:%@",course.name);
            NSLog(@"收藏课程id:%@",course.d_id);
            NSLog(@"收藏click1");
        }];
    }
}

#pragma mark - 创建pageViewController管理的VC
-(void)prepareVCData
{
    _tagArray = @[@"详情介绍",@"课程目录",@"缓存文件"];
    _vcArray = [[NSMutableArray alloc]init];
    
    _introVC = [[IntroductionViewController alloc]init];
    _introVC.currentPage = 0;
    [_vcArray addObject:_introVC];
    
    _lessonVC = [[LessonViewController alloc]init];
    _lessonVC.currentPage = 1;
    [_vcArray addObject:_lessonVC];
    
    _cacheVC = [[CacheViewController alloc]init];
    _cacheVC.currentPage = 2;
    [_vcArray addObject:_cacheVC];
}

#pragma - 监听全屏事件
- (void)moviePlayerWillEnterFullscreenNotification:(NSNotification*)notify
{
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    delegate.allowRotation = YES;
    [_player changeIndicatorFrameToFullScreen];
    _isFullScreened = YES;
    NSLog(@"moviePlayerWillEnterFullscreenNotification");
}

- (void)moviePlayerWillExitFullscreenNotification:(NSNotification*)notify
{
    
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    
    delegate.allowRotation = NO;
    
    [_player play];
    [_player changeIndicatorFrameToOriginal];
    _isFullScreened = NO;
    NSLog(@"moviePlayerWillExitFullscreenNotification");
}

#pragma mark 创建UI
-(void)createUI
{
    _player = [[MyMoviePlayerController alloc]init];
    _player.backgroundView.backgroundColor = [UIColor blackColor];
    [_player.view setFrame:CGRectMake(0, 0, SCREEN_WIDTH,SCREEN_WIDTH * 0.75)];  // player的尺寸
    [_player createIndicator];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moviePlayerWillEnterFullscreenNotification:) name:MPMoviePlayerWillEnterFullscreenNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moviePlayerWillExitFullscreenNotification:) name:MPMoviePlayerWillExitFullscreenNotification object:nil];
    [self.view addSubview: _player.view];
    NSLog(@"createPlayer");
    
    //创建btnView及button
    _btnView = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(_player.view.frame), SCREEN_WIDTH, TITLE_HEIGHT)];
    _btnView.backgroundColor = [UIColor greenColor];
    [self.view addSubview:_btnView];
    
    for (int i = 0; i < _tagArray.count; i++) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        CGFloat btnWidth = SCREEN_WIDTH / _tagArray.count;
        btn.frame = CGRectMake(i * btnWidth, 0, btnWidth, _btnView.frame.size.height);
        if (i == 0) {
            btn.selected = YES;
        }
        [btn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [btn setTitleColor:SET_COLOR forState:UIControlStateSelected];
        
        btn.tag = 300 + i;
        [_btnView addSubview:btn];
        [btn setTitle:_tagArray[i] forState:UIControlStateNormal];
        btn.titleLabel.font = [UIFont systemFontOfSize:15];
        btn.titleLabel.textColor = [UIColor darkGrayColor];
        btn.backgroundColor = [UIColor whiteColor];
        [btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    [self changeBtnTitleColor:_currentPage];
    
    //btnview上面放_bottomSlider
    CGFloat bottomHeight = 6;
    _bottomSlider = [[UIView alloc]initWithFrame:CGRectMake(0, _btnView.frame.size.height - bottomHeight, SCREEN_WIDTH / _tagArray.count , bottomHeight)];
    _bottomSlider.backgroundColor = SET_COLOR;
    [_btnView addSubview:_bottomSlider];
    
    //添加一根灰色的线
    CGFloat lineSpace = 0;
    CGFloat lineHeight = 1;
    _grayLine = [[UIView alloc]initWithFrame:CGRectMake(lineSpace, _btnView.frame.size.height - lineHeight, SCREEN_WIDTH - 2 * lineSpace, lineHeight)];
    _grayLine.backgroundColor = SET_COLOR;
    [_btnView addSubview:_grayLine];
    
    /////////////创建pageViewController/////////////
    _pageViewController = [[UIPageViewController alloc]initWithTransitionStyle:1 navigationOrientation:0 options:nil];
    //添加父子关系,在同一个页面中好传值
    [self addChildViewController:_pageViewController];
    _pageViewController.view.frame = CGRectMake(0, CGRectGetMaxY(_btnView.frame), SCREEN_WIDTH, SCREEN_HEIGHT - CGRectGetMaxY(_btnView.frame) );
    //_pageViewController.view.backgroundColor = [UIColor purpleColor];
    _pageViewController.delegate = self;
    _pageViewController.dataSource = self;
    //设置三个页面为_pageViewControlelr的子VC,这样后者好取pageViewController的bounds
    [_pageViewController addChildViewController:_introVC];
    [_pageViewController addChildViewController:_lessonVC];
    [_pageViewController addChildViewController:_cacheVC];
    
    [_pageViewController setViewControllers:@[_vcArray[0]] direction:1 animated:NO completion:nil];
    [self.view addSubview:_pageViewController.view];
    
    //找到pageViewController上面的scrollView,并且监听滑动事件
    for (UIView *view in _pageViewController.view.subviews) {
        if ([view isKindOfClass:[UIScrollView class]]) {
            UIScrollView *sv = (UIScrollView *)view;
            sv.delegate = self;
        }
    }
    
    //将player的view放到最上层来
    [self.view bringSubviewToFront:_player.view];
}

#pragma mark - 监听按钮事件
-(void)btnClick:(UIButton *)sender
{
    NSInteger index = sender.tag - 300;
    [_pageViewController setViewControllers:@[_vcArray[index]] direction:index<_currentPage animated:YES completion:nil];
    _currentPage = index;
    _isBtnClicked = YES;
    [UIView animateWithDuration:0.25 animations:^{
        CGPoint center = _bottomSlider.center;
        center.x = sender.center.x;
        _bottomSlider.center = center;
        //改颜色
        [self changeBtnTitleColor:index];
        
    }];
    
}

//将slider置于index处
-(void)placeBtnSlider:(NSInteger)index
{
    _currentPage = index;
    CGFloat btnWidth = SCREEN_WIDTH / _tagArray.count;
    CGRect frame = _bottomSlider.frame;
    frame.origin.x = index * btnWidth;
    _bottomSlider.frame = frame;
    //改颜色
    [self changeBtnTitleColor:index];
}

#pragma mark - 实现pageView协议
-(UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    NSInteger index = [_vcArray indexOfObject:viewController];
    if (index == 0) {
        return nil;
    }
    return _vcArray[index-1];
}

-(UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    NSInteger index = [_vcArray indexOfObject:viewController];
    if (index == _vcArray.count-1) {
        return nil;
    }
    return _vcArray[index+1];
}

-(void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed
{
    UIViewController *vc = pageViewController.viewControllers[0];
    NSInteger index = [_vcArray indexOfObject:vc];
    _currentPage = index;
    NSLog(@"%ld",(long)_currentPage);
}

#pragma mark - 设置player播放的集数和开始时间.
-(void)configPlayer
{
#warning 设置如果是standford的话,一开始没有视频,要实现自动跳转到有视频的才行..
#warning 搜索aa出来的第一个,会报错.....!!!大BUG (TED的都有这个问题?)
    
    if (!_isPlayTimeArchive)//如果没有存过数据的话
    {
        if (_lessonArray.count > 0) {
            _player.contentURL = [NSURL URLWithString:[_lessonArray[0] ipad_url]];
        }
    }
    else//如果存过数据的话,显示第二页
    {
        if (_lessonArray.count > _currentPlayRow) {
            _player.contentURL = [NSURL URLWithString:[_lessonArray[_currentPlayRow] ipad_url]];
            _player.initialPlaybackTime = _initialTime;
            //将_pageViewController设置为lesson List,并选中集数所在的row
            [_pageViewController setViewControllers:@[_lessonVC] direction:1 animated:NO completion:nil];
            //并且将lessonVC上的tableView选在第二个上(或者说是让其做某事)
            _currentPage = 1;
            [self placeBtnSlider:_currentPage];
            [self changeBtnTitleColor:_currentPage];
#pragma mark - 这里可能要更改(外观)
            [_lessonVC setCallBack:^(UITableView *tableView, NSIndexPath *indexPath) {
                if(indexPath.row == _currentPlayRow)
                {
                    [tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
                }
            }];
        }
    }
    [_player prepareToPlay];
    _player.shouldAutoplay = NO;
    NSLog(@"configPlayer");
    
}
#warning 看看新浪和网易怎么做
#pragma mark - 更改播放视频
-(void)transitPlayUrl:(NSString *)url withRow:(NSInteger)row
{
    //[_player stop];
    [_player setContentURL:[NSURL URLWithString:url]];
    [_player prepareToPlay];
    [_player play];
    
    _currentPlayRow = row;
    NSLog(@"当前播放为%ld",_currentPlayRow);
}

#pragma mark - 加载数据
-(void)loadData
{
    //这个是指示器 类似系统菊花
    JGProgressHUD *hud = [[JGProgressHUD alloc] initWithStyle:JGProgressHUDStyleDark];
    hud.textLabel.text = @"正在加载...";
    hud.center = self.view.center;
    [hud showInView:_hudView animated:YES];
    
    //解析course信息
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manager GET:_courseUrl parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        id jsonData = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        if ([jsonData isKindOfClass:[NSArray class]]) {
            NSLog(@"是array");
        }
        else if ([jsonData isKindOfClass:[NSDictionary class]])
        {
            NSDictionary *dict = [[jsonData objectForKey:@"result"] objectForKey:@"data"];
            _courseModel = [[CourseModel alloc]init];
            [_courseModel setValuesForKeysWithDictionary:dict];
            NSLog(@"course数据解析成功");
            //传参给introVC
            _introVC.courseModel = _courseModel;
            NSLog(@"%ld",[_courseModel translated_count]);
            [_introVC loadData];
            //添加rightNavigationBtnItem
            [self addNavigationItemBtn];
            _isLoadData = YES;
            NSLog(@"清除hudview和hud");
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
            NSLog(@"是其它数据");
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"解析course失败");
    }];
    
    //解析lesson信息
    [manager GET:_lessonUrl parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        id jsonData = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        if ([jsonData isKindOfClass:[NSArray class]]) {
            NSLog(@"是array");
        }
        else if ([jsonData isKindOfClass:[NSDictionary class]])
        {
            _lessonArray = [[NSMutableArray alloc]init];
            NSDictionary *array = [[[jsonData objectForKey:@"result"] objectForKey:@"data"] objectForKey:@"courses"];
            for (NSDictionary *dict in array) {
                LessonModel *lesson = [[LessonModel alloc]init];
                [lesson setValuesForKeysWithDictionary:dict];
                [_lessonArray addObject:lesson];
            }
            NSLog(@"lesson数据解析成功");
//            NSLog(@"lesson1.ipad_url = %@",[_lessonArray[0] ipad_url]);
//            NSLog(@"lesson1.name = %@",[_lessonArray[0] name]);
            _lessonVC.lessonArray = _lessonArray;
            [self configPlayer];
        }
        else
        {
            NSLog(@"是其它数据");
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"解析lesson失败");
    }];
}

#pragma mark - 修改btn的颜色
-(void)changeBtnTitleColor:(NSInteger)index
{
    UIButton *btn1 = (UIButton *)[self.view viewWithTag:300 + index];
    btn1.selected = YES;
    for (int i = 0; i < _tagArray.count; i++) {
        if (i != index) {
            UIButton *btn= (UIButton *)[self.view viewWithTag:300 + i];
            btn.selected = NO;
        }
    }
}

#pragma mark - scrollView协议方法
-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    _isBtnClicked = NO;
}

//一开始的offset是320,然后慢慢加到640,一旦动画停止,offset立刻变成320(该scrollView立刻回到320)
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (_isBtnClicked == NO) {
        //更改btn颜色
        [self changeBtnTitleColor:_currentPage];
        
        CGFloat offsetx = scrollView.contentOffset.x;
        
        offsetx = offsetx - SCREEN_WIDTH;
        CGFloat offsetxBottom = offsetx / _tagArray.count;
        NSLog(@"%f",offsetxBottom);
        CGRect frame = _bottomSlider.frame;
        frame.origin.x = SCREEN_WIDTH / _tagArray.count * _currentPage + offsetxBottom;
        _bottomSlider.frame = frame;
    }
}

@end
