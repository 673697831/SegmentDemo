//
//  SegmentCategoryBar.m
//  SegmentCategoryViewDemo
//
//  Created by zhenby on 6/30/14.
//  Copyright (c) 2014 zhenby. All rights reserved.
//

#import "SegmentCategoryBar.h"
#import "CategoryTitleButton.h"

#define DefaultSelectedColor        [UIColor colorWithHexString:@"#1D1D1D"]
#define ButtonNormalColor           [UIColor colorWithHexString:@"#999999"]
#define LineViewBackgroundColor     [UIColor colorWithHexString:@"#FFDD00"]
#define DefaultSelectedTitleFont    [UIFont boldSystemFontOfSize:16]
#define ButtonNormalTitleFont       [UIFont systemFontOfSize:16]

static const NSInteger ButtonStartTag               =   200;
static const CGFloat DefaultCategoryTitlePadding    =   20.0;
static const CGFloat LineViewHeight                 =   3.0; //2.0;
static const CGFloat LineViewWidth                  =   25.0;

@interface SegmentCategoryBar ()
    
    @property(assign, nonatomic) NSInteger selectedIndex;
    @property(strong, nonatomic) UIScrollView *scrollView;
    @property(strong, nonatomic) UIView *lineView;
    @property(strong, nonatomic) NSArray *buttonArray;
    
    @end

@interface TestScrollView : UIScrollView
    
    @end

@implementation TestScrollView
    
- (void)setContentOffset:(CGPoint)contentOffset{
    [super setContentOffset:contentOffset];
    NSLog(@"%@",NSStringFromCGPoint(contentOffset));
}
    
    @end

@implementation SegmentCategoryBar
    
    @synthesize selectedColor = _selectedColor;
    @synthesize buttonSelectedTitleFont = _buttonSelectedTitleFont;
    @synthesize buttonNormalTitleFont = _buttonNormalTitleFont;
    
- (instancetype)initWithFrame:(CGRect)frame
    {
        self = [super initWithFrame:frame];
        if (self) {
            _selectedIndex = -1;
            _categoryTitlePadding = DefaultCategoryTitlePadding;
            self.backgroundColor = [UIColor whiteColor];
            self.clipsToBounds = NO;
            self.isCenter = YES;
        }
        
        return self;
    }
    
- (void)setIsCenter:(BOOL)isCenter
    {
        if (_isCenter != isCenter) {
            _isCenter = isCenter;
            
            [self resizeSubview];
            [self updateLineFrameDependOnSelectedIndex];
        }
    }
    
- (void)layoutSubviews
    {
        [super layoutSubviews];
        
        [self resizeSubview];
        [self updateLineFrameDependOnSelectedIndex];
    }
    
    
#pragma mark - Util Methods
    
