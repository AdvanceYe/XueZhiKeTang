//
//  DownloadedSubViewController.m
//  公开课项目1
//
//  Created by AdvanceYe on 15/7/23.
//  Copyright (c) 2015年 AdvanceYe. All rights reserved.
//

#import "DownloadedSubViewController.h"
#import "CoreDataDownloadedManager.h"
#import "MyMPViewController.h"
#import "MyTableView.h"
#import "CourseViewController.h"
#import "MyTapGuestureRecognizer.h"

@interface DownloadedSubViewController ()<UITableViewDataSource,UITableViewDelegate,NSFetchedResultsControllerDelegate,UIAlertViewDelegate>
{
    MyTableView *_tableView;
    NSMutableArray *_dataArray;
    //可以实时监控数据库的变化
    NSFetchedResultsController *_controller;
    NSFetchRequest *_req;
    UIButton *_btn;
    
    //创建底部的bottomView和两个btn;
    CGFloat _bottomViewHeight;
    UIView *_bottomView;
    UIButton *_allSelectBtn;
    UIButton *_deleteBtn;
    
    NSMutableArray *_removeArray;
    BOOL _isAllSelected;
}
@end

@implementation DownloadedSubViewController

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self prepareData];
    [self processDataArray];
    [_tableView reloadData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.translucent = NO;
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.view.backgroundColor = [UIColor yellowColor];
    
    _removeArray = [[NSMutableArray alloc]init];
    _dataArray = [[NSMutableArray alloc]init];
    
    [self createTB];
    [self prepareData];
    [self processDataArray];
    [_tableView reloadData];
    [self createBottomView];
}

#pragma mark - 多选删除
//创建BottomView
-(void)createBottomView
{
    _bottomViewHeight = NAV_HEIGHT;
    _bottomView = [[UIView alloc]initWithFrame:CGRectMake(0, SCREEN_HEIGHT - NAV_HEIGHT - BAR_HEIGHT - TITLE_HEIGHT - _bottomViewHeight ,SCREEN_WIDTH , _bottomViewHeight)];
    _bottomView.backgroundColor = SET_COLOR;
    [self.view addSubview:_bottomView];
    _bottomView.hidden = YES;
    
    //创建两个btn
    CGFloat btnWid = SCREEN_WIDTH * 0.6 / 2;
    CGFloat btnSpace = SCREEN_WIDTH * 0.4 / 5;
    CGFloat btnHeight = _bottomViewHeight - 10;
    
    _allSelectBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    _allSelectBtn.frame = CGRectMake(2 * btnSpace, 5, btnWid, btnHeight);
    _allSelectBtn.backgroundColor = LIGHT_SETCOLOR;
    [_allSelectBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_allSelectBtn addTarget:self action:@selector(allSelectAction) forControlEvents:UIControlEventTouchUpInside];
    [_allSelectBtn setTitle:@"全选" forState:UIControlStateNormal];
    [_bottomView addSubview:_allSelectBtn];
    
    _deleteBtn= [UIButton buttonWithType:UIButtonTypeRoundedRect];
    _deleteBtn.frame = CGRectMake(3 * btnSpace + btnWid, 5, btnWid, btnHeight);
    _deleteBtn.backgroundColor = LIGHT_SETCOLOR;
    [_deleteBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_deleteBtn addTarget:self action:@selector(deleteAction) forControlEvents:UIControlEventTouchUpInside];
    [_deleteBtn setTitle:@"删除" forState:UIControlStateNormal];
    [_bottomView addSubview:_deleteBtn];
}

#pragma mark 全选动作
-(void)allSelectAction
{
    NSLog(@"全部选择");
    //数据库里面course数量大于0才这样做
    if (_controller.fetchedObjects.count >0) {
        if (_isAllSelected == NO) {//如果全选的话，将其放入removeArray中
#warning 回头可能要改
            //多选，选中所有的
            NSLog(@"全部选择");
            for(int section = 0; section < _dataArray.count; section ++)
            {
                for (int row = 0; row < [[_dataArray[section] objectForKey:@"lessonArr"]count]; row++)
                {
                    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:section];
                    [_tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
                }
            }
            _removeArray = [NSMutableArray arrayWithArray:_controller.fetchedObjects];
            [_allSelectBtn setTitle:@"取消全选" forState:UIControlStateNormal];
            _isAllSelected = YES;
        }
        else{
            //多选，取消所有的
            for(int section = 0; section < _dataArray.count; section ++)
            {
                for (int row = 0; row < [[_dataArray[section] objectForKey:@"lessonArr"]count]; row++)
                {
                    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:section];
                    [_tableView deselectRowAtIndexPath:indexPath animated:NO];
                }
            }
            [_removeArray removeAllObjects];
            [_allSelectBtn setTitle:@"全选" forState:UIControlStateNormal];
            _isAllSelected = NO;
        }
    }
}

