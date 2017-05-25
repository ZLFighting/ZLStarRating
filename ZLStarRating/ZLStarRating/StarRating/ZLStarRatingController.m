//
//  ZLStarRatingController.m
//  ZLStarRating
//
//  Created by ZL on 2017/5/25.
//  Copyright © 2017年 ZL. All rights reserved.
//

#import "ZLStarRatingController.h"
#import "ZLStarRatingControl.h"

@interface ZLStarRatingController () <ZLStarRatingControlDelegate>

@property (nonatomic, strong) UILabel *soreLabel;
@property (nonatomic, strong) ZLStarRatingControl *starsControl;

@end

@implementation ZLStarRatingController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self.view addSubview:self.starsControl];
   
    // 设置soreLabel
    UILabel *soreLabel = [[UILabel alloc] init];
    soreLabel.frame = CGRectMake(115, 300, 160, 28);
    soreLabel.textColor = [UIColor redColor];
    soreLabel.font = [UIFont systemFontOfSize:20];
    soreLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:soreLabel];
    self.soreLabel = soreLabel;
    self.soreLabel.text = [NSString stringWithFormat:@"%.1f", self.starsControl.score];
}

- (void)starsControl:(ZLStarRatingControl *)starsControl didChangeScore:(CGFloat)score{
    
    self.soreLabel.text = [NSString stringWithFormat:@"%.1f", score];
}


- (ZLStarRatingControl *)starsControl{
    
    if (!_starsControl) {
        
        // 初始化一个星星评价组件
//        _starsControl = [ZLStarRatingControl.alloc initWithFrame:CGRectMake(50, 100, self.view.frame.size.width - 50 * 2, 50) stars:4 starSize:CGSizeMake(50, 50) darkStarImg:[UIImage imageNamed:@"dark"] brightStarImg:[UIImage imageNamed:@"bright"]];
        
        // 初始化一个星星评价组件，默认星星的长宽为frame的高度
//        _starsControl = [ZLStarRatingControl.alloc initWithFrame:CGRectMake(50, 100, self.view.frame.size.width - 50 * 2, 50) stars:6 darkStarImg:[UIImage imageNamed:@"dark"] brightStarImg:[UIImage imageNamed:@"bright"]];

        // 初始化一个星星评价组件,默认5颗星，默认星星的长宽为frame的高度
        _starsControl = [ZLStarRatingControl.alloc initWithFrame:CGRectMake(50, 100, self.view.frame.size.width - 50 * 2, 50) darkStarImg:[UIImage imageNamed:@"dark"] brightStarImg:[UIImage imageNamed:@"bright"]];

        _starsControl.delegate = self;
        _starsControl.allowFraction = YES;
        // 测试显示
        _starsControl.score = 3.5f;
    }
    return _starsControl;
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
