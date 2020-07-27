//
//  AGPageControllerViewController.m
//  AGCustomPageControllerView
//
//  Created by yang_0921 on 2016/12/7.
//  Copyright © 2016年 yang_0921. All rights reserved.
//

#import "AGPageControllerViewController.h"

#import "AGBaseViewController.h"
#import "AGContainerCollectionViewController.h"

static CGFloat k_fillTopStatusHeight = 20;
static CGFloat k_fillViewTag = 19930000;

@interface ZJCustomGestureTableView : UITableView

@end

@implementation ZJCustomGestureTableView

// 返回YES同时识别多个手势
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return [gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]] && [otherGestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]];
}

@end

@interface AGPageControllerViewController () <UITableViewDelegate,
                                              UITableViewDataSource,
                                              AGContainerCollectionViewControllerDelegate,
                                              AGBaseViewControllerDelegate>

@property (nonatomic, strong) ZJCustomGestureTableView *tableView;
@property (nonatomic, strong) AGContainerCollectionViewController *containerView; // 控制器容器

@property (nonatomic, strong) AGBaseViewController *currentContontViewController;

// 标记设置 contentOffset 的设置，手动设置时跳过 代理中的处理
@property (nonatomic, assign) BOOL scroll;

@property (nonatomic, assign) CGPoint lastContentOffset;
@property (nonatomic, assign) CGPoint scrollViewLastContentOffset;

@property (nonatomic, strong) AGScrollLabelView *scrollLabelView;

@end

@implementation AGPageControllerViewController {

    CGFloat _tableHeaderViewHeight;
    CGFloat _sectionHeaderHeight;
    BOOL _hasFillTop;
}

- (instancetype)initWithChildControllers:(NSArray<UIViewController *> *)ag_childControllers {
    self = [super init];
    if (self) {
        self.ag_childControllers = [NSMutableArray arrayWithArray:ag_childControllers];

        // 默认可滚动
        _scrollEnable = YES;
        _scroll = YES;
    }
    return self;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        // 默认可滚动
        _scrollEnable = YES;
        _scroll = YES;
    }
    return self;
}

#pragma mark - life cycle

- (void)viewDidLoad {
    [super viewDidLoad];

    // 去除导航栏和状态了高度影响
    self.edgesForExtendedLayout = UIRectEdgeNone;

    _sectionHeaderHeight = [self heightOfscrollLabelControl];
    self.tableView.tableHeaderView = [self tableHeaderView];

    /** 转成int，防止double情况下导致判断失败 */
    _tableHeaderViewHeight = (NSInteger) CGRectGetHeight(self.tableView.tableHeaderView.frame);
    if (_tableHeaderViewHeight <= 0) {
        self.tableView.bounces = NO;
    }
}

- (void)viewWillLayoutSubviews {
    /**
     self.view 刚创建时，没有排除 导航栏，状态栏和tabbar 的高度，因此在这里重新设置
     */
    CGRect frame = CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame));
    self.tableView.frame = frame;
    CGFloat topHeight = self.fillTopWhenHiddenNavigation ? k_fillTopStatusHeight : 0;
    if (!self.scrollEnable) {
        topHeight += _tableHeaderViewHeight;
    }
    
    self.containerView.view.frame = CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame) - _sectionHeaderHeight - topHeight);
    self.containerView.frame = self.containerView.view.frame;
    /**
     *  如果containerView，cell 的高度需要刷新
     */
    [self.tableView reloadData];
}

#pragma mark - public

- (void)setAg_childControllers:(NSMutableArray *)ag_childControllers {
    _ag_childControllers = ag_childControllers;
    [self setChildControllersDelegate];
}

- (void)setScrollEnable:(BOOL)scrollEnable {
    _scrollEnable = scrollEnable;
    self.tableView.scrollEnabled = scrollEnable;
}

- (void)setSubViewsbounces:(BOOL)subViewsbounces {
    self.scrollLabelView.bounces = subViewsbounces;
    self.containerView.bounces = subViewsbounces;
}

- (UIView *)tableHeaderView {
    return nil;
}

- (CGFloat)heightOfscrollLabelControl {
    return 44;
}

- (UIView *)viewForSectionHeader {
    return self.scrollLabelView;
}

- (UIView *)rightViewForSectionHeader {
    return nil;
}

