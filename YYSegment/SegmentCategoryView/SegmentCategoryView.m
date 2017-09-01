
//
//  SegmentCategoryView.m
//  SegmentCategoryViewDemo
//
//  Created by zhenby on 6/30/14.
//  Copyright (c) 2014 zhenby. All rights reserved.
//

#import "SegmentCategoryView.h"
#import "SegmentCategoryBar.h"
#import "SegmentCategoryCell.h"
#import "SegmentCategoryCollectionView.h"
#import "UIScrollView+CUIPullRefreshing.h"
#import "UIScrollView+CUIInfiniteScrolling.h"
#import "FBKVOController.h"
#import "SegmentMoreButtonView.h"


#define CollectionViewBackgroundColor   [UIColor whiteColor]
#define SegmentBarAlphaColor            [UIColor colorWithWhite:1.0 alpha:1.0] //6.0设计说不要导航透明度了
const CGFloat NavBarDefaultTopContentInset                  =   64.0;
const CGFloat TabBarDefaultBottomContentInset               =   49.0;
const CGFloat ToolBarDefaultBottomContentInset              =   44.0;

static CGFloat SegmentCategoryBarHeight               =   40.0;
static const CGFloat DivisionWidth                          =   6.0;
static const CGFloat MoreButtonWidth                        =   43.0;
static const CGFloat HideCollectionViewButtonAlpha          =   0.5;
static       CGFloat CollectionViewItemHeigh                =   95.0;
static const CGFloat BottomShadowPadding                    =   0.5;
static const CGFloat AnimateDuration                        =   0.2;
static const CGFloat collectionViewGradientWidth            =   21.0;
static NSString * const SegmentCategoryCellId               =   @"SegmentCategoryCellId";

@interface SegmentCategoryView ()<UIScrollViewDelegate, SegmentCategoryBarDelegate, SegmentMoreButtonViewDelegate,
                                    UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
@property(strong, nonatomic) SegmentCategoryBar *categoryBar;
@property(strong, nonatomic) SegmentMoreButtonView *moreButtonView;
@property(strong, nonatomic) UIView *barBackgroundView;
@property(strong, nonatomic) UIScrollView *contentScrollView;
@property(strong, nonatomic) SegmentCategoryCollectionView *collectionView;
@property(strong, nonatomic) NSMutableDictionary *indicatorDic;
@property(strong, nonatomic) UIButton *hideCollectionViewButton;
@property(strong, nonatomic) UILabel *collectionViewTipsLabel;
@property(strong, nonatomic) UIImageView *shadowLineImageView;
@property(strong, nonatomic) UIImageView *shadowMoreButtonImageView;
@property(strong, nonatomic) NSMutableDictionary *contentViewDict;
@property(assign, nonatomic) BOOL isSendedWillChangeIndex;
@property(assign, nonatomic) CGFloat lastScrollContentOffset;
@property(assign, nonatomic) NSInteger willScrollToPage;
@property(assign, nonatomic) NSInteger triggerScrollToPage;
@property(assign, nonatomic) BOOL isFromMoreCollectionView;
@property(assign, nonatomic) NSInteger selectedIndexInner;
@property(strong, nonatomic) UIImageView *segmentCollectionViewGradient;
@property(strong, nonatomic) UIView *barActionView;

// 是否从 Bar 中点击分类进行的滚动，
@property(assign, nonatomic) BOOL isTriggerScrollFromCategoryBar;

@property(nonatomic, strong) FBKVOController *kvoController;




@end


@implementation SegmentCategoryView

@synthesize showIndicatorOnMoreButton = _showIndicatorOnMoreButton;

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        _selectedIndexInner = NSUIntegerMax;
        _categoryTitlePadding = -1;
        [self resetTriggerScrollToIndex];
        [self registerOrientationNotification];
        self.kvoController = [[FBKVOController alloc] initWithObserver:self];
    }
    
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _selectedIndexInner = NSUIntegerMax;
        _categoryTitlePadding = -1;
        [self resetTriggerScrollToIndex];
        [self registerOrientationNotification];
        _isSupportFull = NO;
    }
    
    return self;
}

- (void)dealloc
{
    [self unregisterOrientationNotification];
    _categoryBar.delegate = nil;
    _contentScrollView.delegate = nil;
    _collectionView.dataSource = nil;
    _collectionView.delegate = nil;
    _collectionView = nil;
    _moreButtonView.delegate = nil;
    _isSupportFull = NO;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    
    if ( ! ([self.delegate respondsToSelector:@selector(topInsetForHeaderView:)]) ) {
    
        [self resizeSubviews];
    }

}


#pragma mark - Setter

- (void)setHorizontalScrollDisable:(BOOL)horizontalScrollDisable
{
    if (horizontalScrollDisable != _horizontalScrollDisable) {
        _horizontalScrollDisable = horizontalScrollDisable;
        self.contentScrollView.scrollEnabled = !_horizontalScrollDisable;
    }
}

- (void)setCategoryBarBackgroundColor:(UIColor *)categoryBarBackgroundColor{
    _categoryBarBackgroundColor = categoryBarBackgroundColor;
    if (!self.barBackgroundView) {
        self.categoryBar.backgroundColor = _categoryBarBackgroundColor?:SegmentBarAlphaColor;
    } else {
        self.categoryBar.backgroundColor = _categoryBarBackgroundColor?:[UIColor clearColor];
    }

}