- (void)updateSubview
    {
        if (!self.categoryTitleArray) {
            [self.scrollView removeFromSuperview];
            self.scrollView = nil;
            return;
        }
        
        if (!self.scrollView) {
            self.scrollView = [[TestScrollView alloc] initWithFrame:CGRectZero];
            self.scrollView.backgroundColor = self.backgroundColor;
            self.scrollView.scrollsToTop = NO;
            [self addSubview:self.scrollView];
        }
        
        [self.buttonArray makeObjectsPerformSelector:@selector(removeFromSuperview)];
        
        NSInteger buttonCount = [self.categoryTitleArray count];
        NSMutableArray *tempArray = [[NSMutableArray alloc] init];
        for (NSInteger i = 0; i < buttonCount; i++) {
            CategoryTitleButton *button = [CategoryTitleButton buttonWithType:UIButtonTypeCustom];
            button.clipsToBounds = NO;
            button.backgroundColor = [UIColor clearColor];
            
            // Title 可能为 NSAttributeString，或者 NSString
            NSObject *titleObject = self.categoryTitleArray[i];
            if ([titleObject isKindOfClass:[NSAttributedString class]]) {
                [button setAttributedTitle:(NSAttributedString *)titleObject
                                  forState:UIControlStateNormal];
                NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc]
                                                               initWithAttributedString:(NSAttributedString *)titleObject];
                [attributedString addAttribute:NSForegroundColorAttributeName
                                         value:DefaultSelectedColor
                                         range:NSMakeRange(0, ((NSAttributedString *)titleObject).length)];
                [button setAttributedTitle:attributedString forState:UIControlStateSelected];
            } else if ([titleObject isKindOfClass:[NSString class]]) {
                [button setTitle:(NSString *)titleObject forState:UIControlStateNormal];
                button.titleLabel.font = self.buttonNormalTitleFont? : ButtonNormalTitleFont;
                [button setTitleColor:ButtonNormalColor forState:UIControlStateNormal];
                [button setTitleColor:DefaultSelectedColor forState:UIControlStateSelected];
            }
            
            button.tag = ButtonStartTag + i;
            
            [button addTarget:self
                       action:@selector(onSegmentCategoryPressed:)
             forControlEvents:UIControlEventTouchUpInside];
            
            if (self.selectedIndex == i) {
                [self setButton:button selected:YES];
            }
            
            [self.scrollView addSubview:button];
            
            [tempArray addObject:button];
        }
        
        self.buttonArray = ([tempArray count] > 0) ? [tempArray copy] : nil;
        
        self.scrollView.showsHorizontalScrollIndicator = NO;
        
        if (!self.lineView) {
            self.lineView = [[UIView alloc] init];
            self.lineView.layer.cornerRadius = LineViewHeight/2.0;
            self.lineView.layer.masksToBounds = YES;
            [self.scrollView addSubview:self.lineView];
        }
        self.lineView.backgroundColor = LineViewBackgroundColor;
        
        if (self.selectedIndex < 0 || self.selectedIndex >= [self.buttonArray count]) {
            [self scrollToIndex:0];
        }
        
        [self resizeSubview];
    }
    
- (void)resizeSubview
    {
        if (_useNewLayoutStrategy) {
            [self layoutWithNewStrategy];
            return ;
        }
        self.scrollView.frame = self.bounds;
        
        NSInteger buttonCount = [self.buttonArray count];
        CGFloat contentWidth = self.categoryTitlePadding;
        for (NSInteger i = 0; i < buttonCount; i++) {
            NSObject *titleObject = self.categoryTitleArray[i];
            CGSize sizeTitle = CGSizeZero;
            if ([titleObject isKindOfClass:[NSAttributedString class]]) {
                sizeTitle = [self sizeWithButtonAttributedTitle:(NSAttributedString *)titleObject];
            } else if ([titleObject isKindOfClass:[NSString class]]) {
                sizeTitle = [self sizeWithButtonTitle:(NSString *)titleObject];
            }
            contentWidth = contentWidth + floor(sizeTitle.width) + self.categoryTitlePadding;
        }
        
        BOOL isOverBound = (contentWidth > CGRectGetWidth(self.bounds));
        
        CGFloat blankSpacePadding = self.categoryTitlePadding;
        if (!isOverBound) {
            
            if (self.isCenter) {
                blankSpacePadding = (CGRectGetWidth(self.bounds) - (contentWidth - (buttonCount + 1) * self.categoryTitlePadding))/ (buttonCount + 1);
            } else {
                blankSpacePadding = (CGRectGetWidth(self.bounds) - contentWidth)/2.0;
            }
            
        }else if(_forceUndraggable){
            self.categoryTitlePadding = self.categoryTitlePadding - (contentWidth -  CGRectGetWidth(self.bounds))/(buttonCount+1);
            [self resizeSubview];
            return ;
        }
        
        CGFloat width = self.categoryTitlePadding + blankSpacePadding;
        
        if (self.isCenter) {
            width = self.categoryTitlePadding + (blankSpacePadding - self.categoryTitlePadding) / 2.0;
        }
        
        for (NSInteger index = 0; index < [self.buttonArray count]; index++) {
            CategoryTitleButton *button = self.buttonArray[index];
            CGSize size = CGSizeZero;
            if (button.currentAttributedTitle) {
                size = [self sizeWithButtonAttributedTitle:button.currentAttributedTitle];
            } else {
                size = [self sizeWithButtonTitle:button.currentTitle];
            }
            CGFloat buttonX = width;
            
            CGFloat buttonWidth = size.width; //+ (blankSpacePadding - self.categoryTitlePadding);
            if (self.isCenter) {
                buttonWidth = size.width + (blankSpacePadding - self.categoryTitlePadding);
            }
            
            button.frame = CGRectMake(buttonX, 0.0, buttonWidth, CGRectGetHeight(self.bounds));
            
            width = width + buttonWidth + self.categoryTitlePadding;
        }
        if (_forceUndraggable){
            self.scrollView.contentSize = self.scrollView.bounds.size;
        }else{
            self.scrollView.contentSize = CGSizeMake(width, CGRectGetHeight(self.scrollView.bounds));
        }
        
        self.lineView.frame = [self lineFrameWithButtonIndex:self.selectedIndex];
        self.lineView.clipsToBounds = YES;
        self.lineView.layer.cornerRadius = self.lineView.frame.size.height/2;
    }
    
