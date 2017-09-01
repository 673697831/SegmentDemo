//
//  SegmentMoreButtonView.m
//  YYMobile
//
//  Created by Arcfat Tsui on 10/21/15.
//  Copyright © 2015 YY.inc. All rights reserved.
//

#import "SegmentMoreButtonView.h"
#import "UIView+Indicator.h"

const CGFloat kSpace            = 4.0;
const CGFloat kIndicatorRadius  = 3.0;
const CGFloat kIndicatorWidth   = 2 * kIndicatorRadius;

@interface SegmentMoreButtonView()

@property (nonatomic, strong) UIButton *moreButton;

@end

@implementation SegmentMoreButtonView

@synthesize showIndicator = _showIndicator;

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _moreButton = [[UIButton alloc]initWithFrame:self.bounds];
        [_moreButton setImage:[UIImage imageNamed:@"segment_down.png"] forState:UIControlStateNormal];
        [_moreButton addTarget:self action:@selector(onTapMoreButton:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_moreButton];
    }
    return self;
}

- (void)onTapMoreButton:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(onSegmentMoreButtonViewTapped)]) {
        [self.delegate onSegmentMoreButtonViewTapped];
    }
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    self.moreButton.frame = self.bounds;
}

- (void)setShowIndicator:(BOOL)showIndicator
{
    if (showIndicator != _showIndicator) {
        _showIndicator = showIndicator;
        CGFloat x = CGRectGetWidth(self.bounds) - kSpace - kIndicatorWidth;
        CGFloat y = kSpace;
        self.indicatorOrigin = CGPointMake(x, y);
        [self showIndicator:showIndicator];
    }
}

- (BOOL)isShowIndicator
{
    return _showIndicator;
}

- (void)setButtonState:(SegmentMoreButtonState)buttonState
{
    _buttonState = buttonState;
    if (buttonState == SegmentMoreButtonState_Normal) {
        self.moreButton.transform = CGAffineTransformMakeRotation(0.0);
    }
    else if (buttonState == SegmentMoreButtonState_Expanded){
        self.moreButton.transform = CGAffineTransformMakeRotation(M_PI);
    }
}

@end