- (void)setCategoryBarHidden:(BOOL)categoryBarHidden {
    if (!_categoryBarHidden && categoryBarHidden) {
        CGFloat diff = CGRectGetHeight(self.categoryBar.frame);
        CGRect frame = self.collectionView.frame;
        frame.origin.y -= diff;
        frame.size.height += diff;
        self.collectionView.frame = frame;
        [self.categoryBar removeFromSuperview];
        SegmentCategoryBarHeight = 0;
    }
    _categoryBarHidden = categoryBarHidden;
}


#pragma mark - Public Methods

- (void)reloadData
{
    if (!self.dataSource || [self numberFirstSegment] == 0) {
        return;
    }
    
    [self initSubviews];
    [self resizeSubviews];
    
    if (self.categoryTitlePadding >= 0) {
        self.categoryBar.categoryTitlePadding = self.categoryTitlePadding;
    }
    
    self.categoryBar.categoryTitleArray = [self segmentTitleArray];

    [self.contentViewDict.allValues makeObjectsPerformSelector:@selector(removeFromSuperview)];
    self.contentViewDict = [NSMutableDictionary dictionary];
    
    self.contentScrollView.scrollEnabled = !self.horizontalScrollDisable;
    
    NSInteger scrollToIndex = self.selectedIndex;
    if (scrollToIndex < 0) {
        scrollToIndex = 0;
    }
    
    [self willScrollToIndex:scrollToIndex];
    [self.categoryBar scrollToIndex:scrollToIndex];
    [self scrollToIndex:scrollToIndex];
    [self didScrollToIndex:scrollToIndex];
}

- (void)reloadBarTitle
{
    NSArray *titleArray = [self segmentTitleArray];
    self.categoryBar.categoryTitleArray = titleArray;
}

- (void)showBarActionView:(UIView *)barActionView
{
    if (barActionView) {
        if (barActionView != self.barActionView) {
            self.barActionView = barActionView;
            [self initSubviews];
            [self resizeSubviews];
        }
    } else {
        [self.barActionView removeFromSuperview];
        self.barActionView = nil;
        [self resizeSubviews];
    }
}

- (UIView *)contentViewAtIndex:(NSUInteger)index
{
    return self.contentViewDict[@(index)];
}

- (void)triggerScrollToIndex:(NSUInteger)index
{
    self.triggerScrollToPage = index;
    [self scrollToIndex:index];
}

- (void)updateSegmentTitle:(NSString *)title atIndex:(NSInteger)index
{
    [self.categoryBar updateTitle:title atIndex:index];
}

- (void)updateSegmentAttributedTitle:(NSAttributedString *)attributedTitle atIndex:(NSInteger)index
{
    [self.categoryBar updateAttributedTitle:attributedTitle atIndex:index];
}

- (void)updateSegmentViewContentOffset
{
    // 此次用屏幕宽度来计算 offset，如果 SegmentCategoryView 不是铺满屏幕宽度的情况下，会有问题
    CGFloat contentOffsetX = self.selectedIndex * CGRectGetWidth([UIApplication sharedApplication].keyWindow.bounds);
    self.contentScrollView.contentOffset = CGPointMake(contentOffsetX, 0.0);
}

#pragma mark - private / helper methods
- (NSIndexPath *)__getIndexPathWithSecondSegmentIndex:(NSInteger)innerIndex
{
    NSInteger index = [self numberFirstSegment] + innerIndex;
    return [NSIndexPath indexPathForItem:index inSection:0];
}

#pragma mark - property getter/setter
- (void)setShowIndicatorOnMoreButton:(BOOL)showIndicator
{
    if (!self.showMoreButton) {
        return;
    }
    
    if (showIndicator != _showIndicatorOnMoreButton) {
        _showIndicatorOnMoreButton = showIndicator;
        self.moreButtonView.showIndicator = showIndicator;
    }
}

- (BOOL)isShowIndicatorOnMoreButton
{
    return _showIndicatorOnMoreButton;
}

- (void)showIndicator:(BOOL)show atSecondSegmentIndex:(NSInteger)innerIndex
{
    if (!self.indicatorDic) {
        self.indicatorDic = [NSMutableDictionary dictionary];
    }
    
    NSIndexPath *indexPath = [self __getIndexPathWithSecondSegmentIndex:innerIndex];
    self.indicatorDic[indexPath] = [NSNumber numberWithBool:show];
    [self.collectionView reloadData];
}

