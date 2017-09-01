//
//  YYBadgeView.m
//  YYMobile
//
//  Created by wuwei on 14-3-3.
//  Copyright (c) 2014年 YY Inc. All rights reserved.
//

#import "YYBadgeView.h"

#define BADGE_VIEW_STANDARD_HEIGHT      17.0f
#define BADGE_VIEW_LARGE_HEIGHT         30.0f
#define BADGE_VIEW_STANDARD_WIDTH       30.0f
#define BADGE_VIEW_SMALL_WIDTH          17.0f
#define BADGE_VIEW_DEFAULT_FONT_SIZE    12.0f

#define BADGE_VIEW_HORIZONTAL_PADDING    3.0
#define BADGE_VIEW_TRUNCATED_SUFFIX      @"..."

@interface NSString (TruncatingToWidthForBadgeView)

- (NSString*)stringByTruncatingToWidth:(CGFloat)width font:(UIFont*)font suffix:(NSString *)suffix;

@end

@interface YYBadgeView ()

@property (nonatomic, strong) NSString *displayTextInternal;
@property (nonatomic, assign) CGRect badgeFrameInternal;

- (void)bvp_setup;
- (void)bvp_adjustBadgeFrameOriginX;
- (void)bvp_adjustBadgeFrameSizeWidth;
- (void)bvp_adjustBadgeFrame;

@end

@implementation YYBadgeView

@synthesize text = __text, textColor = __textColor, badgeColor =__badgeColor;
@synthesize borderColor = __borderColor, borderWidth = __borderWidth;
@synthesize horizontalAlignment = __horizontalAlignment;
@synthesize widthMode = __widthMode, heightMode = __heightMode;
@synthesize textOffset = __textOffset, textFont = __font;
@synthesize displayTextInternal = __displayTextInternal;
@synthesize badgeFrameInternal = __badgeFrameInternal;
@synthesize horizontalPadding = __horizontalPadding;

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self bvp_setup];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self bvp_setup];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self bvp_setup];
    }
    return self;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    if (self.displayTextInternal.length == 0)
    {
        return;
    }
    
    // Drawing Badge
    UIBezierPath *badgePath = [UIBezierPath bezierPath];
    
    CGSize size = self.badgeFrameInternal.size;
    CGFloat radius = size.height / 2.0;
    CGPoint bp = self.badgeFrameInternal.origin;
    CGPoint c1 = CGPointMake(bp.x + radius, bp.y);
    [badgePath moveToPoint:c1];
    c1.y += radius;
    [badgePath addArcWithCenter:c1
                         radius:radius
                     startAngle:3 * M_PI / 2
                       endAngle:M_PI / 2
                      clockwise:NO];
    
    [badgePath addLineToPoint:CGPointMake(bp.x + size.width - radius, bp.y + size.height)];
    
    CGPoint c2 = CGPointMake(bp.x + size.width - radius, bp.y + radius);
    [badgePath addArcWithCenter:c2
                         radius:radius
                     startAngle:M_PI / 2
                       endAngle:-M_PI / 2
                      clockwise:NO];
    
    [badgePath addLineToPoint:CGPointMake(bp.x + radius, bp.y)];
    
    [self.borderColor setStroke];
    [self.badgeColor setFill];
    
    [badgePath setLineWidth:self.borderWidth];
    
    //    CGContextRef context = UIGraphicsGetCurrentContext();
    
    [badgePath fill];
    [badgePath stroke];
    
    // Draw Text
    [self.textColor setFill];
    CGSize textSize = [self.displayTextInternal sizeWithAttributes:@{NSFontAttributeName:self.textFont}];
    CGPoint p = CGPointMake(bp.x + (self.badgeFrameInternal.size.width - textSize.width) / 2.0 + self.textOffset.width,
                            bp.y + (self.badgeFrameInternal.size.height - textSize.height) / 2.0 + self.textOffset.height);
    [self.displayTextInternal drawAtPoint:p withAttributes:@{NSFontAttributeName: self.textFont, NSForegroundColorAttributeName: self.textColor}];
}

#pragma mark - Properties

- (void)setText:(NSString *)text
{
    if (![__text isEqualToString:text])
    {
        __text = text;
        [self bvp_adjustBadgeFrame];
        [self setNeedsDisplay];
    }
    else
    {
        // Equal
        __text = text;
    }
}

- (void)setTextColor:(UIColor *)textColor
{
    __textColor = textColor;
    [self setNeedsDisplay];
}

- (void)setBadgeColor:(UIColor *)badgeColor
{
    __badgeColor = badgeColor;
    [self setNeedsDisplay];
}

- (void)setBorderColor:(UIColor *)borderColor
{
    __borderColor = borderColor;
    [self setNeedsDisplay];
}

- (void)setBorderWidth:(CGFloat)borderWidth
{
    __borderWidth = self.borderWidth;
    [self setNeedsDisplay];
}

- (void)setHorizontalAlignment:(YYBadgeViewHorizontalAlignment)horizontalAlignment
{
    if (__horizontalAlignment != horizontalAlignment)
    {
        __horizontalAlignment = horizontalAlignment;
        [self bvp_adjustBadgeFrameOriginX];
        [self setNeedsDisplay];
    }
}

- (void)setWidthMode:(YYBadgeViewWidthMode)widthMode
{
    if (__widthMode != widthMode)
    {
        __widthMode = widthMode;
        [self bvp_adjustBadgeFrameSizeWidth];
        [self setNeedsDisplay];
    }
}

- (void)setHeightMode:(YYBadgeViewHeightMode)heightMode
{
    if (__heightMode != heightMode)
    {
        __heightMode = heightMode;
        [self bvp_adjustBadgeFrame];
        [self setNeedsDisplay];
    }
}

