//
//  ZLStarRatingControl.m
//  ZLStarRating
//
//  Created by ZL on 2017/5/24.
//  Copyright © 2017年 ZL. All rights reserved.
//

#import "ZLStarRatingControl.h"
#import "ZLStarButton.h"

@interface ZLStarRatingControl ()

@property (nonatomic, strong) ZLStarButton *currentStar;

@property (nonatomic, assign) NSInteger numberOfStars;

// 普通状态星星
@property (nonatomic, strong) UIImage *darkStarImg;

// 高亮色状态星星
@property (nonatomic, strong) UIImage *brightStarImg;

// 星星尺寸
@property (nonatomic, assign) CGSize starSize;

@end

@implementation ZLStarRatingControl

// 初始化一个星星评价组件
- (instancetype)initWithFrame:(CGRect)frame
                        stars:(NSInteger)number
                     starSize:(CGSize)size
              darkStarImg:(UIImage *)darkImg
         brightStarImg:(UIImage *)brightImg{
    
    if (self = [super initWithFrame:frame]) {
        _numberOfStars = number;
        _darkStarImg = darkImg;
        _brightStarImg = brightImg;
        _starSize = size;
        _allowFraction = NO;
        self.clipsToBounds = YES;
        self.backgroundColor = [UIColor clearColor];
        [self setupView];
    }
    return self;
}

// 初始化一个星星评价组件,默认5颗星，默认星星的长宽为frame的高度
- (instancetype)initWithFrame:(CGRect)frame
              darkStarImg:(UIImage *)darkImg
         brightStarImg:(UIImage *)brightImg{
    
    return [self initWithFrame:frame stars:5 starSize:CGSizeMake(frame.size.height, frame.size.height) darkStarImg:darkImg brightStarImg:brightImg];
}


// 初始化一个星星评价组件，默认星星的长宽为frame的高度
- (instancetype)initWithFrame:(CGRect)frame
                        stars:(NSInteger)number
              darkStarImg:(UIImage *)darkImg
         brightStarImg:(UIImage *)brightImg{
    
    return [self initWithFrame:frame stars:number starSize:CGSizeMake(frame.size.height, frame.size.height) darkStarImg:darkImg brightStarImg:brightImg];
}

- (void)setupView {
    for (NSInteger index = 0; index < self.numberOfStars; index++) {
        ZLStarButton *starButton = [ZLStarButton.alloc initWithSize:self.starSize];
        starButton.tag = index;
        starButton.darkImg = self.darkStarImg;
        starButton.brightImg = self.brightStarImg;
        starButton.userInteractionEnabled = NO;
        [self addSubview:starButton];
    }
}


- (void)layoutSubviews {
    [super layoutSubviews];
    
    for (NSInteger index = 0; index < self.numberOfStars; index ++) {
        ZLStarButton *starButton =  [self starForTag:index];
        CGFloat starY = (self.frame.size.height - self.starSize.height) / 2;
        CGFloat margin = 0;
        if (self.numberOfStars > 1) {
            margin = (self.frame.size.width - self.starSize.width * self.numberOfStars) / (self.numberOfStars - 1);
        }
        starButton.frame = CGRectMake((self.starSize.width + margin) * index, starY, self.starSize.width, self.starSize.height);
    }
}



- (ZLStarButton *)starForPoint:(CGPoint)point {
    
    for (NSInteger i = 0; i < self.numberOfStars; i++) {
        ZLStarButton *starButton = [self starForTag:i];
        if (CGRectContainsPoint(starButton.frame, point)) {
            return starButton;
        }
    }
    return nil;
}

- (ZLStarButton *)starForTag:(NSInteger)tag {
    
    __block UIView *target;
    [self.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.tag == tag) {
            target = obj;
            *stop = YES;
        }
    }];
    return (ZLStarButton *)target;
}

// 一个是从第一个到某个星星开始从左到右依次点亮，一个是从最后一个星星到某个星星从右到左依次熄灭
- (void)starsDownToIndex:(NSInteger)index {
    for (NSInteger i = self.numberOfStars; i > index; --i) {
        ZLStarButton *starButton = [self starForTag:i];
        starButton.selected = NO;
        starButton.highlighted = NO;
    }
}

- (void)starsUpToIndex:(NSInteger)index {
    for (NSInteger i = 0; i <= index; i++) {
        ZLStarButton *starButton = [self starForTag:i];
        starButton.selected = YES;
        starButton.highlighted = NO;
    }
}


#pragma mark - Touch Handling UIControl的方法

// 开始点击的时候的事件处理
- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    CGPoint point = [touch locationInView:self];
    ZLStarButton *pressedStar = [self starForPoint:point];
    if (pressedStar) {
        self.currentStar = pressedStar;
        NSInteger index = pressedStar.tag;
        CGFloat fractionPart = 1;
        if (self.isAllowFraction) { // 允许小数半颗星
            fractionPart = [pressedStar fractionPartOfPoint:point];
        }
        self.score = index + fractionPart;
    }
    return YES;
}

// 手指未抬起在屏幕上继续移动的事件处理
- (BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    
    CGPoint point = [touch locationInView:self];
    
    ZLStarButton *pressedStar = [self starForPoint:point];
    
    if (pressedStar) {
        self.currentStar = pressedStar;
        NSInteger index = pressedStar.tag;
        CGFloat fractionPart = 1;
        if (self.isAllowFraction) { // 允许小数半颗星
            fractionPart = [pressedStar fractionPartOfPoint:point];
        }
        self.score = index + fractionPart;
    } else {
        
        if (point.x < self.currentStar.frame.origin.x) {
            self.score = self.currentStar.tag;
        } else if (point.x > (self.currentStar.frame.origin.x + self.currentStar.frame.size.width)){
            self.score = self.currentStar.tag + 1;
        }
    }
    return YES;
}

// 离开屏幕
- (void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    [super endTrackingWithTouch:touch withEvent:event];
    if ([self.delegate respondsToSelector:@selector(starsControl:didChangeScore:)]) {
        [self.delegate starsControl:self didChangeScore:self.score];
    }
}

// 因为别的特殊情况事件被结束取消的处理
- (void)cancelTrackingWithEvent:(UIEvent *)event {
    [super cancelTrackingWithEvent:event];
    if ([self.delegate respondsToSelector:@selector(starsControl:didChangeScore:)]) {
        [self.delegate starsControl:self didChangeScore:self.score];
    }
}

#pragma mark - getter&setter

- (void)setScore:(CGFloat)score{
    if (_score == score) {
        return;
    }
    _score = score;
    NSInteger index = floor(score); // floor函数是取最大整数，相当于直接去除小数点后面的数字。
    CGFloat fractionPart = score - index;
    
    if (!self.isAllowFraction || fractionPart == 0) { // 不允许小数半颗星(取整颗星)
        index -= 1;
    }
    
    ZLStarButton *starButton = [self starForTag:index];
    if (starButton.selected) { // 选中
        [self starsDownToIndex:index];
    } else {
        [self starsUpToIndex:index];
    }
    starButton.fractionPart = fractionPart;
}

@end
