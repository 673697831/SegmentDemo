//
//  SegmentCategoryCollectionView.m
//  SegmentCategoryViewDemo
//
//  Created by zhenby on 14-7-30.
//  Copyright (c) 2014年 zhenby. All rights reserved.
//

#import "SegmentCategoryCollectionView.h"

static CGFloat DividingLineWidth    =   0.5;

@interface SegmentCategoryCollectionView ()

@property(copy, nonatomic) NSArray *dividingLineViewArray;

@end

@implementation SegmentCategoryCollectionView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (CGRectEqualToRect(self.bounds, CGRectZero)) {
        return;
    }
    
    if (self.dividingLineViewArray) {
        for (UIView *lineView in self.dividingLineViewArray) {
            [lineView removeFromSuperview];
        }
        
        self.dividingLineViewArray = nil;
    }
    
    UIColor *lineColor = [UIColor colorWithRed:224.0/255.0
                                         green:224.0/255.0
                                          blue:224.0/255.0
                                         alpha:1.0];
    NSMutableArray *lineViewArray = [NSMutableArray array];
    UICollectionViewFlowLayout *flowLayout = (UICollectionViewFlowLayout *)self.collectionViewLayout;
    CGSize itemSize = flowLayout.itemSize;
    CGFloat contentWidth = self.contentSize.width;
    CGFloat contentHeight = self.contentSize.height;
    
    CGFloat x = itemSize.width + DividingLineWidth;
    while ((x + itemSize.width) < contentWidth) {
        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(x, 0.0,
                                                                    DividingLineWidth, contentHeight)];
        lineView.backgroundColor = lineColor;
        [self addSubview:lineView];
        
        x = x + itemSize.width + DividingLineWidth;
        
        [lineViewArray addObject:lineView];
    }
    
    CGFloat y = itemSize.height + DividingLineWidth;
    while ((y + itemSize.height)  < contentHeight) {
        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0.0, y,
                                                                    contentWidth, DividingLineWidth)];
        lineView.backgroundColor = lineColor;
        [self addSubview:lineView];
        
        y = y + itemSize.height + DividingLineWidth;
        
        [lineViewArray addObject:lineView];
    }
    
    self.dividingLineViewArray = lineViewArray;
}

@end
