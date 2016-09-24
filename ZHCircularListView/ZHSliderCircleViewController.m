//
//  ZHSliderCircleViewController.m
//  ZHCircularListView
//
//  Created by jin on 16/9/24.
//  Copyright © 2016年 jzh. All rights reserved.
//

#import "ZHSliderCircleViewController.h"
#import "ZHSliderCircleView.h"

#define MY_WIDTH [UIScreen mainScreen].bounds.size.width
#define MY_HEIGHT [UIScreen mainScreen].bounds.size.height
@interface ZHSliderCircleViewController ()

@end

@implementation ZHSliderCircleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    [self takeCircle];
    
}
-(void)takeCircle{
    ZHSliderCircleView * zhView = [[ZHSliderCircleView alloc]initWithFrame:CGRectMake(10, 100, MY_WIDTH-20 , 300)];
    zhView.gestureCanUse = YES;
    zhView.backgroundColor = [UIColor colorWithRed:arc4random()%256/256.0 green:arc4random()%256/256.0 blue:arc4random()%256/256.0 alpha:1];
    [zhView addSubViewWithSubView:@[@"as",@"640",@"cw",@"asd",@"dog"] andSelectedImage:@[@"as",@"640",@"cw",@"asd",@"dog"] andTitle:@[@"as",@"640",@"cw",@"asd",@"dog"] andSize:CGSizeMake(40, 40) andcenterImage:[UIImage imageNamed:@"tianjia"]];
    
    zhView.biggestPoint = CGPointMake(0, 60);
    [self.view addSubview:zhView];
    zhView.clickOneOfThis = ^(NSString *str){
        NSLog(@"%@被点击了",str);
    };
    zhView.clickCenter = ^(NSString *str){
        NSLog(@"%@点了中间的！！！",str);
    };

}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
