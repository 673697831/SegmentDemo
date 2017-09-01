//
//  UIView+Indicator.m
//  YY2
//
//  Created by xianbei on 13-11-14.
//  Copyright (c) 2013年 YY Inc. All rights reserved.
//

#import "UIView+Indicator.h"
#import <objc/runtime.h>

@implementation UIView (Indicator)

static char kIndicatorLayerKey;
static char kIndicatorLayerOriginKey;

- (void)showIndicator:(BOOL)show
{
    if (show)
    {
        
        self.indicatorLayer = nil;
        
//        CAShapeLayer *circle = [CAShapeLayer layer];
//        // Make a circular shape
//        CGPoint origin = self.indicatorOrigin;
//        circle.path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(origin.x, origin.y, 7, 7)
//                                                 cornerRadius:3.5].CGPath;
//        
//        // Configure the apperence of the circle
//        circle.fillColor = RGBCOLOR(255, 84, 0).CGColor;
//        circle.strokeColor = [UIColor clearColor].CGColor;
        
        CGPoint origin = self.indicatorOrigin;
        UIImage *redImg = [UIImage imageNamed:@"normal_red"];
        
        CALayer * imageLayer = [CALayer layer];
        imageLayer.contents = (id)redImg.CGImage;
        imageLayer.frame = CGRectMake(origin.x, origin.y, redImg.size.width, redImg.size.height);
        
        // Add to parent layer
        self.indicatorLayer = imageLayer;
        
    }
    else
    {
        self.indicatorLayer = nil;
    }
}

- (void)showNoticeIndicator:(BOOL)show {
    
    if (show) {
        
        self.indicatorLayer = nil;
        CGPoint origin = self.indicatorOrigin;
        UIImage *redImg = [UIImage imageNamed:@"notice_red"];
        
        CALayer * imageLayer = [CALayer layer];
        imageLayer.contents = (id)redImg.CGImage;
        imageLayer.frame = CGRectMake(origin.x, origin.y, redImg.size.width, redImg.size.height);
        
        // Add to parent layer
        self.indicatorLayer = imageLayer;
        
    }
    else
    {
        self.indicatorLayer = nil;
    }
}

- (void)setIndicatorLayer:(CALayer *)indicatorLayer
{
    id oldLayer = self.indicatorLayer;
    if (oldLayer)
    {
        [oldLayer removeFromSuperlayer];
        oldLayer = nil;
    }
    
    objc_setAssociatedObject(self, &kIndicatorLayerKey, indicatorLayer, OBJC_ASSOCIATION_RETAIN);
    
    [self.layer addSublayer:self.indicatorLayer];
}

- (CALayer *)indicatorLayer
{
    return objc_getAssociatedObject(self, &kIndicatorLayerKey);
}

- (void)setIndicatorOrigin:(CGPoint)indicatorOrigin
{
    objc_setAssociatedObject(self, &kIndicatorLayerOriginKey, [NSValue valueWithCGPoint:indicatorOrigin], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    if (self.indicatorLayer)
    {
        CGRect frame = self.indicatorLayer.frame;
        frame.origin = indicatorOrigin;
        self.indicatorLayer.frame = frame;
    }
}

- (CGPoint)indicatorOrigin
{
    id obj = objc_getAssociatedObject(self, &kIndicatorLayerOriginKey);
    if ([obj isKindOfClass:[NSValue class]]) {
        return [obj CGPointValue];
    }
    return CGPointZero;
}

@end

