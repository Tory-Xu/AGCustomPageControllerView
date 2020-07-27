//
//  AGBaseViewController.m
//  AGCustomPageControllerView
//
//  Created by yang_0921 on 2016/12/7.
//  Copyright © 2016年 yang_0921. All rights reserved.
//

#import "AGBaseViewController.h"

@interface AGBaseViewController ()

@property (nonatomic, strong) UIView *header;

@end

static NSString *k_ScrollViewDidScrolling = @"k_ScrollViewDidScrolling";

@implementation AGBaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setScrollView];

    [self addobserver];

    if ([self viewDidLoadBeginRefresh]) {
        [self.scrollView.mj_header beginRefreshing];
    }
}

- (void)dealloc {
    [self.header removeObserver:self forKeyPath:@"state"];
}

- (BOOL)viewDidLoadBeginRefresh {
    return NO;
}

- (void)setScrollView {
    if ([self hasHeaderRefresh]) {
        [self setTableVIewHeaderRefresh];
    }

    if ([self hasFooterRefresh]) {
        [self setTableVIewFooterRefresh];
    }
}

- (BOOL)hasHeaderRefresh {
    return YES;
}

- (BOOL)hasFooterRefresh {
    return YES;
}

- (void)setTableVIewHeaderRefresh {
    __weak typeof(self) weakSelf = self;
    self.header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [weakSelf headerRefreshAction];
    }];
    self.scrollView.mj_header = (MJRefreshHeader *)self.header;
}

- (void)headerRefreshAction {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.scrollView.mj_header endRefreshing];
    });
}

- (void)setTableVIewFooterRefresh {
    __weak typeof(self) weakSelf = self;
    self.scrollView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        [weakSelf footerRefreshAction];
    }];
}

- (void)footerRefreshAction {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.scrollView.mj_footer endRefreshing];
    });
}

- (void)addobserver {
    [self.scrollView.mj_header addObserver:self forKeyPath:@"state" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey, id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"state"]) {
        if (self.scrollView.mj_header.state == MJRefreshStateIdle) {
            // 做完刷新动作，偏移重置
            self.lastContentOffset = CGPointZero;
            if ([self.delegate respondsToSelector:@selector(ag_baseViewController:scrollViewDidScrollLastContentOffset:)]) {
                [self.delegate ag_baseViewController:self scrollViewDidScrollLastContentOffset:self.lastContentOffset];
            }
        }
    }
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (self.scroll) {
        if ([self.delegate respondsToSelector:@selector(ag_baseViewController:scrollViewDidScrollLastContentOffset:)]) {
            [self.delegate ag_baseViewController:self scrollViewDidScrollLastContentOffset:self.lastContentOffset];
        }
    } else {
        self.scroll = YES;
    }

    self.lastContentOffset = scrollView.contentOffset;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    self.lastContentOffset = scrollView.contentOffset;
}

/** 减速结束时调用：
 
 在做下拉刷新的动作中：
 1，为触发下拉刷新：回到顶部的时候调用到
 2，触发：松手就会调用到
 
 快速滑动（上拉/下拉），为触发刷新
 */
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (self.lastContentOffset.y <= 0) {
        self.lastContentOffset = CGPointZero;
        if ([self.delegate respondsToSelector:@selector(ag_baseViewController:scrollViewDidScrollLastContentOffset:)]) {
            [self.delegate ag_baseViewController:self scrollViewDidScrollLastContentOffset:self.lastContentOffset];
        }
    }
}

- (void)setTableHeaderViewCanRefresh:(BOOL)canRefresh {
    self.scrollView.mj_header.hidden = !canRefresh;
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    self.scrollView.frame = self.view.bounds;
}

- (void)setContentOffset:(CGPoint)offset scroll:(BOOL)scroll {

    self.scroll = scroll;
    self.scrollView.contentOffset = offset;
}

@end
