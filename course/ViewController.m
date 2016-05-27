//
//  ViewController.m
//  公开课项目1
//
//  Created by AdvanceYe on 15/7/7.
//  Copyright (c) 2015年 AdvanceYe. All rights reserved.
//

#import "ViewController.h"
#import "RecommendViewController.h"
#import "CategoryViewController.h"
#import "SearchViewController.h"
#import "CollectionViewController.h"
#import "MotherViewController.h"
#import "leftViewController.h"
#import "DownloadViewController.h"

@interface ViewController ()<UIPageViewControllerDataSource,UIPageViewControllerDelegate,UIScrollViewDelegate>
{
    UIPageViewController *_pageViewController;
    RecommendViewController *_recommendViewController;
    CategoryViewController *_categoryViewController;
    NSMutableArray *_vcArray;
    NSArray *_tagArray;
    UIView *_btnView;
    UIView *_grayLine;
    //btn下面的slider
    UIView *_bottomSlider;
    NSInteger _currentPage;
    CGFloat _moveStep;
    BOOL _isBtnClicked;
    BOOL _isMoved;
//    CollectionViewController* _collectionVC;
    
    UITapGestureRecognizer *_tap;
    UISwipeGestureRecognizer *_swipe;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"学知课堂";
    
    _moveStep = SCREEN_WIDTH * 0.7;
    
    _tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(resurgeAction)];
    _swipe = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(resurgeAction)];
    _swipe.direction = UISwipeGestureRecognizerDirectionLeft;
    
    //self.navigationController.navigationBar.backgroundColor = SET_COLOR;
    self.navigationController.navigationBar.barTintColor = SET_COLOR;
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    self.navigationController.navigationBar.translucent = NO;
    
    //创建搜索btn
    [self createSearchBtn];
    
    //创建左边的VC
    UIButton *btn1 = [UIButton buttonWithType:UIButtonTypeCustom];
    btn1.frame = CGRectMake(0, 0, 33, 33);
    [btn1 setImage:[UIImage imageNamed:@"video_chapter_white_normal@3x.png"] forState:UIControlStateNormal];
    [btn1 addTarget:self action:@selector(sideMoveAction) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:btn1];
    
    //_titleArray = @[@"我的收藏",@"播放记录",@"我的下载",@"设置自动播放",@"分享应用",];
    //我的收藏页
    MotherViewController *viewController = (MotherViewController *)self.parentViewController.parentViewController;
    leftViewController *leftVC = (leftViewController *)viewController.leftViewController;
    [leftVC setCallBack0:^(leftViewController * leftVC) {
        if (leftVC.vcPushed == NO) {
            [self pushCollectionPage];
            [self resurgeAction];//复原位置
            leftVC.vcPushed = YES;
        }
    }];
    
    //播放记录
    [leftVC setCallBack1:^(leftViewController * leftVC) {
        if (leftVC.vcPushed == NO) {
            [self pushHistoryPage];
            [self resurgeAction];//复原位置
            leftVC.vcPushed = YES;
        }
    }];
    
    //我的下载
    [leftVC setCallBack2:^(leftViewController * leftVC) {
        if (leftVC.vcPushed == NO) {
            [self pushDownloadPage];
            [self resurgeAction];//复原位置
            leftVC.vcPushed = YES;
        }
    }];
    
    [self prepareData];
    [self uiConfig];
    
    NSLog(@"HOME = %@",NSHomeDirectory());
    
}

#pragma mark - 侧边栏滑动
-(void)sideMoveAction
{
    MotherViewController *viewController = (MotherViewController *)self.parentViewController.parentViewController;
    leftViewController *leftVC = (leftViewController *)viewController.leftViewController;
    if (!_isMoved) {
        [UIView animateWithDuration:0.25 animations:^{
            CGRect frame = viewController.rightView.frame;
            frame.origin.x += _moveStep;
            viewController.rightView.frame = frame;
        } completion:^(BOOL finished) {
            _isMoved = YES;
            leftVC.vcPushed = NO;
            self.view.userInteractionEnabled = NO;
            [self.parentViewController.view addGestureRecognizer:_tap];
            [self.parentViewController.view addGestureRecognizer:_swipe];
        }];
    }
    else
    {
        [UIView animateWithDuration:0.25 animations:^{
            CGRect frame = viewController.rightView.frame;
            frame.origin.x -= _moveStep;
            viewController.rightView.frame = frame;
        } completion:^(BOOL finished) {
            _isMoved = NO;
            leftVC.vcPushed = NO;
            self.view.userInteractionEnabled = YES;
            [self.parentViewController.view removeGestureRecognizer:_tap];
            [self.parentViewController.view addGestureRecognizer:_swipe];
        }];
    }
}
#pragma mark - 侧滑复原
-(void)resurgeAction
{
    if (_isMoved)
    {
        MotherViewController *viewController = (MotherViewController *)self.parentViewController.parentViewController;
        leftViewController *leftVC = (leftViewController *)viewController.leftViewController;
        [UIView animateWithDuration:0.25 animations:^{
            CGRect frame = viewController.rightView.frame;
            frame.origin.x -= _moveStep;
            viewController.rightView.frame = frame;
        } completion:^(BOOL finished) {
            _isMoved = NO;
            leftVC.vcPushed = NO;
            self.view.userInteractionEnabled = YES;
            [self.parentViewController.view removeGestureRecognizer:_tap];
        }];
    }
}