#pragma mark 删除动作
-(void)deleteAction
{
    if (_removeArray.count > 0) {
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"删除确认"
                                                     message:@"删除选中的已下载内容"
                                                    delegate:self
                                           cancelButtonTitle:@"取消"
                                           otherButtonTitles:@"确定",nil];
        [av show];
    }
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    //删除文件
    if (buttonIndex == 1) {
        
        NSFileManager *fm=[NSFileManager defaultManager];
        NSString *cachePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/CacheVideo"];
        for (LessonDownload *lesson in _removeArray) {
            //1.将本地文件删除
            NSString *filePath = [cachePath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.mp4",lesson.vid]];
            BOOL success = [fm removeItemAtPath:filePath error:nil];
            NSLog(@"%@成功了?%d",lesson.vid,success);
            
            //2.将coreData中文件删除
            [[CoreDataDownloadedManager manager]deleteLesson:lesson];
            
            //提示
            UIAlertView *av1 = [[UIAlertView alloc]initWithTitle:@"删除成功" message:nil delegate:nil cancelButtonTitle:nil otherButtonTitles:nil, nil];
            [av1 show];
            dispatch_time_t after = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC));
            //after时间点执行这个任务
            dispatch_after(after, dispatch_get_main_queue(), ^{
                [UIView animateWithDuration:1 animations:^{
                    av1.alpha = 0;
                } completion:^(BOOL finished) {
                    [av1 dismissWithClickedButtonIndex:0 animated:YES];
                    __block av1 = nil;
                }];
            });
        }
    }
    //多选，取消所有的
    for (int row = 0; row < _controller.fetchedObjects.count; row++)
    {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
        [_tableView deselectRowAtIndexPath:indexPath animated:NO];
    }
    [_removeArray removeAllObjects];
    [_allSelectBtn setTitle:@"全选" forState:UIControlStateNormal];
    _isAllSelected = NO;
}


#pragma 上一个页面点击编辑了之后，这边这样操作
-(void)editingAction
{
    [_tableView setEditing:!_tableView.editing animated:YES];
    
    //点击完成
    if (_isCompleted) {//编辑状态
        //[_btn setTitle:@"编辑" forState:UIControlStateNormal];
        _bottomView.hidden = YES;
        _tableView.isOnEditing = NO;
        [_tableView reloadData];
        
        //修改tableView的高度
        CGRect frame = _tableView.frame;
        frame.size.height = frame.size.height + _bottomViewHeight;
        _tableView.frame = frame;
    }
    else//点击了编辑
    {
        //[_btn setTitle:@"完成" forState:UIControlStateNormal];
        _bottomView.hidden = NO;
        _tableView.isOnEditing = YES;
        [_tableView reloadData];
        
        //修改tableView的高度
        CGRect frame = _tableView.frame;
        frame.size.height = frame.size.height - _bottomViewHeight;
        _tableView.frame = frame;
        
        //点击的时候取消全选
#warning coreData还是要写统一删除和统一update的方法,省内存
        if(_controller.fetchedObjects.count >0)
        {
            [_removeArray removeAllObjects];
            [_allSelectBtn setTitle:@"全选" forState:UIControlStateNormal];
            _isAllSelected = NO;
        }
    }
}

#pragma 创建tableView
-(void)createTB
{
    _tableView = [[MyTableView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - NAV_HEIGHT - TITLE_HEIGHT - BAR_HEIGHT)];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.backgroundColor = [UIColor whiteColor];
    _tableView.showsVerticalScrollIndicator = NO;
    _tableView.tableFooterView = [[UIView alloc]init];
    [self.view addSubview:_tableView];
}

#pragma 获得controller舰艇的coreData数据
-(void)prepareData
{
    //获得数据
    //_dataArray = [NSMutableArray arrayWithArray:[[CoreDataDownloadManager manager]fetchLessonSortByCourseId]];
    
    //不用加谓词了
    _req = [[NSFetchRequest alloc]initWithEntityName:@"LessonDownload"];
    //获得status是2的
    
    //已经用courseId排序了
    NSSortDescriptor *sd = [NSSortDescriptor sortDescriptorWithKey:@"courseId" ascending:YES];
    _req.sortDescriptors = @[sd];
    
    NSManagedObjectContext *context = [[CoreDataDownloadedManager manager]context];
    
    _controller = [[NSFetchedResultsController alloc]initWithFetchRequest:_req managedObjectContext:context sectionNameKeyPath:nil cacheName:nil];
    
    _controller.delegate = self;
    [_controller performFetch:nil];
}
#pragma mark - 处理数据
-(void)processDataArray
{
    //先清空
    [_dataArray removeAllObjects];
    NSArray *array = _controller.fetchedObjects;
    
    for (LessonDownload *lesson in array) {
        //先搜索_dataArray中用courseId是否能搜索到dict
        BOOL CourseExist = NO;
        for (NSMutableDictionary *dict in _dataArray) {
            //如果相等
            if ([dict[@"courseId"] isEqualToString:lesson.courseId]) {
                NSMutableArray *lessonArr = dict[@"lessonArr"];
                [lessonArr addObject:lesson];
                CourseExist = YES;
                break;
            }
        }
        if (CourseExist == NO) {//如果不存在,则创建一个,并且加入dict
            NSMutableArray *lessonArr = [[NSMutableArray alloc]init];
            [lessonArr addObject:lesson];
            NSMutableDictionary *dict = [[NSMutableDictionary alloc]initWithObjectsAndKeys:
                                         lesson.courseId,@"courseId",
                                         lesson.courseName,@"courseName",
                                         lessonArr, @"lessonArr",nil];
            [_dataArray addObject:dict];
        }
    }
}

