//
//  ScrollCell.m
//  公开课项目1
//
//  Created by AdvanceYe on 15/7/7.
//  Copyright (c) 2015年 AdvanceYe. All rights reserved.
//

#import "ScrollCell.h"
#import "ScrollModel.h"
#import "MyView.h"

@implementation ScrollCell
{
    UIScrollView *_scrollView;
    UIPageControl *_pageControl;
    UIView *_pageControlView;
    NSTimer *_timer;
}
- (void)awakeFromNib {
    // Initialization code
}

//重写cell的初始化
-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.contentView.backgroundColor = [UIColor yellowColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        _cellHeight = [ScrollModel cellHeight];

        [self makeCellUI];
        [self autoSwitch];
    }
    return self;
}

-(void)makeCellUI
{
    //添加scrollView
    _scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, _cellHeight)];
    _scrollView.pagingEnabled = YES;
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.backgroundColor = [UIColor whiteColor];
    _scrollView.bounces = NO;
    _scrollView.delegate = self;//监听事件
    [self.contentView addSubview:_scrollView];

}

//事先处理一下arr
-(void)processArr
{
    if (_dataArray.count > 0) {
        id firstObj = _dataArray[0];
        id lastObj = _dataArray[_dataArray.count - 1];
        //原最后一个插入第一个的位置
        [_dataArray insertObject:lastObj atIndex:0];
        //原第一个插入最后一个的位置
        [_dataArray addObject:firstObj];
    }
    NSLog(@"dataArray个数:%ld",_dataArray.count);
}

-(void)configureUI
{
    [self processArr];
    //配置scrollView
    for (int i = 0; i < _dataArray.count; i++) {
        ScrollModel* model = (ScrollModel *)_dataArray[i];
        UIImageView *imgv = [[UIImageView alloc]initWithFrame:_scrollView.frame];
        //图片还需要做剪切
        imgv.frame = CGRectMake(SCREEN_WIDTH * i, 0, SCREEN_WIDTH, _scrollView.frame.size.height);
#warning 找一张图片
        [imgv setImageWithURL:[NSURL URLWithString:[model img_ext] ] placeholderImage:[UIImage imageNamed:PLACEHOLDERIMG]];
        imgv.clipsToBounds = YES;
        imgv.contentMode = UIViewContentModeScaleAspectFill;
        //UIViewContentModeScaleToFill:图片被拉伸（比例可能会变化），充满整个imageView
        //UIViewContentModeScaleAspectFill：图片被拉伸（比例不变），图片的小边充满整个imageview，图片会超出imageView
        //UIViewContentModeScaleAspectFit:图片被拉伸（比例不变），图片的长边充满整个imageView，图片不会超出imageView
       
        imgv.userInteractionEnabled = YES;
        [_scrollView addSubview:imgv];
        //NSLog(@"IMG = %@",[model img_ext]);
        
        //加一个黑色的渐变条
        CGFloat gradientHeight = imgv.bounds.size.height * 0.4;
        MyView *gradientBg = [[MyView alloc]initWithFrame:CGRectMake(0, imgv.bounds.size.height - gradientHeight, SCREEN_WIDTH, gradientHeight)];
        [imgv addSubview:gradientBg];
        
        //加两个label
        UILabel *shortTitleLabel = [MyControl createLabelWithFrame:CGRectMake(8, _cellHeight - 40, SCREEN_WIDTH - 100, 12) Font:FONT_SMALL Text:[model img_short_desc]];
        shortTitleLabel.textColor = [UIColor whiteColor];
        shortTitleLabel.numberOfLines = 1;
        shortTitleLabel.lineBreakMode=NSLineBreakByTruncatingTail;
        shortTitleLabel.backgroundColor = SET_COLOR;
        shortTitleLabel.layer.cornerRadius =5;
        shortTitleLabel.layer.masksToBounds = YES;
        [shortTitleLabel sizeToFit];
        [imgv addSubview:shortTitleLabel];
        
        UILabel *titleLabel = [MyControl createLabelWithFrame:CGRectMake(8, CGRectGetMaxY(shortTitleLabel.frame)+2, SCREEN_WIDTH - 100, 20) Font:FONT_LARGE Text:[model title]];
        titleLabel.textColor = [UIColor whiteColor];
        titleLabel.numberOfLines = 1;
        titleLabel.font=[UIFont boldSystemFontOfSize:FONT_LARGE];
        titleLabel.lineBreakMode=NSLineBreakByTruncatingTail;
        [imgv addSubview:titleLabel];
        
        //添加手势
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapAction)];
        [imgv addGestureRecognizer:tap];
    }
    
    _scrollView.contentSize = CGSizeMake(_dataArray.count * SCREEN_WIDTH, 0);
    //让scrollView一开始正向偏移scrollView的宽度大小
    _scrollView.contentOffset = CGPointMake(SCREEN_WIDTH, 0);
    
    //配置pageControl
    //在pageControl下面放个透明的UIView
    _pageControlView = [[UIView alloc]initWithFrame:CGRectMake(SCREEN_WIDTH - 120, _cellHeight - 30, 120, 30)];
    _pageControlView.backgroundColor = [UIColor clearColor];
    [self.contentView addSubview:_pageControlView];
    
    _pageControl = [[UIPageControl alloc]init];
    //_pageControl.frame = CGRectMake(SCREEN_WIDTH - 80, _cellHeight - 30, 80, 30);
    //_pageControl.center = CGPointMake(SCREEN_WIDTH-60, _cellHeight - 15);
    _pageControl.frame = _pageControlView.bounds;
    _pageControl.pageIndicatorTintColor = SET_COLOR;
    _pageControl.currentPageIndicatorTintColor = [UIColor whiteColor];
    [_pageControlView addSubview:_pageControl];
    
    _pageControl.numberOfPages = _dataArray.count - 2;
    //设置初始显示第二张图片
    _pageControl.currentPage = 0;
    //添加一个pageControl的监听事件?
    [_pageControl addTarget:self action:@selector(changePage:) forControlEvents:UIControlEventValueChanged];
}

