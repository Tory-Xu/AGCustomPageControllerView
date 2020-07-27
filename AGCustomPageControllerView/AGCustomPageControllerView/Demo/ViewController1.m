//
//  ViewController1.m
//  AGCustomPageControllerView
//
//  Created by yang_0921 on 2016/12/8.
//  Copyright © 2016年 yang_0921. All rights reserved.
//

#import "ViewController1.h"

#import "CollectionViewCell.h"
#import "CollectionViewController.h"

@interface ViewController1 ()

@end

@implementation ViewController1

static NSString *cellId = @"cellId";

- (void)viewDidLoad {
    [super viewDidLoad];
    self.subViewsbounces = NO;
}

- (UIView *)tableHeaderView {

    UIView *tableHeaderView = [UIView new];
    tableHeaderView.frame = CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 150);
    tableHeaderView.backgroundColor = [UIColor blueColor];

    if (self.isDismiss) {
        UIButton *backButton = [UIButton buttonWithType:0];
        [backButton setTitle:@"返回" forState:UIControlStateNormal];
        [backButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        backButton.layer.cornerRadius = 20;
        backButton.frame = CGRectMake(40, 40, 40, 40);
        [backButton addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
        [tableHeaderView addSubview:backButton];
    }

    return tableHeaderView;
}

- (void)registerCellForScrollLabel:(AGScrollLabelView *)scrollLabelView {
    [scrollLabelView registerClass:[CollectionViewCell class] forCellWithReuseIdentifier:cellId];
}

- (void)backAction {
    [self dismissViewControllerAnimated:YES completion:nil];
}

//- (UIView *)viewForSectionHeader{
//    return nil;
//}

- (CGFloat)heightOfscrollLabelControl {
    return 58;
}

- (UIView *)rightViewForSectionHeader {

    UIView *view = [UIView new];
    view.frame = CGRectMake(0, 0, 150, 58);

    UIButton *button = [UIButton buttonWithType:0];
    button.frame = CGRectMake(0, 0, 50, 58);
    [button setTitle:@"-" forState:UIControlStateNormal];
    button.backgroundColor = [UIColor blackColor];
    [button addTarget:self action:@selector(deleteAction) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:button];

    UIButton *button1 = [UIButton buttonWithType:0];
    button1.frame = CGRectMake(50, 0, 50, 58);
    button1.backgroundColor = [UIColor blackColor];
    [button1 setTitle:@"+" forState:UIControlStateNormal];
    [button1 addTarget:self action:@selector(addAction) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:button1];

    UIButton *button2 = [UIButton buttonWithType:0];
    button2.frame = CGRectMake(100, 0, 50, 58);
    button2.backgroundColor = [UIColor blackColor];
    [button2 setTitle:@"edit" forState:UIControlStateNormal];
    [button2 addTarget:self action:@selector(editAction) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:button2];

    return view;
}

- (void)deleteAction {

    [self.ag_childControllers removeObjectAtIndex:0];
    [self reloadPageControlChildControllers];
}

- (void)addAction {

    CollectionViewController *collVc = [[CollectionViewController alloc] init];
    collVc.title = @"new";

    [self.ag_childControllers addObject:collVc];
    [self reloadPageControlChildControllers];
}

- (void)editAction {
}

- (UICollectionViewCell *)scrollLabel:(AGScrollLabelView *)scrollLabelView collectionView:(UICollectionView *)collectionView cellforIndexPath:(NSIndexPath *)indexPath {

    CollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellId forIndexPath:indexPath];

    return cell;
}

- (NSInteger)numberOfItemsInScrollLabelView:(AGScrollLabelView *)scrollLabelView {
    return self.ag_childControllers.count;
}

- (CGSize)scrollLabel:(AGScrollLabelView *)scrollLabelView sizeForCellAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(70, 58);
}

- (void)scrollLabelScrollCell:(UICollectionViewCell *)cell atIndex:(NSInteger)index {
    CollectionViewCell *newCell = (CollectionViewCell *) cell;
    newCell.backgroundColor = [UIColor colorWithRed:arc4random_uniform(255) / 255.0 green:arc4random_uniform(255) / 255.0 blue:arc4random_uniform(255) / 255.0 alpha:1];
}

@end
