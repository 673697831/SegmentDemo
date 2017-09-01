//
//  YYBadgeView.h
//  YYMobile
//
//  Created by wuwei on 14-3-3.
//  Copyright (c) 2014年 YY Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, YYBadgeViewHorizontalAlignment)
{
    YYBadgeViewHorizontalAlignmentLeft = 0,
    YYBadgeViewHorizontalAlignmentCenter,
    YYBadgeViewHorizontalAlignmentRight,
    
    YYBadgeViewHorizontalAlignmentDefault = YYBadgeViewHorizontalAlignmentRight,
};

typedef NS_ENUM(NSUInteger, YYBadgeViewWidthMode)
{
    YYBadgeViewWidthModeStandard = 0,       // 30
    YYBadgeViewWidthModeSmall,              // 17
    YYBadgeViewWidthMode13,                 // 13
    YYBadgeViewWidthModeDefault = YYBadgeViewWidthModeSmall,
};

typedef NS_ENUM(NSUInteger, YYBadgeViewHeightMode)
{
    YYBadgeViewHeightModeStandard = 0,      // 17
    YYBadgeViewHeightModeLarge,             // 30
    YYBadgeViewHeightMode13,                // 13
    YYBadgeViewHeightModeDefault = YYBadgeViewHeightModeStandard,
};

@interface YYBadgeView : UIView

@property (nonatomic, strong) NSString *text;
@property (nonatomic, strong) UIColor *textColor;
@property (nonatomic, strong) UIColor *badgeColor;
@property (nonatomic, strong) UIColor *borderColor;
@property (nonatomic, strong) UIFont* textFont;
@property (nonatomic, assign) CGFloat borderWidth;
@property (nonatomic, assign) YYBadgeViewHorizontalAlignment horizontalAlignment;
@property (nonatomic, assign) YYBadgeViewWidthMode widthMode;
@property (nonatomic, assign) YYBadgeViewHeightMode heightMode;
@property (nonatomic, assign) CGSize textOffset;    // default is CGSizeZero
@property (nonatomic, assign) CGFloat horizontalPadding;    // default is 3.0

- (CGFloat)badgeHeight;

@end
