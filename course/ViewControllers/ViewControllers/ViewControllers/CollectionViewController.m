//
//  CollectionViewController.m
//  公开课项目1
//
//  Created by qianfeng on 15/7/13.
//  Copyright (c) 2015年 qianfeng. All rights reserved.

#import "CollectionViewController.h"
#import "CourseListCell.h"
#import "CoreDataCollectionManager.h"
#import "CoreDataHistoryManager.h"
#import "CourseModel.h"
#import "CourseViewController.h"
#import "MyTableView.h"
#import "CollectionCourse.h"

@interface CollectionViewController ()<UITableViewDelegate,UITableViewDataSource,NSFetchedResultsControllerDelegate>
{
    MyTableView *_tableView;
    NSFetchedResultsController *_controller;
    UIButton *_btn;
    
    NSMutableArray *_removeArray;
    NSMutableArray *_selectIndexArr;
    
    CGFloat _bottomViewHeight;
    BOOL _isEditCompleted;//是否完成编辑
    BOOL _isAllSelected;
    UIView *_bottomView;
    UIButton *_allSelectBtn;
    UIButton *_deleteBtn;
    
    BOOL _isLoadData;
}

@end

@implementation CollectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _removeArray = [[NSMutableArray alloc]init];
    _selectIndexArr = [[NSMutableArray alloc]init];
    
    _btn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    _btn.frame = CGRectMake(0, 0, 80, 40);
    _btn.backgroundColor = [UIColor orangeColor];
    [_btn addTarget:self action:@selector(editingAction) forControlEvents:UIControlEventTouchUpInside];
    [_btn setTitle:@"编辑" forState:UIControlStateNormal];
    
    UIBarButtonItem *rightBarBtn = [[UIBarButtonItem alloc]initWithCustomView:_btn];
    
    self.navigationItem.rightBarButtonItem = rightBarBtn;
    //设置其为editButton
    //rightBarBtn = self.editButtonItem;
    
    [self createTableView];
    [self createBottomView];
    [self prepareData];
    [_tableView reloadData];
}

#pragma mark - 多选删除
//创建BottomView
-(void)createBottomView
{
    _bottomViewHeight = NAV_HEIGHT;
    _bottomView = [[UIView alloc]initWithFrame:CGRectMake(0, SCREEN_HEIGHT - NAV_HEIGHT - BAR_HEIGHT - _bottomViewHeight ,SCREEN_WIDTH , _bottomViewHeight)];
    _bottomView.backgroundColor = [UIColor orangeColor];
    [self.view addSubview:_bottomView];
    _bottomView.hidden = YES;
    
    //创建两个btn
    CGFloat btnWid = SCREEN_WIDTH * 0.6 / 2;
    CGFloat btnSpace = SCREEN_WIDTH * 0.4 / 5;
    CGFloat btnHeight = _bottomViewHeight - 10;
    
    _allSelectBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    _allSelectBtn.frame = CGRectMake(2 * btnSpace, 5, btnWid, btnHeight);
    _allSelectBtn.backgroundColor = [UIColor yellowColor];
    [_allSelectBtn addTarget:self action:@selector(allSelectAction) forControlEvents:UIControlEventTouchUpInside];
    [_allSelectBtn setTitle:@"全选" forState:UIControlStateNormal];
    [_bottomView addSubview:_allSelectBtn];
    
    _deleteBtn= [UIButton buttonWithType:UIButtonTypeRoundedRect];
    _deleteBtn.frame = CGRectMake(3 * btnSpace + btnWid, 5, btnWid, btnHeight);
    _deleteBtn.backgroundColor = [UIColor greenColor];
    [_deleteBtn addTarget:self action:@selector(deleteAction) forControlEvents:UIControlEventTouchUpInside];
    [_deleteBtn setTitle:@"删除" forState:UIControlStateNormal];
    [_bottomView addSubview:_deleteBtn];
}


#pragma mark - 编辑/完成模式
-(void)editingAction
{
    //如果已经完成了编辑
    if (_isEditCompleted) {//编辑状态
        [_btn setTitle:@"编辑" forState:UIControlStateNormal];
        _bottomView.hidden = YES;
        _isEditCompleted = NO;
        _tableView.isOnEditing = NO;
        [_tableView reloadData];
        
        //修改tableView的高度
        CGRect frame = _tableView.frame;
        frame.size.height = frame.size.height + _bottomViewHeight;
        _tableView.frame = frame;
        
    }
    else
    {
        [_btn setTitle:@"完成" forState:UIControlStateNormal];
        _bottomView.hidden = NO;
        _isEditCompleted = YES;
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
            for (CollectionCourse *course in _controller.fetchedObjects) {
                course.isSelected = @(0);
                if (_isHistoryVC) {
                    [[CoreDataHistoryManager manager]updateCourse:course];
                }
                else
                {
                    [[CoreDataCollectionManager manager]updateCourse:course];
                }
                
            }
            [_removeArray removeAllObjects];
            [_allSelectBtn setTitle:@"全选" forState:UIControlStateNormal];
            _isAllSelected = NO;
        }
    }
}