- (void)layoutWithNewStrategy{
    self.scrollView.frame = self.bounds;
    
    NSInteger buttonCount = [self.buttonArray count];
    _extraClickWidth = MAX(0,MIN(_extraClickWidth, _titlePadding/2));
    CGFloat xPos = _leadingSpace - _extraClickWidth / 2;
    
    CGFloat contentWidth = _leadingSpace;
    
    for (NSInteger i = 0; i < buttonCount; i++) {
        NSObject *titleObject = self.categoryTitleArray[i];
        CGSize titleSize = CGSizeZero;
        if ([titleObject isKindOfClass:[NSAttributedString class]]) {
            titleSize = [self sizeWithButtonAttributedTitle:(NSAttributedString *)titleObject];
        } else if ([titleObject isKindOfClass:[NSString class]]) {
            titleSize = [self sizeWithButtonTitle:(NSString *)titleObject];
        }
        contentWidth = contentWidth + floor(titleSize.width) + _titlePadding; // 不需要管 extraClickWidth， 因为不影响实际的contentWidth
        
        //layout buttons
        CategoryTitleButton *button = self.buttonArray[i];
        button.frame = CGRectMake(xPos, 0, titleSize.width + _extraClickWidth, self.bounds.size.height);
        
        xPos += button.frame.size.width + _titlePadding - _extraClickWidth;
    }
    contentWidth -= _titlePadding; //末尾会多算一个padding
    
    self.scrollView.contentSize = CGSizeMake(contentWidth, self.bounds.size.height);
    if (_placeAtCenter && contentWidth < self.scrollView.bounds.size.width) {
        //算上leadingSpace，contentSize依然小，则忽略leading，走居中逻辑。
        CGFloat offset = (self.scrollView.bounds.size.width - contentWidth) / 2;
        for (NSInteger i = 0; i < buttonCount; i++) {
            //layout buttons
            CategoryTitleButton *button = self.buttonArray[i];
            button.frame = CGRectMake(button.frame.origin.x - _leadingSpace + offset, 0, button.frame.size.width, self.bounds.size.height);
            
            //本来是想设contentInset的，但是设了不知道搞毛系统会各种自动设我的contentOffset，所以只能改buttonFrame了。
        }
        contentWidth -= _leadingSpace;
        
        self.scrollView.contentSize = CGSizeMake(contentWidth, self.bounds.size.height);
    }
    
    
    self.lineView.frame = [self lineFrameWithButtonIndex:self.selectedIndex];
    self.lineView.clipsToBounds = YES;
    self.lineView.layer.cornerRadius = self.lineView.frame.size.height/2;
}
    
    //- (void)setExtraClickWidth:(CGFloat)extraClickWidth{
    //    if (extraClickWidth != _extraClickWidth) {
    //        _extraClickWidth = extraClickWidth;
    //        [self resizeSubview];
    //    }
    //}
    
- (void)setTitlePadding:(CGFloat)titlePadding{
    if (_titlePadding != titlePadding) {
        _titlePadding = titlePadding;
    }
    [self updateSubview];
}
    
- (void)setSelectedButtonSelected:(BOOL)selected
    {
        if (self.selectedIndex < [self.buttonArray count]) {
            CategoryTitleButton *selectedButton = self.buttonArray[self.selectedIndex];
            [self setButton:selectedButton selected:selected];
        }
    }
    
