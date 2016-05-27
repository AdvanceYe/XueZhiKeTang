//
//  CacheViewController.m
//  公开课项目1
//
//  Created by AdvanceYe on 15/7/9.
//  Copyright (c) 2015年 AdvanceYe. All rights reserved.
//

#import "CacheViewController.h"
#import "CacheView.h"

@interface CacheViewController ()
{
    UIScrollView *_scrollView;
}

@end

@implementation CacheViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor grayColor];
    
    NSLog(@"count:%ld",self.lessonArray.count);
    NSLog(@"courseId:%@,courseName:%@",_courseId,_courseName);
    [self createUI];
    [self loadData];
}

//创建UI,创建Label
-(void)createUI
{
    _scrollView = [[UIScrollView alloc]initWithFrame:self.parentViewController.view.bounds];
    _scrollView.backgroundColor = [UIColor lightGrayColor];
    [self.view addSubview:_scrollView];
    
    CGFloat widthSpace = 10;
    CGFloat width = (SCREEN_WIDTH - 3 * widthSpace) / 2.0;
    CGFloat heightSpace = 10;
    CGFloat height = TITLE_HEIGHT;
    
    //根据课程的个数来创建label
    for (int i = 0; i<self.lessonArray.count; i++) {
        /*
         x: i / 2
         y: i % 2
         */
//        CacheView *cacheView = [[CacheView alloc]initWithFrame:CGRectMake((widthSpace + width) * (i % 2) + widthSpace, (heightSpace + height) * (i / 2) + heightSpace, width, height)];
//        cacheView.model = self.lessonArray[i];
//        cacheView.courseId = _courseId;
        
        CacheView *cacheView = [[CacheView alloc]initWithFrame:CGRectMake((widthSpace + width) * (i % 2) + widthSpace, (heightSpace + height) * (i / 2) + heightSpace, width, height) lessonModal:(LessonModel *)self.lessonArray[i] andCourseId:_courseId];
        cacheView.courseName = _courseName;
        //cacheView.tag = 800 + i;//加上tag值
        [cacheView configureUI];
        [_scrollView addSubview:cacheView];
    }
    
    _scrollView.contentSize = CGSizeMake(0 , (heightSpace + height) * ((self.lessonArray.count-1) / 2) + heightSpace + height + heightSpace);
}

-(void)loadData
{
    //判断哪些是已下的,要刷新界面(添加已下载)
    
    //判断哪些是正在下载,但是没下载完的,要在界面上添加进度条
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
