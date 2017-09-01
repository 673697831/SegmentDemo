//
//  CategoryTitleButton.h
//  YYMobile
//
//  Created by zhenby on 14-9-9.
//  Copyright (c) 2014年 YY.inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CategoryTitleButton : UIButton

@property(assign, nonatomic) BOOL showIndicator;

- (void)showBadge:(NSString *)badge;
- (NSString *)badgeString;
- (void)hideBadge;
- (void) showNewBadge:(NSString *)badge;

@end
