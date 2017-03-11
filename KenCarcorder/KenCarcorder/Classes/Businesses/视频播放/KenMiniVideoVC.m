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
    
    [[cell.contentView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    if (indexPath.row != 0) {
        UIView *line = [[UIView alloc] initWithFrame:(CGRect){kKenOffsetX(30), 0, self.contentView.width, 0.5}];
        line.backgroundColor = [UIColor colorWithHexString:@"#73BFE2"];
        [cell.contentView addSubview:line];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [self pushViewControllerString:[[_functionList objectAtIndex:indexPath.row] objectForKey:@"fun"] animated:YES];
}

#pragma mark - event
- (void)speakStart {

}

- (void)speakEnd {

}

- (void)scanUpdown {
    
}

- (void)scanLeftRight {
    
}

- (void)turnUpDown {
    
}

- (void)turnLeftRight {
    
}

- (void)functionUp {
    
}

- (void)functionLongUp {
    
}

- (void)functionDown {
    
}

- (void)functionLongDown {
    
}

- (void)functionLeft {
    
}

- (void)functionLongLeft {
    
}

- (void)functionRight {
    
}

- (void)functionLongRight {
    
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
- (void)initTurnFunctionV {
    UIImageView *funtionBgV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"video_fun_bg"]];
    funtionBgV.center = CGPointMake(self.functionV.width / 2, self.functionV.height / 2);
    [funtionBgV setUserInteractionEnabled:YES];
    [self.functionV addSubview:funtionBgV];
    
    CGFloat offset = kKenOffsetY(36);
    @weakify(self)
    UIButton *upBtn = [UIButton buttonWithImg:nil zoomIn:YES image:[UIImage imageNamed:@"video_fun_up"]
                                     imagesec:nil target:self action:@selector(functionUp)];
    upBtn.size = CGSizeMake(upBtn.width * 3, upBtn.height * 4);
    upBtn.center = CGPointMake(funtionBgV.width / 2, offset);
    [funtionBgV addSubview:upBtn];
    [upBtn longPressed:^(UIView * _Nonnull view) {
        @strongify(self)
        [self functionLongUp];
    }];
    
    UIButton *downBtn = [UIButton buttonWithImg:nil zoomIn:YES image:[UIImage imageNamed:@"video_fun_down"]
                                     imagesec:nil target:self action:@selector(functionDown)];
    downBtn.size = CGSizeMake(downBtn.width * 3, downBtn.height * 4);
    downBtn.center = CGPointMake(upBtn.centerX, funtionBgV.height - offset);
    [funtionBgV addSubview:downBtn];
    [downBtn longPressed:^(UIView * _Nonnull view) {
        @strongify(self)
        [self functionLongDown];
    }];
    
    UIButton *leftBtn = [UIButton buttonWithImg:nil zoomIn:YES image:[UIImage imageNamed:@"video_fun_left"]
                                     imagesec:nil target:self action:@selector(functionLeft)];
    leftBtn.size = CGSizeMake(leftBtn.width * 4, leftBtn.height * 3);
    leftBtn.center = CGPointMake(offset, funtionBgV.height / 2);
    [funtionBgV addSubview:leftBtn];
    [leftBtn longPressed:^(UIView * _Nonnull view) {
        @strongify(self)
        [self functionLongLeft];
    }];
    
    UIButton *rightBtn = [UIButton buttonWithImg:nil zoomIn:YES image:[UIImage imageNamed:@"video_fun_right"]
                                     imagesec:nil target:self action:@selector(functionRight)];
    rightBtn.size = CGSizeMake(rightBtn.width * 4, rightBtn.height * 3);
    rightBtn.center = CGPointMake(funtionBgV.width - offset, leftBtn.centerY);
    [funtionBgV addSubview:rightBtn];
    [rightBtn longPressed:^(UIView * _Nonnull view) {
        @strongify(self)
        [self functionLongRight];
    }];
}

- (void)initScanFunctionV {
    @weakify(self)
    //
    UIImage *scanUpDown = [UIImage imageNamed:@"video_scan_up_down"];
    CGFloat offsetY = (self.functionV.height - scanUpDown.size.height * 2) / 3;
    CGFloat offsetX = kKenOffsetX(30);
    //////// scan up down
    UIImageView *scanUpDownV = [[UIImageView alloc] initWithImage:scanUpDown];
    scanUpDownV.origin = CGPointMake(offsetX, offsetY);
    [self.functionV addSubview:scanUpDownV];
    
    UILabel *label = [UILabel labelWithTxt:@"上下扫描" frame:(CGRect){kKenOffsetX(80), 0, scanUpDownV.size}
                                      font:[UIFont appFontSize12] color:[UIColor colorWithHexString:@"#C8D5D9"]];
    label.textAlignment = NSTextAlignmentLeft;
    [scanUpDownV addSubview:label];
    
    [scanUpDownV clicked:^(UIView * _Nonnull view) {
        @strongify(self)
        [self scanUpdown];
    }];
    //////// scan left right
    UIImageView *scanLeftRightV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"video_scan_left_right"]];
    scanLeftRightV.origin = CGPointMake(scanUpDownV.originX, scanUpDownV.maxY + offsetY);
    [self.functionV addSubview:scanLeftRightV];
    
    UILabel *LRLabel = [UILabel labelWithTxt:@"左右扫描" frame:(CGRect){kKenOffsetX(80), 0, scanUpDownV.size}
                                        font:[UIFont appFontSize12] color:[UIColor colorWithHexString:@"#C8D5D9"]];
    LRLabel.textAlignment = NSTextAlignmentLeft;
    [scanLeftRightV addSubview:LRLabel];
    
    [scanLeftRightV clicked:^(UIView * _Nonnull view) {
        @strongify(self)
        [self scanLeftRight];
    }];
    //////// turn up down
    UIImageView *turnUpDownV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"video_turn_up_down"]];
    turnUpDownV.origin = CGPointMake(self.functionV.width - offsetX - scanUpDownV.width, scanUpDownV.originY);
    [self.functionV addSubview:turnUpDownV];
    
    UILabel *turnUDLabel = [UILabel labelWithTxt:@"上下翻转" frame:(CGRect){kKenOffsetX(80), 0, scanUpDownV.size}
                                            font:[UIFont appFontSize12] color:[UIColor colorWithHexString:@"#C8D5D9"]];
    turnUDLabel.textAlignment = NSTextAlignmentLeft;
    [turnUpDownV addSubview:turnUDLabel];
    
    [turnUpDownV clicked:^(UIView * _Nonnull view) {
        @strongify(self)
        [self turnUpDown];
    }];
    //////// turn left right
    UIImageView *turnLeftRightV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"video_turn_left_right"]];
    turnLeftRightV.origin = CGPointMake(turnUpDownV.originX, scanLeftRightV.originY);
    [self.functionV addSubview:turnLeftRightV];
    
    UILabel *turnLRLabel = [UILabel labelWithTxt:@"左右翻转" frame:(CGRect){kKenOffsetX(80), 0, scanUpDownV.size}
                                            font:[UIFont appFontSize12] color:[UIColor colorWithHexString:@"#C8D5D9"]];
    turnLRLabel.textAlignment = NSTextAlignmentLeft;
    [turnLeftRightV addSubview:turnLRLabel];
    
    [turnLeftRightV clicked:^(UIView * _Nonnull view) {
        @strongify(self)
        [self turnLeftRight];
    }];
}

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
        UIImage *funBg = [UIImage imageNamed:@"video_fun_bg"];
        _functionV = [[UIView alloc] initWithFrame:(CGRect){0, 0, self.contentView.width, funBg.size.height + kKenOffsetY(60)}];
        _functionV.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.1];
        
        [self initTurnFunctionV];
        [self initScanFunctionV];
    }
    return _functionV;
}

