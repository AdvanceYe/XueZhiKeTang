//
//  IntroductionViewController.m
//  公开课项目1
//
//  Created by qianfeng on 15/7/9.
//  Copyright (c) 2015年 qianfeng. All rights reserved.
//

#import "IntroductionViewController.h"
#warning 回头再看这个能否用XIB做,先用代码快速实现

@interface IntroductionViewController ()
{
    UIScrollView *_scrollView;
    UIImageView *_imgv;
    UILabel *_titleLabel;
    UILabel *_teacherLabel;
    UILabel *_schoolLabel;
    UILabel *_translatedLabel;
    UILabel *_descLabel;
}
@end

@implementation IntroductionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    //[self createUI];
    //[self loadData];
}

#warning UI大buG  搜索AA之后第一个会出问题 - title太大....要自动调整字体大小...
/*
 搜索AA之后第一个会出问题
courseurl=http://platform.sina.com.cn/opencourse/get_course?id=932&app_key=1919446470
lessonUrl=http://platform.sina.com.cn/opencourse/get_lessons?course_id=932&page=1&count_per_page=1000&app_key=1919446470
*/

-(void)createUI
{
    _scrollView = [[UIScrollView alloc]initWithFrame:self.view.frame];
    
    _imgv = [[UIImageView alloc]initWithFrame:CGRectMake(10, 10, 0.4 * SCREEN_WIDTH, 0.3 * SCREEN_WIDTH)];
    _scrollView.showsVerticalScrollIndicator = NO;
    [_scrollView addSubview:_imgv];
    
    //title Label
    _titleLabel = [MyControl createLabelWithFrame:CGRectMake(CGRectGetMaxX(_imgv.frame)+10, _imgv.frame.origin.y + 10, SCREEN_WIDTH - 10 - _imgv.frame.size.width - 10 - 10, 20) Font:FONT_MIDDLE Text:@""];
    _titleLabel.textColor = [UIColor blackColor];
    _titleLabel.numberOfLines = 0;
    _titleLabel.lineBreakMode = NSLineBreakByCharWrapping;
    [_scrollView addSubview:_titleLabel];
    
    //第三方库计算文本高度
    CGSize size = [Tool strSize:[self.courseModel name] withMaxSize:CGSizeMake(_titleLabel.frame.size.width, MAXFLOAT) withFont:[UIFont systemFontOfSize:FONT_MIDDLE] withLineBreakMode:NSLineBreakByCharWrapping];
    CGRect frame = _titleLabel.frame;
    frame.size.height = size.height;
    _titleLabel.frame = frame;
    
    //teacher Label
    _teacherLabel = [MyControl createLabelWithFrame:CGRectMake(_titleLabel.frame.origin.x, CGRectGetMaxY(_titleLabel.frame) + 6, SCREEN_WIDTH - 10 - _imgv.frame.size.width - 10, 15) Font:FONT_SMALL Text:@""];
    _teacherLabel.textColor = [UIColor blackColor];
    [_scrollView addSubview:_teacherLabel];
    
    //第三方库计算文本高度
    CGSize size1 = [Tool strSize:[NSString stringWithFormat:@"讲师: %@",[[self.courseModel teachers][0] objectForKey:@"name"]] withMaxSize:CGSizeMake(_teacherLabel.frame.size.width, MAXFLOAT) withFont:[UIFont systemFontOfSize:FONT_SMALL] withLineBreakMode:NSLineBreakByCharWrapping];
    CGRect frame1 = _teacherLabel.frame;
    frame1.size.height = size1.height;
    _teacherLabel.frame = frame1;
    
    //school Label
    _schoolLabel = [MyControl createLabelWithFrame:CGRectMake(_titleLabel.frame.origin.x, CGRectGetMaxY(_teacherLabel.frame), SCREEN_WIDTH - 10 - _imgv.frame.size.width - 10, 20) Font:FONT_SMALL Text:@""];
    _schoolLabel.textColor = [UIColor blackColor];
    [_scrollView addSubview:_schoolLabel];
    
    _translatedLabel = [MyControl createLabelWithFrame:CGRectMake(_imgv.frame.origin.x, CGRectGetMaxY(_imgv.frame) + 10, SCREEN_WIDTH - 10 - 10, 20) Font:FONT_SMALL Text:@""];
    //_translatedLabel.backgroundColor = [UIColor lightGrayColor];
    [_scrollView addSubview:_translatedLabel];
    
    _descLabel = [MyControl createLabelWithFrame:CGRectMake(_translatedLabel.frame.origin.x, CGRectGetMaxY(_translatedLabel.frame) + 10, SCREEN_WIDTH - 10 - 10, 100) Font:FONT_MIDDLE Text:@""];
    _descLabel.numberOfLines = 0;
    _descLabel.lineBreakMode = NSLineBreakByCharWrapping;
    [_scrollView addSubview:_descLabel];
    
    [self.view addSubview:_scrollView];
    //第三方库计算文本高度
    CGSize size2 = [Tool strSize:[self.courseModel brief] withMaxSize:CGSizeMake(_descLabel.frame.size.width, MAXFLOAT) withFont:[UIFont systemFontOfSize:FONT_MIDDLE] withLineBreakMode:NSLineBreakByCharWrapping];
    CGRect frame2 = _descLabel.frame;
    frame2.size.height = size2.height;
    _descLabel.frame = frame2;
    
    //自动计算fontsize,然后还需要设置contentSize
    _scrollView.contentSize = CGSizeMake(0, CGRectGetMaxY(_descLabel.frame) + 10);
}

-(void)loadData
{
    [self createUI];
    [_imgv setImageWithURL:[NSURL URLWithString:[self.courseModel picture]] placeholderImage:[UIImage imageNamed:PLACEHOLDERIMG]];
    _titleLabel.text = [self.courseModel name];
    
    _teacherLabel.text = [NSString stringWithFormat:@"讲师: %@",[[self.courseModel teachers][0] objectForKey:@"name"]];
    
    _schoolLabel.text = [NSString stringWithFormat:@"学校: %@",[self.courseModel school_name]];
    _translatedLabel.text = [NSString stringWithFormat:@"共: %ld节   已翻译: %ld节    播放: %@",(long)[self.courseModel lesson_count], (long)[self.courseModel translated_count],[self.courseModel total_click]];
    _descLabel.text = [NSString stringWithFormat:@"简介: %@",[self.courseModel brief]];
}

@end
