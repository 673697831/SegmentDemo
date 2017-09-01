//
//  SegmentCategoryView.h
//  SegmentCategoryViewDemo
//
//  Created by zhenby on 6/30/14.
//  Copyright (c) 2014 zhenby. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SegmentCategoryView;

extern const CGFloat NavBarDefaultTopContentInset;
extern const CGFloat TabBarDefaultBottomContentInset;
extern const CGFloat ToolBarDefaultBottomContentInset;

@protocol SegmentCategoryDataSource <NSObject>

@optional
- (NSUInteger)numberOfSegmentInSegmentView:(SegmentCategoryView *)segmentView;

- (NSString *)segmentView:(SegmentCategoryView *)segmentView titleAtIndex:(NSUInteger)index;
- (NSAttributedString *)segmentView:(SegmentCategoryView *)segmentView
             attributedTitleAtIndex:(NSUInteger)index;

- (UIView *)segmentView:(SegmentCategoryView *)segmentView contentViewAtIndex:(NSUInteger)index;
- (UIViewController *)segmentView:(SegmentCategoryView *)segmentView
     contentViewControllerAtIndex:(NSUInteger)index;

- (UIImage *)segmentView:(SegmentCategoryView *)segmentView imageIconAtIndex:(NSUInteger)index;
- (UIImage *)segmentView:(SegmentCategoryView *)segmentView selectedImageIconAtIndex:(NSUInteger)index;

- (CGFloat)topInsetForHeaderView:(SegmentCategoryView *)segmentView;
- (CGFloat)currentOffsetForCategoryBar:(SegmentCategoryView *)segmentView;
/**
 *  这四个回调只是为了解决首页下拉分类视图中二级分类需求，没有下拉分类视图的可忽略
 *
 */
- (NSUInteger)numberOfSecondSegmentInSegmentView:(SegmentCategoryView *)segmentView;
- (NSString *)segmentView:(SegmentCategoryView *)segmentView secondeSegmentTitleAtIndex:(NSUInteger)index;
- (UIImage *)segmentView:(SegmentCategoryView *)segmentView secondSegmentImageIconAtIndex:(NSUInteger)index;
- (UIImage *)segmentView:(SegmentCategoryView *)segmentView secondSegmentSelectedImageIconAtIndex:(NSUInteger)index;

@end


@protocol SegmentCategoryDelegate <NSObject>

@optional
- (void)segmentView:(SegmentCategoryView *)segmentView willSelectedAtIndex:(NSUInteger)index;
- (void)segmentView:(SegmentCategoryView *)segmentView didSelectedAtIndex:(NSUInteger)index;
/**
 *  为了统计而加的方法 ಥ_ಥ
 */
- (void)segmentView:(SegmentCategoryView *)segmentView
    didSelectedAtIndex:(NSUInteger)index
    isFromMoreCollectionView:(BOOL)isFromMoreCollectionView;
- (void)onMoreButtonTapInSegmentView:(SegmentCategoryView *)segmentView;
- (void)segmentView:(SegmentCategoryView *)segmentView willSelectedAtIndex:(NSUInteger)index isTriggeredFromCategoryBar:(BOOL)isFromBar;

/**
 *  这个回调只是为了解决首页下拉分类视图中二级分类点击的需求，没有下拉分类视图的可忽略
 *
 */
- (void)segmentView:(SegmentCategoryView *)segmentView didSelectedSecondSegmentAtIndex:(NSUInteger)index;

@end

@class SegmentCategoryBar;

@interface SegmentCategoryView : UIView

@property(strong, nonatomic, readonly) SegmentCategoryBar *categoryBar;
@property(assign, nonatomic) NSUInteger selectedIndex;
@property(assign, nonatomic) BOOL showMoreButton;
@property(nonatomic, getter=isShowIndicatorOnMoreButton) BOOL showIndicatorOnMoreButton;
@property(assign, nonatomic) CGFloat topContentInset;
@property(assign, nonatomic) CGFloat bottomContentInset;
@property(assign, nonatomic) BOOL horizontalScrollDisable;;
@property(weak, nonatomic) id<SegmentCategoryDataSource> dataSource;
@property(weak, nonatomic) id<SegmentCategoryDelegate> delegate;

@property(assign, nonatomic) CGFloat categoryTitlePadding;
@property(assign, nonatomic) BOOL isSupportFull;
@property(strong, nonatomic) UIColor *categoryBarBackgroundColor;
@property(assign, nonatomic) BOOL categoryBarHidden;

- (void)triggerScrollToIndex:(NSUInteger)index;
- (UIView *)contentViewAtIndex:(NSUInteger)index;
- (void)reloadData;

/**
 *  刷新 Bar 中的标题，需保证标题数量不变，只涉及到标题内容的修改
 */
- (void)reloadBarTitle;


// 强制收起分类
- (void)hideSubCollectionView;

/**
 *  更新对应索引的分类标题
 */
- (void)updateSegmentTitle:(NSString *)title atIndex:(NSInteger)index;

/**
 *  以 AttributedString 的方式更新分类标题
 *
 */
- (void)updateSegmentAttributedTitle:(NSAttributedString *)attributedTitle atIndex:(NSInteger)index;

/**
 *  显示在 bar 右边的动作视图，比如一个关注按钮
 *
 */
- (void)showBarActionView:(UIView *)barActionView;

- (void)updateSegmentViewContentOffset;

/**
 *  在二级分类中显示红点
 *
 */
- (void)showIndicator:(BOOL)show atSecondSegmentIndex:(NSInteger)innerIndex;
- (BOOL)isShowIndicatorAtSecondSegmentIndex:(NSInteger)innerIndex;


/**
 *  View 所在的 ViewController 在 -viewWillAppear: 时可调用此方法，
    此方法会调用当前选中的 ChildViewContrller 的 -viewWillAppear:
 *
 *  @param animated If YES, the view was added to the window using an animation.
 */
- (void)viewWillAppear:(BOOL)animated;


/**
 *  View 所在的 ViewController 在 -viewDidAppear: 时可调用此方法，
    此方法会调用当前选中的 ChildViewContrller 的 -viewDidAppear:
 *
 *  @param animated If YES, the view was added to the window using an animation.
 */
- (void)viewDidAppear:(BOOL)animated;

/**
 *  View 所在的 ViewController 在 -viewWillDisappear: 时可调用此方法，
 此方法会调用当前选中的 ChildViewContrller 的 -viewWillDisappear:
 *
 *  @param animated If YES, the view was added to the window using an animation.
 */
- (void)viewWillDisappear:(BOOL)animated;


/**
 *  View 所在的 ViewController 在 -viewDidDisappear: 时可调用此方法，
 此方法会调用当前选中的 ChildViewContrller 的 -viewDidDisappear:
 *
 *  @param animated If YES, the view was added to the window using an animation.
 */
- (void)viewDidDisappear:(BOOL)animated;


@end
