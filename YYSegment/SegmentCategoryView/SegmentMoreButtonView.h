//
//  SegmentMoreButtonView.h
//  YYMobile
//
//  Created by Arcfat Tsui on 10/21/15.
//  Copyright © 2015 YY.inc. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, SegmentMoreButtonState) {
    SegmentMoreButtonState_Normal = 0,
    SegmentMoreButtonState_Expanded
};

@protocol SegmentMoreButtonViewDelegate <NSObject>

/**
 * 点击按钮回调
 *
 */
@optional
- (void)onSegmentMoreButtonViewTapped;

@end

@interface SegmentMoreButtonView : UIView

@property (nonatomic, weak) id<SegmentMoreButtonViewDelegate> delegate;
@property (nonatomic, getter=isShowIndicator) BOOL showIndicator;
@property (nonatomic) SegmentMoreButtonState buttonState;

@end