- (BOOL)isShowIndicatorAtSecondSegmentIndex:(NSInteger)innerIndex
{
    NSIndexPath *indexPath = [self __getIndexPathWithSecondSegmentIndex:innerIndex];
    return [self.indicatorDic[indexPath] boolValue];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    self.isSendedWillChangeIndex = NO;
    self.isTriggerScrollFromCategoryBar = NO;
    NSInteger index = self.contentScrollView.contentOffset.x / self.frame.size.width;
    [self.categoryBar scrollToIndex:index];
    [self didScrollToIndex:index];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    self.isSendedWillChangeIndex = NO;
    self.isTriggerScrollFromCategoryBar = NO;
    NSInteger index = self.contentScrollView.contentOffset.x / self.frame.size.width;
    [self.categoryBar scrollToIndex:index];
    [self didScrollToIndex:index];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGPoint pt = self.contentScrollView.contentOffset;
    NSInteger scrollToPage = pt.x / CGRectGetWidth(self.bounds);
    scrollToPage = (scrollToPage >= [[self segmentTitleArray] count]) ?
                    [[self segmentTitleArray] count] : scrollToPage;
    if (!self.isTriggerScrollFromCategoryBar) {
        CGFloat radio = (((NSInteger)pt.x) % (NSInteger)CGRectGetWidth(self.bounds) / CGRectGetWidth(self.bounds));
        [self.categoryBar setLineOffsetWithPage:scrollToPage ratio:radio];
    }
    
    if (![self isThereTriggerScrollToIndex]) {
        if (self.lastScrollContentOffset > scrollView.contentOffset.x) {
            scrollToPage = self.selectedIndex - 1;
        } else if (self.lastScrollContentOffset < scrollView.contentOffset.x) {
            scrollToPage = self.selectedIndex + 1;
        }
    
        if (scrollToPage != self.willScrollToPage) {
            self.willScrollToPage = scrollToPage;
            self.isSendedWillChangeIndex = NO;
        }
    } else {
        self.willScrollToPage = self.triggerScrollToPage;
    }
    
    if (self.willScrollToPage < 0) {
        self.willScrollToPage = 0;
    }
    
    if (self.willScrollToPage >= [[self segmentTitleArray] count]) {
        self.willScrollToPage = [[self segmentTitleArray] count] - 1;
    }
    
    if (!self.isSendedWillChangeIndex) {
        [self willScrollToIndex:self.willScrollToPage];
        self.isSendedWillChangeIndex = YES;
    }
        
    self.lastScrollContentOffset = scrollView.contentOffset.x;
}


#pragma mark - SegmentCategoryBarDelegate

- (void)segmentCategoryBar:(SegmentCategoryBar *)categoryBar selectedIndexChanged:(NSInteger)index
{
    self.isTriggerScrollFromCategoryBar = YES;
    [self triggerScrollToIndex:index];
}

#pragma mark - SegmentMoreButtonViewDelegate
-(void)onSegmentMoreButtonViewTapped
{
    if (!self.collectionView.superview) {
        [self showCollectionView];
    } else {
        [self hideCollectionView];
    }
}


#pragma mark - Action Handle
- (void)onHideCollectionViewButtonPressed
{
    [self hideCollectionView];
}


#pragma mark - CollectionView
#pragma mark Show/Hide

- (void)hideSubCollectionView
{
    [self hideCollectionView];
}

- (void)showCollectionView
{
    if (!self.collectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        CGFloat width = [[UIScreen mainScreen] bounds].size.width/4 - 1;
        CollectionViewItemHeigh = width+6.0;
        layout.itemSize = CGSizeMake(width, CollectionViewItemHeigh);
        layout.minimumLineSpacing = 1.0;
        layout.minimumInteritemSpacing = 1.0;
   
        self.collectionView = [[SegmentCategoryCollectionView alloc] initWithFrame:CGRectZero
                                                              collectionViewLayout:layout];
        self.collectionView.backgroundColor = CollectionViewBackgroundColor;
        [self.collectionView registerClass:[SegmentCategoryCell class]
                forCellWithReuseIdentifier:SegmentCategoryCellId];
        self.collectionView.dataSource = self;
        self.collectionView.delegate = self;
    }
    
    if (!self.hideCollectionViewButton) {
        self.hideCollectionViewButton = [[UIButton alloc] initWithFrame:CGRectZero];
        self.hideCollectionViewButton.backgroundColor = [UIColor blackColor];
        [self.hideCollectionViewButton addTarget:self
                                          action:@selector(onHideCollectionViewButtonPressed)
                                forControlEvents:UIControlEventTouchUpInside];
    }
    
    if (!self.collectionViewTipsLabel) {
        self.collectionViewTipsLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.collectionViewTipsLabel.textColor = [UIColor blackColor];
        self.collectionViewTipsLabel.font = [UIFont systemFontOfSize:16.0];
        self.collectionViewTipsLabel.backgroundColor = [UIColor whiteColor];
        self.collectionViewTipsLabel.userInteractionEnabled = YES;
        self.collectionViewTipsLabel.text = @"    选择分类";
    }
    
    CGFloat viewWidth = CGRectGetWidth(self.bounds);
    CGFloat viewHeight = CGRectGetHeight(self.bounds);
    CGFloat collectionViewY = CGRectGetMinY(self.shadowLineImageView.frame);
    
    double lineNumber = ceil(([self numberFirstSegment] + [self numberSecondSegment])/4.0);
    if (lineNumber >= 4.0) {
        lineNumber = 3.5;
    }
    CGFloat collectionViewHeight = lineNumber*CollectionViewItemHeigh;
    
    CGRect collectionViewFrame = CGRectMake(0.0, collectionViewY, viewWidth,0.0);
    self.collectionView.frame = collectionViewFrame;
    [self insertSubview:self.collectionView belowSubview:self.shadowLineImageView];
    [self.collectionView reloadData];
    
    CGRect hideButtonFrame = CGRectMake(0.0, collectionViewY, viewWidth, viewHeight - collectionViewY + TabBarDefaultBottomContentInset);
    self.hideCollectionViewButton.frame = hideButtonFrame;
    self.hideCollectionViewButton.alpha = 0.0;
    [self insertSubview:self.hideCollectionViewButton belowSubview:self.collectionView];
    
    
    CGRect tipsLabelFrame = CGRectMake(0.0, 0.0,
                                       viewWidth - MoreButtonWidth, SegmentCategoryBarHeight);
    self.collectionViewTipsLabel.frame = tipsLabelFrame;
    self.collectionViewTipsLabel.alpha = 0.0;
    [self insertSubview:self.collectionViewTipsLabel belowSubview:self.shadowMoreButtonImageView];
    
    self.segmentCollectionViewGradient = [[UIImageView alloc] initWithFrame:CGRectMake(0, collectionViewHeight +  SegmentCategoryBarHeight - collectionViewGradientWidth, viewWidth, collectionViewGradientWidth)];
    self.segmentCollectionViewGradient.image = [UIImage imageNamed:@"live_segmentcollectionview_shadow"];
    [self insertSubview:self.segmentCollectionViewGradient aboveSubview:self.collectionView];
    
    [UIView animateWithDuration:AnimateDuration animations:^{
        self.collectionView.frame = CGRectMake(0.0, collectionViewY,
                                               viewWidth, collectionViewHeight);
        self.hideCollectionViewButton.alpha = HideCollectionViewButtonAlpha;
        self.moreButtonView.backgroundColor = [UIColor whiteColor];
        self.collectionViewTipsLabel.alpha = 1.0;
        self.moreButtonView.buttonState = SegmentMoreButtonState_Expanded;
        self.segmentCollectionViewGradient.frame = CGRectMake(0, collectionViewHeight +  SegmentCategoryBarHeight - collectionViewGradientWidth, viewWidth, collectionViewGradientWidth);
    }];
    
    if ([self.delegate respondsToSelector:@selector(onMoreButtonTapInSegmentView:)]) {
        [self.delegate onMoreButtonTapInSegmentView:self];
    }
}

