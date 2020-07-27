//
//  AGContainerCollectionViewController.h
//  AGCustomPageControllerView
//
//  Created by yang_0921 on 2016/12/7.
//  Copyright © 2016年 yang_0921. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AGContainerCollectionViewController;
@class AGBaseViewController;

@protocol AGContainerCollectionViewControllerDelegate <NSObject>

@optional

/** 滚动到某个控制器 */
- (void)containerCollectionViewController:(AGContainerCollectionViewController *)containerViewController scrollAtIndex:(NSInteger)index currentContentController:(AGBaseViewController *)currentController;

/** 即将开始或结束滚动 */
- (void)containerCollectionViewController:(AGContainerCollectionViewController *)containerViewController willBeginOrWillEndDraggin:(BOOL)isBegin;

- (void)containerCollectionViewDidScroll:(UICollectionView *)collectionView;

@end

@interface AGContainerCollectionViewController : UIViewController

/** 使用此初始化方法 */
- (instancetype)initWithChildControllers:(NSArray<UIViewController *> *)ag_childControllers frame:(CGRect)frame;

/** 是否有弹性效果 */
@property (nonatomic, assign) BOOL bounces;

/** 子控制器frame */
@property (nonatomic, assign) CGRect frame;

@property (nonatomic, weak) id<AGContainerCollectionViewControllerDelegate> delegate;

- (void)setCollectionScrollEnable:(BOOL)scrollEnable;

/** 滚动到指定index的控制器 */
- (void)scrollToItemAtIndex:(NSInteger)index;

/** 更新子控制器显示 */
- (void)updateChildContollers:(NSArray<UIViewController *> *)childControllers;

@end
