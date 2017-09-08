//
//  SegmentCategoryView.m
//  YYSegment
//
//  Created by ouzhirui on 2017/7/29.
//  Copyright © 2017年 YY. All rights reserved.
//

#import "SegmentCategoryView.h"
#import "SegmentCategoryBar.h"

static const CGFloat kCategoryBarHeight = 40;

@interface SegmentCategoryView ()<SegmentCategoryBarDelegate, UIScrollViewDelegate>

@property (nonatomic, assign) BOOL hasLoaded;
@property (nonatomic, strong) NSMutableDictionary *contentViewDict;

@property(assign, nonatomic) NSInteger selectedIndexInner;
@property(assign, nonatomic) BOOL isTriggerScrollFromCategoryBar;
@property(assign, nonatomic) BOOL isSendedWillChangeIndex;
@property(assign, nonatomic) NSInteger triggerScrollToPage;
@property(assign, nonatomic) CGFloat lastScrollContentOffset;
@property(assign, nonatomic) NSInteger willScrollToPage;
@property(assign, nonatomic) BOOL isFromMoreCollectionView;

@end

@implementation SegmentCategoryView

#pragma mark - public method

- (void)reloadData
{
    if (!self.dataSource || [self numberFirstSegment] == 0) {
        return;
    }
    
    self.segmentCategoryBar.categoryTitleArray = [self segmentTitleArray];
    [self.contentViewDict.allValues makeObjectsPerformSelector:@selector(removeFromSuperview)];
    self.contentViewDict = [NSMutableDictionary dictionary];
    
    [self resizeSubviews];
    
    NSInteger scrollToIndex = self.selectedIndex;
    if (scrollToIndex < 0) {
        scrollToIndex = 0;
    }
    [self configContentViewAtIndex:scrollToIndex];
//    [self willScrollToIndex:scrollToIndex];
//    [self.segmentCategoryBar scrollToIndex:scrollToIndex];
//    [self scrollToIndex:scrollToIndex];
//    [self didScrollToIndex:scrollToIndex];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        _contentViewDict = [NSMutableDictionary new];
        [self initSubViews];
        [self initConstraints];
    }
    
    return self;
}

#pragma mark -

- (void)resizeSubviews
{
    self.contentScrollView.contentSize = CGSizeMake([self numberFirstSegment] * CGRectGetWidth(self.bounds),
                                                    0);
//    for (NSNumber *indexNumber in self.contentViewDict.allKeys) {
//        UIView *contentView = self.contentViewDict[indexNumber];
//        [self configUIScrollView:contentView atIndex:[indexNumber integerValue]];
//    }
}


- (UIView *)contentViewAtIndex:(NSUInteger)index
{
    return self.contentViewDict[@(index)];
}

- (NSUInteger)numberFirstSegment
{
    NSUInteger numberFirstSegment = 0;
    if ([self.dataSource respondsToSelector:@selector(numberOfSegmentInSegmentView:)]) {
        numberFirstSegment = [self.dataSource numberOfSegmentInSegmentView:self];
    }
    
    return numberFirstSegment;
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
        
//        // 第一次加载时，需要正确设置 contentOffset，而以后都不需要重新设置，所以抽到这里写
//        if ([contentView isKindOfClass:[UIScrollView class]]) {
//            ((UIScrollView *)contentView).contentOffset = CGPointMake(0.0, -SegmentCategoryBarHeight - [self currentOffsetForCategoryBar]);
//            ((UIScrollView *)contentView).scrollsToTop = NO;
//        }
        
        [self.contentScrollView addSubview:contentView];
        
        [self.contentViewDict setObject:contentView forKey:@(index)];
    }
}

