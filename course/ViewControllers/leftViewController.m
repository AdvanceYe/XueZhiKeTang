//
//  leftViewController.m
//  公开课项目1
//
//  Created by AdvanceYe on 15/7/15.
//  Copyright (c) 2015年 AdvanceYe. All rights reserved.
//

#import "leftViewController.h"
#import "CollectionViewController.h"

@interface leftViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    UITableView *_tableView;
    NSArray *_titleArray;
    CGFloat _cellHeight;
    
    UISwitch *_switch;
}
@end

@implementation leftViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor clearColor];
    // 0 6,11,16可以 13太素 15 2换个颜色?
    UIImageView *imgv= [MyControl createImageViewFrame:self.view.bounds imageName:@"bg5.jpg"];
    [self.view addSubview:imgv];
    _titleArray = @[@"我的收藏",@"播放记录",@"我的下载",@"设置自动播放"];
    _cellHeight = 50;
    [self createTB];
}

-(void)createTB
{
    CGFloat width = SCREEN_WIDTH * 0.7;
    CGFloat height = _cellHeight;
    CGFloat space = (SCREEN_HEIGHT - height * _titleArray.count)/2.0;
    _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, space * 0.45, width, _cellHeight * _titleArray.count)];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_tableView];
    
    [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
}

#pragma mark - tableView协议
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _titleArray.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return _cellHeight;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    cell.backgroundColor = [UIColor clearColor];
    cell.textLabel.text = _titleArray[indexPath.row];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    //如果是3,再加一个switch
    if (indexPath.row == 3) {
        //不能选的
        _switch = [[UISwitch alloc]initWithFrame:CGRectMake(SCREEN_WIDTH * 0.7 - 100, 10, 80, cell.frame.size.height - 20)];
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [_switch setOn:[userDefaults boolForKey:@"isAutoPlay"] animated:YES];
        [userDefaults synchronize];
        [_switch addTarget:self action:@selector(autoPlayAction:) forControlEvents:UIControlEventValueChanged];
        _switch.onTintColor = SET_COLOR;
        _switch.tintColor = LIGHT_SETCOLOR;
        [cell addSubview:_switch];
    }
    //cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

//自动播放
-(void)autoPlayAction:(UISwitch *)sender
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:sender.isOn forKey:@"isAutoPlay"];
    [userDefaults synchronize];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSLog(@"BOOL:%d",_vcPushed);
    //_titleArray = @[@"我的收藏",@"播放记录",@"我的下载",@"设置自动播放",@"分享应用",];
    switch (indexPath.row) {
        case 0://我的收藏
        {
            if (_callBack0 && _vcPushed == NO) {
                _callBack0(self);
            }
        }
            break;
        case 1://播放记录
        {
            if (_callBack1) {
                _callBack1(self);
            }
        }
            break;
        case 2://我的下载
        {
            if (_callBack2) {
                _callBack2(self);
            }
        }
            break;
        case 3://设置自动播放
        {
        }
            break;
        case 4://分享应用
        {
        }
            break;
        default:
            break;
    }
}

@end
