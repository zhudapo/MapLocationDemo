//
//  ViewController.m
//  MapLocationDemo
//
//  Created by Jose Zhu on 16/5/20.
//  Copyright © 2016年 Jose Zhu. All rights reserved.
//

#import "ViewController.h"
#import <CoreLocation/CoreLocation.h>

@interface ViewController ()<CLLocationManagerDelegate>
{
    BOOL _isLocationed; // 是否已经获得定位信息
}
@property (nonatomic, strong) CLLocationManager* locationManager;
@property (nonatomic, strong) UILabel *label;
@property (nonatomic, strong) UILabel *label2;
@end

@implementation ViewController



- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
    self.locationManager=[[CLLocationManager alloc]init];
    _locationManager.delegate = self;
}

- (void)setupUI
{
    self.label = [[UILabel alloc]initWithFrame:CGRectMake(50, 100, 200, 50)];
    self.label2 = [[UILabel alloc]initWithFrame:CGRectMake(50, 50, 300, 50)];
    _label.text = @"位置";
    UIButton *btn = [[UIButton alloc]initWithFrame:CGRectMake(100, 200, 100, 50)];
    btn.backgroundColor = [UIColor redColor];
    [btn setTitle:@"开启定位" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(findMe) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_label];
    [self.view addSubview:_label2];
    [self.view addSubview:btn];
}

- (void)findMe
{
    if([CLLocationManager locationServicesEnabled]){
        /** 由于IOS8中定位的授权机制改变 需要进行手动授权
         * 获取授权认证，两个方法：
         * [self.locationManager requestWhenInUseAuthorization];
         * [self.locationManager requestAlwaysAuthorization];
         */
        if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
            NSLog(@"requestWhenInUseAuthorization");
            [self.locationManager requestWhenInUseAuthorization];
        }
        
        //开始定位，不断调用其代理方法
        [self.locationManager startUpdatingLocation];
        NSLog(@"start gps");
    }
    else{
        NSLog(@"提醒用户：定位服务未开启，可在设置中进行修改。");
    }

}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations
{
    // 此判断的目的：避免多次定位的处理
    // 1.获取用户位置的对象
    CLLocation *location = [locations lastObject];
    CLLocationCoordinate2D coordinate = location.coordinate;
    NSLog(@"纬度:%f 经度:%f", coordinate.latitude, coordinate.longitude);
    NSString *str = [NSString stringWithFormat:@"纬度:%f 经度:%f", coordinate.latitude, coordinate.longitude];
    _label2.text = str;
    // 逆地理编码得到当前定位城市
    [self reGeoCodeLocation:coordinate];
    
}

-(void)reGeoCodeLocation:(CLLocationCoordinate2D)coordinate
{
    // 获取当前所在的城市名
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    //根据经纬度反向地理编译出地址信息
    CLLocation * location = [[CLLocation alloc] initWithLatitude:coordinate.latitude longitude:coordinate.longitude];
    [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *array, NSError *error)
     {
         if (array.count > 0)
         {
             CLPlacemark *placemark = [array objectAtIndex:0];
             
             //将获得的所有信息显示到label上
             //             self.location.text = placemark.name;
             
             //获取城市
             NSString *city = placemark.locality;
             if (!city) {
                 //四大直辖市的城市信息无法通过locality获得，只能通过获取省份的方法来获得（如果city为空，则可知为直辖市）
                 city = placemark.administrativeArea;
             }
             NSLog(@"city = %@", city);
             _label.text = city;
             
         }
         else if (error == nil && [array count] == 0)
         {
             NSLog(@"No results were returned.");
         }
         else if (error != nil)
         {
             NSLog(@"An error occurred = %@", error);
         }
     }];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog( @"ERRORERRORERRORERRORERRORERRORERRORERRORERRORERROR");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