- (void)configUIScrollView:(UIView *)contentView atIndex:(NSInteger)index
{
    if ([contentView isKindOfClass:[UIScrollView class]]) {
//        UIScrollView *scrollView = (UIScrollView *)contentView;
//        
//        scrollView.contentInset = UIEdgeInsetsMake(SegmentCategoryBarHeight + [self topInsetForHeaderView], 0.0,
//                                                   self.bottomContentInset, 0.0);
//        
//        scrollView.scrollIndicatorInsets = scrollView.contentInset;
//        
//        CGRect contentViewFrame = CGRectMake(index * CGRectGetWidth(self.contentScrollView.bounds),
//                                             0.0,
//                                             CGRectGetWidth(self.contentScrollView.bounds),
//                                             CGRectGetHeight(self.contentScrollView.bounds));
//        scrollView.frame = contentViewFrame;
//        
//        // 为了防止上拉刷新、下拉加载更多时把 contentInset 覆盖，所以需要通知上拉、下拉 contentInset 的变化
//        
//        
//        NSString *title = nil;
//        if (index < self.categoryBar.categoryTitleArray.count) {
//            title = [self.categoryBar.categoryTitleArray objectAtIndex:index];
//        }
//        
//        if (scrollView.infiniteScrollingView && ![title isEqualToString:@"动态"]) {
//            [scrollView changeInfiniteScrollingViewOriginalContentInset:scrollView.contentInset];
//        }
//        
//        if (scrollView.pullRefreshingHeader) {
//            [scrollView changePullRefreshingViewOriginalContentInset:scrollView.contentInset];
//        }
    } else {
        CGRect contentViewFrame = CGRectMake(index * CGRectGetWidth(self.bounds), 0,
                                             CGRectGetWidth(self.contentScrollView.bounds),
                                             CGRectGetHeight(self.contentScrollView.bounds));
        contentView.frame = contentViewFrame;
    }
    
}


//- (void)willScrollToIndex:(NSUInteger)index
//{
//    [self configContentViewAtIndex:index];
//    
//    if ([self.dataSource respondsToSelector:@selector(segmentView:contentViewControllerAtIndex:)]) {
//        if ( self.selectedIndexInner != NSUIntegerMax ) {
//            UIViewController *oldViewController = [self.dataSource segmentView:self
//                                                  contentViewControllerAtIndex:self.selectedIndexInner];
//            [oldViewController viewWillDisappear:YES];
//        }
//        
//        UIViewController *newViewController = [self.dataSource segmentView:self
//                                              contentViewControllerAtIndex:index];
//        [newViewController viewWillAppear:YES];
//    }
//    
//    if ([self.delegate respondsToSelector:@selector(segmentView:willSelectedAtIndex:)]) {
//        [self.delegate segmentView:self willSelectedAtIndex:index];
//    }
//    else if ( [self.delegate respondsToSelector:@selector(segmentView:willSelectedAtIndex:isTriggeredFromCategoryBar:)] )
//    {
//        [self.delegate segmentView:self willSelectedAtIndex:index isTriggeredFromCategoryBar:_isTriggerScrollFromCategoryBar];
//    }
//}
//
//- (void)scrollToIndex:(NSUInteger)index
//{
//    CGRect contentFrame = CGRectMake(index * CGRectGetWidth(self.bounds), 0.0,
//                                     CGRectGetWidth(self.bounds),
//                                     CGRectGetHeight(self.contentScrollView.bounds));
//    
//    [self.contentScrollView scrollRectToVisible:contentFrame animated:YES];
//}

//- (void)didScrollToIndex:(NSUInteger)index
//{
//    
//    if (self.selectedIndexInner != index) {
//        self.selectedIndex = index;
//        
//        UIView *oldView = nil;
//        UIView *newView = nil;
//        if ([self.dataSource respondsToSelector:@selector(segmentView:contentViewControllerAtIndex:)]) {
//            if (NSUIntegerMax != self.selectedIndexInner) {
//                UIViewController *oldViewController = [self.dataSource segmentView:self
//                                                      contentViewControllerAtIndex:self.selectedIndexInner];
//                [oldViewController viewDidDisappear:YES];
//                oldView = oldViewController.view;
//            }
//            
//            UIViewController *newViewController = [self.dataSource segmentView:self
//                                                  contentViewControllerAtIndex:index];
//            [newViewController viewDidAppear:YES];
//            newView = newViewController.view;
//        } else {
//            oldView = [self contentViewAtIndex:self.selectedIndexInner];
//            newView = [self contentViewAtIndex:index];
//        }
//        
//        if ([oldView isKindOfClass:[UIScrollView class]]) {
//            ((UIScrollView *)oldView).scrollsToTop = NO;
//        }
//        if ([newView isKindOfClass:[UIScrollView class]]) {
//            ((UIScrollView *)newView).scrollsToTop = YES;
//        }
//        
//        if ([self.delegate respondsToSelector:@selector(segmentView:didSelectedAtIndex:isFromMoreCollectionView:)]) {
//            [self.delegate segmentView:self
//                    didSelectedAtIndex:index
//              isFromMoreCollectionView:self.isFromMoreCollectionView];
//            
//            self.isFromMoreCollectionView = NO;
//        } else if ([self.delegate respondsToSelector:@selector(segmentView:didSelectedAtIndex:)]) {
//            [self.delegate segmentView:self didSelectedAtIndex:index];
//        }
//        
//        self.selectedIndexInner = index;
//    }
//    
//    [self resetTriggerScrollToIndex];
//     
//}

