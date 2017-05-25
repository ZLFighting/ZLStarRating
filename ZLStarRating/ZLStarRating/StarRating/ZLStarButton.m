//
//  ZLStarButton.m
//  ZLStarRating
//
//  Created by ZL on 2017/5/25.
//  Copyright © 2017年 ZL. All rights reserved.
//

#import "ZLStarButton.h"

@implementation ZLStarButton

- (instancetype)initWithSize:(CGSize)size{
    
    if (self = [super initWithFrame:CGRectMake(0, 0, size.width, size.height)]) {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}


- (CGFloat)fractionPartOfPoint:(CGPoint)point{
    
    CGFloat fractionPart =  (point.x - self.frame.origin.x) / self.frame.size.width;
    return round(fractionPart * 10) / 10;
}


#pragma mark - helper

+ (UIImage *)reSizeImage:(UIImage *)image toSize:(CGSize)reSize{
    
    UIGraphicsBeginImageContext(reSize);
    [image drawInRect:CGRectMake(0, 0, reSize.width, reSize.height)];
    UIImage *reSizeImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return reSizeImage;
}

// 按百分比裁剪图片
+ (UIImage *)cutImage:(UIImage *)image fraction:(CGFloat)fractonPart{
    
    CGFloat width = image.size.width * fractonPart * image.scale;
    CGRect newFrame = CGRectMake(0, 0, width , image.size.height * image.scale);
    CGImageRef resultImage = CGImageCreateWithImageInRect(image.CGImage, newFrame);
    UIImage *result = [UIImage imageWithCGImage:resultImage scale:image.scale orientation:image.imageOrientation];
    CGImageRelease(resultImage);
    
    return result;
}

#pragma mark - setter&getter

// 暗色置灰的状态可以设置为UIButton的正常普通状态
- (void)setDarkImg:(UIImage *)darkImg{
    
    _darkImg = [ZLStarButton reSizeImage:darkImg toSize:self.frame.size];
    [self setImage:_darkImg forState:UIControlStateNormal];
    
}

// 全高亮的状态可以设置为UIButton的点击状态
- (void)setBrightImg:(UIImage *)brightImg{
    
    _brightImg = [ZLStarButton reSizeImage:brightImg toSize:self.frame.size];
    [self setImage:_brightImg forState:UIControlStateSelected];
}

// 在BackgroundImage设置为灰色的星星图像，设置为Button的高亮状态
- (void)setFractionPart:(CGFloat)fractionPart{
    
    if (fractionPart == 0) {
        return;
    }
    
    UIImage *image = [ZLStarButton cutImage:self.brightImg fraction:fractionPart];
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    self.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    self.contentVerticalAlignment = UIControlContentVerticalAlignmentFill;
    [self setImage:image forState:UIControlStateHighlighted];
    [self setBackgroundImage:self.darkImg forState:UIControlStateHighlighted];
    self.selected = NO;
    self.highlighted = YES;
}


@end
