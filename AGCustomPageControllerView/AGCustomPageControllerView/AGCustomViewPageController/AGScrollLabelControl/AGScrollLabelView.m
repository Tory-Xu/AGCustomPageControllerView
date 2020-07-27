//
//  AGScrollLabelView.m
//  AGCustomPageControllerView
//
//  Created by yang_0921 on 2016/12/9.
//  Copyright © 2016年 yang_0921. All rights reserved.
//

#import "AGScrollLabelView.h"
#import "AGLabelCell.h"
#import "TestTool.h"

@interface AGScrollLabelView () <UICollectionViewDelegate,
                                 UICollectionViewDataSource,
                                 UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic, strong) NSMutableArray *titlesArr;

@property (nonatomic, strong) NSArray *iconsArr;

@property (nonatomic, strong) UIView *lineView;

@property (nonatomic, assign) CGFloat lineViewHeight;
@property (nonatomic, assign) CGFloat lineViewY;

@property (nonatomic, strong) NSMutableArray *itemSizeArr;
@property (nonatomic, strong) NSMutableArray<NSString *> *cellFrameArr;

@property (nonatomic, assign) NSInteger currentIndex;

// 使用时设置标签的个数：如果是自定义类型的 标签，需要设置此参数
@property (nonatomic, assign) NSInteger labelCount;

@end

static NSString *cellId = @"ag_cellId";

static CGFloat k_leftAndRightMargin = 0;
static CGFloat k_height_Of_LineView = 3;

@implementation AGScrollLabelView

#pragma mark - init

- (instancetype)initWithTitls:(NSArray *)titles frame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _titlesArr = [NSMutableArray arrayWithArray:titles];
        [self ag_setup];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self ag_setup];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - rewrite

- (void)layoutSubviews {
    [super layoutSubviews];
    self.collectionView.frame = self.bounds;
}

#pragma mark - private

- (void)ag_setup {
    self.currentIndex = 0;
    self.labelAlignment = AGLabelAlignmentLeft;

    [self.collectionView addSubview:self.lineView];
}

- (void)scrollToIndex:(NSInteger)index sendScrollDelegate:(BOOL)sendDelegate {
    self.currentIndex = index;

    if (sendDelegate && [self.delegate respondsToSelector:@selector(scrollLabel:cell:didSelectIndex:)]) {

        UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
        [self.delegate scrollLabel:self cell:cell didSelectIndex:index];
    }

    /**
     cell是复用的，在滑动到后边的cell时，前面的（0，1，2..）的 cell 通过上面方法获取到的是 nil，因为被复用了
     这导致我们不能通过获取 cell 来获取到 cell 的 frame。使用数组进行保存 cell 的 frame 数据
     */
    CGRect cellFrame = CGRectFromString(self.cellFrameArr[index]);

    CGFloat halfWidth = CGRectGetWidth(self.frame) * 0.5;
    CGFloat centerX = cellFrame.origin.x + cellFrame.size.width * 0.5;
    CGFloat scrollX = centerX - halfWidth;
    CGFloat lestX = [self widthOfCollectionView] - centerX;

#warning 待优化
    BOOL animated = NO;      // 设置为YES，则不能正常滚动
    if (lestX < halfWidth) { // 右边不需要移动部分
        [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:self.labelCount - 1 inSection:0] atScrollPosition:UICollectionViewScrollPositionRight animated:animated];
    } else if (scrollX < 0) {
        [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UICollectionViewScrollPositionLeft animated:animated];
    } else {
        [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:animated];
    }

    [self.collectionView selectItemAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] animated:animated scrollPosition:UICollectionViewScrollPositionCenteredHorizontally];
    // 刷新指定 cell 不成功
    [self.collectionView reloadData];

    if (sendDelegate && self.selectStyle == AGSelectStyleLine) {
        [UIView animateWithDuration:0.5
                         animations:^{
                             self.lineView.frame = CGRectMake(0, self.lineViewY, cellFrame.size.width, self.lineViewHeight);
                             self.lineView.center = CGPointMake(centerX, self.lineView.center.y);
                         }];
    }
}

