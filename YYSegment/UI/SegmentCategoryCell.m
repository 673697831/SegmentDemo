//
//  SegmentCategoryCell.m
//  SegmentCategoryViewDemo
//
//  Created by zhenby on 7/1/14.
//  Copyright (c) 2014 zhenby. All rights reserved.
//

#import "SegmentCategoryCell.h"
#import "UIView+Indicator.h"


#define SelectedBackgroundColor     [UIColor colorWithRed:255.0/255.0 green:136.0/255.0 blue:0.0/255.0 alpha:1.0]
#define NormalBackgroundColor       [UIColor whiteColor]

#define SelectedTextColor           [UIColor whiteColor]
#define NormalTextColor             [UIColor colorWithRed:36.0/255.0 green:36.0/255.0 blue:36.0/255.0 alpha:1.0]

static const CGFloat IconImageViewWidth     = 30.0;
static const CGFloat IconImageViewHeight    = 30.0;
static const CGFloat VerticalPadding        = 20.0;

@interface SegmentCategoryCell ()

@property(strong, nonatomic) UILabel *titleLabel;
@property(strong, nonatomic) UIImageView *iconImageView;

@end


@implementation SegmentCategoryCell

@synthesize showIndicator = _showIndicator;

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        CGRect iconFrame = CGRectMake((CGRectGetWidth(frame) - IconImageViewWidth) / 2.0, VerticalPadding,
                                      IconImageViewWidth, IconImageViewHeight);
        _iconImageView = [[UIImageView alloc] initWithFrame:iconFrame];
        [self.contentView addSubview:_iconImageView];
        
        
        CGRect labelFrame = CGRectMake(0.0, CGRectGetMaxY(iconFrame),
                                       CGRectGetWidth(frame),
                                       CGRectGetHeight(frame) - CGRectGetMaxY(iconFrame) - VerticalPadding);
        _titleLabel = [[UILabel alloc] initWithFrame:labelFrame];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.font = [UIFont systemFontOfSize:14.0];
        _titleLabel.textColor = NormalTextColor;
        [self.contentView addSubview:_titleLabel];
        
        self.contentView.backgroundColor = NormalBackgroundColor;
    }
    
    return self;
}

- (void)setTitle:(NSString *)title iconImage:(UIImage *)iconImage
{
    self.iconImageView.image = iconImage;
    self.titleLabel.text = title;
    self.titleLabel.textColor = NormalTextColor;
    self.contentView.backgroundColor = NormalBackgroundColor;
}

- (void)setTitle:(NSString *)title selectedIconImage:(UIImage *)selectedIconImage
{
    self.iconImageView.image = selectedIconImage;
    self.titleLabel.text = title;
    self.titleLabel.textColor = SelectedTextColor;
    self.contentView.backgroundColor = SelectedBackgroundColor;
}

- (void)highlightedWithIconImage:(UIImage *)iconImage
{
    if (iconImage) {
        self.iconImageView.image = iconImage;
    }
    self.titleLabel.textColor = SelectedTextColor;
    self.contentView.backgroundColor = SelectedBackgroundColor;
}

- (void)unhighlightedWithIconImage:(UIImage *)iconImage
{
    if (iconImage) {
        self.iconImageView.image = iconImage;
    }
    self.titleLabel.textColor = NormalTextColor;
    self.contentView.backgroundColor = NormalBackgroundColor;
}

- (void)setShowIndicator:(BOOL)showIndicator
{
    if (showIndicator != _showIndicator) {
        _showIndicator = showIndicator;
        CGFloat x = CGRectGetMinX(self.iconImageView.frame) + CGRectGetWidth(self.iconImageView.bounds);
        CGFloat y = CGRectGetMinY(self.iconImageView.frame);
        self.indicatorOrigin = CGPointMake(x, y);
        [self showIndicator:showIndicator];
    }
}

- (BOOL)isShowIndicator
{
    return _showIndicator;
}

@end
