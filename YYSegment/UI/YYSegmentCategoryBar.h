//
//  YYSegmentCategoryView.h
//  YYSegment
//
//  Created by ouzhirui on 2017/7/29.
//  Copyright © 2017年 YY. All rights reserved.
//

#import <UIKit/UIKit.h>

@class YYSegmentCategoryBar;

@protocol YYSegmentCategoryBarDelegate <NSObject>

@optional
- (void)segmentCategoryBar:(YYSegmentCategoryBar *)categoryBar selectedIndexChanged:(NSInteger)index;

@end


@interface YYSegmentCategoryBar : UIView

@property(assign, nonatomic) CGFloat categoryTitlePadding;
@property(assign, nonatomic) CGFloat lineViewHeight;
@property(assign, nonatomic) CGFloat lineViewWidth;

@property(strong, nonatomic) NSArray *categoryTitleArray;
@property(assign, nonatomic, readonly) NSInteger selectedIndex;
@property(strong, nonatomic) UIColor *selectedColor;
@property(strong, nonatomic) UIFont *buttonNormalTitleFont;
@property(strong, nonatomic) UIFont *buttonSelectedTitleFont;
@property(weak, nonatomic) id<YYSegmentCategoryBarDelegate> delegate;

@property(assign, nonatomic) BOOL isCenter;
@property(nonatomic ,assign) BOOL forceUndraggable;

- (CGSize)preferredContentSize;

- (void)scrollToIndex:(NSInteger)index;
- (void)setLineOffsetWithPage:(NSInteger)page ratio:(CGFloat)ratio;
- (void)changeButtonFontWithOffset:(CGFloat)offset width:(CGFloat)width;

- (void)updateTitle:(NSString *)title atIndex:(NSInteger)index;
- (void)updateAttributedTitle:(NSAttributedString *)attributedTitle atIndex:(NSInteger)index;

@end