#pragma mark - 设置timer
-(void)startTimer
{
    [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSDefaultRunLoopMode];
}

-(void)autoSwitch
{
    _timer = [NSTimer timerWithTimeInterval:6.0 target:self selector:@selector(changeAction) userInfo:nil repeats:YES];
}

-(void)changeAction
{
    //NSLog(@"啊");
    //判断
    int index = _scrollView.contentOffset.x/SCREEN_WIDTH;
    index ++;
    CGPoint pt = _scrollView.contentOffset;
    pt.x += SCREEN_WIDTH;
    [UIView animateWithDuration:0.36 animations:^{
        _scrollView.contentOffset = pt;
    }completion:^(BOOL finished) {
        _pageControl.currentPage = index - 1;
        
        //当显示最后一张图片时瞬间切换下标为1的图片
        if(index == _dataArray.count - 1){
            [_scrollView setContentOffset:CGPointMake(SCREEN_WIDTH, 0)];
            _pageControl.currentPage=0;
        }
        else if(index == 0){
            [_scrollView setContentOffset:CGPointMake((_dataArray.count - 2) * SCREEN_WIDTH, 0)];
            _pageControl.currentPage = _dataArray.count - 2;
        }
    }];
}

#pragma mark - 点击的时候,进入courseVC页面
-(void)tapAction
{
    NSInteger index = _scrollView.contentOffset.x/SCREEN_WIDTH;
    if (_callback) {
        _callback(_dataArray[index]);
    }
}
//改变pageControl执行此方法
-(void)changePage:(UIPageControl *)sender
{
    //获取pageControl的当前页码
    NSUInteger page = sender.currentPage;
    //设置内容偏移到pageControl当前页码对应的视图
    [_scrollView setContentOffset:CGPointMake((page + 1)*SCREEN_WIDTH, 0) animated:YES];
}

#pragma mark -scrollView协议方法
//如果pageEnabled为yes，一定会调用这个方法
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    //scrollView.contentOffset获取内容偏移量
    CGPoint pt = scrollView.contentOffset;
    //计算出内容属于第几页（从0开始）
    int index = pt.x/SCREEN_WIDTH;

    _pageControl.currentPage = index - 1;

    //当显示最后一张图片时瞬间切换下标为1的图片
    if(index == _dataArray.count - 1){
        [_scrollView setContentOffset:CGPointMake(SCREEN_WIDTH, 0)];
        _pageControl.currentPage=0;
    }
    else if(index == 0){
        [_scrollView setContentOffset:CGPointMake((_dataArray.count - 2) * SCREEN_WIDTH, 0)];
        _pageControl.currentPage = _dataArray.count - 2;
    }
}

@end
