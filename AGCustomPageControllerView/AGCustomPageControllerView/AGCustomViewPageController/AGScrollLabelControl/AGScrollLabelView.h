//
//  AGScrollLabelView.h
//  AGCustomPageControllerView
//
//  Created by yang_0921 on 2016/12/9.
//  Copyright © 2016年 yang_0921. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AGScrollLabelView;

typedef void (^registerCellBlock)(AGScrollLabelView *scrollLabelView);

/** 默认样式的类型 */
typedef NS_ENUM(NSInteger, AGSelectStyle) {
    AGSelectStyleNone = 0,
    AGSelectStyleLine // 线条
};

typedef NS_ENUM(NSInteger, AGLabelAlignment) {
    AGLabelAlignmentLeft = 0,
    AGLabelAlignmentPull // 铺满
};

@class AGScrollLabelView;

@protocol AGScrollLabelViewDelegate <NSObject>

@optional

/** 注册 cell */
- (void)registerCellForScrollLabel:(AGScrollLabelView *)scrollLabelView;

/**  返回自定义类型的标签 */
- (UICollectionViewCell *)scrollLabel:(AGScrollLabelView *)scrollLabelView collectionView:(UICollectionView *)collectionView cellforIndexPath:(NSIndexPath *)indexPath;

/** 标签个数 */
- (NSInteger)numberOfItemsInScrollLabelView:(AGScrollLabelView *)scrollLabelView;

/** 标签的size */
- (CGSize)scrollLabel:(AGScrollLabelView *)scrollLabelView sizeForCellAtIndexPath:(NSIndexPath *)indexPath;

/** 开始或即将结束滚动 */
- (void)scrollLabel:(AGScrollLabelView *)scrollLabelView willBeginOrWillEndDraggin:(BOOL)isBegin;

/** 当前选中的标签 */
- (void)scrollLabel:(AGScrollLabelView *)scrollLabelView cell:(UICollectionViewCell *)cell didSelectIndex:(NSInteger)index;

@end

@interface AGScrollLabelView : UIView

/** 标签默认只显示标题，使用此方法即可 */
- (instancetype)initWithTitls:(NSArray *)titles
                        frame:(CGRect)frame;

@property (nonatomic, weak) id<AGScrollLabelViewDelegate> delegate;

@property (nonatomic, assign) BOOL bounces;
/** 滚动标签样式 */
@property (nonatomic, assign) AGSelectStyle selectStyle;
/** 标签选中的样式 */
@property (nonatomic, assign) AGLabelAlignment labelAlignment;

- (void)setContentInsets:(UIEdgeInsets)contentInsets;

/** 设置当前选中的标签 */
- (void)setCurrentLabelIndex:(NSInteger)index; // 默认发送切换子控制器的 代理方法
- (void)setCurrentLabelIndex:(NSInteger)index sendScrollDelegate:(BOOL)sendDelegate;

/** 建议在初始化方法中注册 */
- (void)registerClass:(Class)cellClass forCellWithReuseIdentifier:(NSString *)identifier;

/** 更新标签标题 */
- (void)updateTitles:(NSArray<NSString *> *)titles;

/** 标签滚动 */
- (void)lineViewScroll:(UICollectionView *)collectionView;

@end
