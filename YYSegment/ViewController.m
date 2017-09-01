//
//  ViewController.m
//  YYSegment
//
//  Created by ouzhirui on 2017/7/29.
//  Copyright © 2017年 YY. All rights reserved.
//

#import "ViewController.h"
#import "DWSegmentCategoryViewController.h"
#import <ReactiveCocoa.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    UIButton *button = [UIButton new];
    @weakify(self);
    button.rac_command = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        @strongify(self);
        [self.navigationController pushViewController:[DWSegmentCategoryViewController new] animated:YES];
        return [RACSignal empty];
    }];
    [button setTitleColor:[UIColor redColor]
                 forState:UIControlStateNormal];
    [button setTitle:@"测试"
            forState:UIControlStateNormal];
    [self.view addSubview:button];
    
    [button mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.view);
    }];
//
//    NSMutableParagraphStyle *stype = [NSMutableParagraphStyle new];
//    stype.lineSpacing = 50;
//    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:@"测试测试测试世界佛教佛奥奇偶覅骄傲积分飞的撒娇就案件佛ofo酒叟案件佛家居佛安抚就" attributes:@{
//                                                                                                                                                 //NSParagraphStyleAttributeName:stype
//                                                                                                                    }];
//    [str addAttribute:NSForegroundColorAttributeName
//                value:[UIColor redColor]
//                range:NSMakeRange(0, 5)];
//    [str addAttribute:NSParagraphStyleAttributeName
//                value:stype
//                range:NSMakeRange(0, str.length)];
//    UILabel *label = [UILabel new];
//    label.numberOfLines = 0;
//    label.attributedText = str;
//    
//    [self.view addSubview:label];
//    
//    [label mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.width.equalTo(@100);
//        make.center.equalTo(self.view);
//    }];
    
}

@end