- (void)setLabelAlignment:(AGLabelAlignment)labelAlignment {
    _labelAlignment = labelAlignment;
    self.scrollLabelView.labelAlignment = labelAlignment;
}

- (void)setSelectStyle:(AGSelectStyle)selectStyle {
    _selectStyle = selectStyle;
    self.scrollLabelView.selectStyle = selectStyle;
}

- (void)setCurrentLabelIndex:(NSInteger)index {
    [self.scrollLabelView setCurrentLabelIndex:index];
}

- (void)setScrollLabelViewEdgeInsets:(UIEdgeInsets)scrollLabelViewEdgeInsets {
    [self.scrollLabelView setContentInsets:scrollLabelViewEdgeInsets];
}

- (void)reloadTableViewHeader {
    self.tableView.tableHeaderView = [self tableHeaderView];
    _tableHeaderViewHeight = (NSInteger) CGRectGetHeight(self.tableView.tableHeaderView.frame);
    if (_tableHeaderViewHeight <= 0) {
        self.tableView.bounces = NO;
    }
}

- (void)updateChildContollers:(NSArray<UIViewController *> *)childControllers {
    self.ag_childControllers = [NSMutableArray arrayWithArray:childControllers];
    [self reloadPageControlChildControllers];
}

- (void)reloadPageControlChildControllers {
    NSMutableArray *titles = [NSMutableArray array];
    for (UIViewController *vc in self.ag_childControllers) {
        if (!vc.title) {
            titles = nil;
            break;
        }
        [titles addObject:vc.title];
    }
    [self.scrollLabelView updateTitles:titles];
    [self.containerView updateChildContollers:self.ag_childControllers];
}

- (void)allViewScrollToTop {
    [self setContentOffset:CGPointMake(0, 0) scroll:NO];
    [self.currentContontViewController setContentOffset:CGPointMake(0, 0) scroll:NO];
}

#pragma mark - private

/** 头部未完全显示 */
- (BOOL)headerShow {
    return self.lastContentOffset.y > 0 && self.lastContentOffset.y < _tableHeaderViewHeight - self.fillTopWhenHiddenNavigation * k_fillTopStatusHeight;
}

/** 头部完全显示 */
- (BOOL)headerShowAll {
    return self.lastContentOffset.y <= 0;
}

/** 头部隐藏 */
- (BOOL)headerHidden {
    return self.lastContentOffset.y >= _tableHeaderViewHeight - self.fillTopWhenHiddenNavigation * k_fillTopStatusHeight;
}

/** 内容刚好在顶部 */
- (BOOL)contentInTop {
    return self.scrollViewLastContentOffset.y == 0;
}

/** 内容超出顶部（触发刷新的状态） */
- (BOOL)contentUpTop {
    return self.scrollViewLastContentOffset.y < 0;
}

/** 内容不在顶部 */
- (BOOL)contentBottomTop {
    return self.scrollViewLastContentOffset.y > 0;
}

#pragma mark -

- (void)setChildControllersDelegate {
    [self.ag_childControllers enumerateObjectsUsingBlock:^(UIViewController *vc, NSUInteger idx, BOOL *_Nonnull stop) {
        if ([vc isKindOfClass:[AGBaseViewController class]]) {
            AGBaseViewController *baseViewController = (AGBaseViewController *) vc;
            baseViewController.delegate = self;
        }
    }];
}

/**
    通过高度进行判断：
        顶部statusBar填充，containView的高度会较少 k_fillTopStatusHeight ，即整个 tableView 的高度也会受到影响，拖动到的位置受到变化
 */
- (void)fillTopViewhandle {
    if (self.fillTopWhenHiddenNavigation && self.tableView.tableHeaderView) {
        BOOL hasScrollToBottom = self.tableView.contentOffset.y >= self.tableView.contentSize.height - CGRectGetHeight(self.containerView.frame) - _sectionHeaderHeight - k_fillTopStatusHeight;
        BOOL headerHidden = self.tableView.contentOffset.y >= _tableHeaderViewHeight - self.fillTopWhenHiddenNavigation * k_fillTopStatusHeight;

        if (hasScrollToBottom || headerHidden) {
            if (!_hasFillTop) {
                _hasFillTop = YES;
                UIView *fillView = [self.tableView.tableHeaderView viewWithTag:k_fillViewTag];
                if (!fillView) {
                    fillView = [UIView new];
                    CGFloat height = k_fillTopStatusHeight + 2;
                    fillView.frame = CGRectMake(0, CGRectGetHeight(self.tableView.tableHeaderView.frame) - height, CGRectGetWidth(self.tableView.tableHeaderView.frame), height);
                    fillView.backgroundColor = self.fillTopColor ?: [UIColor whiteColor];
                    fillView.tag = k_fillViewTag;
                    [self.tableView.tableHeaderView addSubview:fillView];
                }
                [self.tableView.tableHeaderView bringSubviewToFront:fillView];
                fillView.hidden = NO;
            }
        } else {
            if (_hasFillTop) {
                _hasFillTop = NO;
                UIView *fillView = [self.tableView.tableHeaderView viewWithTag:k_fillViewTag];
                if (fillView) {
                    fillView.hidden = YES;
                }
            }
        }
    }
}