//从数据库获取数据
-(void)prepareData
{
    NSFetchRequest *req = [[NSFetchRequest alloc]initWithEntityName:@"CollectionCourse"];
    NSSortDescriptor *sd = [NSSortDescriptor sortDescriptorWithKey:@"updateDate" ascending:NO];
    req.sortDescriptors = @[sd];
    NSManagedObjectContext *context;
    if (_isHistoryVC) {
        context = [[CoreDataHistoryManager manager]context];
    }
    else
    {
        context = [[CoreDataCollectionManager manager]context];
    }
    
#warning - 大BUG，fatal bug....断网情况下这句话会报错。。(好像后来没报过错?)
        _controller = [[NSFetchedResultsController alloc]initWithFetchRequest:req managedObjectContext:context sectionNameKeyPath:nil cacheName:nil];
        _controller.delegate = self;
        [_controller performFetch:nil];
}

//监听,当controller里面的结果集发生变化的时候,调用这个方法
- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath
{
    if (![_removeArray isEqualToArray:_controller.fetchedObjects]) {
        [_allSelectBtn setTitle:@"全选" forState:UIControlStateNormal];
        _isAllSelected = NO;
    }
    [_tableView reloadData];
}

-(void)createTableView
{
    self.navigationController.navigationBar.translucent = NO;
    self.automaticallyAdjustsScrollViewInsets = NO;
    _tableView = [[MyTableView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - NAV_HEIGHT - BAR_HEIGHT)];
    _tableView.backgroundColor = [UIColor whiteColor];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.tableFooterView = [[UIView alloc]init];
    [self.view addSubview:_tableView];
    [_tableView registerClass:[CourseListCell class] forCellReuseIdentifier:@"cell"];
    self.tableView = _tableView;
}

#pragma mark - tableview协议
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _controller.fetchedObjects.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CourseListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    CollectionCourse *course = _controller.fetchedObjects[indexPath.row];
    if (_isHistoryVC) {
        [cell configHistoryUI:course];
    }
    else
    {
        [cell configCollectionUI:course];
    }
    //如果tableview在编辑状态,showgray
    if (_tableView.isOnEditing) {
        if ([course.isSelected integerValue] == 0) {
            [cell addGrayImg];
        }
        else{
            [cell addColorImg];
        }
    }
    else
    {
        [cell removeMarkImg];
    }
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [CourseModel cellHeight];
}

#pragma 删除按钮
-(void)deleteAction
{
    //如果表视图处于编辑状态，并且有选中某些行时，将删除数组中的数据从数据源数组中删除，然后刷新数据
    if(_tableView.isOnEditing){
        if(_removeArray.count>0){
            NSLog(@"removeAction");
            if (_isHistoryVC) {
                [[CoreDataHistoryManager manager]deleteCourses:_removeArray];
            }
            else
            {
                [[CoreDataCollectionManager manager]deleteCourses:_removeArray];
            }
        }
    }
}

#pragma 全选按钮
-(void)allSelectAction
{
    //数据库里面course数量大于0才这样做
    if (_controller.fetchedObjects.count >0) {
        if (_isAllSelected == NO) {//是否全选
            for (CollectionCourse *course in _controller.fetchedObjects) {
                course.isSelected = @(1);
                if (_isHistoryVC) {
                    [[CoreDataHistoryManager manager]updateCourse:course];
                }
                else
                {
                    [[CoreDataCollectionManager manager]updateCourse:course];
                }
                
            }
            _removeArray = [NSMutableArray arrayWithArray:_controller.fetchedObjects];
            [_allSelectBtn setTitle:@"取消全选" forState:UIControlStateNormal];
            _isAllSelected = YES;
        }
        else{
            for (CollectionCourse *course in _controller.fetchedObjects) {
                course.isSelected = @(0);
                if (_isHistoryVC) {
                    [[CoreDataHistoryManager manager]updateCourse:course];
                }
                else
                {
                    [[CoreDataCollectionManager manager]updateCourse:course];
                }
                
            }
            [_removeArray removeAllObjects];
            [_allSelectBtn setTitle:@"全选" forState:UIControlStateNormal];
            _isAllSelected = NO;
        }
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_tableView.isOnEditing == YES) {
        NSLog(@"tB onEditing");
        //如果是在编辑状态下,修改model的状态,并存入数据库
        CollectionCourse *course = _controller.fetchedObjects[indexPath.row];
        if([course.isSelected integerValue] == 0)
        {
            course.isSelected = @(1);
            [_removeArray addObject:course];
        }
        else
        {
            course.isSelected = @(0);
            [_removeArray removeObject:course];
        }
        if (_isHistoryVC) {
            [[CoreDataHistoryManager manager]updateCourse:course];
        }
        else
        {
            [[CoreDataCollectionManager manager]updateCourse:course];
        }
        
        //刷新
        [_tableView reloadData];
        [tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
        
    }
    else
    {
        //如果不在编辑状态
        //先去选择
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
        //进入course页面
        CollectionCourse *model = _controller.fetchedObjects[indexPath.row];
        CourseViewController *vc = [[CourseViewController alloc]init];
        vc.courseId = model.d_id;
        //将集数和播放时间传过去
        NSLog(@"model.currentPlayRow integerValue: %d",[model.currentPlayRow integerValue]);
        NSLog(@"model.time floatValue: %f",[model.time floatValue]);
        NSLog(@"BOOL = %d",!([model.currentPlayRow integerValue] == 0 && [model.time floatValue] == 0));
        if (!([model.currentPlayRow integerValue] == 0 && [model.time floatValue] == 0)) {
            vc.currentPlayRow = [model.currentPlayRow integerValue];
            vc.initialTime = [model.time floatValue];
            vc.isPlayTimeArchive = YES;
            NSLog(@"%@",vc.courseId);
        }
    
        [self.navigationController pushViewController:vc animated:YES];

        NSLog(@"tb not onEditing..");
    }
}


@end