- (UIView *)speakV {
    if (_speakV == nil) {
        UIImage *bg = [UIImage imageNamed:@"video_speak_bg"];
        _speakV = [[UIView alloc] initWithFrame:(CGRect){0, 0, self.contentView.width, bg.size.height + kKenOffsetY(120)}];
        _speakV.backgroundColor = [UIColor clearColor];
        
        UIButton *speakBtn = [UIButton buttonWithImg:nil zoomIn:YES image:[UIImage imageNamed:@"video_speak_bg"]
                                            imagesec:nil target:self action:@selector(speakStart)];
        [speakBtn addTarget:self action:@selector(speakEnd) forControlEvents:UIControlEventTouchDown];
        speakBtn.center = CGPointMake(_speakV.centerX, _speakV.height / 2);
        [_speakV addSubview:speakBtn];
        
        UIImageView *speak = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"video_speak"]];
        speak.center = CGPointMake(speakBtn.width / 2, speakBtn.height / 2);
        [speakBtn addSubview:speak];
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
        _functionTableV.separatorStyle = UITableViewCellSeparatorStyleNone;
        _functionTableV.tableFooterView = self.speakV;
        
        UIView *footV = [[UIView alloc] initWithFrame:(CGRect){0, 0, self.functionV.width, self.functionV.height + kKenOffsetY(26)}];
        footV.backgroundColor = [UIColor clearColor];
        [footV addSubview:_functionV];
        _functionTableV.tableHeaderView = footV;
    }
    return _functionTableV;
}
@end
