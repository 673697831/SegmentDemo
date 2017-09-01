//
//  SegmentCategoryViewController.h
//  SegmentCategoryViewDemo
//
//  Created by zhenby on 6/30/14.
//  Copyright (c) 2014 zhenby. All rights reserved.
//

//#import "YYViewController.h"
#import <UIKit/UIKit.h>
#import "SegmentCategoryView.h"

@class SegmentCategoryViewController;

@protocol SegmentCategoryViewControllerDelegate <NSObject>

- (void)segmentCategoryViewController:(SegmentCategoryViewController *)segmentCategoryViewControlelr
                   didSelectedAtIndex:(NSUInteger)index;

@end


@interface SegmentCategoryViewController : UIViewController

@property(strong, nonatomic) SegmentCategoryView *segmentView;
@property(weak, nonatomic) id<SegmentCategoryViewControllerDelegate> delegate;
@property(copy, nonatomic) NSArray *viewControllers;
@property(assign, nonatomic) BOOL horizontalScrollDisable;

@property(readonly, nonatomic) UIViewController *selectedViewController;
@property(assign, nonatomic) NSUInteger selectedIndex;

@property(assign, nonatomic) CGFloat topContentInset;
@property(assign, nonatomic) CGFloat bottomContentInset;
@property(assign, nonatomic) CGFloat categoryTitlePadding;

@property(strong, nonatomic) UIColor *categoryBarBackgroundColor;
@property(strong, nonatomic) UIFont *categoryBarNormalButtonFont;
@property(strong, nonatomic) UIFont *categoryBarSelectedButtonFont;

@property(assign, nonatomic) BOOL isSupportFull;
@property(assign, nonatomic) BOOL disableSegment;
@property(assign, nonatomic) BOOL segmentHidden;

- (void)reloadSegment;

- (void)triggerScrollToIndex:(NSInteger)index;
- (void)setCategoryBarTintColor:(UIColor *)color;
- (void)showIndicator:(BOOL)showIndicator atIndex:(NSInteger)index;
- (BOOL)isShowIndicateorAtIndex:(NSInteger)index;
- (void)showBadge:(NSString *)badge atIndex:(NSInteger)index;
- (NSString *)badgeStringAtIndex:(NSInteger)index;
- (void)hideBadgeAtIndex:(NSInteger)index;

- (void)updateSegmentTitle:(NSString *)title atIndex:(NSInteger)index;

@end
