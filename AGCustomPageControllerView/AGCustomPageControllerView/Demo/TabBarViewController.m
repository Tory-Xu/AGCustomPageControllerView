//
//  TabBarViewController.m
//  AGCustomPageControllerView
//
//  Created by yang_0921 on 2016/12/9.
//  Copyright © 2016年 yang_0921. All rights reserved.
//

#import "TabBarViewController.h"
#import "CollectionViewController.h"
#import "NavigationViewController.h"
#import "TableViewController.h"
#import "ViewController1.h"

@interface TabBarViewController ()

@end

@implementation TabBarViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self addChildViewController:[self getVcWithScrollEnable:YES title:@"banner滚动"]];

    NavigationViewController *nav = [[NavigationViewController alloc] initWithRootViewController:[self getVcWithScrollEnable:NO title:@"banner禁止滚动"]];
    [self addChildViewController:nav];
}

- (ViewController1 *)getVcWithScrollEnable:(BOOL)scrollEnable title:(NSString *)title {
    NSMutableArray *childVcs = [NSMutableArray array];
    for (int index = 0; index < 10; index++) {

        if (index % 2) {
            TableViewController *tabVc = [[TableViewController alloc] init];
            tabVc.title = [NSString stringWithFormat:@"==== %d ====", index];
            [childVcs addObject:tabVc];
        } else {
            CollectionViewController *collVc = [[CollectionViewController alloc] init];
            collVc.title = [NSString stringWithFormat:@"== %d ==", index];
            [childVcs addObject:collVc];
        }
    }

    ViewController1 *vc = [[ViewController1 alloc] initWithChildControllers:childVcs];
    // 设置headerView是否可以滚动
    vc.scrollEnable = scrollEnable;
    if (scrollEnable) {
        vc.fillTopWhenHiddenNavigation = YES;
    }
    vc.fillTopColor = [UIColor grayColor];
    vc.title = title;
    return vc;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
