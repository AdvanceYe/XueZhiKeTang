//
//  LessonListCell.m
//  公开课项目1
//
//  Created by AdvanceYe on 15/7/9.
//  Copyright (c) 2015年 AdvanceYe. All rights reserved.
//

#import "LessonListCell.h"

@implementation LessonListCell

- (void)awakeFromNib {
    // Initialization code
}

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        //self.backgroundColor = [UIColor yellowColor];
        self.textLabel.backgroundColor = [UIColor greenColor];
        self.textLabel.font = [UIFont systemFontOfSize:FONT_MIDDLE];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

}

@end
