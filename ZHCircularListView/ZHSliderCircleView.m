//
//  ZHSliderCircleView.m
//  cycleCollection
//
//  Created by 焰炉何 on 16/9/20.
//  Copyright © 2016年 JZH. All rights reserved.
//

#import "ZHSliderCircleView.h"
//临界速度值
#define MAXSPEED 200
#define MINSPEED 0.01
#define SPEED_DOWN_SCALE 0.99 //（0～1）


#define RADIANS_TO_DEGREES(radians) ((radians) * (180.0 / M_PI))
//角度转弧度
#define DEGREES_TO_RADIANS(angle) ((angle) / 180.0 * M_PI)


@interface ZHSliderCircleView()<UIGestureRecognizerDelegate>{
    //滑动从开始到结束的时间
    NSDate *startTouchDate;
}

//@property(nonatomic,assign) NSDate *startTouchDate;
//减速计数
@property(nonatomic,assign) NSInteger decelerTime;
//转动的角度
@property(nonatomic,assign) double mStartAngle;

//第一触碰点
@property(nonatomic,assign) CGPoint beginPoint;
//第二触碰点
@property(nonatomic,assign) CGPoint movePoint;
//正在跑
@property(nonatomic,assign) BOOL isPlaying;
//显示最大的点的坐标
@property(nonatomic,assign) CGFloat biggestPointAngle;

//子试图数量
@property(nonatomic,assign) NSInteger numOfSubView;
//子视图按钮数组
@property(nonatomic,retain) NSMutableArray *btnArray;
//拖动手势
@property(nonatomic,strong) UIPanGestureRecognizer * panGR;
//检测按下到抬起手指时旋转的角度
@property(nonatomic,assign) float mTmpAngle;


@property(nonatomic,strong) CADisplayLink *flowtime;//超过最大速度后，滚动的定时器
@property(nonatomic,assign) float anglePerSecond;//每秒移动的角度
@property(nonatomic,assign) float speed;  //转动速度
@end


