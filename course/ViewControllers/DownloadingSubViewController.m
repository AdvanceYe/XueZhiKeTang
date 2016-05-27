//
//  DownloadingSubViewController.m
//  公开课项目1
//
//  Created by AdvanceYe on 15/7/23.
//  Copyright (c) 2015年 AdvanceYe. All rights reserved.
//

#import "DownloadingSubViewController.h"
#import "CoreDataDownloadingManager.h"
#import "MyMPViewController.h"
#import "MyTableView.h"
#import "DownloadTableViewCell.h"
#import "CacheView.h"
#import "CacheViewManager.h"
#import "ActiveCacheModelManager.h"
#import "ASIDownloadManager.h"
#import "CourseViewController.h"
#import "MyTapGuestureRecognizer.h"

@interface DownloadingSubViewController ()<UITableViewDataSource,UITableViewDelegate,NSFetchedResultsControllerDelegate,UIAlertViewDelegate>
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
    
    //创建底部的控制request开始和结束的view和两个btn;
    CGFloat _bottomControlHeight;
    UIView *_bottomControlView;
    UIButton *_allStartBtn;
    UIButton *_allStopBtn;
    
    NSMutableArray *_removeArray;
    BOOL _isAllSelected;
    
    //是在下载还是暂停
    
}
@end

@implementation DownloadingSubViewController

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self prepareData];
    [_tableView reloadData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.translucent = NO;
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.view.backgroundColor = [UIColor whiteColor];
    _removeArray = [[NSMutableArray alloc]init];
    _dataArray = [[NSMutableArray alloc]init];
    
    [self createTB];
    [self prepareData];
    [self processDataArray];
    [_tableView reloadData];
    [self createBottomView];
    [self createControlView];
    [self.view addSubview:_bottomView];//controlView创建完再加上去
    
}

