//
//  TestViewController.m
//  AGCustomPageControllerView
//
//  Created by yang_0921 on 2016/12/9.
//  Copyright © 2016年 yang_0921. All rights reserved.
//

#import "TestViewController.h"

#import "CollectionViewController.h"
#import "TableViewController.h"
#import "ViewController1.h"
#import "ViewController3.h"

@interface TestViewController ()

@end

@implementation TestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {

    NSMutableArray *childVcs = [NSMutableArray array];
    for (int index = 0; index < 2; index++) {

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

    ViewController3 *normalVc = [ViewController3 new];
    [childVcs addObject:normalVc];

    ViewController1 *vc = [[ViewController1 alloc] initWithChildControllers:childVcs];
    vc.isDismiss = YES;
    vc.fillTopWhenHiddenNavigation = YES;
    [vc setScrollLabelEdgeInsets:UIEdgeInsetsMake(2, 2, 2, 2)];
    [self presentViewController:vc animated:YES completion:nil];

    //    TableViewController *vc = [[TableViewController alloc] init];
    //    CollectionViewController *vc = [[CollectionViewController alloc] init];
    //    [self.navigationController pushViewController:vc animated:YES];
}

@end