@implementation ZHSliderCircleView
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.mStartAngle = 0.0;
        self.isPlaying = false;
        self.btnArray = [[NSMutableArray alloc]init];
        //初始化终点为zero，后面判断，默认为中点
        self.mCenter = CGPointZero;
        self.subViewSize = CGSizeZero;
        CGFloat bpX = frame.size.width / 2.0;
        CGFloat bpY = frame.size.width / 2.0;
        self.beginPoint = CGPointMake(bpX, bpY);
        self.biggestPoint = CGPointMake(self.mCenter.x+50, self.mCenter.y);
    }
    return self;
}
#pragma mark -  加子视图,初始化其他部分
//添加图片和文字
-(void)addSubViewWithSubView:(NSArray *)imageArray andSelectedImage:(NSArray *)selectImageArray andTitle:(NSArray *)titleArray andSize:(CGSize)size andcenterImage:(UIImage *)centerImage{
    
    self.subViewSize=size;
    self.numOfSubView = titleArray.count;
//    self.numOfSubView = 4;
    if(titleArray.count == 0){
        self.numOfSubView = imageArray.count;
    }

    for (NSInteger i = 0; i < self.numOfSubView; i++) {
        UIButton * btn = [[UIButton alloc]initWithFrame:CGRectMake(20, 20, size.width, size.height)];
        if (imageArray == nil) {
            btn.backgroundColor = [UIColor colorWithRed:arc4random()%256/256.0 green:arc4random()%256/256.0 blue:arc4random()%256/256.0 alpha:1];
            btn.layer.cornerRadius = size.width / 2;
        }else{
            [btn setImage:[UIImage imageNamed:imageArray[i]] forState:UIControlStateNormal];
        }
        if (titleArray == nil) {
        }else{
            [btn setTitle:titleArray[i] forState:UIControlStateNormal];
            [btn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        }
        btn.tag = 2000 + i;
        [btn addTarget:self action:@selector(subViewOut:) forControlEvents:UIControlEventTouchUpInside];
        [self.btnArray addObject:btn];
        
        [self addSubview:btn];
    }
    //设置按钮的布局
    [self layoutBtnSet];
    [self setCenterView:centerImage];
}
//只添加图片
-(void)addSubViewWithImage:(NSArray *)imageArray andSelectedImage:(NSArray *)selectImageArray andSize:(CGSize)size andcenterImage:(UIImage *)centerImage{
    self.subViewSize=size;
    self.numOfSubView = imageArray.count;
    
    for (NSInteger i = 0; i < self.numOfSubView; i++) {
        UIButton * btn = [[UIButton alloc]initWithFrame:CGRectMake(20, 20, size.width, size.height)];
        if (imageArray == nil) {
            btn.backgroundColor = [UIColor colorWithRed:arc4random()%256/256.0 green:arc4random()%256/256.0 blue:arc4random()%256/256.0 alpha:1];
            btn.layer.cornerRadius = size.width / 2;
        }else{
            [btn setImage:[UIImage imageNamed:imageArray[i]] forState:UIControlStateNormal];
            [btn setImage:[UIImage imageNamed:selectImageArray[i]] forState:UIControlStateSelected];
        }

        btn.tag = 2000 + i;
        [btn addTarget:self action:@selector(subViewOut:) forControlEvents:UIControlEventTouchUpInside];
        [self.btnArray addObject:btn];
        
        [self addSubview:btn];
    }
    //设置按钮的布局
    [self layoutBtnSet];
    [self setCenterView:centerImage];
}
//只添加文字
-(void)addSubViewWithTitle:(NSArray *)titleArray andSize:(CGSize)size andcenterImage:(UIImage *)centerImage{
    self.subViewSize=size;
    self.numOfSubView = titleArray.count;
    

    for (NSInteger i = 0; i < self.numOfSubView; i++) {
        UIButton * btn = [[UIButton alloc]initWithFrame:CGRectMake(20, 20, size.width, size.height)];
        if (titleArray != nil) {
            [btn setTitle:titleArray[i] forState:UIControlStateNormal];
            [btn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        }else{
        }
        btn.tag = 2000 + i;
        [btn addTarget:self action:@selector(subViewOut:) forControlEvents:UIControlEventTouchUpInside];
        [self.btnArray addObject:btn];
        
        [self addSubview:btn];
    }
    //设置按钮的布局
    [self layoutBtnSet];
    [self setCenterView:centerImage];
}


//设置中间控件
-(void)setCenterView:(UIImage *)centerImage{
    //中间可能的按钮
    CGFloat btnCenterW = self.frame.size.width / 3.0;
    CGFloat btnCenterH = self.frame.size.width / 3.0;
    UIButton * buttonCenter = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, btnCenterW, btnCenterH)];
    buttonCenter.tag = 2000 + self.numOfSubView;
    if (centerImage == nil) {
        //中间没有图就画一个圆
        buttonCenter.layer.cornerRadius=self.frame.size.width/6.0;
        buttonCenter.backgroundColor=[UIColor colorWithRed:arc4random()%256/256.0 green:arc4random()%256/256.0 blue:arc4random()%256/256.0 alpha:1];
        [buttonCenter setTitleColor:[UIColor blackColor]forState:UIControlStateNormal];
        [buttonCenter setTitle:@"中间" forState:UIControlStateNormal];
    }else{
        buttonCenter.backgroundColor = [UIColor yellowColor];
        [buttonCenter setImage:centerImage forState:UIControlStateNormal];
    }
    buttonCenter.center = self.mCenter;
    //加点击效果{没看到效果呢}
    [buttonCenter addTarget:self action:@selector(centerBtnChick:) forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview:buttonCenter];
    
}