#pragma mark - 创建BottomView
-(void)createBottomView
{
    _bottomViewHeight = NAV_HEIGHT;
    _bottomView = [[UIView alloc]initWithFrame:CGRectMake(0, SCREEN_HEIGHT - NAV_HEIGHT - BAR_HEIGHT - TITLE_HEIGHT - _bottomViewHeight ,SCREEN_WIDTH , _bottomViewHeight)];
    _bottomView.backgroundColor = SET_COLOR;
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
    [_deleteBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    _deleteBtn.backgroundColor = LIGHT_SETCOLOR;
    [_deleteBtn addTarget:self action:@selector(deleteAction) forControlEvents:UIControlEventTouchUpInside];
    [_deleteBtn setTitle:@"删除" forState:UIControlStateNormal];
    [_bottomView addSubview:_deleteBtn];
}

#pragma mark - 全选动作
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
                                                     message:@"删除选中的正在下载内容"
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
        //将queue里面的停掉
        ASINetworkQueue *asiqueue = [[ASIDownloadManager sharedManager]asiQueue];
        NSArray *requestArr = [asiqueue operations];
        
        //删除已下载的暂存视频
        NSFileManager *fm=[NSFileManager defaultManager];
        NSString *webPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/TempVideo"];
        
        for (LessonDownload *lesson in _removeArray) {
            NSLog(@"lesson vid=%@",lesson.vid);
            NSString *filePath = [webPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.mp4",lesson.vid]];
            BOOL success = [fm removeItemAtPath:filePath error:nil];
            NSLog(@"%@删除暂存视频成功了?%d",lesson.vid,success);
            for (ASIHTTPRequest *request in requestArr) {
                NSDictionary *dict = request.userInfo;
                NSLog(@"dict vid =%@",[dict objectForKey:@"vid"]);
                if ([lesson.vid isEqualToString:[dict objectForKey:@"vid"]]) {
                    NSLog(@"vid = %@",lesson.vid);
                    [request cancel];
                    NSLog(@"删除成功");
                }
            }
        }
        
        //先删除数据库
        for (LessonDownload *lesson in _removeArray) {
            [[CoreDataDownloadingManager manager] deleteLesson:lesson];
        }
        
        //将cacheView中request停掉，并删除掉
        [[CacheViewManager sharedManager]deleteCacheViewsByLessonArray:_removeArray];
        
        //cachemodel中request停掉，并删除掉
        [[ActiveCacheModelManager sharedManager]deleteCacheModelByLessonArray:_removeArray];
        
        //提示删除成功
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

#pragma - 创建BottomControlView
-(void)createControlView
{
    _bottomControlHeight = NAV_HEIGHT;
    _bottomControlView = [[UIView alloc]initWithFrame:_bottomView.frame];
    _bottomControlView.backgroundColor = SET_COLOR;
    [self.view addSubview:_bottomControlView];
    
    //创建两个btn
    
    _allStartBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    _allStartBtn.frame = _allSelectBtn.frame;
    _allStartBtn.backgroundColor = LIGHT_SETCOLOR;
    [_allStartBtn addTarget:self action:@selector(allStartAction) forControlEvents:UIControlEventTouchUpInside];
    [_allStartBtn setTitle:@"全部开始" forState:UIControlStateNormal];
    [_allStartBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_bottomControlView addSubview:_allStartBtn];
    
    _allStopBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    _allStopBtn.frame = _deleteBtn.frame;
    _allStopBtn.backgroundColor = LIGHT_SETCOLOR;
    [_allStopBtn addTarget:self action:@selector(allStopAction) forControlEvents:UIControlEventTouchUpInside];
    [_allStopBtn setTitle:@"全部暂停" forState:UIControlStateNormal];
    [_allStopBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_bottomControlView addSubview:_allStopBtn];
}

#pragma mark - 全部开始动作
-(void)allStartAction
{
    NSLog(@"全部开始");
    //对于所有库里面的文件,得到vid和url,开启下载
    //-(ASIHTTPRequest *)beginDownload:(NSString *)vid andURL:(NSString *)url
    NSArray *arr = _controller.fetchedObjects;
    NSLog(@"count = %ld",arr.count);
    for (LessonDownload *lesson in arr) {
        if([lesson.downloadStatus integerValue] == 0)//如果是暂停的，执行以下操作
        {
            [self requestRestartAction:lesson];
        }
    }
    [_tableView reloadData];
}

#pragma mark - 重新启动任务时的操作
//重新启动的时候有BUG
-(void)requestRestartAction:(LessonDownload*)lesson
{
    ASIHTTPRequest *request = [[ASIDownloadManager sharedManager]beginDownload:lesson.vid andURL:lesson.ipad_url];
    //创建一个cacheView，存入数组
    LessonModel *model = [[LessonModel alloc]init];
    model.short_name = lesson.lessonName;
    model.number = lesson.number;
    model.ipad_url = lesson.ipad_url;
    model.vid = lesson.vid;
    model.index = [lesson.index integerValue];
    
    CGFloat widthSpace = 10;
    CGFloat width = (SCREEN_WIDTH - 3 * widthSpace) / 2.0;
    CGFloat heightSpace = 10;
    CGFloat height = TITLE_HEIGHT;
    
    CacheView *cacheView = [[CacheView alloc]initWithFrame:CGRectMake((widthSpace + width) * (model.index % 2) + widthSpace, (heightSpace + height) * (model.index / 2) + heightSpace, width, height) lessonModal:model andCourseId:lesson.courseId];
    cacheView.lessonDownloadModel = lesson;
    cacheView.request = request;
    request.delegate = cacheView;
    request.downloadProgressDelegate = cacheView;
    [[CacheViewManager sharedManager]addCacheView:cacheView];
    
    //然后更新数据库
    lesson.downloadStatus = @(1);
    [[CoreDataDownloadingManager manager]updateLesson:lesson];
}

#pragma mark - 取消任务时的操作
-(void)requestStopAction:(LessonDownload*)lesson
{
    //先储存progress值（都在cacheView里。。）
    CacheView *cacheView = [[CacheViewManager sharedManager]fetchCacheViewbyCourseId:lesson.courseId andVid:lesson.vid];
    
    //cachemodel
    ActiveCacheModel *cacheModel = [[ActiveCacheModelManager sharedManager]searchCacheModelByLesson:lesson];
    
    lesson.percentage = @(cacheView.progressView.progress);
    lesson.downloadStatus = @(0);//表示暂停
    [[CoreDataDownloadingManager manager]updateLesson:lesson];
    
    //将queue里面的request停掉
    [cacheView.request cancel];
    
    //将cacheView中request停掉，并删除掉
    [[CacheViewManager sharedManager]deleteCacheView:cacheView];
    
    //cachemodel中request停掉，并删除掉
    [[ActiveCacheModelManager sharedManager]deleteCacheModel:cacheModel];
}

#pragma mark - 全部停止动作
-(void)allStopAction
{
    NSLog(@"全部结束");
    
    //先储存progress值（都在cacheView里。。）
    NSArray *array = [[CacheViewManager sharedManager]fetchAllCacheView];
    //每个cacheView对应一个coreData,存值。
    for (CacheView *cacheView in array) {
        LessonDownload *lesson = [[CoreDataDownloadingManager manager]returnLessonByVid:cacheView.model.vid];
        lesson.percentage = @(cacheView.progressView.progress);
        lesson.downloadStatus = @(0);//表示暂停
        [[CoreDataDownloadingManager manager]updateLesson:lesson];
    }
    
    //将queue里面的停掉
    ASINetworkQueue *asiqueue = [[ASIDownloadManager sharedManager]asiQueue];
    NSArray *requestArr = [asiqueue operations];
    
    for (ASIHTTPRequest *request in requestArr) {
        [request cancel];
    }

    //将cacheView中request停掉，并删除掉
    [[CacheViewManager sharedManager]deleteAllCacheView];

    //cachemodel中request停掉，并删除掉
    [[ActiveCacheModelManager sharedManager]deleteAllCacheModel];
}

#pragma mark - 编辑状态引发的动作
-(void)editingAction
{
    [_tableView setEditing:!_tableView.editing animated:YES];
    
    //点击完成
    if (_isCompleted) {//编辑状态
        //[_btn setTitle:@"编辑" forState:UIControlStateNormal];
        _bottomView.hidden = YES;
        _tableView.isOnEditing = NO;
        
    }
    else//点击了编辑
    {
        //[_btn setTitle:@"完成" forState:UIControlStateNormal];
        _bottomView.hidden = NO;
        _tableView.isOnEditing = YES;
        
        //点击的时候取消全选
        if(_controller.fetchedObjects.count >0)
        {
            [_removeArray removeAllObjects];
            [_allSelectBtn setTitle:@"全选" forState:UIControlStateNormal];
            _isAllSelected = NO;
        }
    }
}

-(void)createTB
{
    _tableView = [[MyTableView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - NAV_HEIGHT - TITLE_HEIGHT - BAR_HEIGHT - NAV_HEIGHT)];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.backgroundColor = [UIColor whiteColor];
    _tableView.showsVerticalScrollIndicator = NO;
    _tableView.tableFooterView = [[UIView alloc]init];
    //_tableView.separatorColor = [UIColor darkGrayColor];
    [self.view addSubview:_tableView];
    //[_tableView registerClass:[DownloadTableViewCell class] forCellReuseIdentifier:@"cell"];
    
}

-(void)prepareData
{
    //获得数据
    //_dataArray = [NSMutableArray arrayWithArray:[[CoreDataDownloadManager manager]fetchLessonSortByCourseId]];
    
    //不用加谓词了
    _req = [[NSFetchRequest alloc]initWithEntityName:@"LessonDownload"];
    
    //已经用courseId排序了
    NSSortDescriptor *sd = [NSSortDescriptor sortDescriptorWithKey:@"courseId" ascending:YES];
    _req.sortDescriptors = @[sd];
    
    NSManagedObjectContext *context = [[CoreDataDownloadingManager manager]context];
    
    _controller = [[NSFetchedResultsController alloc]initWithFetchRequest:_req managedObjectContext:context sectionNameKeyPath:nil cacheName:nil];
    
    _controller.delegate = self;
    [_controller performFetch:nil];
}

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

//当controller里面的结果集发生变化的时候,调用这个方法
- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath
{
    [self processDataArray];
    //手动让另外一个也去load一下data
    //_callback();
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

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[_dataArray[section]objectForKey:@"lessonArr"] count];
    //return _controller.fetchedObjects.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DownloadTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];// forIndexPath:indexPath];
    if (!cell) {
        cell = [[DownloadTableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"];
    }
    [cell configureUI];
    LessonDownload *lesson = [_dataArray[indexPath.section] objectForKey:@"lessonArr"][indexPath.row];

    //获取cacheView
    CacheView *cacheView = [[CacheViewManager sharedManager]fetchCacheViewbyCourseId:lesson.courseId andVid:lesson.vid];
    cell.textLabel.text = [NSString stringWithFormat:@"[第%@集] %@",lesson.number,lesson.lessonName];
    
    //如果在cacheView中存在
    if(cacheView)
    {
        [cell showDownloadStatusLabel:YES];
    }
    else//如果不存在，要配置progressView的进度
    {
        [cell showDownloadStatusLabel:NO];
        //配置进度条
        CGFloat progress = [lesson.percentage floatValue];
        [cell configureProgress:progress];
    }
    //监听的东西有两个，cacheView上的一个东西，还有这边的一个东西
    //所以这边最好能去创建一个cacheView
    cacheView.downloadPageProgressView = cell.progressView;
    //cacheView.progressLabel = cell.detailTextLabel;
    cacheView.progressLabel = cell.nameLabel;

    cell.textLabel.text = [NSString stringWithFormat:@"[第%@集] %@",lesson.number,lesson.lessonName];
    CGFloat totalSize = [self transferFileSize:lesson.totalSize];
    CGFloat downloadedSize = totalSize * [lesson.percentage floatValue];
    cell.nameLabel.text = [NSString stringWithFormat:@"%0.2fM/%0.2fM",downloadedSize,totalSize];
    
    return cell;
}

//计算文件大小
-(CGFloat)transferFileSize:(NSNumber *)size
{
    return [size floatValue]/1024/1024;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [DownloadTableViewCell cellHeight];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //如果没在编辑状态,那么暂停，重启
    if (tableView.isEditing == NO) {
        LessonDownload *lesson = [_dataArray[indexPath.section] objectForKey:@"lessonArr"][indexPath.row];
        //LessonDownload *lesson = _controller.fetchedObjects[indexPath.row];
        if ([lesson.downloadStatus integerValue] == 0) {
            //那么开始启动
            [self requestRestartAction:lesson];
        }
        else if ([lesson.downloadStatus integerValue] == 1)
        {
            //那么暂停
            [self requestStopAction:lesson];
        }
    }
    else//如果在编辑状态(多选,或者取消选择)
    {
        LessonDownload *lesson = [_dataArray[indexPath.section] objectForKey:@"lessonArr"][indexPath.row];
        //LessonDownload *lesson = _controller.fetchedObjects[indexPath.row];
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