#pragma mark 当controller里面的结果集发生变化的时候,调用这个方法
- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath
{
    [self processDataArray];
    [_tableView reloadData];
}

#pragma mark tableview的协议方法
//设置表视图的编辑状态（插入、删除、选择）
-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete|UITableViewCellEditingStyleInsert;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [_dataArray[section] objectForKey:@"courseName"];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _dataArray.count;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[_dataArray[section]objectForKey:@"lessonArr"] count];
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc]init];
    view.backgroundColor = LIGHT_SETCOLOR;
    UILabel *titleLabel = [MyControl createLabelWithFrame:CGRectMake(20, 5, SCREEN_WIDTH, FONT_LARGE) Font:FONT_LARGE Text:nil];
    titleLabel.text = [_dataArray[section] objectForKey:@"courseName"];
    [view addSubview:titleLabel];
    
    UIImageView *imgv= [[UIImageView alloc]initWithFrame:CGRectMake(SCREEN_WIDTH - 30, 5, 15, 15)];
    imgv.image = [UIImage imageNamed:@"arrow.png"];
    [view addSubview:imgv];
    
    MyTapGuestureRecognizer *tap = [[MyTapGuestureRecognizer alloc]initWithTarget:self action:@selector(pushAction:)];
    [view addGestureRecognizer:tap];
    return view;
}

#pragma mark - push进入课程界面
-(void)pushAction:(MyTapGuestureRecognizer *)tap
{
    NSInteger section = tap.section;
    NSString *courseid = [_dataArray[section] objectForKey:@"courseId"];
    CourseViewController *vc = [[CourseViewController alloc]init];
    vc.courseId = courseid;
    [self.navigationController pushViewController:vc animated:YES];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" ];// forIndexPath:indexPath];
    //    LessonDownload *lesson = _dataArray[indexPath.section][1][indexPath.row];
    //    cell.textLabel.text = lesson.lessonName;
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"];
    }
    //LessonDownload *lesson = _controller.fetchedObjects[indexPath.row];
    LessonDownload *lesson = [_dataArray[indexPath.section] objectForKey:@"lessonArr"][indexPath.row];
    cell.textLabel.font = [UIFont systemFontOfSize:FONT_MIDDLE];
    cell.textLabel.text = [NSString stringWithFormat:@"[第%@集] %@",lesson.number,lesson.lessonName];
    CGFloat totalSize = [self transferFileSize:lesson.totalSize];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"              %0.2fM",totalSize];
    return cell;
}

//计算文件大小
-(CGFloat)transferFileSize:(NSNumber *)size
{
    return [size floatValue]/1024/1024;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //如果没在编辑状态,那么就能push视频出来
    if (tableView.isEditing == NO) {
        NSString *cachePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/CacheVideo"];
        LessonDownload *lesson = [_dataArray[indexPath.section] objectForKey:@"lessonArr"][indexPath.row];
        NSString *filePath = [cachePath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.mp4",lesson.vid]];
        MyMPViewController *player = [[MyMPViewController alloc]initWithContentURL:[NSURL fileURLWithPath:filePath]];
        [self presentMoviePlayerViewControllerAnimated:player];
    }
    else//如果在编辑状态(多选,或者取消选择)
    {
        LessonDownload *lesson = [_dataArray[indexPath.section] objectForKey:@"lessonArr"][indexPath.row];
        NSLog(@"添加入removeArr中");
        [_removeArray addObject:lesson];
    }
}

-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView.editing == YES) {
        LessonDownload *lesson = [_dataArray[indexPath.section] objectForKey:@"lessonArr"][indexPath.row];
        //LessonDownload *lesson = _controller.fetchedObjects[indexPath.row];
        NSLog(@"从removeArr中删除");
        [_removeArray removeObject:lesson];
        //删除的时候，将_btn改变为“全选”
        [_allSelectBtn setTitle:@"全选" forState:UIControlStateNormal];
        _isAllSelected = NO;
    }
}

@end
