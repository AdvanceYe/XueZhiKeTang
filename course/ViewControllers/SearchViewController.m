//
//  SearchViewController.m
//  公开课项目1
//
//  Created by AdvanceYe on 15/7/11.
//  Copyright (c) 2015年 AdvanceYe. All rights reserved.
//

#import "SearchViewController.h"
#import "CourseListCell.h"
#import "CourseViewController.h"
#import "ClearBtnCell.h"

@interface SearchViewController ()<UISearchBarDelegate,UITableViewDataSource,UITableViewDelegate>
{
    UISearchBar *_searchBar;
    CGFloat _sBarHeight;
    NSMutableArray *_resultArray;
    NSMutableArray *_searchHistoryArray;
    UITableView *_tableView;
    NSInteger _resultNumber;
    BOOL _isResult;
    
    UIView *_coverView;
}
/*
 搜索的时候,按下return,一方面把text放进userDefault里面(或者放进数据库里面);另一方面提交数据,load数据,并分析结果,如果搜索结果>0,则刷新界面,cell用字定义的那种结果.如果没搜索到结果,则放个view上去.
 becomefirstResponder且内容为空的时候,刷新界面,显示历史搜索内容.使用defaultcell."cellHistory",而且设置点击了之后可以完成事件.(能push到课程详情页)
 */

@end

@implementation SearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"搜索";
    self.view.backgroundColor = [UIColor orangeColor];
    
    self.urlStr = @"http://platform.sina.com.cn/opencourse/get_courses?";
    _resultArray = [[NSMutableArray alloc]init];
    self.pageNumber = 1;
    _sBarHeight = NAV_HEIGHT;

    [self createLeftBarBtn];
    [self createSearchBar];
    [self createTableView];
    [self addCoverView];
    [self createRefresh];
    //一开始就刷新一下界面
    [self getHistory];
    [_tableView reloadData];
    
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

-(void)addCoverView
{
#warning 本页有些bug,firstResponder的时候,不能显示搜索记录
    if (!_coverView) {
        _coverView = [[UIView alloc]initWithFrame:_tableView.frame];
        _coverView.backgroundColor = [UIColor whiteColor];
    }
    [self.view addSubview:_coverView];
}

-(void)removeCoverView
{
    [_coverView removeFromSuperview];
}

-(void)createSearchBar
{
    /*
     //搜索”统计”:
     http://platform.sina.com.cn/opencourse/get_courses?q=%E7%BB%9F%E8%AE%A1&page=1&count_per_page=20&app_key=1919446470
     //可以的
     http://platform.sina.com.cn/opencourse/get_courses?q=%E7%BB%9F%E8%AE%A1&page=1&count_per_page=20&app_key=1919446470
     */
    
    _searchBar = [[UISearchBar alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, NAV_HEIGHT)];
    _searchBar.searchBarStyle = UISearchBarStyleProminent;
    //_searchBar.showsCancelButton = YES;
    //_searchBar.showsSearchResultsButton = YES;
    _searchBar.placeholder = @"搜索您感兴趣的课程";
    _searchBar.delegate = self;
    //_searchBar.returnKeyType = UIReturnKeySearch;
    [self.view addSubview:_searchBar];

}

-(void)createTableView
{
    _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(_searchBar.frame), SCREEN_WIDTH, SCREEN_HEIGHT - NAV_HEIGHT - BAR_HEIGHT - CGRectGetMaxY(_searchBar.frame))];
    _tableView.backgroundColor = [UIColor whiteColor];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.tableFooterView = [[UIView alloc]init];
    [self.view addSubview:_tableView];
    [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"historyCell"];
    [_tableView registerClass:[CourseListCell class] forCellReuseIdentifier:@"resultCell"];
    [_tableView registerNib:[UINib nibWithNibName:@"ClearBtnCell" bundle:nil] forCellReuseIdentifier:@"clearCell"];
    self.tableView = _tableView;
}

#pragma mark - searchBar协议
//按下搜索键
// 搜索的时候,按下return,一方面把text放进userDefault里面(或者放进数据库里面);另一方面提交数据,load数据,并分析结果,如果搜索结果>0,则刷新界面,cell用字定义的那种结果.如果没搜索到结果,则放个view上去.
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self searchAction];
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    [self getHistory];
    //如果数量大于0,则显示
    if (_searchHistoryArray.count > 0) {
        [self removeCoverView];
    }
    return YES;
}

-(void)searchAction
{
    [self removeCoverView];
    [_searchBar resignFirstResponder];
    self.isLoadData = NO;
    _isResult = YES;
    NSLog(@"search..");
    
    self.pageNumber = 1;
    
    //清空_resultArray
    [_resultArray removeAllObjects];
    [self showhudView];
    [self checkNetWorkStatus];
    
    //并且使用userDefault,存入历史
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray *historyArr = [NSMutableArray arrayWithArray:[userDefaults objectForKey:@"history"]];
    if (historyArr == nil) {
        historyArr = [[NSMutableArray alloc]init];
    }
    else
    {
        //去除数组中相同的文字
        [historyArr removeObject:_searchBar.text];
    }
    //将新的搜索词插入第0行
    [historyArr insertObject:_searchBar.text atIndex:0];
    [userDefaults setObject:historyArr forKey:@"history"];
    [userDefaults synchronize];
}

