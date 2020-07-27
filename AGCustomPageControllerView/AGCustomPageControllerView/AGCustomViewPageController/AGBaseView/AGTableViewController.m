//
//  AGTableViewController.m
//  AGCustomPageControllerView
//
//  Created by yang_0921 on 2016/12/7.
//  Copyright © 2016年 yang_0921. All rights reserved.
//

#import "AGTableViewController.h"

@interface AGTableViewController ()

@end

@implementation AGTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)setScrollView {
    [self.view addSubview:self.tableView];
    [super setScrollView];
}

#pragma mark - lazy

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.tableFooterView = [UIView new];
        _tableView.backgroundColor = self.view.backgroundColor;
        self.scrollView = _tableView;
    }
    return _tableView;
}

@end
