//
//  AGCollectionViewController.m
//  AGCustomPageControllerView
//
//  Created by yang_0921 on 2016/12/8.
//  Copyright © 2016年 yang_0921. All rights reserved.
//

#import "AGCollectionViewController.h"

@interface AGCollectionViewController ()

@end

@implementation AGCollectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)setScrollView {
    [self.view addSubview:self.collectionView];
    [super setScrollView];
}

- (UICollectionViewFlowLayout *)flowLayout {

    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = CGSizeMake(100, 100);
    layout.minimumLineSpacing = 10;
    return layout;
}

- (UICollectionView *)collectionView {
    if (!_collectionView) {

        _collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:[self flowLayout]];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.backgroundColor = self.view.backgroundColor;
        self.scrollView = _collectionView;
    }
    return _collectionView;
}

@end