//内容修改的话，如果清空了，刷新页面
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if([_searchBar.text isEqualToString:@""])
    {
        _searchBar.text = @"";
        [_searchBar resignFirstResponder];
        _isResult = NO;
        
        //获取historyArr
        [self getHistory];
        [_tableView reloadData];
    }
}

//获取history
-(void)getHistory
{
    [_searchHistoryArray removeAllObjects];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray *historyArr = [NSMutableArray arrayWithArray:[userDefaults objectForKey:@"history"]];
    _searchHistoryArray = [historyArr mutableCopy];
}

//取消搜索
//becomefirstResponder且内容为空的时候,刷新界面,显示历史搜索内容.使用defaultcell."cellHistory",而且设置点击了之后可以完成事件.(能push到课程详情页)
-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    _searchBar.text = @"";
    [_searchBar resignFirstResponder];
    _isResult = NO;
    [self getHistory];
    [_tableView reloadData];
}

#pragma mark - 处理搜索数据
-(void)loadData
{
    //这个是指示器 类似系统菊花
    JGProgressHUD *hud = [[JGProgressHUD alloc] initWithStyle:JGProgressHUDStyleDark];
    hud.textLabel.text = @"正在加载...";
    [hud showInView:self.hudView animated:YES];
    
    /*
     //搜索”统计”:
     http://platform.sina.com.cn/opencourse/get_courses?q=%E7%BB%9F%E8%AE%A1&page=1&count_per_page=20&app_key=1919446470
     */
    
    NSDictionary *parameter = @{
                  @"q":_searchBar.text,
                  @"page":[NSString stringWithFormat:@"%ld",self.pageNumber],
                  @"count_per_page":@"20",
                  @"app_key":@"1919446470",
                  };
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    [manager GET:self.urlStr parameters:parameter success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        id jsonData = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        
        if (self.isRefresh == NO) {
            [_resultArray removeAllObjects];
        }
        if([jsonData isKindOfClass:[NSArray class]])
        {
            NSLog(@"是array");
        }
        else if([jsonData isKindOfClass:[NSDictionary class]])
        {
            NSMutableArray *arr = [[NSMutableArray alloc]init];
            arr = [[[jsonData objectForKey:@"result"]objectForKey:@"data"]objectForKey:@"courses"];
            for (NSDictionary *d in arr) {
                CourseModel *model = [[CourseModel alloc]init];
                [model setValuesForKeysWithDictionary:d];
                [_resultArray addObject:model];
            }
            [_tableView reloadData];
            self.isLoadData = YES;
            [hud dismissAnimated:YES];
            if (self.hudView) {
                [UIView animateWithDuration:0.5 animations:^{
                    self.hudView.alpha = 0;
                }completion:^(BOOL finished) {
                    [self.hudView removeFromSuperview];
                    self.hudView = nil;
                }];
            }
            //这里我们结束刷新
            [self.footer endRefreshing];
            [self.header endRefreshing];
            
            //解析搜索结果的个数
            _resultNumber = [[[[jsonData objectForKey:@"result"]objectForKey:@"data"]objectForKey:@"total"] intValue];
        }
        else
        {
            NSLog(@"啥都不是");
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"解析失败");
    }];
    
    
}

#pragma mark - tableview协议
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (!_isResult) {
        return _searchHistoryArray.count + 1;
    }
    return _resultArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!_isResult) {
        UITableViewCell *cell;
        if (indexPath.row < _searchHistoryArray.count) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"historyCell" forIndexPath:indexPath];
            cell.textLabel.text = _searchHistoryArray[indexPath.row];
        }
        else
        {
            cell = [tableView dequeueReusableCellWithIdentifier:@"clearCell" forIndexPath:indexPath];
            //cell.textLabel.text = @"清空搜索记录";
        }
        return cell;
    }
    else
    {
        CourseListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"resultCell" forIndexPath:indexPath];
        [cell configUI:_resultArray[indexPath.row]];
        return cell;
    }
    
}
-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (!_isResult) {
        return @"历史搜索记录";
    }
    return [NSString stringWithFormat:@"共找到%ld个相关课程",_resultNumber];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!_isResult) {
        return 40;
    }
    else
    {
        return [CourseModel cellHeight];
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (_isResult == YES) {
        CourseModel *model = _resultArray[indexPath.row];
        CourseViewController *vc = [[CourseViewController alloc]init];
        vc.courseId = model.d_id;
        NSLog(@"%@",vc.courseId);
        [self.navigationController pushViewController:vc animated:YES];
    }
    else//开始搜索
    {
        if(indexPath.row < _searchHistoryArray.count)
        {
            _searchBar.text = _searchHistoryArray[indexPath.row];
            [self searchAction];
        }
        else //清空历史记录
        {
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            NSMutableArray *historyArr = [[NSMutableArray alloc]init];
            [userDefaults setObject:historyArr forKey:@"history"];
            [userDefaults synchronize];
            [self addCoverView];
//            //获取historyArr
//            [self getHistory];
//            [_tableView reloadData];
        }
    }
}

#pragma mark - 析构函数
- (void)dealloc
{
    [self.header free];
    [self.footer free];
}

@end
