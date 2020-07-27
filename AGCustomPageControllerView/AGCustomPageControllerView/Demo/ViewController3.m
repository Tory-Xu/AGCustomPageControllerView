//
//  ViewController3.m
//  AGCustomPageControllerView
//
//  Created by againXu on 2017/3/7.
//  Copyright © 2017年 yang_0921. All rights reserved.
//

#import "ViewController3.h"

@interface ViewController3 ()

@property (nonatomic, strong) UITextView *textView;

@end

@implementation ViewController3

- (void)viewDidLoad {
    [super viewDidLoad];

    self.textView.text = @"这是一个继承子 UIViewController 的普通控制器";
}

- (UITextView *)textView {
    if (!_textView) {
        _textView = [[UITextView alloc] init];
        _textView.frame = CGRectMake(0, 0, 200, 200);
        _textView.center = self.view.center;
        _textView.backgroundColor = [UIColor whiteColor];
        _textView.font = [UIFont systemFontOfSize:20];
        _textView.editable = NO;
        [self.view addSubview:_textView];
    }
    return _textView;
}

@end
