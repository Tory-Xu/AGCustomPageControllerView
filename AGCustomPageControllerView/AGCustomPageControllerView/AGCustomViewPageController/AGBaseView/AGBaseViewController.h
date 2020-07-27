//
//  AGBaseViewController.h
//  AGCustomPageControllerView
//
//  Created by yang_0921 on 2016/12/7.
//  Copyright © 2016年 yang_0921. All rights reserved.
//

#import "MJRefresh.h"
#import <UIKit/UIKit.h>

@class AGBaseViewController;
@protocol AGBaseViewControllerDelegate <NSObject>

- (void)ag_baseViewController:(AGBaseViewController *)baseViewController scrollViewDidScrollLastContentOffset:(CGPoint)lastContentOffset;

@end

@interface AGBaseViewController : UIViewController <UIScrollViewDelegate>

@property (nonatomic, strong) UIScrollView *scrollView;

@property (nonatomic, assign) BOOL scroll;

@property (nonatomic, weak) id<AGBaseViewControllerDelegate> delegate;

// 记录上一次的偏移
@property (nonatomic, assign) CGPoint lastContentOffset;

- (void)setScrollView;

- (void)setContentOffset:(CGPoint)offset scroll:(BOOL)scroll;

- (void)setTableHeaderViewCanRefresh:(BOOL)canRefresh;

/**
    是否有头部刷新：默认 YES
 */
- (BOOL)hasHeaderRefresh;
/**
    是否有底部刷新：默认 YES
 */
- (BOOL)hasFooterRefresh;

/**
    重写设置头部刷新
 */
- (void)setTableVIewHeaderRefresh;
/**
    重写设置底部刷新
 */
- (void)setTableVIewFooterRefresh;

/**
    头部刷新方法
 */
- (void)headerRefreshAction;
/**
    底部刷新方法
 */
- (void)footerRefreshAction;
/**
    viewDidload的时候是否开启头部刷新，默认 NO
 */
- (BOOL)viewDidLoadBeginRefresh;

@end
