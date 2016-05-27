//
//  CategoryViewController.m
//  公开课项目1
//
//  Created by AdvanceYe on 15/7/7.
//  Copyright (c) 2015年 AdvanceYe. All rights reserved.
//

#import "CategoryViewController.h"
#import "DisciplineModel.h"
#import "DisciplineViewController.h"
#import "SchoolViewController.h"
#import "SchoolPageViewController.h"

@interface CategoryViewController ()
{
    //tabBarController来管理4个视图控制器
    UITabBarController *_tabBarController;
    //4个VC:
    NSMutableArray *_vcArray;
    DisciplineViewController *_disVC;
    SchoolViewController *_schoolVC;
    SchoolPageViewController *_tedVC;
    DisciplineViewController *_orgVC;
    
    NSArray *_titleArray;
    NSArray *_urlArray;
    
    UIView *_btnView;
    
    NSInteger _selectBtnIndex;
}
@end

@implementation CategoryViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.automaticallyAdjustsScrollViewInsets = NO;
    self.view.backgroundColor = [UIColor redColor];
    self.navigationController.navigationBar.translucent = NO;
    [self prepareData];
    [self prepareVC];
    [self createTabBarController];
}

-(void)createTabBarController
{
    _titleArray = @[@"学科分类",@"大学课程",@"TED演讲",@"机构课程"];

#warning  title要好好弄弄图片啥的
    //放四个btn上去.
    CGFloat btnWidth = SCREEN_WIDTH / 8.0;
    CGFloat btnRadius = btnWidth / 2.0;
    CGFloat btnSpaceHeight = 5;
    CGFloat labelWidth = 2 * btnWidth;
    CGFloat labelHeight = FONT_SMALL;
    _btnView = [MyControl createViewWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, btnSpaceHeight + btnWidth + 3 + 5 + labelHeight)];
    _btnView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_btnView];

    NSArray *imgArr = @[@"dici.png",@"uni.png",@"ted.png",@"org.png"];
    for (int i = 0; i < _titleArray.count; i++) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setImage:[UIImage imageNamed:imgArr[i]] forState:UIControlStateNormal];
        
        btn.frame = CGRectMake( 2 * btnWidth * i + btnRadius, btnSpaceHeight, btnWidth, btnWidth);
        btn.tag = 600 + i;
        btn.backgroundColor = SET_COLOR;
        btn.layer.cornerRadius = btnRadius;
        if (i != 0) {
            btn.alpha = 0.5;
        }
        
        [btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
        [_btnView addSubview:btn];

        //创建label
        UILabel *label = [MyControl createLabelWithFrame:CGRectMake(i * labelWidth, CGRectGetMaxY(btn.frame)+3,labelWidth,labelHeight) Font:labelHeight Text:_titleArray[i]];
        label.textAlignment = NSTextAlignmentCenter;
        label.tag = 500 + i;
        label.textColor = [UIColor grayColor];
        if(i == 0)
        {
            label.textColor = SET_COLOR;
            label.font = [UIFont boldSystemFontOfSize:FONT_SMALL];
        }
        [_btnView addSubview:label];
    }
    
    _tabBarController = [[UITabBarController alloc]init];
    _tabBarController.view.backgroundColor = [UIColor cyanColor];
    _tabBarController.view.frame = CGRectMake(0, _btnView.frame.size.height, SCREEN_WIDTH, self.view.frame.size.height - _btnView.frame.size.height);
    _tabBarController.tabBar.hidden = YES;
    
    _tabBarController.viewControllers = _vcArray;
    [_tabBarController addChildViewController:_disVC];
    [_tabBarController addChildViewController:_schoolVC];
    [_tabBarController addChildViewController:_tedVC];
    [_tabBarController addChildViewController:_orgVC];
    [self addChildViewController:_tabBarController];
    [self.view addSubview:_tabBarController.view];
}

