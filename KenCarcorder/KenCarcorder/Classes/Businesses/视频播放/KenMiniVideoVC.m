//
//  KenMiniVideoVC.m
//  KenCarcorder
//
//  Created by hzyouda on 2017/3/11.
//  Copyright © 2017年 Ken.Liu. All rights reserved.
//

#import "KenMiniVideoVC.h"
#import "KenDeviceDM.h"
#import "KenVideoV.h"

@interface KenMiniVideoVC ()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) KenVideoV *videoV;
@property (nonatomic, strong) UITableView *functionTableV;
@property (nonatomic, strong) NSArray *functionList;
@property (nonatomic, strong) UIView *functionV;
@property (nonatomic, strong) UIView *speakV;

@end

@implementation KenMiniVideoVC
#pragma mark - life cycle
- (instancetype)init {
    self = [super init];
    if (self) {
        self.screenType = kKenViewScreenFull;
    
        _functionList = @[@{@"title":@"回看", @"img":@"video_history", @"fun":@"KenHistoryVC"},
                          @{@"title":@"设置", @"img":@"video_setting", @"fun":@"KenDeviceSettingVC"}];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UIImageView *bgV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"video_mini_bg"]];
    bgV.size = self.contentView.size;
    [self.contentView addSubview:bgV];
    
    [self.contentView addSubview:self.videoV];
    [self.contentView addSubview:self.functionTableV];
}

#pragma mark - Table delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _functionList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *bankCellIdentifier = @"videoCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:bankCellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:bankCellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.1];
        cell.textLabel.textColor = [UIColor appWhiteTextColor];
    }
    
    NSDictionary *function = [_functionList objectAtIndex:indexPath.row];
    [cell.imageView setImage:[UIImage imageNamed:[function objectForKey:@"img"]]];
    [cell.textLabel setText:[function objectForKey:@"title"]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [self pushViewControllerString:[[_functionList objectAtIndex:indexPath.row] objectForKey:@"fun"] animated:YES];
}

#pragma mark - public method
- (void)setDirectConnect {
    NSString *ssid = [KenCarcorder getCurrentSSID];
    
    KenDeviceDM *device = [KenDeviceDM initWithJsonDictionary:@{}];
    device.netStat = kKenNetworkDdns;
    device.ddns = @"192.168.1.168";
    device.name = ssid;
    
    NSInteger value = [[ssid substringFromIndex:[ssid length] - 3] integerValue];
    device.dataport = 7000 + value;
    device.httpport = 8000 + value;
    
    self.device = device;
}

#pragma mark - private method

#pragma mark - getter setter 
- (void)setDevice:(KenDeviceDM *)device {
    _device = device;
    
    [self setNavTitle:_device.name];
}

- (KenVideoV *)videoV {
    if (_videoV == nil) {
        _videoV = [[KenVideoV alloc] initWithFrame:(CGRect){0,64,self.contentView.width,ceilf(self.contentView.width * kAppImageHeiWid)}];
    }
    return _videoV;
}

- (UIView *)functionV {
    if (_functionV == nil) {
        
    }
    return _functionV;
}

- (UIView *)speakV {
    if (_speakV == nil) {
        
    }
    return _speakV;
}

- (UITableView *)functionTableV {
    if (_functionTableV == nil) {
        _functionTableV = [[UITableView alloc] initWithFrame:(CGRect){0, self.videoV.maxY, self.contentView.width,
                                                                    self.contentView.height - self.videoV.maxY}
                                                       style:UITableViewStyleGrouped];
        _functionTableV.delegate = self;
        _functionTableV.dataSource = self;
        _functionTableV.backgroundColor = [UIColor clearColor];
        _functionTableV.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        _functionTableV.tableHeaderView = self.functionV;
        _functionTableV.tableFooterView = self.speakV;
    }
    return _functionTableV;
}
@end
