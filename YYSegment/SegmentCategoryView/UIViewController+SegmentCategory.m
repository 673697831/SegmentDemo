//
//  UIViewController+SegmentCategory.m
//  SegmentCategoryViewDemo
//
//  Created by zhenby on 14-7-25.
//  Copyright (c) 2014年 zhenby. All rights reserved.
//

#import "UIViewController+SegmentCategory.h"
#import <objc/runtime.h>

static char kSegmentTitle;
static char kSegmentIndex;

@implementation UIViewController (SegmentCategory)

- (SegmentCategoryViewController *)segmentViewController
{
    SegmentCategoryViewController *segmentViewController = nil;
    if ([self.parentViewController isKindOfClass:[SegmentCategoryViewController class]]) {
        segmentViewController = (SegmentCategoryViewController *)self.parentViewController;
    }
    
    return segmentViewController;
}


- (NSString *)segmentTitle
{
    return objc_getAssociatedObject(self, &kSegmentTitle);
}

- (void)setSegmentTitle:(NSString *)segmentTitle
{
    if (![segmentTitle isEqualToString:[self segmentTitle]]) {
        objc_setAssociatedObject(self, &kSegmentTitle, segmentTitle, OBJC_ASSOCIATION_COPY_NONATOMIC);
        [[self segmentViewController] updateSegmentTitle:segmentTitle atIndex:self.segmentIndex];
    }
}


- (void)setShowIndicator:(BOOL)showIndicator
{
    [[self segmentViewController] showIndicator:showIndicator atIndex:self.segmentIndex];
}

- (BOOL)showIndicator
{
    return [[self segmentViewController] isShowIndicateorAtIndex:self.segmentIndex];
}

- (void)showBadge:(NSString *)badge
{
    [[self segmentViewController] showBadge:badge atIndex:self.segmentIndex];
}

- (NSString *)badgeString
{
    return [[self segmentViewController] badgeStringAtIndex:self.segmentIndex];
}

- (void)hideBadge
{
    [[self segmentViewController] hideBadgeAtIndex:self.segmentIndex];
}

- (void)setSegmentIndex:(NSInteger)segmentIndex
{
    NSNumber *segmentIndexNumber = @(segmentIndex);
    objc_setAssociatedObject(self, &kSegmentIndex, segmentIndexNumber, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (NSInteger)segmentIndex
{
    return [objc_getAssociatedObject(self, &kSegmentIndex) integerValue];
}

@end