- (CGFloat)widthOfCollectionView {
    return MAX(self.collectionView.contentSize.width, CGRectGetWidth(self.collectionView.frame));
}

#pragma mark - public

- (void)setBounces:(BOOL)bounces {
    self.collectionView.bounces = bounces;
}

- (void)setSelectStyle:(AGSelectStyle)selectStyle {
    _selectStyle = selectStyle;

    switch (selectStyle) {
        case AGSelectStyleNone: {
            [self.lineView removeFromSuperview];
            self.lineView = nil;
            break;
        }
        case AGSelectStyleLine: {

            self.lineViewHeight = k_height_Of_LineView;
            self.lineViewY = CGRectGetHeight(self.collectionView.frame) - k_height_Of_LineView;
            break;
        }
        default:
            break;
    }
}

- (void)setLabelAlignment:(AGLabelAlignment)labelAlignment {
    _labelAlignment = labelAlignment;
    switch (labelAlignment) {
        case AGLabelAlignmentLeft: {
            break;
        }
        case AGLabelAlignmentPull: {
            [self.collectionView reloadData];
            break;
        }
        default:
            break;
    }
}

- (void)setContentInsets:(UIEdgeInsets)contentInsets {
    self.collectionView.contentInset = contentInsets;
}

/**
    设置当前标签位置：
        注意，如果一开始就设置初始位置，由于是使用 collectionView 实现，需要等待 collectionView cell 加载完毕再进行切换，因此有一个延时操作
*/
- (void)setCurrentLabelIndex:(NSInteger)index {
    [self setCurrentLabelIndex:index sendScrollDelegate:YES];
}

- (void)setCurrentLabelIndex:(NSInteger)index sendScrollDelegate:(BOOL)sendDelegate {
    void (^cellFrameDidComputed)(AGScrollLabelView *weakSelf, BOOL sendDelegate) = ^(AGScrollLabelView *obj, BOOL sendDelegate) {
        if (obj) {
            if (index < obj.cellFrameArr.count) {
                [obj scrollToIndex:index sendScrollDelegate:sendDelegate];
            } else {
                NSLog(@"数组越界");
            }
        }
    };
    
    if (self.cellFrameArr.count) {
        cellFrameDidComputed(self, sendDelegate);
        return;
    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        cellFrameDidComputed(self, sendDelegate);
    });
}

- (void)registerClass:(Class)cellClass forCellWithReuseIdentifier:(NSString *)identifier {

    [self.collectionView registerClass:cellClass forCellWithReuseIdentifier:identifier];
}

- (void)updateTitles:(NSArray<NSString *> *)titles {
    self.titlesArr = [NSMutableArray arrayWithArray:titles];
    [self scrollToIndex:0 sendScrollDelegate:YES];
    /** 清空重新计算 */
    [self.itemSizeArr removeAllObjects];
    [self.cellFrameArr removeAllObjects];
    [self.collectionView reloadData];
}

- (void)lineViewScroll:(UICollectionView *)collectionView {
    NSInteger count = collectionView.contentOffset.x / (CGRectGetWidth(collectionView.frame) * 0.5);
    NSInteger index = count / 2 + count % 2;

    CGFloat indexOffsetX = index * CGRectGetWidth(collectionView.frame);
    CGFloat offsetX = collectionView.contentOffset.x - indexOffsetX;
    CGFloat percent = fabs(offsetX) / CGRectGetWidth(collectionView.frame) * 2;

    if (offsetX < 0 && index > 0) { // 左侧变化
        NSInteger nextIndex = index - 1;
        NSString *cellFrameString = self.cellFrameArr[nextIndex];
        CGRect cellFrame = CGRectFromString(cellFrameString);
        CGFloat offsetWidth = CGRectGetWidth(cellFrame) * percent;

        NSString *currentCellFrameString = self.cellFrameArr[index];
        CGRect lineFrame = CGRectFromString(currentCellFrameString);
        lineFrame.size.width = offsetWidth + CGRectGetWidth(lineFrame);
        lineFrame.size.height = self.lineViewHeight;
        lineFrame.origin.y = self.lineView.frame.origin.y;
        lineFrame.origin.x -= offsetWidth;
        self.lineView.frame = lineFrame;
    } else if (offsetX > 0 && index + 1 < self.labelCount) { // 右侧变化
        NSInteger nextIndex = index + 1;
        NSString *cellFrameString = self.cellFrameArr[nextIndex];
        CGRect cellFrame = CGRectFromString(cellFrameString);
        CGFloat offsetWidth = CGRectGetWidth(cellFrame) * percent;

        NSString *currentCellFrameString = self.cellFrameArr[index];
        CGRect lineFrame = CGRectFromString(currentCellFrameString);
        lineFrame.size.width = offsetWidth + CGRectGetWidth(lineFrame);
        lineFrame.size.height = self.lineViewHeight;
        lineFrame.origin.y = self.lineView.frame.origin.y;
        self.lineView.frame = lineFrame;
    }
}