//按钮布局
-(void)layoutBtnSet{

    for (NSInteger i = 0; i < self.numOfSubView; i++) {
        CGFloat centerX = self.mCenter.x + self.mRadius * cosf(2 * i * M_PI / self.numOfSubView + self.mStartAngle);
        CGFloat centerY = self.mCenter.y + self.mRadius * sinf(2 * i * M_PI / self.numOfSubView + self.mStartAngle);
//        CGFloat centerX=self.mCenter.x +sin((i/self.numOfSubView)*M_PI*2+self.mStartAngle)*(self.frame.size.width/2-self.subViewSize.width/2-20);
//        CGFloat centerY=self.mCenter.y+cos((i/self.numOfSubView)*M_PI*2+self.mStartAngle)*(self.frame.size.width/2-self.subViewSize.width/2-20);
//        CGFloat centerX=self.mCenter.x +sin((i/self.numOfSubView)*M_PI*2+self.mStartAngle)*self.mRadius;
//        CGFloat centerY=self.mCenter.y+cos((i/self.numOfSubView)*M_PI*2+self.mStartAngle)*self.mRadius;
        UIButton *button=[self.btnArray objectAtIndex:i];
        button.center = CGPointMake(centerX, centerY);
        //缩放方法
        [self zoomSubView:button];
    }
}

#pragma mark - 转动手势
-(void)sliderCircle:(UIPanGestureRecognizer *)pgr{
    if (pgr.state == UIGestureRecognizerStateBegan) {
        self.mTmpAngle = 0;
        self.beginPoint = [pgr locationInView:self];
        startTouchDate = [NSDate date];
    }else if (pgr.state == UIGestureRecognizerStateChanged){
        float startAngleLast = self.mStartAngle;
        self.movePoint = [pgr locationInView:self];
        float start = [self getAngle:self.beginPoint];//获得起始的弧度
        float end = [self getAngle:self.movePoint];//获得结束弧度
        
        if ([self getQuadrant:self.movePoint] == 1 || [self getQuadrant:self.movePoint] == 4) {
            self.mStartAngle += end -start;
            self.mTmpAngle += end - start;
            //NSLog(@"第一、四象限____%f",mStartAngle);
        }else{// 二、三象限，角度值是付值
            self.mStartAngle += start - end;
            self.mTmpAngle += start - end;
            //            NSLog(@"第二、三象限____%f",mStartAngle);
            //             NSLog(@"mTmpAngle is %f",mTmpAngle);
        }
        //重绘button位置
        [self layoutBtnSet];
        self.beginPoint = self.movePoint;
        //速度为转动后的角度减去改变之前的角度
        self.speed = self.mStartAngle - startAngleLast;
//        NSLog(@"speed is %f",self.speed);
    }else if (pgr.state == UIGestureRecognizerStateEnded){
        NSTimeInterval time = [[NSDate date]timeIntervalSinceDate:startTouchDate];
        [self slowDownAction:time];

    }
}
-(void)buttonToDown:(UIButton *)button{
    self.beginPoint = button.center;
    self.movePoint = [self.panGR locationInView:self];
    float start = [self getAngle:self.beginPoint];//获得起始的弧度
    float end = 0;//获得结束弧度
//    self.mStartAngle += ABS(end -start) ;
//    self.mTmpAngle += ABS(end -start);
    if ([self getQuadrant:self.movePoint] == 1 || [self getQuadrant:self.movePoint] == 4) {
        self.mStartAngle += end -start;
        self.mTmpAngle += end - start;
        //NSLog(@"第一、四象限____%f",mStartAngle);
    }else{// 二、三象限，角度值是付值
        self.mStartAngle += start - end;
        self.mTmpAngle += start - end;
        //NSLog(@"第二、三象限____%f",mStartAngle);
        //NSLog(@"mTmpAngle is %f",mTmpAngle);
    }
    //重绘button位置
    [self layoutBtnSet];
    self.beginPoint = self.movePoint;
//    self slowDownAction:(NSTimeInterval)
}
//缩放方法
-(void)zoomSubView:(UIButton *)btn{
    if (!self.subviewsCanBeZoom) {
        return;
    }
    float selfP = [self get4Angle:CGPointMake(btn.center.x, btn.center.y)];
    float cha = 0.0;
    if (self.biggestPointAngle >= M_PI && selfP < M_PI ) {
        cha = ABS(ABS(self.biggestPointAngle - selfP) - M_PI);
        //            cha = ABS(ABS(self.biggestPointAngle - selfP) + M_PI);
        
    }else if (self.biggestPointAngle <= M_PI && selfP > M_PI){
        cha = ABS(ABS(self.biggestPointAngle - selfP) - M_PI);
        
    }else{
        //            cha = ABS(self.biggestPointAngle - selfP - M_PI);
        cha = M_PI - ABS(self.biggestPointAngle - selfP);
        
    }
    float scale = cha / M_PI_2  ;
    
    NSLog(@"scale = %f\nstart = %f  end = %f\ncha = %f",scale,RADIANS_TO_DEGREES(self.biggestPointAngle),RADIANS_TO_DEGREES(selfP),cha);
    
    btn.transform = CGAffineTransformMakeScale(scale, scale);

    
    
    
//    float selfP = [self get4Angle:CGPointMake(btn.center.x, btn.center.y)];
//    
//    float cha = 0.0;
//    if ((biggestP > M_PI && selfP < M_PI) || (biggestP < M_PI && selfP > M_PI)) {
//        cha = M_PI - ABS(biggestP - selfP - M_PI);
//    }else{
//        cha = ABS(biggestP - selfP - M_PI);
//    }
//    float scale = ABS(cha / M_PI)  ;
//    
//    NSLog(@"---ddddd----%f\nend = %f\ncha = %f",scale,selfP,cha);
//    btn.transform = CGAffineTransformMakeScale(scale, scale);
    
}
//计算当前弧度度（0～360）
-(float)get4Angle:(CGPoint)point{
    //减半径是为了变换坐标系，从中点为center的变成｛0，0｝的
    double x = point.x - self.mCenter.x;
    double y = point.y - self.mCenter.y;
    //hypot(x, y)  计算三角形斜边长度
    //asin(double)  求后面这个数的反正弦（就是弧度）
    CGFloat angle = (float)(asin(y / hypot(x, y)));
    angle = ABS(angle);
    int xx = [self getQuadrant:point];
    switch (xx) {
        case 1:{

            angle = M_PI * 2 - angle;
            break;
        }
        case 2:{
            angle = M_PI + angle;
            break;
        }
        case 3:{
            angle = M_PI - angle;
            break;
        }
        case 4:{
//            angle = angle;
            break;
        }
    }
//    NSLog(@"aaaa----%f\n%d",angle,xx);
    return angle;
}

