//
//  ViewController.m
//  ZHCircularListView
//
//  Created by jin on 16/9/24.
//  Copyright © 2016年 jzh. All rights reserved.
//

#import "ViewController.h"
#import "ZHSliderCircleViewController.h"
#define MY_WIDTH [UIScreen mainScreen].bounds.size.width
#define MY_HEIGHT [UIScreen mainScreen].bounds.size.height

@interface ViewController ()<UITableViewDelegate,UITableViewDataSource>
@property(nonatomic,strong)UITableView * tv;
@property(nonatomic,strong)NSArray * dataArr;
@property(nonatomic,strong)NSArray * subViewsArr;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}
-(void)viewWillAppear:(BOOL)animated{
    self.tv.delegate = self;
    self.tv.dataSource = self;
}
-(void)viewWillDisappear:(BOOL)animated{
    self.tv.delegate = nil;
    self.tv.dataSource = nil;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma  mark - delegate
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataArr.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    cell.textLabel.text = self.dataArr[indexPath.row];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    UIViewController * controll = [[[self.subViewsArr[indexPath.row] class] alloc] init];
    [self.navigationController pushViewController:controll  animated:YES];
}



#pragma  mark - setter & getter
-(UITableView *)tv{
    if (!_tv) {
        UITableView * tv = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, MY_WIDTH, MY_HEIGHT)];
        _tv = tv;
        [self.view addSubview:_tv];
        
    }
    return _tv;
}
-(NSArray *)dataArr{
    if (!_dataArr) {
        _dataArr = @[
                     @"顺时针滑动，缩放"
                     ];
    }
    return _dataArr;
}
-(NSArray *)subViewsArr{
    if (!_subViewsArr) {
        _subViewsArr = @[
                         [ZHSliderCircleViewController class]
                         ];
    }
    return _subViewsArr;
}
@end