- (void)initConstraints{
    
    [_segmentCategoryBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.equalTo(self);
        make.height.equalTo(@(kCategoryBarHeight));
    }];
    
    [_contentScrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_segmentCategoryBar.mas_bottom);
        make.left.bottom.right.equalTo(self);
    }];
    
}

- (void)initSubViews
{
    SegmentCategoryBar *categoryBar = [[SegmentCategoryBar alloc] initWithFrame:CGRectZero];
//    categoryBar.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth;
    categoryBar.delegate = self;
    categoryBar.backgroundColor = [UIColor clearColor];
    [self addSubview:categoryBar];
    _segmentCategoryBar = categoryBar;
    
    UIScrollView *contentScrollView = [[UIScrollView alloc] initWithFrame:CGRectZero];
    contentScrollView.backgroundColor = [UIColor clearColor];
    contentScrollView.delegate = self;
    contentScrollView.pagingEnabled = YES;
    contentScrollView.showsHorizontalScrollIndicator = NO;
    contentScrollView.showsVerticalScrollIndicator = NO;
    contentScrollView.directionalLockEnabled = YES;
//    contentScrollView.autoresizingMask = UIViewAutoresizingFlexibleHeight |
//    UIViewAutoresizingFlexibleWidth;
    contentScrollView.scrollsToTop = NO;
    contentScrollView.decelerationRate = UIScrollViewDecelerationRateFast;
    [self addSubview:contentScrollView];
    _contentScrollView = contentScrollView;
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

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (!self.hasLoaded) {
        [self reloadData];
        self.hasLoaded = YES;
    }
}

//- (void)triggerScrollToIndex:(NSUInteger)index
//{
//    self.triggerScrollToPage = index;
//    [self scrollToIndex:index];
//}
//
//- (void)resetTriggerScrollToIndex
//{
//    self.triggerScrollToPage = -1;
//}
//
//- (BOOL)isThereTriggerScrollToIndex
//{
//    return (self.triggerScrollToPage >= 0);
//}


#pragma mark - SegmentCategoryBarDelegate

