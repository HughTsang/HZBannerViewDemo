//
//  ViewController.m
//  HZBannerViewDemo
//
//  Created by Null on 2017/4/18.
//  Copyright © 2017年 Null. All rights reserved.
//

#import "ViewController.h"
#import "HZBannerView.h"

@interface ViewController () <HZBannerViewDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"DataPropertyList" ofType:@"plist"];
    NSArray *arr = [NSArray arrayWithContentsOfFile:filePath];
    NSMutableArray *models = @[].mutableCopy;
    for (NSDictionary *dic in arr) {
        HZBannerModel *model = [HZBannerModel new];
        [model setValuesForKeysWithDictionary:dic];
        [models addObject:model];
    }
    
    HZBannerView *banner = ({
        
        CGFloat width = self.view.bounds.size.width;
        HZBannerView *banner = [[HZBannerView alloc] initWithFrame:CGRectMake(0, 64, width, width)];
        banner.models = models;
        banner.delegate = self;
        banner;
    });
    [self.view addSubview:banner];
    
}

#pragma mark ----HZBannerViewDelegate----
- (void)HZBannerView:(HZBannerView *)bannerView didSelectedAt:(NSInteger)index{
    
    NSLog(@"你选择了\"%@\"", bannerView.models[index].title);
}

@end
