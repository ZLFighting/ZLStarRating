//
//  ZLStarRatingControl.h
//  ZLStarRating
//
//  Created by ZL on 2017/5/24.
//  Copyright © 2017年 ZL. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ZLStarRatingControl;

@protocol ZLStarRatingControlDelegate <NSObject>
@optional

/**
 * 回调改变星星评价后的分数
 @param starsControl 星星组件
 @param score 分数
 */
- (void)starsControl:(ZLStarRatingControl *)starsControl didChangeScore:(CGFloat)score;

@end


@interface ZLStarRatingControl : UIControl

/**
 * 初始化一个星星评价组件,默认5颗星，默认星星的长宽为frame的高度
 @param frame frame
 @param darkImg 暗色状态星星
 @param brightImg 高亮色状态星星
 @return 星星组件
 */
- (instancetype)initWithFrame:(CGRect)frame
              darkStarImg:(UIImage *)darkImg
         brightStarImg:(UIImage *)brightImg;


/**
 * 初始化一个星星评价组件，默认星星的长宽为frame的高度
 @param frame frame
 @param number 暗色数量
 @param darkImg 普通状态星星
 @param brightImg 高亮色状态星星
 @return 星星组件
 */
- (instancetype)initWithFrame:(CGRect)frame
                        stars:(NSInteger)number
              darkStarImg:(UIImage *)darkImg
         brightStarImg:(UIImage *)brightImg;


/**
 * 初始化一个星星评价组件
 
 @param frame frame
 @param number 星星数目
 @param size 星星大小
 @param darkImg 普通状态星星
 @param brightImg 高亮色状态星星
 @return 星星组件
 */
- (instancetype)initWithFrame:(CGRect)frame
                        stars:(NSInteger)number
                     starSize:(CGSize)size
              darkStarImg:(UIImage *)darkImg
         brightStarImg:(UIImage *)brightImg;


@property (nonatomic, weak)   id<ZLStarRatingControlDelegate> delegate;

// 是否允许小数（1位小数），默认为NO
@property (nonatomic, assign, getter=isAllowFraction) BOOL allowFraction;

// 星星组件上的分数，可以直接设置
@property (nonatomic, assign) CGFloat score;

@end