#pragma mark - delegate

#pragma mark - AGBaseViewControllerDelegate

- (void)ag_baseViewController:(AGBaseViewController *)baseViewController scrollViewDidScrollLastContentOffset:(CGPoint)lastContentOffset {
    self.currentContontViewController = baseViewController;
    self.scrollViewLastContentOffset = lastContentOffset;
}

#pragma mark - scrollView delegate
/** 情况分析 - 理想状态（对于不存在的情况，在实际中可能存在，发现则更具情况处理）

    头部完全显示，内容在顶部 ： 向上-头部向上    向下-内容向下
 
    头部完全显示，内容不在顶部：  向上-头部向上     向下-内容向下
 
    头部未完全显示，内容不再顶部： 向上-头部向上     向下-头部向下
 
    头部未完全显示，内容在顶部：   向上-头部向上    向下-头部向下
 
    头部隐藏，内容不在顶部：    向上-内容显示     向下-内容向下
 
    头部隐藏，内容在顶部： 向上-内容向上     向下-头部向下
                            
    头部隐藏，内容超出顶部：    不存在
    头部完全显示，内容超出顶部：  向上-内容向上  向下-内容向下
    头部未完全显示，内容超出顶部： 不存在
 */

- (void)setContentOffset:(CGPoint)offset scroll:(BOOL)scroll {

    self.scroll = scroll;
    self.tableView.contentOffset = offset;
}