#pragma mark - 进入我的收藏页面
-(void)pushCollectionPage
{
    CollectionViewController *vc = [[CollectionViewController alloc]init];
    vc.title = @"我的收藏";
    [self.navigationController pushViewController:vc animated:YES];
}
#pragma mark - 进入我的历史页面
-(void)pushHistoryPage
{
    CollectionViewController *vc = [[CollectionViewController alloc]init];
    vc.isHistoryVC = YES;
    vc.title = @"播放记录";
    [self.navigationController pushViewController:vc animated:YES];
}
#pragma mark - 进入我的下载页面
-(void)pushDownloadPage
{
    DownloadViewController *vc = [[DownloadViewController alloc]init];
    vc.title = @"我的下载";
    [self.navigationController pushViewController:vc animated:YES];    
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

-(void)prepareData
{
    _tagArray = @[@"发现课程",@"课程分类"];
    _vcArray = [[NSMutableArray alloc]init];
    
    _recommendViewController = [[RecommendViewController alloc]init];
    _recommendViewController.currentPage = 0;
    [_vcArray addObject:_recommendViewController];
    
    _categoryViewController = [[CategoryViewController alloc]init];
    _categoryViewController.currentPage = 1;
    [_vcArray addObject:_categoryViewController];
}

-(void)uiConfig
{
#warning 有点小问题 - 需要添加个搜索图标
    ////////////////////////
    //创建pageViewController
    CGFloat scrollHeight = TITLE_HEIGHT;
    
    _pageViewController = [[UIPageViewController alloc]initWithTransitionStyle:1 navigationOrientation:0 options:nil];
    [self addChildViewController:_pageViewController];
    _pageViewController.view.frame = CGRectMake(0, scrollHeight, SCREEN_WIDTH, SCREEN_HEIGHT - scrollHeight);
    _pageViewController.delegate = self;
    _pageViewController.dataSource = self;
    
    [_pageViewController setViewControllers:@[_vcArray[0]] direction:1 animated:NO completion:nil];
    [self.view addSubview:_pageViewController.view];
    
    //找到pageViewController上面的scrollView,并且监听滑动事件
    for (UIView *view in _pageViewController.view.subviews) {
        if ([view isKindOfClass:[UIScrollView class]]) {
            UIScrollView *sv = (UIScrollView *)view;
            sv.delegate = self;
        }
    }
    
#warning (回头有空弄),需要设置其到头之后,无法往左或往右bounce.
    ////////////////////////
    //创建btnView及2个button

    _btnView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, scrollHeight)];
    for (int i = 0; i < _tagArray.count; i++) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        CGFloat btnWidth = SCREEN_WIDTH / _tagArray.count;
        btn.frame = CGRectMake(i * btnWidth, 0, btnWidth, scrollHeight);
        
#pragma mark - 如何设计btn点了之后不会变白一下？
        btn.tag = 300 + i;
        [_btnView addSubview:btn];
        [btn setTitle:_tagArray[i] forState:UIControlStateNormal];
        btn.titleLabel.font = [UIFont systemFontOfSize:FONT_LARGE];
        if (i == 0) {
            btn.selected = YES;
        }
        
        [btn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [btn setTitleColor:SET_COLOR forState:UIControlStateSelected];
        btn.backgroundColor = [UIColor whiteColor];
        btn.tintColor = [UIColor clearColor];
        [btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    [self.view addSubview:_btnView];
    
    //添加下划线
    CGFloat bottomSpace = (SCREEN_WIDTH - 8*FONT_LARGE) / 4.0;
    CGFloat bottomHeight = 6;
    _bottomSlider = [[UIView alloc]initWithFrame:CGRectMake(bottomSpace, _btnView.frame.size.height - bottomHeight, SCREEN_WIDTH / _tagArray.count - 2 * bottomSpace, bottomHeight)];
    _bottomSlider.backgroundColor = SET_COLOR;
    [_btnView addSubview:_bottomSlider];
    
    //添加一根灰色的线
    CGFloat lineSpace = 10;
    CGFloat lineHeight = 1;
    _grayLine = [[UIView alloc]initWithFrame:CGRectMake(lineSpace, _btnView.frame.size.height - lineHeight, SCREEN_WIDTH - 2 * lineSpace, lineHeight)];
    _grayLine.backgroundColor = [UIColor colorWithWhite:0 alpha:0.1];
    [_btnView addSubview:_grayLine];
    
}

#pragma mark - 监听按钮事件
-(void)btnClick:(UIButton *)sender
{
    NSInteger index = sender.tag - 300;
    for (int i = 0; i < 2; i++) {
        UIButton *btn = (UIButton *)[self.view viewWithTag:300 + i];
        if (i != index) {
            btn.selected = NO;
        }
        else
        {
            btn.selected = YES;
        }
    }

    [_pageViewController setViewControllers:@[_vcArray[index]] direction:index<_currentPage animated:YES completion:nil];
    _currentPage = index;
    _isBtnClicked = YES;
    
    [UIView animateWithDuration:0.25 animations:^{
        CGPoint center = _bottomSlider.center;
        center.x = sender.center.x;
        _bottomSlider.center = center;
    } completion:^(BOOL finished) {
    }];
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
    NSLog(@"%ld",_currentPage);
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
        //修改btn的选中颜色
        for (int i = 0; i < 2; i++) {
            UIButton *btn = (UIButton *)[self.view viewWithTag:300 + i];
            if (i != _currentPage) {
                btn.selected = NO;
            }
            else
            {
                btn.selected = YES;
            }
        }
        
        //滑动条
        CGFloat offsetx = scrollView.contentOffset.x;
        
        offsetx = offsetx - SCREEN_WIDTH;
        CGFloat offsetxBottom = offsetx / 2.0;
        NSLog(@"%f",offsetxBottom);
        CGPoint center = _bottomSlider.center;
        center.x = SCREEN_WIDTH / 2.0 * _currentPage + SCREEN_WIDTH / 4.0 + offsetxBottom;
        _bottomSlider.center = center;
    }
}

@end
