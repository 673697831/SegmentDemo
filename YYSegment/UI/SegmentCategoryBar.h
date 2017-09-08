//
//  SegmentCategoryBar.h
//  SegmentCategoryViewDemo
//
//  Created by zhenby on 6/30/14.
//  Copyright (c) 2014 zhenby. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SegmentCategoryBar;

@protocol SegmentCategoryBarDelegate <NSObject>

@optional
- (void)segmentCategoryBar:(SegmentCategoryBar *)categoryBar selectedIndexChanged:(NSInteger)index;

@end


@interface SegmentCategoryBar : UIView

@property(assign, nonatomic) CGFloat categoryTitlePadding;
@property(strong, nonatomic) NSArray *categoryTitleArray;
@property(assign, nonatomic, readonly) NSInteger selectedIndex;
@property(strong, nonatomic) UIColor *selectedColor;
@property(strong, nonatomic) UIFont *buttonNormalTitleFont;
@property(strong, nonatomic) UIFont *buttonSelectedTitleFont;
@property(weak, nonatomic) id<SegmentCategoryBarDelegate> delegate;

@property(assign, nonatomic) BOOL isCenter;
@property(nonatomic ,assign) BOOL forceUndraggable;

//------ 重写SegmentCategoryBar的layout

@property (nonatomic ,assign) BOOL useNewLayoutStrategy; //打开开关才会用新逻辑layout
@property (nonatomic ,assign) CGFloat leadingSpace; //首个title距离segementBar origin x的距离
@property (nonatomic ,assign) CGFloat titlePadding; // title之间的距离
@property (nonatomic ,assign) BOOL placeAtCenter; //当标题较少(contentWidth < bounds.width)时，将整体标题居中显示
@property (nonatomic ,assign) CGFloat extraClickWidth; //不影响UI展示，但是设置这个值可以增加每个标签的可点击宽度

// ------


- (void)showIndicator:(BOOL)showIndicator atIndex:(NSInteger)index;
- (BOOL)isShowIndicateorAtIndex:(NSInteger)index;
- (void)scrollToIndex:(NSInteger)index;
- (void)setLineOffsetWithPage:(NSInteger)page ratio:(CGFloat)ratio;
- (void)changeButtonFontWithOffset:(CGFloat)offset;

- (void)showBadge:(NSString *)badge atIndex:(NSInteger)index;
- (void) showNewBadge:(NSString *)badge atIndex:(NSInteger)index;
- (NSString *)badgeStringAtIndex:(NSInteger)index;
- (void)hideBadgeAtIndex:(NSInteger)index;

- (void)updateTitle:(NSString *)title atIndex:(NSInteger)index;
- (void)updateAttributedTitle:(NSAttributedString *)attributedTitle atIndex:(NSInteger)index;

@end
