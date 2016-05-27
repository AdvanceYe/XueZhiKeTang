//
//  leftViewController.m
//  公开课项目1
//
//  Created by qianfeng on 15/7/15.
//  Copyright (c) 2015年 qianfeng. All rights reserved.
//

#import "leftViewController.h"
#import "CollectionViewController.h"

@interface leftViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    UITableView *_tableView;
    NSArray *_titleArray;
    CGFloat _cellHeight;
}
@end

@implementation leftViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor clearColor];
    UIImageView *imgv= [MyControl createImageViewFrame:self.view.bounds imageName:@"Default3@2x.png"];
    [self.view addSubview:imgv];
    _titleArray = @[@"我的收藏",@"播放记录",@"我的下载",@"设置自动播放",@"分享应用",];
    _cellHeight = 60;
    [self createTB];
}

-(void)createTB
{
    CGFloat width = SCREEN_WIDTH * 0.7;
    CGFloat height = _cellHeight;
    CGFloat space = (SCREEN_HEIGHT - height * _titleArray.count)/2.0;
    _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, space * 0.8, width, _cellHeight * _titleArray.count)];
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
    //cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
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
            if (_callBack3) {
                _callBack3(self);
            }
        }
        case 4://分享应用
        {
            if (_callBack4) {
                _callBack4(self);
            }
        }
            break;
        default:
            break;
    }
}

@end
