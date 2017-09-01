 //
//  UIView+Indicator.h
//  YY2
//
//  Created by xianbei on 13-11-14.
//  Copyright (c) 2013年 YY Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (Indicator)

@property (nonatomic, strong, readonly) CALayer *indicatorLayer;
@property (nonatomic, assign) CGPoint indicatorOrigin;

- (void)showIndicator:(BOOL)show;

- (void)showNoticeIndicator:(BOOL)show;

@end