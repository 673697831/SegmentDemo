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

/**
 *  YYSegmentCategoryBar排版问题
 */
typedef NS_ENUM(NSUInteger, YYSegmentCategoryViewAlignment) {
    /**
     *  左对齐
     */
    kYYSegmentCategoryViewAlignmentLeft,
    /**
     *  居中
     */
    kYYSegmentCategoryViewAlignmentCenter,
    /**
     *  右对齐
     */
    kYYSegmentCategoryViewAlignmentRight,
};


@protocol YYSegmentCategoryDataSource <NSObject>

@optional

/**
 *
 *
 *   YYSegmentCategoryBar 属性设置
 *
 *
 */

- (NSUInteger)numberOfSegmentInSegmentView:(YYSegmentCategoryView *)segmentView;

- (NSString *)segmentView:(YYSegmentCategoryView *)segmentView titleAtIndex:(NSUInteger)index;
- (NSAttributedString *)segmentView:(YYSegmentCategoryView *)segmentView
             attributedTitleAtIndex:(NSUInteger)index;
- (UIView *)segmentView:(YYSegmentCategoryView *)segmentView titleViewAtIndex:(NSUInteger)index;
- (CGFloat)segmentView:(YYSegmentCategoryView *)segmentView titleViewWidthAtIndex:(NSUInteger)index;

/**
 *
 *
 *   YYSegmentCategoryViewController
 *
 *
 */

- (UIView *)segmentView:(YYSegmentCategoryView *)segmentView contentViewAtIndex:(NSUInteger)index;
- (UIViewController *)segmentView:(YYSegmentCategoryView *)segmentView
     contentViewControllerAtIndex:(NSUInteger)index;

@end


@protocol YYSegmentCategoryDelegate <NSObject>

@optional
- (void)segmentView:(YYSegmentCategoryView *)segmentView willSelectedAtIndex:(NSUInteger)index;
- (void)segmentView:(YYSegmentCategoryView *)segmentView didSelectedAtIndex:(NSUInteger)index;

@end

@interface YYSegmentCategoryView : UIView

@property (nonatomic, weak) YYSegmentCategoryBar *segmentCategoryBar;
@property (nonatomic, weak) UIScrollView *contentScrollView;
@property (nonatomic, weak) id<YYSegmentCategoryDataSource> dataSource;
@property (nonatomic, weak) id<YYSegmentCategoryDelegate> delegate;
@property (nonatomic, assign) NSUInteger selectedIndex;

@property (nonatomic, assign, readonly) CGFloat realContentWidth; //控件所占的真实宽度
@property (assign, nonatomic) YYSegmentCategoryViewAlignment barAlignment;//对齐方向

- (void)reloadData;


@end
