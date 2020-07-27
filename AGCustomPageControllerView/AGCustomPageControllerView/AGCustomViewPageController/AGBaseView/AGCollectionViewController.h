//
//  AGCollectionViewController.h
//  AGCustomPageControllerView
//
//  Created by yang_0921 on 2016/12/8.
//  Copyright © 2016年 yang_0921. All rights reserved.
//

#import "AGBaseViewController.h"
#import <UIKit/UIKit.h>
@interface AGCollectionViewController : AGBaseViewController <UICollectionViewDelegate,
                                                              UICollectionViewDataSource>

@property (nonatomic, strong) UICollectionView *collectionView;

/** 重写此方法实现自己的 layout */
- (UICollectionViewFlowLayout *)flowLayout;

@end