- (void)setButton:(CategoryTitleButton *)button selected:(BOOL)selected
    {
        //    button.titleLabel.font = selected ? DefaultSelectedTitleFont : ButtonNormalTitleFont;
        //    button.selected = selected;
        if(selected){
            button.titleLabel.font = self.buttonSelectedTitleFont ? : DefaultSelectedTitleFont;
        }else{
            button.titleLabel.font = self.buttonNormalTitleFont ? : ButtonNormalTitleFont;
        }
        
        button.selected = selected;
    }
    
- (void)showIndicator:(BOOL)showIndicator atIndex:(NSInteger)index
    {
        if (index < [self.buttonArray count]) {
            CategoryTitleButton *selectedButton = self.buttonArray[index];
            selectedButton.showIndicator = showIndicator;
        }
    }
    
- (BOOL)isShowIndicateorAtIndex:(NSInteger)index
    {
        BOOL showIndicator = NO;
        if (index < [self.buttonArray count]) {
            CategoryTitleButton *selectedButton = self.buttonArray[index];
            showIndicator = selectedButton.showIndicator;
        }
        
        return showIndicator;
    }
    
- (void)showBadge:(NSString *)badge atIndex:(NSInteger)index
    {
        if (index < [self.buttonArray count]) {
            CategoryTitleButton *selectedButton = self.buttonArray[index];
            [selectedButton showBadge:badge];
        }
    }
    
- (void) showNewBadge:(NSString *)badge atIndex:(NSInteger)index
    {
        if (index < [self.buttonArray count]) {
            CategoryTitleButton *selectedButton = self.buttonArray[index];
            [selectedButton showNewBadge:badge];
        }
    }
    
- (NSString *)badgeStringAtIndex:(NSInteger)index
    {
        NSString *badge = nil;
        
        if (index < [self.buttonArray count]) {
            CategoryTitleButton *selectedButton = self.buttonArray[index];
            badge = [selectedButton badgeString];
        }
        
        return badge;
    }
    
- (void)hideBadgeAtIndex:(NSInteger)index
    {
        if (index < [self.buttonArray count]) {
            CategoryTitleButton *selectedButton = self.buttonArray[index];
            [selectedButton hideBadge];
        }
    }
    
- (void)updateTitle:(NSString *)title atIndex:(NSInteger)index
    {
        if (title.length > 0 && index < [self.buttonArray count]) {
            CategoryTitleButton *titleButton = self.buttonArray[index];
            [titleButton setTitle:title forState:UIControlStateNormal];
            
            if (index < [self.categoryTitleArray count]) {
                NSMutableArray *tempArray = [NSMutableArray arrayWithArray:self.categoryTitleArray];
                tempArray[index] = title;
                _categoryTitleArray = tempArray;
            }
        }
    }
    
- (void)updateAttributedTitle:(NSAttributedString *)attributedTitle atIndex:(NSInteger)index
    {
        if (attributedTitle != nil && index < [self.buttonArray count]) {
            CategoryTitleButton *titleButton = self.buttonArray[index];
            [titleButton setTitle:@"" forState:UIControlStateNormal];
            [titleButton setAttributedTitle:attributedTitle forState:UIControlStateNormal];
            
            if (index < [self.categoryTitleArray count]) {
                NSMutableArray *tempArray = [NSMutableArray arrayWithArray:self.categoryTitleArray];
                tempArray[index] = attributedTitle;
                _categoryTitleArray = [tempArray copy];
            }
        }
    }
    
    
#pragma mark - Setter
    
- (void)setCategoryTitleArray:(NSArray *)categoryTitleArray
    {
        if (categoryTitleArray != _categoryTitleArray) {
            _categoryTitleArray = [categoryTitleArray copy];
            
            [self updateSubview];
        }
    }
    
- (void)setSelectedColor:(UIColor *)selectedColor
    {
        if (_selectedColor != selectedColor) {
            _selectedColor = selectedColor;
            [self setSelectedButtonSelected:YES];
            //        self.lineView.backgroundColor = self.selectedColor;
        }
    }
    