/** 上下滑动的时候，需要控制 collectionView 不能左右滑动，处理正常控制器滑动容易切换到左右滑动的情况 */
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if (scrollView == self.tableView) {
        self.lastContentOffset = scrollView.contentOffset;
        [self.containerView setCollectionScrollEnable:NO];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (scrollView == self.tableView) {
        [self.containerView setCollectionScrollEnable:YES];
    }
}
////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {

    [self fillTopViewhandle];

    /**
        过滤正常的控制器的情况，并且关闭弹性属性，否则页面时而有弹性效果，时而无弹性效果
     */
    if (![self.currentContontViewController isKindOfClass:[AGBaseViewController class]]) {
        self.tableView.bounces = NO;
        return;
    }

    if (!self.scrollEnable) {
        return;
    }

    if (_tableHeaderViewHeight <= 0) {
        return;
    }

    if (scrollView != self.tableView) return;

    /** 解决快速下拉的时候，头部会超出问题 */
    if (self.tableView.contentOffset.y <= 0) {
        self.tableView.bounces = YES;
    } else {
        self.tableView.bounces = NO;
    }

    // 向上
    CGFloat offsetY = scrollView.contentOffset.y - self.lastContentOffset.y;

    BOOL up = offsetY > 0;

    /** 解决：头部未完全显示时，下拉底部内容会跳动问题 */
    // 头全部显示 或 隐藏 - yes
    if (!up) {

        if ([self headerShowAll] || [self headerHidden]) {
            self.currentContontViewController.scrollView.bounces = YES;
        } else {
            self.currentContontViewController.scrollView.bounces = NO;
        }
    } else { // 不打开，会影响底部的上拉刷新功能
        self.currentContontViewController.scrollView.bounces = YES;
    }

    /** 解决：从头部隐藏状态时，快速下拉滑动过程中，内容的 mj_header 显示的问题 */
    // 头像在隐藏 切 内容在顶部 -- no
    if ([self headerShowAll]) {
        [self.currentContontViewController setTableHeaderViewCanRefresh:YES];
    } else {
        [self.currentContontViewController setTableHeaderViewCanRefresh:NO];
    }

    if (self.scroll == NO) {
        self.lastContentOffset = scrollView.contentOffset;
        self.scroll = YES;
        return;
    }

    if (offsetY == 0) {
        return;
    }

    // 头部完全显示，内容在顶部 ： 向上-头部向上    向下-内容向下
    if ([self headerShowAll] && [self contentInTop]) {
        NSLog(@"-----1----");
        if (up) { // 头部向上，内容保持位置 =》 头部未完全，内容顶部

            [self setContentOffset:CGPointMake(0, self.tableView.contentOffset.y + offsetY) scroll:NO];
            [self.currentContontViewController setContentOffset:CGPointZero scroll:NO];

        } else { // 内容向下，头部保持 =》 头部完全，内容超出
            [self setContentOffset:CGPointZero scroll:NO];
        }
    }
    // 头部完全显示，内容不在顶部：  向上-头部向上     向下-内容向下
    if ([self headerShowAll] && [self contentBottomTop]) {
        NSLog(@"----2-----");
        if (up) {
            [self.currentContontViewController setContentOffset:self.scrollViewLastContentOffset scroll:NO];
        } else {
            [self setContentOffset:CGPointZero scroll:NO];
        }
    }
    // 头部未完全显示，内容不再顶部： 向上-头部向上     向下-头部向下
    if ([self headerShow] && [self contentBottomTop]) {
        NSLog(@"----3-----");
        [self.currentContontViewController setContentOffset:self.scrollViewLastContentOffset scroll:NO];
    }
    // 头部未完全显示，内容在顶部：   向上-头部向上    向下-头部向下
    if ([self headerShow] && [self contentInTop]) {
        NSLog(@"----4-----");
        [self.currentContontViewController setContentOffset:CGPointZero scroll:NO];
    }
    // 头部隐藏，内容不在顶部：    向上-内容显示     向下-内容向下
    if ([self headerHidden] && [self contentBottomTop]) {
        NSLog(@"-----5----");
        [self setContentOffset:CGPointMake(0, _tableHeaderViewHeight - self.fillTopWhenHiddenNavigation * k_fillTopStatusHeight) scroll:NO];
    }
    // 头部隐藏，内容在顶部： 向上-内容向上     向下-头部向下
    if ([self headerHidden] && [self contentInTop]) {
        NSLog(@"----6-----");
        if (up) {
            [self setContentOffset:CGPointMake(0, _tableHeaderViewHeight - self.fillTopWhenHiddenNavigation * k_fillTopStatusHeight) scroll:NO];
        } else {
            [self.currentContontViewController setContentOffset:CGPointZero scroll:NO];
        }
    }
    // 头部隐藏，内容超出顶部：  特殊情况
    if ([self headerHidden] && [self contentUpTop]) {
        NSLog(@"-----7----");
        if (up) {
            NSLog(@"如果出现，则处理 1111");
        } else {
            /** 出现情况：头部隐藏时，快速下拉 */
            [self.currentContontViewController setContentOffset:CGPointZero scroll:NO];
        }
    }
    // 头部完全显示，内容超出顶部：  向上-内容向上  向下-内容向下
    if ([self headerShowAll] && [self contentUpTop]) {
        NSLog(@"------8---");
        [self setContentOffset:CGPointZero scroll:NO];
    }
    // 头部未完全显示，内容超出顶部： 特殊情况
    if ([self headerShow] && [self contentUpTop]) {
        NSLog(@"-----9----");
        if (up) {
            NSLog(@"如果出现，则处理 3333");
            [self.currentContontViewController setContentOffset:CGPointZero scroll:NO];
        } else {
            // 出现时的处理
            [self.currentContontViewController setContentOffset:CGPointZero scroll:NO];
        }
    }

    self.lastContentOffset = scrollView.contentOffset;
}

