//
//  UIViewController+SegmentCategory.h
//  SegmentCategoryViewDemo
//
//  Created by zhenby on 14-7-25.
//  Copyright (c) 2014年 zhenby. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SegmentCategoryViewController.h"

@interface UIViewController (SegmentCategory)

@property(readonly, nonatomic) SegmentCategoryViewController *segmentViewController;
@property(copy, nonatomic) NSString *segmentTitle;

@property(assign, nonatomic) NSInteger segmentIndex;
@property(assign, nonatomic) BOOL showIndicator;

- (void)showBadge:(NSString *)badge;
- (NSString *)badgeString;
- (void)hideBadge;

@end
