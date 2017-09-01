//
//  SegmentCategoryViewController.m
//  SegmentCategoryViewDemo
//
//  Created by zhenby on 6/30/14.
//  Copyright (c) 2014 zhenby. All rights reserved.
//

#import "SegmentCategoryViewController.h"
#import "SegmentCategoryBar.h"
#import "UIViewController+SegmentCategory.h"

@interface SegmentCategoryViewController ()<SegmentCategoryDataSource, SegmentCategoryDelegate>

@property(assign, nonatomic) BOOL isReloaded;

@end

@implementation SegmentCategoryViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];

    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.categoryTitlePadding = -1;
    self.topContentInset = -1;
    self.bottomContentInset = -1;
    self.disableSegment = NO;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.automaticallyAdjustsScrollViewInsets = NO;

    self.segmentView = [[SegmentCategoryView alloc] initWithFrame:self.view.bounds];
    self.segmentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.segmentView.dataSource = self;
    self.segmentView.delegate = self;
    self.segmentView.selectedIndex = self.selectedIndex;
    self.segmentView.horizontalScrollDisable = self.horizontalScrollDisable;
    if (self.topContentInset >= 0) {
        self.segmentView.topContentInset = self.topContentInset;
    }
    if (self.bottomContentInset >= 0) {
        self.segmentView.bottomContentInset = self.bottomContentInset;
    }

    [self.view addSubview:self.segmentView];
    
    if (self.navigationController) {
        self.segmentView.topContentInset = NavBarDefaultTopContentInset;
#ifdef IsWolfSDK
        if (IsWolfSDK) {
            self.segmentView.topContentInset = 0; //狼人杀navitabbar实现和手y不同。
        }
#endif
    }
    
    if (self.tabBarController && self.hidesBottomBarWhenPushed == NO) {
        self.segmentView.bottomContentInset = TabBarDefaultBottomContentInset;
#ifdef IsWolfSDK
        if (IsWolfSDK) {
            self.segmentView.bottomContentInset = 0; //狼人杀tabbar实现和手y不同。
        }
#endif
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (!self.isReloaded) {
        [self.segmentView reloadData];
        self.isReloaded = YES;
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Public Method

- (void)triggerScrollToIndex:(NSInteger)index
{
    [self.segmentView triggerScrollToIndex:index];
}

- (void)showIndicator:(BOOL)showIndicator atIndex:(NSInteger)index
{
    [self.segmentView.categoryBar showIndicator:showIndicator atIndex:index];
}

- (BOOL)isShowIndicateorAtIndex:(NSInteger)index
{
    return [self.segmentView.categoryBar isShowIndicateorAtIndex:index];
}

- (void)showBadge:(NSString *)badge atIndex:(NSInteger)index
{
    [self.segmentView.categoryBar showBadge:badge atIndex:index];
}

- (NSString *)badgeStringAtIndex:(NSInteger)index
{
    return [self.segmentView.categoryBar badgeStringAtIndex:index];
}

- (void)hideBadgeAtIndex:(NSInteger)index
{
    [self.segmentView.categoryBar hideBadgeAtIndex:index];
}

- (void)updateSegmentTitle:(NSString *)title atIndex:(NSInteger)index
{
    [self.segmentView updateSegmentTitle:title atIndex:index];
}

#pragma mark - Setter

- (void)setViewControllers:(NSArray *)viewControllers
{
    for (UIViewController *viewController in self.childViewControllers) {
        [viewController removeFromParentViewController];
    }
    
    NSInteger index = 0;
    for (UIViewController *viewController in viewControllers) {
        viewController.segmentIndex = index;
        //如果viewControllers数组有重复的元素，此处不会进行重复添加
        [self addChildViewController:viewController];
        
        index ++;
    }
}

- (void)reloadSegment
{
    [self.segmentView reloadData];
}

- (void)setSelectedIndex:(NSUInteger)selectedIndex
{
    if (_selectedIndex != selectedIndex) {
        _selectedIndex = selectedIndex;
        self.segmentView.selectedIndex = selectedIndex;
    }
}

- (void)setHorizontalScrollDisable:(BOOL)horizontalScrollDisable
{
    if (_horizontalScrollDisable != horizontalScrollDisable) {
        _horizontalScrollDisable = horizontalScrollDisable;
        
        self.segmentView.horizontalScrollDisable = _horizontalScrollDisable;
    }
}

- (void)setCategoryBarTintColor:(UIColor *)color
{
    self.segmentView.categoryBar.selectedColor = color;
}

- (void)setCategoryBarBackgroundColor:(UIColor *)categoryBarBackgroundColor{
    self.segmentView.categoryBarBackgroundColor = categoryBarBackgroundColor;
}

- (void)setCategoryBarNormalButtonFont:(UIFont *)categoryBarNormalButtonFont{
    self.segmentView.categoryBar.buttonNormalTitleFont = categoryBarNormalButtonFont;
}

- (void)setCategoryBarSelectedButtonFont:(UIFont *)categoryBarSelectedButtonFont{
    self.segmentView.categoryBar.buttonSelectedTitleFont = categoryBarSelectedButtonFont;
}

- (void)setCategoryTitlePadding:(CGFloat)categoryTitlePadding
{
    self.segmentView.categoryTitlePadding = categoryTitlePadding;
}

- (void)setTopContentInset:(CGFloat)topContentInset
{
    if (_topContentInset != topContentInset && topContentInset >= 0) {
        _topContentInset = topContentInset;
        self.segmentView.topContentInset = _topContentInset;
    }
}

- (void)setBottomContentInset:(CGFloat)bottomContentInset
{
    if (_bottomContentInset != bottomContentInset && bottomContentInset >= 0) {
        _bottomContentInset = bottomContentInset;
        self.segmentView.bottomContentInset = _bottomContentInset;
    }
}

- (void)setIsSupportFull:(BOOL)isSupportFull
{
    _isSupportFull = isSupportFull;
    self.segmentView.isSupportFull = isSupportFull;
}

- (void)setDisableSegment:(BOOL)disableSegment
{
    _disableSegment = disableSegment;
    self.segmentView.dataSource = nil;
    self.segmentView.delegate = nil;
    [self.segmentView removeFromSuperview];
    self.segmentView = nil;
}

- (void)setSegmentHidden:(BOOL)segmentHidden {
    [self.segmentView setCategoryBarHidden:segmentHidden];
}

#pragma mark - Getter

- (NSArray *)viewControllers
{
    return self.childViewControllers;
}


#pragma mark - SegmentCategoryDataSource

- (NSUInteger)numberOfSegmentInSegmentView:(SegmentCategoryView *)segmentView
{
    return [self.viewControllers count];
}

- (NSString *)segmentView:(SegmentCategoryView *)segmentView titleAtIndex:(NSUInteger)index
{
    NSString *title = nil;
    
    if(index < [self.viewControllers count]) {
        UIViewController *viewController = self.viewControllers[index];
        if ([viewController respondsToSelector:@selector(segmentTitle)]) {
            title = [viewController segmentTitle];
        }
    }
    
    return title;
}

- (UIViewController *)segmentView:(SegmentCategoryView *)segmentView contentViewControllerAtIndex:(NSUInteger)index
{
    UIViewController *viewController = nil;
    if (index < [self.viewControllers count]) {
        viewController = self.viewControllers[index];
    }
    
    return viewController;
}


#pragma mark - SegmentCategoryDelegate

- (void)segmentView:(SegmentCategoryView *)segmentView didSelectedAtIndex:(NSUInteger)index
{
    _selectedIndex = index;
    
    if ([self.delegate respondsToSelector:@selector(segmentCategoryViewController:didSelectedAtIndex:)]) {
        [self.delegate segmentCategoryViewController:self didSelectedAtIndex:index];
    }
}

@end
