//
//  AGContainerCollectionViewController.m
//  AGCustomPageControllerView
//
//  Created by yang_0921 on 2016/12/7.
//  Copyright © 2016年 yang_0921. All rights reserved.
//

#import "AGContainerCollectionViewController.h"

@interface AGContainerCollectionViewController () <UICollectionViewDelegate,
                                                   UICollectionViewDataSource>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UICollectionViewFlowLayout *layout;

@property (nonatomic, strong) NSArray *ag_childControllers;

@property (nonatomic, strong) NSMutableArray<NSNumber *> *didLoadViewIndex;

@end

@implementation AGContainerCollectionViewController {
    NSInteger _lastIndex;
}

static NSString *const reuseIdentifier = @"Cell";

- (instancetype)initWithChildControllers:(NSArray<UIViewController *> *)ag_childControllers frame:(CGRect)frame {
    self = [super init];
    if (self) {
        _ag_childControllers = ag_childControllers;
        _frame = frame;
        self.view.frame = frame;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addChildViewController];
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:reuseIdentifier];
}

- (void)setBounces:(BOOL)bounces {
    self.collectionView.bounces = bounces;
}

- (void)setCollectionScrollEnable:(BOOL)scrollEnable {
    self.collectionView.scrollEnabled = scrollEnable;
}

- (void)scrollToItemAtIndex:(NSInteger)index {
    /** 直接求换到响应界面，不做滚动动作。如果做滚动动作，滚动经过的界面都会被显示而调用viewDidLoad方法进行加载 */
    self.collectionView.contentOffset = CGPointMake(CGRectGetWidth(self.collectionView.frame) * index, 0);
    [self scrollViewDidEndScrollingAnimation:self.collectionView];
    //    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    //    [self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];
}

- (void)updateChildContollers:(NSArray<UIViewController *> *)childControllers {
    self.ag_childControllers = childControllers;
    [self addChildViewController];
    [self.collectionView reloadData];
}

- (void)addChildViewController {
    [self.childViewControllers makeObjectsPerformSelector:@selector(removeFromParentViewController)];
    for (UIViewController *vc in self.ag_childControllers) {
        [self addChildViewController:vc];
    }
}

#pragma mark - scroll view delegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if ([self.delegate respondsToSelector:@selector(containerCollectionViewController:willBeginOrWillEndDraggin:)]) {
        [self.delegate containerCollectionViewController:self willBeginOrWillEndDraggin:YES];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if ([self.delegate respondsToSelector:@selector(containerCollectionViewController:willBeginOrWillEndDraggin:)]) {
        [self.delegate containerCollectionViewController:self willBeginOrWillEndDraggin:NO];
    }
}

/**
    滚动过程标签跟随变化
 */
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    NSInteger count = scrollView.contentOffset.x / (CGRectGetWidth(self.collectionView.frame) * 0.5);
    NSInteger index = count / 2 + count % 2;
    index = MAX(0, MIN(self.ag_childControllers.count - 1, index));
    if (_lastIndex != index && [self.delegate respondsToSelector:@selector(containerCollectionViewController:scrollAtIndex:currentContentController:)]) {
        _lastIndex = index;
        [self.delegate containerCollectionViewController:self scrollAtIndex:index currentContentController:self.ag_childControllers[index]];
    }

    if ([self.delegate respondsToSelector:@selector(containerCollectionViewDidScroll:)]) {
        [self.delegate containerCollectionViewDidScroll:self.collectionView];
    }
}

/** 滑动停止才载入页面 */
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    //    if ([self.delegate respondsToSelector:@selector(containerCollectionViewController:scrollAtIndex:currentContentController:)]) {
    //        NSInteger index = scrollView.contentOffset.x / CGRectGetWidth(self.collectionView.frame);
    //        [self.delegate containerCollectionViewController:self scrollAtIndex:index currentContentController:self.ag_childControllers[index]];
    //    }
    [self scrollViewDidEndScrollingAnimation:scrollView];
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    NSInteger index = scrollView.contentOffset.x / CGRectGetWidth(self.collectionView.frame);
    if (![self.didLoadViewIndex containsObject:@(index)]) {
        [self.didLoadViewIndex addObject:@(index)];
        UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
        /** cell 不一定能获取到，获取不到的时候，通过数据源方法添加vc.view */
        if (!cell) {
            [self.collectionView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]]];
            return;
        } else {
            UIViewController *vc = self.ag_childControllers[index];
            vc.view.frame = self.frame;
            [cell.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
            [cell.contentView addSubview:vc.view];
        }
    }
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {

    return self.ag_childControllers.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    [cell.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    if ([self.didLoadViewIndex containsObject:@(indexPath.row)]) {
        UIViewController *vc = self.ag_childControllers[indexPath.row];
        vc.view.frame = self.frame;
        [cell.contentView addSubview:vc.view];
    } else {
        NSUInteger currrentIndex = collectionView.contentOffset.x / self.layout.itemSize.width;
        if (currrentIndex == indexPath.row) {
            UIViewController *vc = self.ag_childControllers[indexPath.row];
            vc.view.frame = self.frame;
            [cell.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
            [cell.contentView addSubview:vc.view];
        }
    }
    return cell;
}

#pragma mark - lazy

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        _collectionView = [[UICollectionView alloc] initWithFrame:self.frame collectionViewLayout:self.layout];
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        _collectionView.pagingEnabled = YES;
        _collectionView.backgroundColor = [UIColor whiteColor];
        [self.view addSubview:_collectionView];
    }
    return _collectionView;
}

- (NSMutableArray<NSNumber *> *)didLoadViewIndex {
    if (!_didLoadViewIndex) {
        _didLoadViewIndex = @[@0].mutableCopy;
    }
    return _didLoadViewIndex;
}

- (void)dealloc {
    NSLog(@"AGContainerCollectionViewController dealloc");
}

- (UICollectionViewFlowLayout *)layout {
	if(_layout == nil) {
        _layout = [[UICollectionViewFlowLayout alloc] init];
        _layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        _layout.itemSize = self.frame.size;
        _layout.minimumLineSpacing = 0;
	}
	return _layout;
}

@end
