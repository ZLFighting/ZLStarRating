# ZLStarRating
星级评分控件(可支持小数)

现在很多应用都有评分功能.当然我们项目也不例外，有了订单就有订单评论，订单评论里就有星级评分控件了! 一般来说, 都是简单整星的评价, 但是也有奇葩的小数星评价.

![](https://github.com/ZLFighting/ZLStarRating/blob/master/ZLStarRating/星级评分.gif)

## 一. 简单整星评价
>**实现步骤：**
1. 创建 imageView, 用来改变星级图片.
2. 通过手势来区分点击到的位置.
3. 通过位置判断 imageView 显示的图片(一般都是5颗星评价，根据星星点亮颗数进行命名：score1~score5)

![简单整星评分](https://github.com/ZLFighting/ZLStarRating/blob/master/ZLStarRating/简单整星评分.png)
现把项目中关键代码整理如下：
```
@property (nonatomic, weak) UIImageView *starImage;
@property (nonatomic, copy) NSString *score;
```
```
// 设置starImage
UIImageView *starImage = [[UIImageView alloc] init];
starImage.userInteractionEnabled = YES;
starImage.backgroundColor = [UIColor clearColor];
starImage.frame = CGRectMake(CGRectGetMaxX(label.frame) + 15, 0, 80, 14);
starImage.image = [UIImage imageNamed:@"score0"];
[bgView addSubview:starImage];
self.starImage = starImage;
// 添加星级评价手势
UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(scoreClick:)];
[starImage addGestureRecognizer:tap];
```
```
- (void)scoreClick:(UITapGestureRecognizer *)tap {
CGPoint point = [tap locationInView:tap.view];
QTXLog(@"%@", NSStringFromCGPoint(point));

if (point.x < self.starImage.width / 5) {
self.starImage.image = [UIImage imageNamed:@"score1"]; // 展示点亮图片
self.score = @"1"; // 评论分数
} else if (point.x < self.starImage.width / 5 * 2) {
self.starImage.image = [UIImage imageNamed:@"score2"];
self.score = @"2";
} else if (point.x < self.starImage.width / 5 * 3) {
self.starImage.image = [UIImage imageNamed:@"score3"];
self.score = @"3";
} else if (point.x < self.starImage.width / 5 * 4) {
self.starImage.image = [UIImage imageNamed:@"score4"];
self.score = @"4";
} else if (point.x < self.starImage.width) {
self.starImage.image = [UIImage imageNamed:@"score5"];
self.score = @"5";
}
}
```

## 二. 非整星精评价

之前我们需求并没有那么细,就评论整颗星星评价, 但是最近有新需求半颗星星,这边就先整理下. 同时这次不仅支持非整星精评价, 也支持简单整星评价.

>**实现步骤：**
1. 初始化单个星星的实现, 按百分比裁剪图片改变星星整体图片(一张灰色暗色星星图, 一张高亮色星星图).
2. 初始化星星按钮的布局, 通过触摸事件响应区分点击到的位置, 展现整体评价效果.
3. 对score分数属性和allowFraction是否小数整颗星属性露出展现,在当前控制器里使用代理做分数改变后的操作, 初始化星星评价组件。


#### Step1. 初始化单个星星的实现

单个星星的实现, 要考虑到全灰状态，全亮状态，百分比高亮状态. 这里用UIButton来实现, 先把图片缩放到和Button大小一样, 可以根据百分比将图像进行裁剪，让新图像的宽度只有百分比所占的整个图像的宽度. 这里自定义ZLStarButton

按百分比裁剪图片
```
+ (UIImage *)cutImage:(UIImage *)image fraction:(CGFloat)fractonPart{

CGFloat width = image.size.width * fractonPart * image.scale;
CGRect newFrame = CGRectMake(0, 0, width , image.size.height * image.scale);
CGImageRef resultImage = CGImageCreateWithImageInRect(image.CGImage, newFrame);
UIImage *result = [UIImage imageWithCGImage:resultImage scale:image.scale orientation:image.imageOrientation];
CGImageRelease(resultImage);

return result;
}
```
暗色置灰的状态设置为UIButton的正常普通状态
```
- (void)setDarkImg:(UIImage *)darkImg{

_darkImg = [ZLStarButton reSizeImage:darkImg toSize:self.frame.size];
[self setImage:_darkImg forState:UIControlStateNormal];

}
```
全高亮的状态设置为UIButton的点击状态
```
- (void)setBrightImg:(UIImage *)brightImg{

_brightImg = [ZLStarButton reSizeImage:brightImg toSize:self.frame.size];
[self setImage:_brightImg forState:UIControlStateSelected];
}
```
在BackgroundImage设置为灰色的星星图像，设置为Button的高亮状态
```
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
```

如果点击到星星的一部分，把点击点转换成小数部分给上层。C语言的round函数可以四舍五入，这里的10代表保留一位小数。
```
- (CGFloat)fractionPartOfPoint:(CGPoint)point{

CGFloat fractionPart =  (point.x - self.frame.origin.x) / self.frame.size.width;
return round(fractionPart  *  10)  /  10;
}
```

#### Step2. 初始化星星按钮的布局, 通过触摸事件ZLStarRatingControl响应区分点击到的位置, 展现整体评价效果.

根据星星的数量逐个添加在视图上，用UIView的tag来标记对应的星星按钮。
```
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
```
计算每个星星的位置及计算间隔和上下边距并layout
```
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
```
根据tag和根据点击的CGPoint找到对应的星星按钮
```
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
```

处理触摸事件:
从最后一个星星到某个星星从右到左依次熄灭
```
- (void)starsDownToIndex:(NSInteger)index {
for (NSInteger i = self.numberOfStars; i > index; --i) {
ZLStarButton *starButton = [self starForTag:i];
starButton.selected = NO;
starButton.highlighted = NO;
}
}
```
从第一个到某个星星开始从左到右依次点亮
```
- (void)starsUpToIndex:(NSInteger)index {
for (NSInteger i = 0; i <= index; i++) {
ZLStarButton *starButton = [self starForTag:i];
starButton.selected = YES;
starButton.highlighted = NO;
}
}
```

ZLStarRatingControl.h 文件设置一个评分的属性score，重写其setter方法. allowFraction，用来判断组件是否需要分数表示. 判断评分的整数部分是否已经亮着，亮着那么说明从左到右最后一个亮着的右边，反之在左边，分别调用从右到左依次熄灭，或从左到右依次点亮的方法，最后再设置分数部分.
```
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
if (starButton.selected || score == 0) { // 当选中或者分数为0则依次熄灭
[self starsDownToIndex:index];
} else { // 当未选中则依次点亮
[self starsUpToIndex:index];
}
starButton.fractionPart = fractionPart;
}
```
这里面用到UIControl的四个方法:
开始点击的时候的事件处理: 点击时候只要确定点击的星星，确定其小数部分，然后调用评分属性score的setter方法就好了.
```
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
```
手指未抬起在屏幕上继续移动的事件处理: 移动处理除了和点击一样的判断逻辑，还要注意手指移开了星星之外的地方，分为所在星星的左边（当前星星熄灭），右边（当前星星完全点亮）两种状态.
```
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
```
离开屏幕处理
```
- (void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
[super endTrackingWithTouch:touch withEvent:event];
if ([self.delegate respondsToSelector:@selector(starsControl:didChangeScore:)]) {
[self.delegate starsControl:self didChangeScore:self.score];
}
}
```
因为别的特殊情况事件被结束取消的处理
```
- (void)cancelTrackingWithEvent:(UIEvent *)event {
[super cancelTrackingWithEvent:event];
if ([self.delegate respondsToSelector:@selector(starsControl:didChangeScore:)]) {
[self.delegate starsControl:self didChangeScore:self.score];
}
}
```
完成触摸操作时，设置一个代理, 可以用一个回调将当前的评分传给外界。
```
@protocol ZLStarRatingControlDelegate <NSObject>
@optional

/**
* 回调改变星星评价后的分数
@param starsControl 星星组件
@param score 分数
*/
- (void)starsControl:(ZLStarRatingControl *)starsControl didChangeScore:(CGFloat)score;

@end
```
初始化星星组件方法
```
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
```

####Step3. 在当前控制器里使用代理做分数改变后的操作, 初始化星星评价组件.
使用代理做分数改变后的操作
```
- (void)starsControl:(ZLStarRatingControl *)starsControl didChangeScore:(CGFloat)score{

self.soreLabel.text = [NSString stringWithFormat:@"%.1f", score];
}
```
初始化星星评价组件时, 如果不需要精确只是整颗星评分,则不需要设置starsControl.allowFraction = YES;
```
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
```

这时候测试效果如下:
![非整星精评价](https://github.com/ZLFighting/ZLStarRating/blob/master/ZLStarRating/非整星精评价.png)

如需看详尽版，请移步 [下载](http://www.demodashi.com/demo/10711.html)

您的支持是作为程序媛的我最大的动力, 如果觉得对你有帮助请送个Star吧,谢谢啦
