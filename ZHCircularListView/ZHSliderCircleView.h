//
//  ZHSliderCircleView.h
//  cycleCollection
//
//  Created by 焰炉何 on 16/9/20.
//  Copyright © 2016年 JZH. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZHSliderCircleView : UIView
//子试图大小(每一个小图标的大小)
@property(nonatomic,assign) CGSize subViewSize;
//是否能手势拖动，默认不能
@property(nonatomic,assign) BOOL gestureCanUse;
//显示最大的点的坐标
@property(nonatomic,assign) CGPoint biggestPoint;
//能否被缩放   默认是不能
@property(nonatomic,assign) BOOL subviewsCanBeZoom;


//半径
@property(nonatomic,assign) int mRadius;
//中点
@property(nonatomic,assign) CGPoint mCenter;
//转动临界速度，超过此速度便是快速滑动，手指离开仍会转动
@property(nonatomic,assign) int mFlingableValue;
@property (nonatomic,copy)void(^clickOneOfThis)(NSString *);
@property (nonatomic,copy)void(^clickCenter)(NSString *);


//添加图片和文字
-(void)addSubViewWithSubView:(NSArray *)imageArray andSelectedImage:(NSArray *)selectImageArray andTitle:(NSArray *)titleArray andSize:(CGSize)size andcenterImage:(UIImage *)centerImage;
//只添加图片
-(void)addSubViewWithImage:(NSArray *)imageArray andSelectedImage:(NSArray *)selectImageArray andSize:(CGSize)size andcenterImage:(UIImage *)centerImage;
//只添加文字
-(void)addSubViewWithTitle:(NSArray *)titleArray andSize:(CGSize)size andcenterImage:(UIImage *)centerImage;
@end