- (void)segmentCategoryBar:(SegmentCategoryBar *)categoryBar selectedIndexChanged:(NSInteger)index
{
    self.isTriggerScrollFromCategoryBar = YES;
//    [self triggerScrollToIndex:index];
    self.selectedIndex = index;
    [self.contentScrollView setContentOffset:CGPointMake(index * self.bounds.size.width, 0) animated:NO];
    [self.segmentCategoryBar scrollToIndex:index];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    self.isTriggerScrollFromCategoryBar = NO;
    if (scrollView == self.contentScrollView) {
//        [self scrollViewContentOffsetChangeWithOffsetX:targetContentOffset -> x];
//        NSInteger index = self.contentScrollView.contentOffset.x / self.frame.size.width;
//        [self.segmentCategoryBar scrollToIndex:index];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    self.isTriggerScrollFromCategoryBar = NO;
    if (scrollView == self.contentScrollView) {
        [self scrollViewContentOffsetChangeWithOffsetX:scrollView.contentOffset.x];
        NSInteger index = self.contentScrollView.contentOffset.x / self.frame.size.width;
        [self.segmentCategoryBar scrollToIndex:index];
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{

}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGPoint pt = self.contentScrollView.contentOffset;
    CGFloat radio = (((NSInteger)pt.x) % (NSInteger)CGRectGetWidth(self.bounds) / CGRectGetWidth(self.bounds));
    NSInteger scrollToPage = pt.x / CGRectGetWidth(self.bounds);
    scrollToPage = (scrollToPage >= [[self segmentTitleArray] count]) ?
    [[self segmentTitleArray] count] : scrollToPage;
    
    if (!self.isTriggerScrollFromCategoryBar) {
        NSInteger index = self.contentScrollView.contentOffset.x / self.frame.size.width;
//        [self.segmentCategoryBar selectToIndex:index];
        [self.segmentCategoryBar setLineOffsetWithPage:scrollToPage ratio:radio];
        [self.segmentCategoryBar changeButtonFontWithOffset:scrollView.contentOffset.x];
        NSLog(@"scrollViewDidScroll %f", radio);
//        [self.segmentCategoryBar scrollToIndex:index];
    }
    
    [self scrollViewContentOffsetChangeWithOffsetX:scrollView.contentOffset.x];
}

- (void)scrollViewContentOffsetChangeWithOffsetX:(CGFloat)x
{
    int xInt = x;
    int wInt = self.bounds.size.width;
    if (xInt % wInt == 0) {
        int index = xInt / wInt;
        [self configContentViewAtIndex:index];
    }
}

//- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
//{
//    self.isSendedWillChangeIndex = NO;
//    self.isTriggerScrollFromCategoryBar = NO;
//    NSInteger index = self.contentScrollView.contentOffset.x / self.frame.size.width;
//    [self.segmentCategoryBar scrollToIndex:index];
//    [self didScrollToIndex:index];
//}
//
//- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
//{
//    self.isSendedWillChangeIndex = NO;
//    self.isTriggerScrollFromCategoryBar = NO;
//    NSInteger index = self.contentScrollView.contentOffset.x / self.frame.size.width;
//    [self.segmentCategoryBar scrollToIndex:index];
//    [self didScrollToIndex:index];
//}
//
//- (void)scrollViewDidScroll:(UIScrollView *)scrollView
//{
//    CGPoint pt = self.contentScrollView.contentOffset;
//    NSInteger scrollToPage = pt.x / CGRectGetWidth(self.bounds);
//    scrollToPage = (scrollToPage >= [[self segmentTitleArray] count]) ?
//    [[self segmentTitleArray] count] : scrollToPage;
//    if (!self.isTriggerScrollFromCategoryBar) {
//        CGFloat radio = (((NSInteger)pt.x) % (NSInteger)CGRectGetWidth(self.bounds) / CGRectGetWidth(self.bounds));
//        [self.segmentCategoryBar setLineOffsetWithPage:scrollToPage ratio:radio];
//    }
//    
//    if (![self isThereTriggerScrollToIndex]) {
//        if (self.lastScrollContentOffset > scrollView.contentOffset.x) {
//            scrollToPage = self.selectedIndex - 1;
//        } else if (self.lastScrollContentOffset < scrollView.contentOffset.x) {
//            scrollToPage = self.selectedIndex + 1;
//        }
//        
//        if (scrollToPage != self.willScrollToPage) {
//            self.willScrollToPage = scrollToPage;
//            self.isSendedWillChangeIndex = NO;
//        }
//    } else {
//        self.willScrollToPage = self.triggerScrollToPage;
//    }
//    
//    if (self.willScrollToPage < 0) {
//        self.willScrollToPage = 0;
//    }
//    
//    if (self.willScrollToPage >= [[self segmentTitleArray] count]) {
//        self.willScrollToPage = [[self segmentTitleArray] count] - 1;
//    }
//    
//    if (!self.isSendedWillChangeIndex) {
//        [self willScrollToIndex:self.willScrollToPage];
//        self.isSendedWillChangeIndex = YES;
//    }
//    
//    self.lastScrollContentOffset = scrollView.contentOffset.x;
//}


@end