- (void)setButtonNormalTitleFont:(UIFont *)buttonNormalTitleFont{
    if (_buttonNormalTitleFont != buttonNormalTitleFont) {
        _buttonNormalTitleFont = buttonNormalTitleFont;
        
        for(NSInteger i = 0; i < self.buttonArray.count; i++){
            if (self.selectedIndex != i) {
                CategoryTitleButton *button = self.buttonArray[i];
                button.titleLabel.font = _buttonNormalTitleFont;
            }
        }
    }
}
    
- (void)setButtonSelectedTitleFont:(UIFont *)buttonSelectedTitleFont{
    if (_buttonSelectedTitleFont != buttonSelectedTitleFont) {
        _buttonSelectedTitleFont = buttonSelectedTitleFont;
        
        if (self.selectedIndex < [self.buttonArray count]) {
            CategoryTitleButton *selectedButton = self.buttonArray[self.selectedIndex];
            selectedButton.titleLabel.font = _buttonSelectedTitleFont;
        }
        
    }
}
    
- (UIFont *)buttonNormalTitleFont{
    return _buttonNormalTitleFont ? : ButtonNormalTitleFont;
}
    
- (UIFont *)buttonSelectedTitleFont{
    return _buttonSelectedTitleFont ? : DefaultSelectedTitleFont;
}
    
#pragma mark - Public Method
    
- (void)setLineOffsetWithPage:(NSInteger)page ratio:(CGFloat)ratio
    {
        UIButton *currentButton = (UIButton *)[self viewWithTag:(page + ButtonStartTag)];
        CGRect lineFrame = currentButton.frame;
        if ([currentButton isKindOfClass:[UIButton class]]) {
            CGSize titleSize = [self sizeWithButtonTitle:currentButton.currentTitle];
            lineFrame.origin.x = lineFrame.origin.x + (lineFrame.size.width - titleSize.width) / 2.0;
            lineFrame.size.width = titleSize.width;
        }
        
        CGFloat width = lineFrame.size.width;
        CGFloat x = lineFrame.origin.x + lineFrame.size.width * ratio;
        
        UIButton *nextButton = (UIButton *)[self viewWithTag:(page + 1 + ButtonStartTag)];
        if (nextButton) {
            CGRect nextLineFrame = nextButton.frame;
            if ([nextButton isKindOfClass:[UIButton class]]) {
                CGSize nextTitleSize = [self sizeWithButtonTitle:nextButton.currentTitle];
                nextLineFrame.origin.x = nextLineFrame.origin.x + (nextLineFrame.size.width - nextTitleSize.width) / 2.0;
                nextLineFrame.size.width = nextTitleSize.width;
            }
            
            width = nextLineFrame.size.width;
            if (nextLineFrame.size.width < lineFrame.size.width) {
                width =  lineFrame.size.width - (lineFrame.size.width - nextLineFrame.size.width) * ratio;
            } else if(nextLineFrame.size.width > lineFrame.size.width) {
                width =  lineFrame.size.width + (nextLineFrame.size.width - lineFrame.size.width) * ratio;
            }
            x = lineFrame.origin.x + (nextLineFrame.origin.x - lineFrame.origin.x) * ratio;
        }
        
        self.lineView.frame = [self lineFrameWithLineX:x lineWidth:width];
    }
    
