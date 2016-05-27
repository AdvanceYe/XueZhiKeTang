//
//  CollectionViewController.h
//  公开课项目1
//
//  Created by qianfeng on 15/7/13.
//  Copyright (c) 2015年 qianfeng. All rights reserved.
//

#import "BaseViewController.h"
#import "MyTableView.h"
#import "CourseListCell.h"
#import "CoreDataCollectionManager.h"
#import "CourseModel.h"
#import "CourseViewController.h"
#import "CollectionCourse.h"

@interface CollectionViewController : BaseViewController


@property(strong,nonatomic) MyTableView *tableView;
@property(strong,nonatomic) NSFetchedResultsController *controller;
@property(strong,nonatomic) UIButton *btn;
    
@property(strong,nonatomic) NSMutableArray *removeArray;
@property(strong,nonatomic) NSMutableArray *selectIndexArr;
    
@property(assign,nonatomic) CGFloat bottomViewHeight;
@property(assign,nonatomic) BOOL isEditCompleted;//是否完成编辑
@property(assign,nonatomic) BOOL isAllSelected;
@property(assign,nonatomic) BOOL isHistoryVC;//是否是history.

@property(strong,nonatomic) UIView *bottomView;
@property(strong,nonatomic) UIButton *allSelectBtn;
@property(strong,nonatomic) UIButton *deleteBtn;
    
@property(assign,nonatomic) BOOL isLoadData;

@end