- (void)hideCollectionView
{
    [self.segmentCollectionViewGradient removeFromSuperview];
    [UIView animateWithDuration:AnimateDuration animations:^{
        CGRect collectionViewFrame = self.collectionView.frame;
        collectionViewFrame.size.height = 0.0;
        self.collectionView.frame = collectionViewFrame;
        self.hideCollectionViewButton.alpha = 0.0;
        self.collectionViewTipsLabel.alpha = 0.0;
        self.moreButtonView.buttonState = SegmentMoreButtonState_Normal;
        self.moreButtonView.backgroundColor = [UIColor clearColor];
    } completion:^(BOOL finished) {
        [self.hideCollectionViewButton removeFromSuperview];
        [self.collectionView removeFromSuperview];
        [self.collectionViewTipsLabel removeFromSuperview];
    }];
}


#pragma mark UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return ([self numberFirstSegment] + [self numberSecondSegment]);
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    SegmentCategoryCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:SegmentCategoryCellId
                                                                          forIndexPath:indexPath];
    
    if (indexPath.row < [self numberFirstSegment]) {
        NSString *title = nil;
        if ([self.dataSource respondsToSelector:@selector(segmentView:titleAtIndex:)]) {
            title = [self.dataSource segmentView:self titleAtIndex:indexPath.row];
        }
        
        if (self.selectedIndexInner == indexPath.row) {
            UIImage *selectedImage = nil;
            if ([self.dataSource respondsToSelector:@selector(segmentView:selectedImageIconAtIndex:)]) {
                selectedImage = [self.dataSource segmentView:self
                                    selectedImageIconAtIndex:indexPath.row];
                [cell setTitle:title selectedIconImage:selectedImage];
            }
        } else {
            UIImage *image = nil;
            if ([self.dataSource respondsToSelector:@selector(segmentView:imageIconAtIndex:)]) {
                image = [self.dataSource segmentView:self imageIconAtIndex:indexPath.row];
            }
            [cell setTitle:title iconImage:image];
        }
    } else if (indexPath.row < ([self numberFirstSegment] + [self numberSecondSegment])) {
        NSUInteger row = indexPath.row - [self numberFirstSegment];
        NSString *title = nil;
        if ([self.dataSource respondsToSelector:@selector(segmentView:secondeSegmentTitleAtIndex:)]) {
            title = [self.dataSource segmentView:self secondeSegmentTitleAtIndex:row];
        }
        
        UIImage *image = nil;
        if ([self.dataSource respondsToSelector:@selector(segmentView:secondSegmentImageIconAtIndex:)]) {
            image = [self.dataSource segmentView:self secondSegmentImageIconAtIndex:row];
        }
        [cell setTitle:title iconImage:image];
    }
    
    cell.showIndicator = [self.indicatorDic[indexPath] boolValue];
    
    return cell;
}


#pragma mark UICollectionViewDelegate

- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath
{
        return YES;
}

- (void)collectionView:(UICollectionView *)collectionView didHighlightItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger indexArr[] = {0, self.selectedIndexInner};
    SegmentCategoryCell *lastCell = (SegmentCategoryCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathWithIndexes:indexArr length:2]];
    SegmentCategoryCell *curCell = (SegmentCategoryCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
        
    UIImage *selectedImage = [self selectedImageIconAtIndex:indexPath.row];
    [curCell highlightedWithIconImage:selectedImage];
    
    if (lastCell != curCell) {
        UIImage *image = [self imageIconAtIndex:self.selectedIndexInner];
        [lastCell unhighlightedWithIconImage:image];
    }
}

