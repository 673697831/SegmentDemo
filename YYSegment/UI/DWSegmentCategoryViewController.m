//
//  DWSegmentCategoryViewController.m
//  YYSegment
//
//  Created by ouzhirui on 2017/7/29.
//  Copyright © 2017年 YY. All rights reserved.
//

#import "DWSegmentCategoryViewController.h"
#import "SegmentCategoryView.h"
#import "YYSegmentGroupViewController.h"
#import "YYSegmentFriendsViewController.h"
#import "YYSegmentMessageViewController.h"

@interface DWSegmentCategoryViewController ()<SegmentCategoryDataSource, SegmentCategoryDelegate>

@property (nonatomic, strong) SegmentCategoryView *categoryView;

@end

@implementation DWSegmentCategoryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.viewControllers = @[[YYSegmentMessageViewController new], [YYSegmentFriendsViewController new], [YYSegmentGroupViewController new], [YYSegmentGroupViewController new], [YYSegmentGroupViewController new], [YYSegmentGroupViewController new], [YYSegmentGroupViewController new], [YYSegmentGroupViewController new], [YYSegmentGroupViewController new], [YYSegmentGroupViewController new], [YYSegmentGroupViewController new], [YYSegmentGroupViewController new], [YYSegmentGroupViewController new], [YYSegmentGroupViewController new], [YYSegmentGroupViewController new], [YYSegmentGroupViewController new], [YYSegmentGroupViewController new], [YYSegmentGroupViewController new], [YYSegmentGroupViewController new], [YYSegmentGroupViewController new], [YYSegmentGroupViewController new]];
    
    [self.view addSubview:self.categoryView];
    [self.categoryView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.left.right.equalTo(self.view);
        make.top.equalTo(self.view).with.offset(20);
    }];
}

#pragma mark - SegmentCategoryDataSource & SegmentCategoryDelegate

- (NSUInteger)numberOfSegmentInSegmentView:(SegmentCategoryView *)segmentView
{
    return [self.viewControllers count];
}

- (NSString *)segmentView:(SegmentCategoryView *)segmentView titleAtIndex:(NSUInteger)index
{
    NSString *title = nil;
    
    if(index < [self.viewControllers count]) {
        YYSegmentBaseViewController *viewController = self.viewControllers[index];
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

- (void)segmentView:(SegmentCategoryView *)segmentView didSelectedAtIndex:(NSUInteger)index
{
//    _selectedIndex = index;
//    
//    if ([self.delegate respondsToSelector:@selector(segmentCategoryViewController:didSelectedAtIndex:)]) {
//        [self.delegate segmentCategoryViewController:self didSelectedAtIndex:index];
//    }
}


#pragma mark - getter & setter

- (SegmentCategoryView *)categoryView
{
    if (!_categoryView) {
        _categoryView = [SegmentCategoryView new];
        _categoryView.dataSource = self;
        _categoryView.delegate = self;
    }
    
    return _categoryView;
}

- (NSArray *)viewControllers
{
    return self.childViewControllers;
}

- (void)setViewControllers:(NSArray *)viewControllers
{
    for (UIViewController *viewController in self.childViewControllers) {
        [viewController removeFromParentViewController];
    }
    
    NSInteger index = 0;
    for (UIViewController *viewController in viewControllers) {
        //viewController.segmentIndex = index;
        [self addChildViewController:viewController];
        [viewController didMoveToParentViewController:self];
        index ++;
    }
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