- (void)setDelegate:(id<AGScrollLabelViewDelegate>)delegate {
    _delegate = delegate;
    if ([self.delegate respondsToSelector:@selector(registerCellForScrollLabel:)]) {
        [self.delegate registerCellForScrollLabel:self];
    } else {
        [self.collectionView registerClass:[AGLabelCell class] forCellWithReuseIdentifier:cellId];
    }
}

#pragma mark - scroll delegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if ([self.delegate respondsToSelector:@selector(scrollLabel:willBeginOrWillEndDraggin:)]) {
        [self.delegate scrollLabel:self willBeginOrWillEndDraggin:YES];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if ([self.delegate respondsToSelector:@selector(scrollLabel:willBeginOrWillEndDraggin:)]) {
        [self.delegate scrollLabel:self willBeginOrWillEndDraggin:NO];
    }
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {

    [self scrollToIndex:indexPath.row sendScrollDelegate:YES];
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGSize size = [self computeItemSizeIndexPath:indexPath];
    if (indexPath.row + 1 == self.labelCount) {
        [self computeCellFrame];
    }
    return size;
}

- (CGSize)computeItemSizeIndexPath:(NSIndexPath *)indexPath {
    if ([self.delegate respondsToSelector:@selector(scrollLabel:sizeForCellAtIndexPath:)]) {
        return [self sizeOfCustomCellAtIndexPath:indexPath];
    }
    return [self sizeOfLabelCellAtIndexPath:indexPath];
}

- (CGSize)sizeOfCustomCellAtIndexPath:(NSIndexPath *)indexPath {
    CGSize size = [self.delegate scrollLabel:self sizeForCellAtIndexPath:indexPath];
    NSString *sizeString = NSStringFromCGSize(size);
    if (self.labelAlignment == AGLabelAlignmentPull) {
        size.width = CGRectGetWidth(self.frame) / self.titlesArr.count;
    }
    if (self.itemSizeArr.count < indexPath.row + 1) {
        [self.itemSizeArr addObject:sizeString];
    } else {
        [self.itemSizeArr replaceObjectAtIndex:indexPath.row withObject:sizeString];
    }
    return CGSizeFromString(sizeString);
}

- (CGSize)sizeOfLabelCellAtIndexPath:(NSIndexPath *)indexPath {
    if (self.itemSizeArr.count < indexPath.row + 1) {
        CGFloat width = 0;
        if (self.labelAlignment == AGLabelAlignmentPull) {
            width = CGRectGetWidth(self.frame) / self.titlesArr.count;
        } else {
            width = [self widthOfTitleAtIndex:indexPath.row];
        }
        CGSize size = CGSizeMake(width, CGRectGetHeight(self.frame));
        NSString *sizeString = NSStringFromCGSize(size);

        [self.itemSizeArr addObject:sizeString];
        return size;
    }
    NSString *sizeString = self.itemSizeArr[indexPath.row];
    return CGSizeFromString(sizeString);
}

