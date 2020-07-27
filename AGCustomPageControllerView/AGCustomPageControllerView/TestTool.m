//
//  TestTool.m
//  AGCustomPageControllerView
//
//  Created by yang_0921 on 2017/1/17.
//  Copyright © 2017年 yang_0921. All rights reserved.
//

#import "TestTool.h"
#import <UIKit/UIKit.h>

@interface TestTool ()

@property (nonatomic, strong) UILabel *dataLabel;

@end

@implementation TestTool

+ (instancetype)share {

    static TestTool *tool_;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        tool_ = [TestTool new];
    });
    return tool_;
}

- (instancetype)init {
    self = [super init];
    if (self) {

        [self ag_setupUi];
    }
    return self;
}

#pragma mark - private

- (void)ag_setupUi {

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction)];
    [self.dataLabel addGestureRecognizer:tap];
}

- (void)showDataWithTitle:(NSString *)title {

    self.dataLabel.text = title;
    [self.dataLabel sizeToFit];
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    self.dataLabel.center = CGPointMake(CGRectGetWidth(window.frame) * 0.5, CGRectGetHeight(window.frame) * 0.5);
    [window addSubview:self.dataLabel];
}

#pragma mark - publick

+ (void)showWithTitle:(NSString *)title {
    [[TestTool share] showDataWithTitle:title];
}

#pragma mark - response

- (void)tapAction {
    [self.dataLabel removeFromSuperview];
}

#pragma mark - getters and setters

- (UILabel *)dataLabel {
    if (!_dataLabel) {
        _dataLabel = [[UILabel alloc] init];
        _dataLabel.textColor = [UIColor redColor];
        _dataLabel.font = [UIFont systemFontOfSize:18];
        _dataLabel.textAlignment = NSTextAlignmentCenter;
        _dataLabel.userInteractionEnabled = YES;
        _dataLabel.numberOfLines = 0;
    }
    return _dataLabel;
}

@end
