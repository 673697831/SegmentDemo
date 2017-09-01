//
//  CategoryTitleButton.m
//  YYMobile
//
//  Created by zhenby on 14-9-9.
//  Copyright (c) 2014年 YY.inc. All rights reserved.
//

#import "CategoryTitleButton.h"
#import "UIView+Indicator.h"
#import "YYBadgeView.h"

const CGFloat IndicatorRadius       =   3.0;
const CGFloat IndicatorCorrectionX  =   2.0;
const CGFloat IndicatorCorrectionY  =   2.0;
const CGFloat BadgeCorrectionX      =   11.0;
const CGFloat BadgeCorrectionY      =   5.0;

@interface CategoryTitleButton ()

@property(strong, nonatomic) YYBadgeView *badgeView;

@end

@implementation CategoryTitleButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
//    if (self) {
//        // Initialization code
//        
//    }
    return self;
}

- (void)setShowIndicator:(BOOL)showIndicator
{
    if (showIndicator != _showIndicator) {
        _showIndicator = showIndicator;
        CGFloat x = CGRectGetWidth(self.bounds) - (CGRectGetWidth(self.bounds) - [self sizeOfButtonTitle].width) / 2.0 + IndicatorCorrectionX;
        CGFloat y = (CGRectGetHeight(self.bounds) - [self sizeOfButtonTitle].height) / 2.0 - IndicatorCorrectionY;
        self.indicatorOrigin = CGPointMake(x, y);
        [self showIndicator:showIndicator];
    }
}

- (void) showNewBadge:(NSString *)badge
{
    if (badge.length != 0) {
        if (!self.badgeView) {
            self.badgeView = [[YYBadgeView alloc] initWithFrame:CGRectMake(0.0, 0.0, 30.0, 18.0)];
            [self addSubview:self.badgeView];
        }
        CGRect badgeFrame = self.badgeView.frame;
        CGFloat x = CGRectGetWidth(self.bounds) - (CGRectGetWidth(self.bounds) - [self sizeOfButtonTitle].width) / 2.0 - 3.0;
        CGFloat y = (CGRectGetHeight(self.bounds) - [self sizeOfButtonTitle].height) / 2.0 - BadgeCorrectionY;
        badgeFrame.origin = CGPointMake(x, y);
        self.badgeView.frame = badgeFrame;
        [self.badgeView setText:badge];
    } else {
        [self hideBadge];
    }

    
}

- (void)showBadge:(NSString *)badge
{
    if (badge.length != 0) {
        if (!self.badgeView) {
            self.badgeView = [[YYBadgeView alloc] initWithFrame:CGRectMake(0.0, 0.0, 30.0, 18.0)];
            [self addSubview:self.badgeView];
        }
        CGRect badgeFrame = self.badgeView.frame;
        CGFloat x = CGRectGetWidth(self.bounds) - (CGRectGetWidth(self.bounds) - [self sizeOfButtonTitle].width) / 2.0 - BadgeCorrectionX;
        CGFloat y = (CGRectGetHeight(self.bounds) - [self sizeOfButtonTitle].height) / 2.0 - BadgeCorrectionY;
        badgeFrame.origin = CGPointMake(x, y);
        self.badgeView.frame = badgeFrame;
        [self.badgeView setText:badge];
    } else {
        [self hideBadge];
    }
}

- (NSString *)badgeString
{
    return self.badgeView.text;
}

- (void)hideBadge
{
    [self.badgeView removeFromSuperview];
    self.badgeView = nil;
}


#pragma mark - Util Method

- (CGSize)sizeOfButtonTitle
{
    UILabel *label = self.titleLabel;
    return [label.text boundingRectWithSize:CGSizeMake(MAXFLOAT, CGRectGetHeight(self.bounds))
                                    options:NSStringDrawingUsesLineFragmentOrigin
                                 attributes:@{NSFontAttributeName:label.font}
                                    context:nil].size;
}

@end
