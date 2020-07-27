//
//  ViewController2.m
//  AGCustomPageControllerView
//
//  Created by yang_0921 on 2016/12/10.
//  Copyright © 2016年 yang_0921. All rights reserved.
//

#import "ViewController2.h"

#import "CollectionViewController.h"
#import "EditeViewController.h"

@interface ViewController2 ()

@end

@implementation ViewController2

- (void)viewDidLoad {
    [super viewDidLoad];

    //    self.selectStyle = AGSelectStyleNone;
}

- (UIView *)rightViewForSectionHeader {
    UIButton *scrollButton = [UIButton buttonWithType:0];
    [scrollButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [scrollButton setTitle:@"滚动到最后一个" forState:UIControlStateNormal];
    [scrollButton addTarget:self action:@selector(scrollToLast) forControlEvents:UIControlEventTouchUpInside];
    scrollButton.frame = CGRectMake(0, 0, 150, 44);
    return scrollButton;

    UIView *view = [UIView new];
    view.frame = CGRectMake(0, 0, 150, 44);

    UIButton *button = [UIButton buttonWithType:0];
    button.frame = CGRectMake(0, 0, 50, 44);
    [button setTitle:@"-" forState:UIControlStateNormal];
    button.backgroundColor = [UIColor blackColor];
    [button addTarget:self action:@selector(deleteAction) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:button];

    UIButton *button1 = [UIButton buttonWithType:0];
    button1.frame = CGRectMake(50, 0, 50, 44);
    button1.backgroundColor = [UIColor blackColor];
    [button1 setTitle:@"+" forState:UIControlStateNormal];
    [button1 addTarget:self action:@selector(addAction) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:button1];

    UIButton *button2 = [UIButton buttonWithType:0];
    button2.frame = CGRectMake(100, 0, 50, 44);
    button2.backgroundColor = [UIColor blackColor];
    [button2 setTitle:@"edit" forState:UIControlStateNormal];
    [button2 addTarget:self action:@selector(editAction) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:button2];

    return view;
}

- (void)scrollToLast {
    [self setCurrentLabelIndex:self.ag_childControllers.count - 1];
}

- (void)deleteAction {

    [self.ag_childControllers removeObjectAtIndex:0];
    [self reloadPageControlChildControllers];

    [self showAlert:@"删除第一个"];
}

- (void)addAction {

    CollectionViewController *collVc = [[CollectionViewController alloc] init];
    collVc.title = @"new";

    [self.ag_childControllers addObject:collVc];
    [self reloadPageControlChildControllers];

    [self showAlert:@"添加在最后面"];
}

- (void)editAction {
    EditeViewController *vc = [[EditeViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)showAlert:(NSString *)title {

    UIAlertController *alertVc = [UIAlertController alertControllerWithTitle:title message:nil preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"关闭"
                                                     style:UIAlertActionStyleDefault
                                                   handler:^(UIAlertAction *_Nonnull action){
                                                   }];
    [alertVc addAction:action];
    [self presentViewController:alertVc animated:YES completion:nil];
}

@end