- (void)setTextOffset:(CGSize)textOffset
{
    if (!CGSizeEqualToSize(__textOffset, textOffset))
    {
        __textOffset = textOffset;
        [self setNeedsDisplay];
    }
}

- (void)setHorizontalPadding:(CGFloat)horizontalPadding
{
    if (__horizontalPadding != horizontalPadding)
    {
        __horizontalPadding = horizontalPadding;
        [self bvp_adjustBadgeFrame];
        [self setNeedsDisplay];
    }
}

- (void)setTextFont:(UIFont *)textFont
{
    __font = textFont;
    
    [self bvp_adjustBadgeFrame];
    [self setNeedsDisplay];
}

- (UIFont *)textFont
{
    if (__font == nil) {
        __font = [UIFont systemFontOfSize:BADGE_VIEW_DEFAULT_FONT_SIZE];
    }
    return __font;
}

- (UIColor *)textColor
{
    if (__textColor == nil) {
        __textColor = [UIColor blackColor];
    }
    return __textColor;
}

- (CGFloat)badgeWidth {
    CGFloat width = 0.0f;
    switch (self.widthMode) {
        case YYBadgeViewWidthModeSmall:
            width = BADGE_VIEW_SMALL_WIDTH;
            break;
        case YYBadgeViewHeightMode13:
            width = 13;
            break;
        case YYBadgeViewWidthModeStandard:
        default:
            width = BADGE_VIEW_STANDARD_WIDTH;
            break;
    }
    return width;
}

- (CGFloat)badgeHeight
{
    CGFloat height = 0.0f;
    switch (self.heightMode) {
        case YYBadgeViewHeightModeLarge:
            height = BADGE_VIEW_LARGE_HEIGHT;
            break;
        case YYBadgeViewHeightMode13:
            height = 13;
            break;
        case YYBadgeViewHeightModeStandard:
        default:
            height = BADGE_VIEW_STANDARD_HEIGHT;
            break;
    }
    return height;
}

#pragma mark - Badge View Private

- (void)bvp_setup
{
    __text = @"";
    __horizontalAlignment = YYBadgeViewHorizontalAlignmentDefault;
    __widthMode = YYBadgeViewWidthModeDefault;
    __heightMode = YYBadgeViewHeightModeDefault;
    __horizontalPadding = BADGE_VIEW_HORIZONTAL_PADDING;
    
    self.backgroundColor = [UIColor clearColor];
    self.userInteractionEnabled = NO;
    
    // System style
    __textColor = UIColor.whiteColor;
    __badgeColor = [UIColor colorWithHexString:@"FF4F4F"];
    
    __font = [UIFont systemFontOfSize:BADGE_VIEW_DEFAULT_FONT_SIZE];
    __textOffset = CGSizeZero;
    __borderWidth = 0.0f;
    __borderColor = [UIColor colorWithWhite:0.65 alpha:1.0];
}

- (void)bvp_adjustBadgeFrame
{
    __badgeFrameInternal.size.height = self.badgeHeight;
    
    [self bvp_adjustBadgeFrameSizeWidth];
    
    __badgeFrameInternal.origin.y = (self.bounds.size.height - __badgeFrameInternal.size.height) / 2.0;
    
    [self bvp_adjustBadgeFrameOriginX];
}

- (void)bvp_adjustBadgeFrameOriginX
{
    switch (self.horizontalAlignment) {
        case YYBadgeViewHorizontalAlignmentLeft:
            __badgeFrameInternal.origin.x = self.borderWidth;
            break;
            
        case YYBadgeViewHorizontalAlignmentCenter:
            __badgeFrameInternal.origin.x = (self.bounds.size.width - __badgeFrameInternal.size.width) / 2.0;
            break;
            
        case YYBadgeViewHorizontalAlignmentRight:
            __badgeFrameInternal.origin.x = self.bounds.size.width - __badgeFrameInternal.size.width - self.borderWidth;
            break;
            
        default:
            // Error
            break;
    }
}

- (void)bvp_adjustBadgeFrameSizeWidth
{
    CGFloat paddingWidth = self.horizontalPadding * 2;
    self.displayTextInternal = self.text;
    CGSize size = [self.text sizeWithAttributes:@{NSFontAttributeName:self.textFont}];
    __badgeFrameInternal.size.width = size.width + paddingWidth;
    
    if (__badgeFrameInternal.size.width > self.bounds.size.width)
    {
        // truncating is required
        CGFloat expectedWidth = self.bounds.size.width - paddingWidth;
        self.displayTextInternal = [self.text stringByTruncatingToWidth:expectedWidth font:self.textFont suffix:BADGE_VIEW_TRUNCATED_SUFFIX];
        __badgeFrameInternal.size.width = [self.displayTextInternal sizeWithAttributes:@{NSFontAttributeName:self.textFont}].width + paddingWidth;
    }
    
    __badgeFrameInternal.size.width = MAX(__badgeFrameInternal.size.width, [self badgeWidth]);
}

@end

@implementation NSString (TruncatingToWidthForBadgeView)

- (NSString *)stringByTruncatingToWidth:(CGFloat)width font:(UIFont*)font suffix:(NSString *)suffix
{
    int min = 0, max = @(self.length).intValue, mid;
    NSString *currentString = @"";
    while (min <= max)
    {
        mid = (min + max) / 2;
        
        currentString = [[self substringToIndex:mid] stringByAppendingString:suffix];
        CGSize currentSize = [currentString sizeWithAttributes:@{NSFontAttributeName:font}];
        
        if (currentSize.width < width) {
            min = mid + 1;
        }
        else if (currentSize.width > width) {
            max = mid - 1;
        }
        else
        {
            min = mid;
            break;
        }
    }
    return currentString;
}

@end

