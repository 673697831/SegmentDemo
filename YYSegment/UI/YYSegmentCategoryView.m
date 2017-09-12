//
//  SegmentCategoryView.m
//  YYSegment
//
//  Created by ouzhirui on 2017/7/29.
//  Copyright © 2017年 YY. All rights reserved.
//

#import "YYSegmentCategoryView.h"
#import "YYSegmentCategoryBar.h"

static const CGFloat kCategoryBarHeight = 40;

@interface YYSegmentCategoryView ()<YYSegmentCategoryBarDelegate, UIScrollViewDelegate>

@property (nonatomic, assign) BOOL hasLoaded;
@property (nonatomic, strong) NSMutableDictionary *contentViewDict;

@property(assign, nonatomic) BOOL isTriggerScrollFromCategoryBar;

@end

@implementation YYSegmentCategoryView

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
    
    [self resetConstraints];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        _contentViewDict = [NSMutableDictionary new];
        _barAlignment = kYYSegmentCategoryViewAlignmentCenter;
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
        
        [self.contentScrollView addSubview:contentView];
        
        [self.contentViewDict setObject:contentView forKey:@(index)];
    }
}

- (void)configUIScrollView:(UIView *)contentView atIndex:(NSInteger)index
{
    CGRect contentViewFrame = CGRectMake(index * CGRectGetWidth(self.bounds), 0,
                                         CGRectGetWidth(self.contentScrollView.bounds),
                                         CGRectGetHeight(self.contentScrollView.bounds));
    contentView.frame = contentViewFrame;
}

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

- (void)resetConstraints
{
    switch (self.barAlignment) {
        case kYYSegmentCategoryViewAlignmentLeft:
        {
            CGFloat width = self.segmentCategoryBar.preferredContentSize.width;
            [_segmentCategoryBar mas_remakeConstraints:^(MASConstraintMaker *make) {
                if (width > [UIScreen mainScreen].bounds.size.width) {
                    make.width.equalTo(self);
                }else
                {
                    make.width.equalTo(@(width));
                }
                make.left.top.equalTo(self);
                make.height.equalTo(@(kCategoryBarHeight));
            }];
            break;
        }
        case kYYSegmentCategoryViewAlignmentRight:
        {
            CGFloat width = self.segmentCategoryBar.preferredContentSize.width;
            [_segmentCategoryBar mas_remakeConstraints:^(MASConstraintMaker *make) {
                if (width > [UIScreen mainScreen].bounds.size.width) {
                    make.width.equalTo(self);
                }else
                {
                    make.width.equalTo(@(width));
                }
                make.right.top.equalTo(self);
                make.width.equalTo(@(width));
                make.height.equalTo(@(kCategoryBarHeight));
            }];
            break;
        }
        case kYYSegmentCategoryViewAlignmentCenter:
        {
            [_segmentCategoryBar mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.centerX.equalTo(self);
                make.height.equalTo(@(kCategoryBarHeight));
            }];
            break;
        }
        default:
            break;
    }
}

- (void)initSubViews
{
    YYSegmentCategoryBar *categoryBar = [[YYSegmentCategoryBar alloc] initWithFrame:CGRectZero];
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

#pragma mark - YYSegmentCategoryBarDelegate

- (void)segmentCategoryBar:(YYSegmentCategoryBar *)categoryBar selectedIndexChanged:(NSInteger)index
{
    self.isTriggerScrollFromCategoryBar = YES;
    self.selectedIndex = index;
    [self.contentScrollView setContentOffset:CGPointMake(index * self.bounds.size.width, 0) animated:NO];
    [self.segmentCategoryBar scrollToIndex:index];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    self.isTriggerScrollFromCategoryBar = NO;
    if (scrollView == self.contentScrollView) {
        [self scrollViewContentOffsetChangeWithOffsetX:scrollView.contentOffset.x];
        NSInteger index = self.contentScrollView.contentOffset.x / self.frame.size.width;
        [self.segmentCategoryBar scrollToIndex:index];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGPoint pt = self.contentScrollView.contentOffset;
    CGFloat radio = (((NSInteger)pt.x) % (NSInteger)CGRectGetWidth(self.bounds) / CGRectGetWidth(self.bounds));
    NSInteger scrollToPage = pt.x / CGRectGetWidth(self.bounds);
    scrollToPage = (scrollToPage >= [[self segmentTitleArray] count]) ?
    [[self segmentTitleArray] count] : scrollToPage;
    
    if (!self.isTriggerScrollFromCategoryBar) {
        [self.segmentCategoryBar setLineOffsetWithPage:scrollToPage ratio:radio];
        [self.segmentCategoryBar changeButtonFontWithOffset:scrollView.contentOffset.x width:[UIScreen mainScreen].bounds.size.width];
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

@end
