//
//  SegmentCategoryView.h
//  YYSegment
//
//  Created by ouzhirui on 2017/7/29.
//  Copyright © 2017年 YY. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SegmentCategoryBar;
@class SegmentCategoryView;

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

@interface SegmentCategoryView : UIView

@property (nonatomic, weak) SegmentCategoryBar *segmentCategoryBar;
@property (nonatomic, weak) UIScrollView *contentScrollView;
@property (nonatomic, weak) id<SegmentCategoryDataSource> dataSource;
@property (nonatomic, weak) id<SegmentCategoryDelegate> delegate;
@property (nonatomic, assign) NSUInteger selectedIndex;

- (void)reloadData;


@end
