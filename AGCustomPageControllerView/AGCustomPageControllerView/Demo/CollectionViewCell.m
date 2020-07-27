//
//  CollectionViewCell.m
//  AGCustomPageControllerView
//
//  Created by yang_0921 on 2016/12/9.
//  Copyright © 2016年 yang_0921. All rights reserved.
//

#import "CollectionViewCell.h"

@interface CollectionViewCell ()

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIImageView *iconImageView;

@end

@implementation CollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {

        [self setupBaseUI];
    }
    return self;
}

- (void)setupBaseUI {

    [self.contentView addSubview:self.iconImageView];
    [self.contentView addSubview:self.titleLabel];
}

- (void)layoutSubviews {
    self.iconImageView.center = CGPointMake(CGRectGetWidth(self.frame) * 0.5, CGRectGetHeight(self.frame) * 0.5 - 8);
    self.titleLabel.frame = CGRectMake(0, CGRectGetMaxY(self.iconImageView.frame) + 4, CGRectGetWidth(self.frame), 20);
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];

    if (selected) {
        self.contentView.backgroundColor = [UIColor grayColor];
    } else {
        self.contentView.backgroundColor = [UIColor whiteColor];
    }
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.text = @"text";
        _titleLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _titleLabel;
}

- (UIImageView *)iconImageView {
    if (!_iconImageView) {
        _iconImageView = [[UIImageView alloc] init];
        _iconImageView.image = [UIImage imageNamed:@"channelmg_advancedstudy_s"];
        [_iconImageView sizeToFit];
    }
    return _iconImageView;
}

@end