-(int) get42Quadrant:(CGPoint)point {
    int tmpX = (int)(point.x - self.mCenter.x);
    int tmpY = (int)(point.y - self.mCenter.y);
    if (tmpX >= 0) {
        return tmpY >= 0? 1 : 4;
    }else{
        return tmpY >= 0? 2 : 3;
    }
}

//计算获得当前弧度（这样算出来的是0～90度）
-(float)getAngle:(CGPoint)point{
    //减半径是为了变换坐标系，从中点为center的变成｛0，0｝的
    double x = point.x - self.mCenter.x;
    double y = point.y - self.mCenter.y;
    //hypot(x, y)  计算三角形斜边长度
    //asin(double)  求后面这个数的反正弦（就是弧度）
    return (float)(asin(y / hypot(x, y)));
}

//根据当前位置计算象限
-(int) getQuadrant:(CGPoint)point {
    int tmpX = (int)(point.x - self.mCenter.x);
    int tmpY = (int)(point.y - self.mCenter.y);
    if (tmpX >= 0) {
        return tmpY >= 0? 1 : 4;
    }else{
        return tmpY >= 0? 2 : 3;
    }
}
//惯性滚动方法
-(void)slowDownAction:(NSTimeInterval)time{
    // 计算，每秒移动的角度
    
    self.anglePerSecond = self.mTmpAngle * 50 / time;
    NSLog(@"anglePerSecond is %f",self.anglePerSecond);
    //如果该值超过了最大速度值，认为是快速移动
    //abs(int) 取绝对值
    //fabsf(anglePerSecond) 取绝对值
    if (fabsf(self.anglePerSecond) > self.mFlingableValue && !self.isPlaying) {
        //post一个任务，去自动滚动
        self.isPlaying = true;

        self.flowtime = [CADisplayLink   displayLinkWithTarget : self   selector : @selector(flowAction)];
        [self.flowtime   addToRunLoop:[NSRunLoop   currentRunLoop]   forMode : NSDefaultRunLoopMode];
        }
}
//减速滚动方法
-(void)flowAction{
    if (self.speed < MINSPEED) {
        self.isPlaying = false;
        
        [self.flowtime invalidate];
        self.flowtime = nil;
        return;
    }
    //不断改变mSartAngle，让其滚动，／30是为了避免滚动太快
    self.mStartAngle += self.speed;
    //逐渐减小这个值
    self.speed = self.speed * SPEED_DOWN_SCALE;
    //重新画button
    [self layoutBtnSet];
}
//button的点击方法，用block进行回调
-(void)subViewOut:(UIButton *)button{
    NSLog(@"点击~~~");
    
//    [self buttonToDown:button];
    //点击
    if (self.clickOneOfThis) {
        self.clickOneOfThis([NSString stringWithFormat:@"%ld",button.tag]);
        self.clickOneOfThis(@"点击");
    }
}
-(void)centerBtnChick:(UIButton *)button{
    NSLog(@"点击~~~");
    //点击
    if (self.clickCenter) {
        self.clickCenter([NSString stringWithFormat:@"%ld",button.tag]);
        self.clickCenter(@"点击");
    }
}
    /*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
#pragma mark - UIGestureRecognizerDelegate手势协议
-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    if ([touch.view isKindOfClass:[UIButton class]]) {
        return NO;
    }
    return YES;
}

#pragma mark - set & get
//view是否能滚动，来添加手势
-(void)setGestureCanUse:(BOOL)gestureCanUse{
    if (gestureCanUse) {
        self.userInteractionEnabled = YES;
        //添加转动手势
        self.panGR = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(sliderCircle:)];
        self.panGR.cancelsTouchesInView = NO;
        [self addGestureRecognizer:self.panGR];
    }else{
        self.userInteractionEnabled = NO;
    }
}
//子控件大小
-(CGSize)subViewSize{
    if (CGSizeEqualToSize (_subViewSize, CGSizeZero)) {
        CGFloat sizeX = self.frame.size.width/4.0;
        CGFloat sizeY = self.frame.size.height/4.0;
        _subViewSize = CGSizeMake(sizeX, sizeY);
    }
    return _subViewSize;
}
//显示最大时的角度
-(void)setBiggestPoint:(CGPoint)biggestPoint{
    CGFloat bpX = biggestPoint.x + self.mCenter.x;
    CGFloat bpY = biggestPoint.y + self.mCenter.y;
    _biggestPoint = CGPointMake(bpX, bpY) ;
//    double x = biggestPoint.x - self.mCenter.x;
//    double y = biggestPoint.y - self.mCenter.y;
//    //hypot(x, y)  计算三角形斜边长度
//    //asin(double)  求后面这个数的反正弦（就是弧度）
//    CGFloat c = (CGFloat)(asin(y / hypot(x, y)));
//    _biggestPointAngle = c;
    self.biggestPointAngle = [self get4Angle:_biggestPoint];
}
//减速计数
-(NSInteger)decelerTime{
    if (!_decelerTime) {
        _decelerTime = 0;
    }
    return _decelerTime;
}
//半径
-(int)mRadius{
    if (!_mRadius) {
        _mRadius = self.frame.size.width > self.frame.size.height ? self.frame.size.height/2.5 : self.frame.size.width/2.5;
    }
    return _mRadius;
}
-(CGPoint)mCenter{
    //官方提供的宏 __CGPointEqualToPoint(CGPoint point1, CGPoint point2)
    if (CGPointEqualToPoint(_mCenter, CGPointZero)) {
        CGFloat centerX = self.frame.size.width/2;
        CGFloat centerY = self.frame.size.height/2;
        _mCenter = CGPointMake(centerX, centerY);
    }
    return _mCenter;
}
-(int)mFlingableValue{
    if (!_mFlingableValue) {
        _mFlingableValue = MAXSPEED;
    }
    return _mFlingableValue;
}


//-(void)dealloc
//{
////    [self.timer setFireDate:[NSDate distantFuture]];
////    [self.timer invalidate];
//}
@end
