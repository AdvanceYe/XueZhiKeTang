//
//  LessonViewController.m
//  公开课项目1
//
//  Created by AdvanceYe on 15/7/9.
//  Copyright (c) 2015年 AdvanceYe. All rights reserved.
//

#import "LessonViewController.h"
#import "LessonListCell.h"
#import "CourseViewController.h"

@interface LessonViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    UITableView *_tableView;
}
@end

@implementation LessonViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor blueColor];
    
    [self createTB];
}

-(void)createTB
{
    _tableView = [[UITableView alloc]initWithFrame:self.parentViewController.view.bounds];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.showsVerticalScrollIndicator = NO;
    _tableView.showsHorizontalScrollIndicator = NO;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:_tableView];
    [_tableView registerClass:[LessonListCell class] forCellReuseIdentifier:@"cellId"];
}

-(void)uiConfigure
{
    [_tableView reloadData];
}

#pragma mark - 实现tableView协议方法
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.lessonArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    LessonListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellId" forIndexPath:indexPath];
    cell.textLabel.text = [NSString stringWithFormat:@"[第%@集] %@",[self.lessonArray[indexPath.row] number],[self.lessonArray[indexPath.row] short_name]];
    
    //回调函数让其选择
    if (_callBack) {
        _callBack(_tableView,indexPath);
    }
    
    return cell;
}

#warning 如果要用button的话,要在cell里面加button,并且加监听事件
#warning 还需要相应地选中下面的cell
//如果是整行被selected
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    CourseViewController *courseVC = (CourseViewController *)self.parentViewController.parentViewController;
    [courseVC transitPlayUrl:[self.lessonArray[indexPath.row] ipad_url] withRow:indexPath.row];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40;
}

@end
