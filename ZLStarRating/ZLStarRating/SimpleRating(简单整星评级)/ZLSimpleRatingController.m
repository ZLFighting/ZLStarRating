//
//  ZLSimpleRatingController.m
//  ZLStarRating
//
//  Created by ZL on 2017/5/25.
//  Copyright © 2017年 ZL. All rights reserved.
//

#import "ZLSimpleRatingController.h"

@interface ZLSimpleRatingController ()

@property (nonatomic, weak) UIImageView *starImage;
@property (nonatomic, copy) NSString *score;

@end

@implementation ZLSimpleRatingController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];

    // 简单评级视图
    [self setupSimpleRatingView];
}

/**
 * 简单评级视图
 */
- (void)setupSimpleRatingView {
    
    // 设置starImage
    UIImageView *starImage = [[UIImageView alloc] init];
    starImage.userInteractionEnabled = YES;
    starImage.backgroundColor = [UIColor clearColor];
    starImage.frame = CGRectMake(115, 100, 160, 28);
    // 测试 添加默认图片
    starImage.image = [UIImage imageNamed:@"score0"];
    [self.view addSubview:starImage];
    self.starImage = starImage;
    
    // 添加星级评价手势
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(scoreClick:)];
    [starImage addGestureRecognizer:tap];
    
}

- (void)scoreClick:(UITapGestureRecognizer *)tap {
    CGPoint point = [tap locationInView:tap.view];
    NSLog(@"%@", NSStringFromCGPoint(point));
    
    CGFloat starImageWidth = self.starImage.frame.size.width;
    
    if (point.x < starImageWidth / 5) {
        self.starImage.image = [UIImage imageNamed:@"score1"]; // 展示点亮图片
        self.score = @"1"; // 评论分数
    } else if (point.x < starImageWidth / 5 * 2) {
        self.starImage.image = [UIImage imageNamed:@"score2"];
        self.score = @"2";
    } else if (point.x < starImageWidth / 5 * 3) {
        self.starImage.image = [UIImage imageNamed:@"score3"];
        self.score = @"3";
    } else if (point.x < starImageWidth / 5 * 4) {
        self.starImage.image = [UIImage imageNamed:@"score4"];
        self.score = @"4";
    } else if (point.x < starImageWidth) {
        self.starImage.image = [UIImage imageNamed:@"score5"];
        self.score = @"5";
    }
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