-(void)collectionView:(UICollectionView *)collectionView didUnhighlightItemAtIndexPath:(NSIndexPath *)indexPath
{
    SegmentCategoryCell * curCell = (SegmentCategoryCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
    
    UIImage *image = [self imageIconAtIndex:indexPath.row];
    [curCell unhighlightedWithIconImage:image];
    
    // 保证正确的选中所在分类
    NSUInteger indexArr[] = {0, self.selectedIndexInner};
    SegmentCategoryCell *selectedCell = (SegmentCategoryCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathWithIndexes:indexArr length:2]];
    UIImage *selectedImage = [self selectedImageIconAtIndex:self.selectedIndexInner];
    [selectedCell highlightedWithIconImage:selectedImage];
}

- (void)collectionView:(UICollectionView *)collectionView
        didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [self hideCollectionView];
    
    if (indexPath.row < [self numberFirstSegment]) {
        self.isFromMoreCollectionView = YES;
        NSUInteger index = indexPath.row;
        [self willScrollToIndex:index];
        [self.categoryBar scrollToIndex:index];
        [self scrollToIndex:index];
        [self didScrollToIndex:index];
    } else if (indexPath.row < ([self numberFirstSegment] + [self numberSecondSegment])) {
        NSUInteger row = indexPath.row - [self numberFirstSegment];
        if ([self.delegate respondsToSelector:@selector(segmentView:didSelectedSecondSegmentAtIndex:)]) {
            [self.delegate segmentView:self didSelectedSecondSegmentAtIndex:row];
        }
    }
}


#pragma mark - Orientation

- (void)registerOrientationNotification
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(statusBarOrientationDidChange:)
                                                 name:UIApplicationDidChangeStatusBarOrientationNotification
                                               object:nil];
}

- (void)unregisterOrientationNotification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationDidChangeStatusBarOrientationNotification
                                                  object:nil];
}

- (void)statusBarOrientationDidChange:(NSNotification *)notification
{
    [self updateSegmentViewContentOffset];
}


#pragma mark - ViewController

