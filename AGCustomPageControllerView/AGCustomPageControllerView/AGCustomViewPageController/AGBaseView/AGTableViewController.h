//
//  AGTableViewController.h
//  AGCustomPageControllerView
//
//  Created by yang_0921 on 2016/12/7.
//  Copyright © 2016年 yang_0921. All rights reserved.
//

#import "AGBaseViewController.h"
#import <UIKit/UIKit.h>
@interface AGTableViewController : AGBaseViewController <UITableViewDelegate,
                                                         UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;

@end