#pragma mark - table view datasource

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {

    UIView *sectionHeaderView = [UIView new];
    sectionHeaderView.clipsToBounds = YES;
    sectionHeaderView.frame = CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), _sectionHeaderHeight);

    UIView *rightView = [self rightViewForSectionHeader];
    UIView *scrollLabelView = [self viewForSectionHeader];
    CGFloat scrollLabelViewX = self.scrollLabelEdgeInsets.left;
    CGFloat scrollLabelViewY = self.scrollLabelEdgeInsets.top;
    CGFloat scrollLabelViewWidth = CGRectGetWidth(self.view.bounds) - self.scrollLabelEdgeInsets.left - self.scrollLabelEdgeInsets.right - CGRectGetWidth(rightView.bounds);
    CGFloat scrollLabelViewHeight = _sectionHeaderHeight - self.scrollLabelEdgeInsets.top - self.scrollLabelEdgeInsets.bottom;
    scrollLabelView.frame = CGRectMake(scrollLabelViewX, scrollLabelViewY, scrollLabelViewWidth, scrollLabelViewHeight);
    [sectionHeaderView addSubview:scrollLabelView];

    if (rightView) {
        CGFloat rightViewX = CGRectGetWidth(self.view.bounds) - self.scrollLabelEdgeInsets.right - CGRectGetWidth(rightView.bounds);
        CGFloat rightViewY = scrollLabelViewY;
        CGFloat rightViewHeight = scrollLabelViewHeight;
        rightView.frame = CGRectMake(rightViewX, rightViewY, CGRectGetWidth(rightView.frame), rightViewHeight);
        [sectionHeaderView addSubview:rightView];
    }

    return sectionHeaderView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return _sectionHeaderHeight;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return CGRectGetHeight(self.containerView.view.frame);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    static NSString *cellId = @"cellId";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }

    [cell.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [cell.contentView addSubview:self.containerView.view];
    return cell;
}

#pragma mark - AGContainerCollectionViewControllerDelegate

- (void)containerCollectionViewController:(AGContainerCollectionViewController *)containerViewController scrollAtIndex:(NSInteger)index currentContentController:(AGBaseViewController *)currentController {

    [self.scrollLabelView setCurrentLabelIndex:index sendScrollDelegate:NO];
    self.currentContontViewController = currentController;
    if ([currentController isKindOfClass:[AGBaseViewController class]]) {
        self.scrollViewLastContentOffset = currentController.lastContentOffset;
    } else {
        self.scrollViewLastContentOffset = CGPointZero;
    }
}

- (void)containerCollectionViewController:(AGScrollLabelView *)scrollLabelView willBeginOrWillEndDraggin:(BOOL)isBegin {
    if (self.scrollEnable) {
        self.tableView.scrollEnabled = !isBegin;
    }
}

- (void)containerCollectionViewDidScroll:(UICollectionView *)collectionView {
    [self.scrollLabelView lineViewScroll:collectionView];
}

#pragma mark - AGScrollLabelViewDelegate

- (void)scrollLabel:(AGScrollLabelView *)scrollLabelView cell:(UICollectionViewCell *)cell didSelectIndex:(NSInteger)index {

    [self.containerView scrollToItemAtIndex:index];
    [self scrollLabelScrollCell:cell atIndex:index];
}

- (void)scrollLabelScrollCell:(UICollectionViewCell *)cell atIndex:(NSInteger)index {
}

/** 标签栏滚动的时候禁止 tableView 滚动 */
- (void)scrollLabel:(AGScrollLabelView *)scrollLabelView willBeginOrWillEndDraggin:(BOOL)isBegin {
    if (self.scrollEnable) {
        self.tableView.scrollEnabled = !isBegin;
    }
}

#pragma mark - lazy

- (ZJCustomGestureTableView *)tableView {
    if (!_tableView) {
        _tableView = [[ZJCustomGestureTableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.showsVerticalScrollIndicator = NO;
        _tableView.tableFooterView = [UIView new];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
        [self.view addSubview:_tableView];
    }
    return _tableView;
}

- (AGContainerCollectionViewController *)containerView {
    if (!_containerView) {

        CGRect frame = CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame) - _sectionHeaderHeight);

        _containerView = [[AGContainerCollectionViewController alloc] initWithChildControllers:self.ag_childControllers frame:frame];
        _containerView.delegate = (id<AGContainerCollectionViewControllerDelegate>) self;
        [self addChildViewController:_containerView];
    }
    return _containerView;
}

- (AGScrollLabelView *)scrollLabelView {
    if (!_scrollLabelView) {

        NSMutableArray *titles = [NSMutableArray array];
        for (UIViewController *vc in self.ag_childControllers) {
            if (!vc.title) {
                titles = nil;
                break;
            }
            [titles addObject:vc.title];
        }
        _scrollLabelView = [[AGScrollLabelView alloc] initWithTitls:titles frame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), _sectionHeaderHeight)];
        _scrollLabelView.delegate = self;
        [_scrollLabelView setSelectStyle:AGSelectStyleLine];
    }
    return _scrollLabelView;
}

@end
