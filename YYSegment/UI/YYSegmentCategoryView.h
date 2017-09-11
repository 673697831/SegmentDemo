//
//  SegmentCategoryView.h
//  YYSegment
//
//  Created by ouzhirui on 2017/7/29.
//  Copyright © 2017年 YY. All rights reserved.
//

#import <UIKit/UIKit.h>

@class YYSegmentCategoryBar;
@class YYSegmentCategoryView;

@protocol YYSegmentCategoryDataSource <NSObject>

@optional
- (NSUInteger)numberOfSegmentInSegmentView:(YYSegmentCategoryView *)segmentView;

- (NSString *)segmentView:(YYSegmentCategoryView *)segmentView titleAtIndex:(NSUInteger)index;
- (NSAttributedString *)segmentView:(YYSegmentCategoryView *)segmentView
             attributedTitleAtIndex:(NSUInteger)index;

- (UIView *)segmentView:(YYSegmentCategoryView *)segmentView contentViewAtIndex:(NSUInteger)index;
- (UIViewController *)segmentView:(YYSegmentCategoryView *)segmentView
     contentViewControllerAtIndex:(NSUInteger)index;

- (UIImage *)segmentView:(YYSegmentCategoryView *)segmentView imageIconAtIndex:(NSUInteger)index;
- (UIImage *)segmentView:(YYSegmentCategoryView *)segmentView selectedImageIconAtIndex:(NSUInteger)index;

- (CGFloat)topInsetForHeaderView:(YYSegmentCategoryView *)segmentView;
- (CGFloat)currentOffsetForCategoryBar:(YYSegmentCategoryView *)segmentView;
/**
 *  这四个回调只是为了解决首页下拉分类视图中二级分类需求，没有下拉分类视图的可忽略
 *
 */
- (NSUInteger)numberOfSecondSegmentInSegmentView:(YYSegmentCategoryView *)segmentView;
- (NSString *)segmentView:(YYSegmentCategoryView *)segmentView secondeSegmentTitleAtIndex:(NSUInteger)index;
- (UIImage *)segmentView:(YYSegmentCategoryView *)segmentView secondSegmentImageIconAtIndex:(NSUInteger)index;
- (UIImage *)segmentView:(YYSegmentCategoryView *)segmentView secondSegmentSelectedImageIconAtIndex:(NSUInteger)index;

@end


@protocol YYSegmentCategoryDelegate <NSObject>

@optional
- (void)segmentView:(YYSegmentCategoryView *)segmentView willSelectedAtIndex:(NSUInteger)index;
- (void)segmentView:(YYSegmentCategoryView *)segmentView didSelectedAtIndex:(NSUInteger)index;
/**
 *  为了统计而加的方法 ಥ_ಥ
 */
- (void)segmentView:(YYSegmentCategoryView *)segmentView
 didSelectedAtIndex:(NSUInteger)index
isFromMoreCollectionView:(BOOL)isFromMoreCollectionView;
- (void)onMoreButtonTapInSegmentView:(YYSegmentCategoryView *)segmentView;
- (void)segmentView:(YYSegmentCategoryView *)segmentView willSelectedAtIndex:(NSUInteger)index isTriggeredFromCategoryBar:(BOOL)isFromBar;

/**
 *  这个回调只是为了解决首页下拉分类视图中二级分类点击的需求，没有下拉分类视图的可忽略
 *
 */
- (void)segmentView:(YYSegmentCategoryView *)segmentView didSelectedSecondSegmentAtIndex:(NSUInteger)index;

@end

@interface YYSegmentCategoryView : UIView

@property (nonatomic, weak) YYSegmentCategoryBar *segmentCategoryBar;
@property (nonatomic, weak) UIScrollView *contentScrollView;
@property (nonatomic, weak) id<YYSegmentCategoryDataSource> dataSource;
@property (nonatomic, weak) id<YYSegmentCategoryDelegate> delegate;
@property (nonatomic, assign) NSUInteger selectedIndex;

- (void)reloadData;


@end