- (void)updateLineFrameDependOnSelectedIndex
    {
        CGRect lineRC  = [self viewWithTag:(self.selectedIndex + ButtonStartTag)].frame;
        [UIView animateWithDuration:0.2 animations:^{
            self.lineView.frame = [self lineFrameWithButtonIndex:self.selectedIndex];
        } completion:^(BOOL finished) {
            if((lineRC.origin.x - self.scrollView.contentOffset.x) > (CGRectGetWidth(self.bounds) * 2 / 3)) {
                NSInteger index = self.selectedIndex;
                if (self.selectedIndex + 2 < self.buttonArray.count) {
                    index = self.selectedIndex + 2;
                } else if (self.selectedIndex + 1 < self.buttonArray.count) {
                    index = self.selectedIndex + 1;
                }
                CGRect rc = [self viewWithTag:index + ButtonStartTag].frame;
                rc = CGRectMake(CGRectGetMinX(rc) - self.categoryTitlePadding, CGRectGetMinY(rc),
                                CGRectGetWidth(rc) + 2 * self.categoryTitlePadding, CGRectGetHeight(rc));
                [self.scrollView scrollRectToVisible:rc animated:YES];
            } else if(lineRC.origin.x - self.scrollView.contentOffset.x < CGRectGetWidth(self.bounds) / 3) {
                NSInteger index = self.selectedIndex;
                if ((self.selectedIndex - 2) >= 0) {
                    index = self.selectedIndex - 2;
                } else if (self.selectedIndex - 1 >= 0) {
                    index = self.selectedIndex - 1;
                }
                CGRect rc = [self viewWithTag:index + ButtonStartTag].frame;
                rc = CGRectMake(CGRectGetMinX(rc) - self.categoryTitlePadding, CGRectGetMinY(rc),
                                CGRectGetWidth(rc) + 2 * self.categoryTitlePadding, CGRectGetHeight(rc));
                [self.scrollView scrollRectToVisible:rc animated:YES];
            }
        }];
    }
    
- (void)scrollToIndex:(NSInteger)index
    {
        if(self.selectedIndex != index) {
            [self setSelectedButtonSelected:NO];
            self.selectedIndex = index;
            [self setSelectedButtonSelected:YES];
            
            [self updateLineFrameDependOnSelectedIndex];
        }
    }
    
#pragma mark - Getter
    
- (UIColor *)selectedColor
    {
        return _selectedColor ? _selectedColor : DefaultSelectedColor;
    }
    
    
#pragma mark - Action Handle
    
- (void)onSegmentCategoryPressed:(CategoryTitleButton *)sender
    {
        CategoryTitleButton *btn = (CategoryTitleButton *)sender;
        if (self.selectedIndex != btn.tag - ButtonStartTag) {
            [self scrollToIndex:(btn.tag - ButtonStartTag)];
            
            if([self.delegate respondsToSelector:@selector(segmentCategoryBar:selectedIndexChanged:)]) {
                [self.delegate segmentCategoryBar:self selectedIndexChanged:self.selectedIndex];
            }
        }
    }
    
    
#pragma mark - Util Methods
    
- (CGSize)sizeWithButtonTitle:(NSString *)title
    {
        return [title boundingRectWithSize:CGSizeMake(MAXFLOAT, CGRectGetHeight(self.bounds))
                                   options:NSStringDrawingUsesLineFragmentOrigin
                                attributes:@{NSFontAttributeName:self.buttonSelectedTitleFont ? : DefaultSelectedTitleFont}
                                   context:nil].size;
    }
    
- (CGSize)sizeWithButtonAttributedTitle:(NSAttributedString *)attributedTitle
    {
        return [attributedTitle boundingRectWithSize:CGSizeMake(MAXFLOAT, CGRectGetHeight(self.bounds))
                                             options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesFontLeading
                                             context:nil].size;
    }
    
- (CGRect)lineFrameWithLineX:(CGFloat)lineX lineWidth:(CGFloat)lineWidth
    {
        //6.0宽度固定为24*3,距离下边距5
        CGFloat aLineX = lineX +(lineWidth - LineViewWidth)/2.0;
        return CGRectMake(aLineX, self.frame.size.height - LineViewHeight - 5, LineViewWidth, LineViewHeight);
    }
    
- (CGRect)lineFrameWithButtonIndex:(NSUInteger)buttonIndex
    {
        UIButton *button  = (UIButton *)[self viewWithTag:self.selectedIndex + ButtonStartTag];
        if (![button isKindOfClass:[UIButton class]]) {
            return CGRectZero;
        }
        
        CGFloat titleWidth = 0.0;
        if (button.currentAttributedTitle) {
            titleWidth = [self sizeWithButtonAttributedTitle:button.currentAttributedTitle].width;
        } else {
            titleWidth = [self sizeWithButtonTitle:button.currentTitle].width;
        }
        
        CGFloat lineX = CGRectGetMinX(button.frame) + (CGRectGetWidth(button.frame) - titleWidth) / 2.0;
        return [self lineFrameWithLineX:lineX lineWidth:titleWidth];
    }
    
    
    @end