- (void)viewWillAppear:(BOOL)animated
{
    if ([self.dataSource respondsToSelector:@selector(segmentView:contentViewControllerAtIndex:)]) {
        UIViewController *selectedViewController = [self.dataSource segmentView:self
                                                   contentViewControllerAtIndex:self.selectedIndex];
        [selectedViewController viewWillAppear:animated];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    if ([self.dataSource respondsToSelector:@selector(segmentView:contentViewControllerAtIndex:)]) {
        UIViewController *selectedViewController = [self.dataSource segmentView:self
                                                   contentViewControllerAtIndex:self.selectedIndex];
        [selectedViewController viewDidAppear:animated];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    if ([self.dataSource respondsToSelector:@selector(segmentView:contentViewControllerAtIndex:)]) {
        UIViewController *selectedViewController = [self.dataSource segmentView:self
                                                   contentViewControllerAtIndex:self.selectedIndex];
        [selectedViewController viewWillDisappear:animated];
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    if ([self.dataSource respondsToSelector:@selector(segmentView:contentViewControllerAtIndex:)]) {
        UIViewController *selectedViewController = [self.dataSource segmentView:self
                                                   contentViewControllerAtIndex:self.selectedIndex];
        [selectedViewController viewDidDisappear:animated];
    }
}


#pragma mark - Util Method

- (void)initSubviews
{
    if (!self.contentScrollView) {
        self.contentScrollView = [[UIScrollView alloc] initWithFrame:CGRectZero];
        self.contentScrollView.backgroundColor = [UIColor clearColor];
        self.contentScrollView.delegate = self;
        self.contentScrollView.pagingEnabled = YES;
        self.contentScrollView.showsHorizontalScrollIndicator = NO;
        self.contentScrollView.showsVerticalScrollIndicator = NO;
        self.contentScrollView.directionalLockEnabled = YES;
        self.contentScrollView.autoresizingMask = UIViewAutoresizingFlexibleHeight |
        UIViewAutoresizingFlexibleWidth;
        self.contentScrollView.scrollsToTop = NO;
        self.contentScrollView.decelerationRate = UIScrollViewDecelerationRateFast;
        [self addSubview:self.contentScrollView];
    }
    
    // 只要需要显示下拉按钮的才需添加 barBackgroundView，为了挡住下拉按钮旋转时露出的背景
    if (self.showMoreButton && !self.barBackgroundView) {
        self.barBackgroundView = [[UIView alloc] initWithFrame:CGRectZero];
        self.barBackgroundView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth;
        self.barBackgroundView.backgroundColor = SegmentBarAlphaColor;
        [self addSubview:self.barBackgroundView];
    }
    
    if (!self.categoryBar) {
        self.categoryBar = [[SegmentCategoryBar alloc] initWithFrame:CGRectZero];
        self.categoryBar.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth;
        self.categoryBar.delegate = self;
        
        // 如果有背景条 barBackgroundView，则 categoryBar 变成透明的，避免两个透明色重叠从而影响透明度
        if (!self.barBackgroundView) {
            self.categoryBar.backgroundColor = self.categoryBarBackgroundColor?:SegmentBarAlphaColor;
        } else {
            self.categoryBar.backgroundColor = self.categoryBarBackgroundColor?:[UIColor clearColor];
        }
        [self addSubview:self.categoryBar];
    }
    
    if (self.showMoreButton) {
        if (!self.shadowMoreButtonImageView) {
            self.shadowMoreButtonImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"segment_division.png"]];
            
            [self addSubview:self.shadowMoreButtonImageView];
        }
        
        if (!self.moreButtonView) {
            self.moreButtonView = [[SegmentMoreButtonView alloc] initWithFrame:CGRectZero];
            self.moreButtonView.delegate = self;
            self.moreButtonView.backgroundColor = [UIColor clearColor];
            self.moreButtonView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
            [self addSubview:self.moreButtonView];
        }
    } else if (self.barActionView && ![self.barActionView superview]) {
        [self addSubview:self.barActionView];
    }
    
    if (!self.shadowLineImageView) {
//        UIImage *shadowLineImage = [UIImage imageNamed:@"segment_bar_shadow_line.png"];
//        self.shadowLineImageView = [[UIImageView alloc] initWithImage:shadowLineImage];
        self.shadowLineImageView = [[UIImageView alloc] init];
        self.shadowLineImageView.backgroundColor = UIColorFromRGB(0xE8E8E8);
//        [self addSubview:self.shadowLineImageView];
        
        __weak __typeof__(self) wself = self;
        
        [self.kvoController unobserve:self.shadowLineImageView];
        [self.kvoController observe:self.categoryBar keyPath:@"frame" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld block:^(id observer, id object, NSDictionary *change) {
            
            wself.shadowLineImageView.frame = CGRectMake(0.0, CGRectGetMaxY([[change objectForKey:NSKeyValueChangeNewKey] CGRectValue]),
                                                         CGRectGetWidth(wself.bounds), BottomShadowPadding);
        }];
    }
}

- (void)resizeSubviews
{
    // 谁设置frame 超过屏幕宽度，谁2B。
    // segmentcategoryView 不支持横屏 请见谅，如需支持请找请找镇波
    //开播端的贡献榜需要这个横屏，所以给个属性设置一下；
    if (!_isSupportFull) {
        if (CGRectGetWidth(self.bounds) >= CGRectGetHeight([UIApplication sharedApplication].keyWindow.bounds)) {
            return;
        }
    }
    
    CGFloat beginY = _categoryBarHidden ? 0 : self.topContentInset;
    
    BOOL isShowBarActionView = self.showMoreButton || (self.barActionView != nil);
    CGFloat barActionViewWidth = 0;
    if (isShowBarActionView) {
        if (self.showMoreButton) {
            barActionViewWidth = DivisionWidth + MoreButtonWidth;
        } else {
            barActionViewWidth = [self.barActionView bounds].size.width;
        }
    }
    
    if (self.barBackgroundView) {
        self.barBackgroundView.frame = CGRectMake(0.0, beginY,
                                                  CGRectGetWidth(self.bounds),
                                                  SegmentCategoryBarHeight);
    }
    
    CGFloat cateoryBarWidth = isShowBarActionView ?
                                (CGRectGetWidth(self.bounds) -  barActionViewWidth) :
                                CGRectGetWidth(self.bounds);
    CGRect categoryBarFrame = CGRectMake(0.0, beginY + [self topInsetForHeaderView], cateoryBarWidth, SegmentCategoryBarHeight);
    self.categoryBar.frame = categoryBarFrame;

    if (self.shadowMoreButtonImageView) {
        self.shadowMoreButtonImageView.frame = CGRectMake(CGRectGetWidth(self.bounds) - barActionViewWidth,
                                                          beginY, DivisionWidth, SegmentCategoryBarHeight);
    }
    
    if (self.moreButtonView) {
        CGRect moreButtonFrame = CGRectMake(CGRectGetMaxX(self.shadowMoreButtonImageView.frame), beginY,
                                            MoreButtonWidth, SegmentCategoryBarHeight);
        self.moreButtonView.frame = moreButtonFrame;
    } else if (self.barActionView && [self.barActionView superview]) {
        self.barActionView.frame = CGRectMake(CGRectGetWidth(self.bounds) - barActionViewWidth,
                                              beginY,
                                              CGRectGetWidth(self.barActionView.bounds),
                                              SegmentCategoryBarHeight);
    }
    
    CGRect contentViewFrame = CGRectMake(0.0, beginY,
                                         CGRectGetWidth(self.bounds),
                                         CGRectGetHeight(self.bounds) - beginY);
    self.contentScrollView.frame = contentViewFrame;
    self.contentScrollView.contentSize = CGSizeMake([self numberFirstSegment] * CGRectGetWidth(self.bounds),
                                                    CGRectGetHeight(self.contentScrollView.bounds));
    
    self.shadowLineImageView.frame = CGRectMake(0.0, CGRectGetMaxY(categoryBarFrame),
                                                CGRectGetWidth(self.bounds), BottomShadowPadding);
    
    for (NSNumber *indexNumber in self.contentViewDict.allKeys) {
        UIView *contentView = self.contentViewDict[indexNumber];
        [self configUIScrollView:contentView atIndex:[indexNumber integerValue]];
    }
}

- (NSArray *)segmentTitleArray
{
    NSMutableArray *titleArray = [NSMutableArray array];
    
    if ([self.dataSource respondsToSelector:@selector(numberOfSegmentInSegmentView:)]) {
        NSUInteger number = [self.dataSource numberOfSegmentInSegmentView:self];
        for (NSUInteger index = 0; index < number; index++) {
            NSAttributedString *attributedTitle = nil;
            if ([self.dataSource respondsToSelector:@selector(segmentView:attributedTitleAtIndex:)]) {
                attributedTitle = [self.dataSource segmentView:self attributedTitleAtIndex:index];
            }
            
            if (!attributedTitle) {
                NSString *title = nil;
                if ([self.dataSource respondsToSelector:@selector(segmentView:titleAtIndex:)]) {
                    title = [self.dataSource segmentView:self titleAtIndex:index];
                }
                if (!title) {
                    title = @"";
                }
                
                [titleArray addObject:title];
            } else {
                [titleArray addObject: attributedTitle];
            }
        }
    }
    
    return ([titleArray count] > 0) ? [titleArray copy] : nil;
}

/**
 *  一次滑动过程只调用一次
 *
 *  @param index 要滑动到的index
 */
- (void)willScrollToIndex:(NSUInteger)index
{
    [self configContentViewAtIndex:index];
    
    if ([self.dataSource respondsToSelector:@selector(segmentView:contentViewControllerAtIndex:)]) {
        if ( self.selectedIndexInner != NSUIntegerMax ) {
            UIViewController *oldViewController = [self.dataSource segmentView:self
                                                  contentViewControllerAtIndex:self.selectedIndexInner];
            [oldViewController viewWillDisappear:YES];
        }
    
        UIViewController *newViewController = [self.dataSource segmentView:self
                                              contentViewControllerAtIndex:index];
        [newViewController viewWillAppear:YES];
    }
    
    if ([self.delegate respondsToSelector:@selector(segmentView:willSelectedAtIndex:)]) {
        [self.delegate segmentView:self willSelectedAtIndex:index];
    }
    else if ( [self.delegate respondsToSelector:@selector(segmentView:willSelectedAtIndex:isTriggeredFromCategoryBar:)] )
    {
        [self.delegate segmentView:self willSelectedAtIndex:index isTriggeredFromCategoryBar:_isTriggerScrollFromCategoryBar];
    }
}

- (void)scrollToIndex:(NSUInteger)index
{
    CGRect contentFrame = CGRectMake(index * CGRectGetWidth(self.bounds), 0.0,
                                     CGRectGetWidth(self.bounds),
                                     CGRectGetHeight(self.contentScrollView.bounds) - self.bottomContentInset);
    
    [self.contentScrollView scrollRectToVisible:contentFrame animated:YES];
}

- (void)didScrollToIndex:(NSUInteger)index
{
    if (self.selectedIndexInner != index) {
        self.selectedIndex = index;
        
        UIView *oldView = nil;
        UIView *newView = nil;
        if ([self.dataSource respondsToSelector:@selector(segmentView:contentViewControllerAtIndex:)]) {
            if (NSUIntegerMax != self.selectedIndexInner) {
                UIViewController *oldViewController = [self.dataSource segmentView:self
                                                      contentViewControllerAtIndex:self.selectedIndexInner];
                [oldViewController viewDidDisappear:YES];
                oldView = oldViewController.view;
            }
            
            UIViewController *newViewController = [self.dataSource segmentView:self
                                                  contentViewControllerAtIndex:index];
            [newViewController viewDidAppear:YES];
            newView = newViewController.view;
        } else {
            oldView = [self contentViewAtIndex:self.selectedIndexInner];
            newView = [self contentViewAtIndex:index];
        }
        
        if ([oldView isKindOfClass:[UIScrollView class]]) {
            ((UIScrollView *)oldView).scrollsToTop = NO;
        }
        if ([newView isKindOfClass:[UIScrollView class]]) {
            ((UIScrollView *)newView).scrollsToTop = YES;
        }
        
        if ([self.delegate respondsToSelector:@selector(segmentView:didSelectedAtIndex:isFromMoreCollectionView:)]) {
            [self.delegate segmentView:self
                    didSelectedAtIndex:index
              isFromMoreCollectionView:self.isFromMoreCollectionView];
            
            self.isFromMoreCollectionView = NO;
        } else if ([self.delegate respondsToSelector:@selector(segmentView:didSelectedAtIndex:)]) {
            [self.delegate segmentView:self didSelectedAtIndex:index];
        }

        self.selectedIndexInner = index;
    }
    
    [self resetTriggerScrollToIndex];
}

- (NSUInteger)numberFirstSegment
{
    NSUInteger numberFirstSegment = 0;
    if ([self.dataSource respondsToSelector:@selector(numberOfSegmentInSegmentView:)]) {
        numberFirstSegment = [self.dataSource numberOfSegmentInSegmentView:self];
    }
    
    return numberFirstSegment;
}

- (NSUInteger)numberSecondSegment
{
    NSUInteger numberSecondSegment = 0;
    if ([self.dataSource respondsToSelector:@selector(numberOfSecondSegmentInSegmentView:)]) {
        numberSecondSegment = [self.dataSource numberOfSecondSegmentInSegmentView:self];
    }
    
    return numberSecondSegment;
}

- (UIImage *)selectedImageIconAtIndex:(NSInteger)index
{
    UIImage *selectedImage = nil;
    
    if (index < [self numberFirstSegment]) {
        if ([self.dataSource respondsToSelector:@selector(segmentView:selectedImageIconAtIndex:)]) {
            selectedImage = [self.dataSource segmentView:self selectedImageIconAtIndex:index];
        }
    } else if (index < [self numberFirstSegment] + [self numberSecondSegment]) {
        if ([self.dataSource respondsToSelector:@selector(segmentView:secondSegmentImageIconAtIndex:)]) {
            selectedImage = [self.dataSource segmentView:self
                   secondSegmentSelectedImageIconAtIndex:index - [self numberFirstSegment]];
        }
    }
    
    return selectedImage;
}

- (UIImage *)imageIconAtIndex:(NSInteger)index
{
    UIImage *image = nil;
    
    if (index < [self numberFirstSegment]) {
        if ([self.dataSource respondsToSelector:@selector(segmentView:selectedImageIconAtIndex:)]) {
            image = [self.dataSource segmentView:self imageIconAtIndex:index];
        }
    } else if (index < [self numberFirstSegment] + [self numberSecondSegment]) {
        if ([self.dataSource respondsToSelector:@selector(segmentView:secondSegmentImageIconAtIndex:)]) {
            image = [self.dataSource segmentView:self
                   secondSegmentImageIconAtIndex:index - [self numberFirstSegment]];
        }
    }
    
    return image;
}

- (void)resetTriggerScrollToIndex
{
    self.triggerScrollToPage = -1;
}

- (BOOL)isThereTriggerScrollToIndex
{
    return (self.triggerScrollToPage >= 0);
}

- (void)configContentViewAtIndex:(NSInteger)index
{
    // 如果已经缓存到 contentViewDict 中了，则直接返回
    if (self.contentViewDict[@(index)]) {
        return;
    }
    
    UIView *contentView = nil;
    if ([self.dataSource respondsToSelector:@selector(segmentView:contentViewControllerAtIndex:)]) {
        contentView = [self.dataSource segmentView:self contentViewControllerAtIndex:index].view;
    } else if ([self.dataSource respondsToSelector:@selector(segmentView:contentViewAtIndex:)]) {
        contentView = [self.dataSource segmentView:self contentViewAtIndex:index];
    }
    
    if (contentView) {
        [self configUIScrollView:contentView atIndex:index];
        
        // 第一次加载时，需要正确设置 contentOffset，而以后都不需要重新设置，所以抽到这里写
        if ([contentView isKindOfClass:[UIScrollView class]]) {
            ((UIScrollView *)contentView).contentOffset = CGPointMake(0.0, -SegmentCategoryBarHeight - [self currentOffsetForCategoryBar]);
            ((UIScrollView *)contentView).scrollsToTop = NO;
        }
        
        [self.contentScrollView addSubview:contentView];
        
        [self.contentViewDict setObject:contentView forKey:@(index)];
    }
}

- (void)configUIScrollView:(UIView *)contentView atIndex:(NSInteger)index
{
    if ([contentView isKindOfClass:[UIScrollView class]]) {
        UIScrollView *scrollView = (UIScrollView *)contentView;
        
        scrollView.contentInset = UIEdgeInsetsMake(SegmentCategoryBarHeight + [self topInsetForHeaderView], 0.0,
                                                   self.bottomContentInset, 0.0);

        scrollView.scrollIndicatorInsets = scrollView.contentInset;
        
        CGRect contentViewFrame = CGRectMake(index * CGRectGetWidth(self.contentScrollView.bounds),
                                             0.0,
                                             CGRectGetWidth(self.contentScrollView.bounds),
                                             CGRectGetHeight(self.contentScrollView.bounds));
        scrollView.frame = contentViewFrame;
        
        // 为了防止上拉刷新、下拉加载更多时把 contentInset 覆盖，所以需要通知上拉、下拉 contentInset 的变化
        
        
        NSString *title = nil;
        if (index < self.categoryBar.categoryTitleArray.count) {
            title = [self.categoryBar.categoryTitleArray objectAtIndex:index];
        }
        
        if (scrollView.infiniteScrollingView && ![title isEqualToString:@"动态"]) {
            [scrollView changeInfiniteScrollingViewOriginalContentInset:scrollView.contentInset];
        }
        
        if (scrollView.pullRefreshingHeader) {
            [scrollView changePullRefreshingViewOriginalContentInset:scrollView.contentInset];
        }
    } else {
        CGRect contentViewFrame = CGRectMake(index * CGRectGetWidth(self.bounds), SegmentCategoryBarHeight,
                                             CGRectGetWidth(self.bounds),
                                             CGRectGetHeight(self.contentScrollView.bounds) - self.bottomContentInset - SegmentCategoryBarHeight);
        contentView.frame = contentViewFrame;
    }
    
}

- (CGFloat)topInsetForHeaderView
{
    if (self.dataSource != nil && [self.dataSource respondsToSelector:@selector(topInsetForHeaderView:)]) {
        return [self.dataSource topInsetForHeaderView:self];
    }
    
    return 0;
}

- (CGFloat)currentOffsetForCategoryBar
{
    if (self.dataSource != nil && [self.dataSource respondsToSelector:@selector(currentOffsetForCategoryBar:)]) {
        return [self.dataSource currentOffsetForCategoryBar:self];
    }
    
    return 0;
}

@end
