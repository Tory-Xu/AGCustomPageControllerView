//
//  AGPageControllerViewController.h
//  AGCustomPageControllerView
//
//  Created by yang_0921 on 2016/12/7.
//  Copyright © 2016年 yang_0921. All rights reserved.
//

#import "AGScrollLabelView.h"
#import <UIKit/UIKit.h>

@interface AGPageControllerViewController : UIViewController <AGScrollLabelViewDelegate>

- (instancetype)initWithChildControllers:(NSArray<UIViewController *> *)ag_childControllers;

/** 子控制器数组请直接赋值，或 - (void)updateChildContollers:(NSArray<UIViewController *> *)childControllers; 方法 */
@property (nonatomic, strong) NSMutableArray *ag_childControllers;

// 头部视图是否允许滚动
@property (nonatomic, assign) BOOL scrollEnable;

/** 设置子控件（滚动标签和自控制是否弹性效果） */
@property (nonatomic, assign) BOOL subViewsbounces;

/** 滚动标签样式 */
@property (nonatomic, assign) AGLabelAlignment labelAlignment;

/** 标签选中的样式 */
@property (nonatomic, assign) AGSelectStyle selectStyle;

@property (nonatomic, assign) UIEdgeInsets scrollLabelEdgeInsets;

/** 设置标签滚动的内边距 */
- (void)setScrollLabelViewEdgeInsets:(UIEdgeInsets)scrollLabelViewEdgeInsets;

/** 推荐在导航栏隐藏时使用，是否设置顶部白色20的高度填充 */
/** 注意：在有设置 banner（tableHeaderView） 的时候，这个属性能达到效果，否则效果不佳 */
@property (nonatomic, assign) BOOL fillTopWhenHiddenNavigation;
@property (nonatomic, strong) UIColor *fillTopColor;

/** 设置当前标签位置 */
- (void)setCurrentLabelIndex:(NSInteger)index;

/** 头视图 */
- (UIView *)tableHeaderView;

/** 标签栏高度 */
- (CGFloat)heightOfscrollLabelControl;

/** 重写：自定义滑动条上的视图 */
//- (UIView *)viewForSectionHeader;

/** 滚动条右侧视图：默认无 */
- (UIView *)rightViewForSectionHeader;

/** 更新头部视图：tableViewHeader 如果是动态设定的，可以使用此方法更新 */
- (void)reloadTableViewHeader;

/** 更新子控制器 */
- (void)updateChildContollers:(NSArray<UIViewController *> *)childControllers;
- (void)reloadPageControlChildControllers;

/** 所有视图滚动到顶部 */
- (void)allViewScrollToTop;

#pragma mark - 自定义标签设置 AGScrollLabelViewDelegate
/** 注册自定义类型的 标签 */
/** 这是个代理方法，如果需要注册自定义的 lable cell，实现代理进行注册 */
- (void)registerCellForScrollLabel:(AGScrollLabelView *)scrollLabelView;

/** 自定义类型标签 */
- (UICollectionViewCell *)scrollLabel:(AGScrollLabelView *)scrollLabelView collectionView:(UICollectionView *)collectionView cellforIndexPath:(NSIndexPath *)indexPath;

/** 标签个数，如果只显示title（通过设置vc.titles即可），不需要实现这里的方法 */
- (NSInteger)numberOfItemsInScrollLabelView:(AGScrollLabelView *)scrollLabelView;

/** 自定义类型标签的size */
- (CGSize)scrollLabel:(AGScrollLabelView *)scrollLabelView sizeForCellAtIndexPath:(NSIndexPath *)indexPath;

/** 当前选中的 标签 */
- (void)scrollLabelScrollCell:(UICollectionViewCell *)cell atIndex:(NSInteger)index;

@end
