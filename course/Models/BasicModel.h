//
//  BasicModel.h
//  公开课项目1
//
//  Created by AdvanceYe on 15/7/7.
//  Copyright (c) 2015年 AdvanceYe. All rights reserved.
//

#import <Foundation/Foundation.h>
#define proStr(str) @property(copy,nonatomic)NSString* str
#define proArr(arr) @property(strong,nonatomic)NSMutableArray* arr
#define proDict(dict) @property(strong,nonatomic)NSMutableDictionary* dict

@interface BasicModel : NSObject

//这里设定行高?还是设定cellType?
//@property(assign,nonatomic)NSInteger cellType;

@end
