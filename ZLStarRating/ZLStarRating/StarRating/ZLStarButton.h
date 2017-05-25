//
//  ZLStarButton.h
//  ZLStarRating
//
//  Created by ZL on 2017/5/25.
//  Copyright © 2017年 ZL. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZLStarButton : UIButton

// 暗色星星图
@property (nonatomic, strong) UIImage *darkImg;

// 高亮色星星图
@property (nonatomic, strong) UIImage *brightImg;

// 小数部分点处
@property (nonatomic, assign) CGFloat fractionPart;

- (instancetype)initWithSize:(CGSize)size;

- (CGFloat)fractionPartOfPoint:(CGPoint)point;

@end