#pragma mark - 更改页面
-(void)btnClick:(UIButton *)sender
{
    _selectBtnIndex = sender.tag - 600;
    _tabBarController.selectedViewController = _vcArray[_selectBtnIndex];
    
    //更改btn透明度
    for(int i = 0; i< _vcArray.count; i++)
    {
        UIButton *btn = (UIButton *)[self.view viewWithTag:600 + i];
        if (i != _selectBtnIndex) {
            btn.alpha = 0.5;
        }
        else
        {
            btn.alpha = 1.0;
        }
    }
    
    //更改字体颜色
    for(int i = 0; i< _vcArray.count; i++)
    {
        UILabel *label = (UILabel *)[self.view viewWithTag:500 + i];
        if (i != _selectBtnIndex) {
            label.textColor = [UIColor grayColor];
            label.font = [UIFont systemFontOfSize:FONT_SMALL];
        }
        else
        {
            label.textColor = SET_COLOR;
            label.font = [UIFont boldSystemFontOfSize:FONT_SMALL];
        }
    }
}

#pragma mark - 准备vc
-(void)prepareVC
{
    //学科分类
    _disVC = [[DisciplineViewController alloc]init];
    _disVC.urlStr = _urlArray[0];
    
    //大学课程
    _schoolVC = [[SchoolViewController alloc]init];
    _schoolVC.urlStr = _urlArray[1];
    
    //TED演讲
    _tedVC = [[SchoolPageViewController alloc]init];
    _tedVC.isTED = YES;
    _tedVC.urlStr = _urlArray[2];
    
    
    //机构课程
    _orgVC = [[DisciplineViewController alloc]init];
    _orgVC.isOrg = YES;
    _orgVC.urlStr = _urlArray[3];
    
    _vcArray = [NSMutableArray arrayWithArray:@[_disVC,_schoolVC,_tedVC,_orgVC]];
}

-(void)prepareData
{
    /*
     学科分类
     //学科分类列表(不刷新)
     http://platform.sina.com.cn/opencourse/get_disciplines?app_key=1919446470
     http://platform.sina.com.cn/opencourse/get_courses?discipline_id=2&page=1&count_per_page=20&app_key=1919446470&order_by=modified_at%20DESC
     
     大学课程
     大学列表(可刷新)
     http://platform.sina.com.cn/opencourse/get_schools?type=university&page=1&count_per_page=10&app_key=1919446470
     大学课程列表
     http://platform.sina.com.cn/opencourse/get_courses?school_id=3&page=1&count_per_page=20&app_key=1919446470&order_by=total_click%20DESC
     某大学的某课程
     http://platform.sina.com.cn/opencourse/get_lessons?course_id=320&page=1&count_per_page=1000&app_key=1919446470
     
     TED:
     列表(可刷新)
     http://platform.sina.com.cn/opencourse/get_school?id=57&app_key=1919446470
          http://platform.sina.com.cn/opencourse/get_courses?school_id=57&page=1&count_per_page=20&app_key=1919446470&order_by=modified_at%20DESC
     
     机构网址
     列表(不刷新)
    http://platform.sina.com.cn/opencourse/get_schools?type=organization&page=0&count_per_page=20&app_key=1919446470
        
    http://platform.sina.com.cn/opencourse/get_courses?school_id=1&page=1&count_per_page=20&app_key=1919446470&order_by=modified_at%20DESC
        
    http://platform.sina.com.cn/opencourse/get_course?id=325&app_key=1919446470
     */
    
    _urlArray = @[
                  @"http://platform.sina.com.cn/opencourse/get_disciplines?app_key=1919446470",//学科分类(不刷新)
                  @"http://platform.sina.com.cn/opencourse/get_schools?",//type=university&page=1&count_per_page=10&app_key=1919446470",//大学课程(page要增加)
                  @"http://platform.sina.com.cn/opencourse/get_courses?",//school_id=57&page=1&count_per_page=20&app_key=1919446470&order_by=modified_at%20DESC",//TED(刷新)
                  @"http://platform.sina.com.cn/opencourse/get_schools?type=organization&page=0&count_per_page=20&app_key=1919446470",//机构(不刷新)
                  ];
}


@end
