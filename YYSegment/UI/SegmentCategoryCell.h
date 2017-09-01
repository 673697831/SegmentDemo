//
//  SegmentCategoryCell.h
//  SegmentCategoryViewDemo
//
//  Created by zhenby on 7/1/14.
//  Copyright (c) 2014 zhenby. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SegmentCategoryCell : UICollectionViewCell

@property (nonatomic, getter=isShowIndicator) BOOL showIndicator;

- (void)setTitle:(NSString *)title iconImage:(UIImage *)iconImage;
- (void)setTitle:(NSString *)title selectedIconImage:(UIImage *)selectedIconImage;
- (void)highlightedWithIconImage:(UIImage *)iconImage;
- (void)unhighlightedWithIconImage:(UIImage *)iconImage;

@end
