//
//  AGLabelCell.m
//  AGCustomPageControllerView
//
//  Created by yang_0921 on 2016/12/9.
//  Copyright © 2016年 yang_0921. All rights reserved.
//

#import "AGLabelCell.h"

@interface AGLabelCell ()

@property (nonatomic, strong) UILabel *label;

@end

@implementation AGLabelCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {

        self.backgroundColor = [UIColor whiteColor];
        [self setupBaseUI];
    }
    return self;
}

- (void)setupBaseUI {

    [self.contentView addSubview:self.label];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.label.frame = self.contentView.bounds;
}

- (void)setTitle:(NSString *)title {
    _title = title;
    self.label.text = title;
}

/** 设置选中状态的样式 */
- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    if (selected) {
        self.label.textColor = [UIColor redColor];
    } else {
        self.label.textColor = [UIColor whiteColor];
    }
}

- (UILabel *)label {
    if (!_label) {
        _label = [[UILabel alloc] init];
        _label.textColor = [UIColor whiteColor];
        _label.font = [UIFont systemFontOfSize:14];
        _label.textAlignment = NSTextAlignmentCenter;
    }
    return _label;
}

@end
