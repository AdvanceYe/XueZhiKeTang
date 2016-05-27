//
//  DownloadViewController.m
//  公开课项目1
//
//  Created by AdvanceYe on 15/7/21.
//  Copyright (c) 2015年 AdvanceYe. All rights reserved.
//

#import "DownloadViewController.h"
#import "DownloadedSubViewController.h"
#import "DownloadingSubViewController.h"

@interface DownloadViewController ()<UIPageViewControllerDataSource,UIPageViewControllerDelegate, UIScrollViewDelegate>
{
    UIPageViewController *_pageViewController;
    UIView *_btnView;
    UIButton *_btn1;
    UIButton *_btn2;
    UIView *_btnSlider;
    UIView *_grayLine;
    
    NSArray *_titleArray;
    NSArray *_vcArray;
    DownloadedSubViewController *_downloadedVC;
    DownloadingSubViewController *_downloadingVC;
    
    NSInteger _currentPage;
    
    //右上角的btn
    UIButton *_btn;
    //是否编辑完成
    BOOL _isCompleted;
    BOOL _isBtnClicked;
}
@end

@implementation DownloadViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationController.navigationBar.translucent = NO;
    self.automaticallyAdjustsScrollViewInsets = NO;
    _titleArray =@[@"下载中",@"已下载"];
    
    [self prepareVC];
    //[self showhudView];
    [self createUI];
    [self createLeftBarBtn];
    //创建btn
    [self createBtn];
    //[self checkNetWorkStatus];//判断网络状态
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

#pragma mark - 创建VC
-(void)prepareVC
{
    _downloadedVC = [DownloadedSubViewController new];
    _downloadedVC.view.backgroundColor = [UIColor whiteColor];
    _downloadingVC = [DownloadingSubViewController new];
    _vcArray = @[_downloadingVC,_downloadedVC];
}

//创建右上角的btn.
-(void)createBtn
{
    _btn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    _btn.frame = CGRectMake(0, 0, 60, 30);
    _btn.backgroundColor = LIGHT_SETCOLOR;
    [_btn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [_btn addTarget:self action:@selector(editingAction) forControlEvents:UIControlEventTouchUpInside];
    [_btn setTitle:@"编辑" forState:UIControlStateNormal];
    
    UIBarButtonItem *rightBarBtn = [[UIBarButtonItem alloc]initWithCustomView:_btn];
    
    self.navigationItem.rightBarButtonItem = rightBarBtn;
}

-(void)editingAction
{
    if (_isCompleted) {//如果完成，显示为编辑
        [_btn setTitle:@"编辑" forState:UIControlStateNormal];
    }
    else
    {
        [_btn setTitle:@"完成" forState:UIControlStateNormal];
    }
    _downloadedVC.isCompleted = _isCompleted;
    [_downloadedVC performSelector:@selector(editingAction)];
    _downloadingVC.isCompleted = _isCompleted;
    [_downloadingVC performSelector:@selector(editingAction)];
    _isCompleted = !_isCompleted;
}

-(void)createUI
{
    //创建两个Btn及btnView;
    _btnView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, TITLE_HEIGHT)];
    //_btnView.backgroundColor = [UIColor orangeColor];
    [self.view addSubview:_btnView];
    
    CGFloat btnWidth = SCREEN_WIDTH/_titleArray.count;
    for (int i = 0; i<_titleArray.count; i++) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setTitle:_titleArray[i] forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        [btn setTitleColor:SET_COLOR forState:UIControlStateSelected];
        btn.titleLabel.font = [UIFont systemFontOfSize:FONT_LARGE];
        [btn addTarget:self action:@selector(changeVC:) forControlEvents:UIControlEventTouchUpInside];
        btn.tag = 880 + i;
        btn.frame = CGRectMake(i * btnWidth, 0, btnWidth, _btnView.frame.size.height);
        [_btnView addSubview:btn];
        if (i == 0) {
            _btn1 = btn;
            _btn1.selected = YES;
        }
        else
        {
            _btn2 = btn;
        }
    }
    
    //加slider
    CGFloat sliderHeight = 5;
    _btnSlider = [[UIView alloc]initWithFrame:CGRectMake(0, _btnView.frame.size.height - sliderHeight, btnWidth, sliderHeight)];
    _btnSlider.backgroundColor = SET_COLOR;
    [_btnView addSubview:_btnSlider];
    
    //添加一根灰色的线
    CGFloat lineSpace = 10;
    CGFloat lineHeight = 1;
    _grayLine = [[UIView alloc]initWithFrame:CGRectMake(lineSpace, _btnView.frame.size.height - lineHeight, SCREEN_WIDTH - 2 * lineSpace, lineHeight)];
    _grayLine.backgroundColor = [UIColor colorWithWhite:0 alpha:0.1];
    [_btnView addSubview:_grayLine];
    
    //创建pageViewController
    _pageViewController = [[UIPageViewController alloc]initWithTransitionStyle:1 navigationOrientation:0 options:nil];
    [self addChildViewController:_pageViewController];
    _pageViewController.view.frame = CGRectMake(0, CGRectGetMaxY(_btnView.frame), SCREEN_WIDTH, SCREEN_HEIGHT - CGRectGetMaxY(_btnView.frame));
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
}

#pragma mark - 监听按钮事件
-(void)changeVC:(UIButton *)sender
{
    _isBtnClicked = YES;
    NSInteger index = sender.tag - 880;
    
    //更改slider坐标
    CGPoint center = _btnSlider.center;
    center.x = sender.center.x;
    _btnSlider.center = center;

    //更改vc
    if (index != _currentPage) {
        [_pageViewController setViewControllers:@[_vcArray[index]] direction:index<_currentPage animated:YES completion:nil];
        _currentPage = index;
        
        //更改btn文字颜色
        sender.selected = YES;
        //更改另一个btn的文字颜色
        UIButton *btn = (UIButton *)[self.view viewWithTag:880 + 1 -index];
        btn.selected = NO;
    }
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
            UIButton *btn = (UIButton *)[self.view viewWithTag:880 + i];
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
        CGPoint center = _btnSlider.center;
        center.x = SCREEN_WIDTH / 2.0 * _currentPage + SCREEN_WIDTH / 4.0 + offsetxBottom;
        _btnSlider.center = center;
    }
}


@end