- (void)computeCellFrame {
    [self.cellFrameArr removeAllObjects];
    CGSize firstSize = CGSizeFromString(self.itemSizeArr[0]);
    CGRect firstFrame = CGRectMake(k_leftAndRightMargin, 0, firstSize.width, firstSize.height);
    NSString *cellFrame = NSStringFromCGRect(firstFrame);
    [self.cellFrameArr addObject:cellFrame];

    CGRect lastFrame = firstFrame;
    CGFloat x = 0;
    CGFloat y = 0;
    for (int index = 1; index < self.labelCount; index++) {

        x = CGRectGetMaxX(lastFrame);
        CGSize size = CGSizeFromString(self.itemSizeArr[index]);
        CGRect frame = CGRectMake(x, y, size.width, size.height);
        [self.cellFrameArr addObject:NSStringFromCGRect(frame)];
        lastFrame = frame;
    }
}

- (CGFloat)widthOfTitleAtIndex:(NSInteger)index {
    NSString *title = self.titlesArr[index];
    return [title boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGRectGetHeight(self.frame))
                               options:NSStringDrawingUsesLineFragmentOrigin
                            attributes:@{ NSFontAttributeName: [UIFont systemFontOfSize:14] }
                               context:nil]
               .size.width +
           10;
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if ([self.delegate respondsToSelector:@selector(numberOfItemsInScrollLabelView:)]) {
        self.labelCount = [self.delegate numberOfItemsInScrollLabelView:self];
    } else {
        self.labelCount = self.titlesArr.count;
    }
    return self.labelCount;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = nil;
    if ([self.delegate respondsToSelector:@selector(scrollLabel:collectionView:cellforIndexPath:)]) {
        cell = [self.delegate scrollLabel:self collectionView:self.collectionView cellforIndexPath:indexPath];
    } else {
        cell = [self labelCellAtIndexPath:indexPath];
    }

    /**
        此处设置，主要是为了设置 标签 的初始位置：
            由于使用的是 collectionView，第一个 cell 的 frame 需要在 collectionView 加载出来以后才能够获得
        因此设置初始的 标签 位置就边的比较麻烦了
     */
    if (self.currentIndex == 0 && indexPath.row == 0) {
        self.lineView.frame = CGRectMake(cell.frame.origin.x, self.lineViewY, CGRectGetWidth(cell.frame), self.lineViewHeight);
    }

    [self.collectionView selectItemAtIndexPath:[NSIndexPath indexPathForRow:self.currentIndex inSection:0] animated:YES scrollPosition:UICollectionViewScrollPositionCenteredVertically];

    return cell;
}

- (AGLabelCell *)labelCellAtIndexPath:(NSIndexPath *)indexPath {
    AGLabelCell *labelCell = [self.collectionView dequeueReusableCellWithReuseIdentifier:cellId forIndexPath:indexPath];
    labelCell.title = self.titlesArr[indexPath.row];
    labelCell.contentView.backgroundColor = [UIColor colorWithRed:indexPath.row * 30 / 255.0 green:indexPath.row * 30 / 255.0 blue:indexPath.row / 255.0 alpha:1];
    return labelCell;
}

#pragma mark - lazy

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        layout.minimumLineSpacing = 0;
        layout.minimumInteritemSpacing = 0;
        layout.sectionInset = UIEdgeInsetsMake(0, k_leftAndRightMargin, 0, k_leftAndRightMargin);

        _collectionView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:layout];
        _collectionView.backgroundColor = self.backgroundColor;
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        [self addSubview:_collectionView];
    }
    return _collectionView;
}

- (UIView *)lineView {
    if (!_lineView) {
        _lineView = [[UIView alloc] init];
        _lineView.backgroundColor = [UIColor redColor];
    }
    return _lineView;
}

- (NSMutableArray *)itemSizeArr {
    if (!_itemSizeArr) {
        _itemSizeArr = [[NSMutableArray alloc] init];
    }
    return _itemSizeArr;
}

- (NSMutableArray<NSString *> *)cellFrameArr {
    if (!_cellFrameArr) {
        _cellFrameArr = [[NSMutableArray alloc] init];
    }
    return _cellFrameArr;
}

@end
