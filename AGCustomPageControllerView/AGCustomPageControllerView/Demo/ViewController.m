//
//  ViewController.m
//  AGCustomPageControllerView
//
//  Created by yang_0921 on 2016/12/7.
//  Copyright © 2016年 yang_0921. All rights reserved.
//

#import "ViewController.h"

#import "ViewController2.h"
#import "TableViewController.h"

#import "CollectionViewController.h"

@interface ViewController ()

@property (nonatomic, strong) UITextView *textView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.textView.text = @"设置滚动标签的边距(2, 10, 4, 20)";
}


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{

    NSMutableArray *childVcs = [NSMutableArray array];
    for (int index = 0; index < 10; index++) {
        
        if (index % 2) {
            TableViewController *tabVc = [[TableViewController alloc] init];
            NSInteger count = MAX(arc4random_uniform(15), 5);
            NSMutableString *mutString = @"".mutableCopy;
            for (int i = 0; i < count; i++) {
                [mutString appendString:[NSString stringWithFormat:@"%d", index]];
            }
            tabVc.title = mutString;
//            tabVc.title = [NSString stringWithFormat:@"==== %d ====", index];
            [childVcs addObject:tabVc];
        }else{
            CollectionViewController *collVc = [[CollectionViewController alloc] init];
            collVc.title = [NSString stringWithFormat:@"== %d ==", index];
            [childVcs addObject:collVc];
        }
    }
    
    ViewController2 *vc = [[ViewController2 alloc] initWithChildControllers:childVcs];
    [vc setScrollLabelEdgeInsets:UIEdgeInsetsMake(2, 10, 4, 20)];
    [vc setCurrentLabelIndex:2];
    // 设置默认选中
//    [vc setCurrentLabelIndex:4];
    [self.navigationController pushViewController:vc animated:YES];
    
//    TableViewController *vc = [[TableViewController alloc] init];
//    CollectionViewController *vc = [[CollectionViewController alloc] init];
//    [self.navigationController pushViewController:vc animated:YES];
    
}

- (UITextView *)textView{
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
