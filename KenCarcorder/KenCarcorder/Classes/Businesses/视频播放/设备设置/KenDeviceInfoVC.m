//
//  KenDeviceInfoVC.m
//  KenCarcorder
//
//  Created by 邱根友 on 2017/4/15.
//  Copyright © 2017年 Ken.Liu. All rights reserved.
//

#import "KenDeviceInfoVC.h"
#import "KenDeviceDM.h"

@interface KenDeviceInfoVC ()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) KenDeviceDM *deviceDM;
@property (nonatomic, strong) UITableView *infoTable;
@property (nonatomic, strong) NSArray *infoArray;
@property (nonatomic, strong) NSArray *contentArray;

@end

@implementation KenDeviceInfoVC

#pragma mark - life cycle
- (instancetype)initWithDevice:(KenDeviceDM *)device {
    self = [super init];
    if (self) {
        _deviceDM = device;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setNavTitle:@"设备信息"];

    [self.contentView addSubview:self.infoTable];
    
    _infoArray = @[@"设备名称：", @"型号：", @"序列号：", @"版本：", @"SD/TF总容量(MB)：", @"SD/TF剩余容量(MB)：", @"使用无线连接：", @"uPnP状态：", @"外网状态：", @"P2P状态：", @"UID号："];
}

#pragma mark - Table delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_infoArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *bankCellIdentifier = @"videoCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:bankCellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:bankCellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    NSString *content = [_infoArray objectAtIndex:indexPath.row];
    if (indexPath.row < [_contentArray count]) {
        content = [content stringByAppendingString:[_contentArray objectAtIndex:indexPath.row]];
    }
    [cell.textLabel setText:content];
    
    return cell;
}

#pragma mark - public method
- (void)setDeviceInfo:(NSString *)info {
    if ([NSString isEmpty:info]) {
        [self getCurrentDeviceInfo];
    } else {
        [Async mainAfter:0.5 block:^{
            [self loadData:info];
        }];
    }
}

#pragma mark - private method
- (void)getCurrentDeviceInfo {
    @weakify(self)
    [[KenServiceManager sharedServiceManager] deviceLoadInfo:self.deviceDM start:^{
        @strongify(self)
        [self showActivity];
    } success:^(BOOL successful, NSString * _Nullable errMsg, id _Nullable info) {
        @strongify(self)
        [self hideActivity];
        
        if (successful) {
            [self loadData:info];
        }
    } failed:^(NSInteger status, NSString * _Nullable errMsg) {
        @strongify(self)
        [self hideActivity];
    }];
}

- (void)loadData:(NSString *)data {
    NSArray *array = [data componentsSeparatedByString:@"\r\n"];
    
    NSString *DevName =@"";
    NSString *DevModal =@"";
    NSString *SN=@"";
    NSString *SoftVersion =@"";
    NSString *DiskSize =@"";
    NSString *FreeSize=@"";
    NSString *ethLinkStatus=@"" ;
    NSString *upnpStatus=@"" ;
    NSString *WlanStatus=@"" ;
    NSString *p2pStatus =@"";
    NSString *DDNSDomain =@"";
    
    for (int i=0; i<[array count]; i++) {
        NSString * tmp = [array objectAtIndex:i];
        
        if ([tmp rangeOfString:@"INFO_DevName"].length > 0) {
            DevName = [[[array objectAtIndex:i] componentsSeparatedByString:@"="] objectAtIndex:1];
        }
        if ([tmp rangeOfString:@"INFO_DevModal"].length > 0) {
            DevModal = [[[array objectAtIndex:i] componentsSeparatedByString:@"="] objectAtIndex:1];
        }
        if ([tmp rangeOfString:@"INFO_SN"].length > 0) {
            SN = [[[array objectAtIndex:i] componentsSeparatedByString:@"="] objectAtIndex:1];
        }
        if ([tmp rangeOfString:@"INFO_SoftVersion"].length > 0) {
            SoftVersion = [[[array objectAtIndex:i] componentsSeparatedByString:@"="] objectAtIndex:1];
        }
        if ([tmp rangeOfString:@"DISK_DiskSize"].length > 0) {
            DiskSize = [[[array objectAtIndex:i] componentsSeparatedByString:@"="] objectAtIndex:1];
        }
        if ([tmp rangeOfString:@"DISK_FreeSize"].length > 0) {
            FreeSize = [[[array objectAtIndex:i] componentsSeparatedByString:@"="] objectAtIndex:1];
        }
        if ([tmp rangeOfString:@"INFO_ethLinkStatus"].length > 0) {
            ethLinkStatus = [[[array objectAtIndex:i] componentsSeparatedByString:@"="] objectAtIndex:1];
        }
        if ([tmp rangeOfString:@"INFO_upnpStatus"].length > 0) {
            upnpStatus = [[[array objectAtIndex:i] componentsSeparatedByString:@"="] objectAtIndex:1];
        }
        if ([tmp rangeOfString:@"INFO_WlanStatus"].length > 0) {
            WlanStatus = [[[array objectAtIndex:i] componentsSeparatedByString:@"="] objectAtIndex:1];
        }
        if ([tmp rangeOfString:@"INFO_p2pStatus"].length > 0) {
            p2pStatus = [[[array objectAtIndex:i] componentsSeparatedByString:@"="] objectAtIndex:1];
        }
        if ([tmp rangeOfString:@"NET_DDNSDomain"].length > 0) {
            DDNSDomain = [[[array objectAtIndex:i] componentsSeparatedByString:@"="] objectAtIndex:1];
        }
    }
    
    DevName = [DevName stringByReplacingOccurrencesOfString:@";" withString:@""];
    DevName = [DevName stringByReplacingOccurrencesOfString:@"\"" withString:@""];
    
    DevModal = [DevModal stringByReplacingOccurrencesOfString:@";" withString:@""];
    DevModal =[DevModal stringByReplacingOccurrencesOfString:@"\"" withString:@""];
    
    SN = [SN stringByReplacingOccurrencesOfString:@";" withString:@""];
    SN = [SN stringByReplacingOccurrencesOfString:@"\"" withString:@""];
    
    SoftVersion = [SoftVersion stringByReplacingOccurrencesOfString:@";" withString:@""];
    SoftVersion = [SoftVersion stringByReplacingOccurrencesOfString:@"\"" withString:@""];
    
    DiskSize = [DiskSize stringByReplacingOccurrencesOfString:@";" withString:@""];
    DiskSize = [DiskSize stringByReplacingOccurrencesOfString:@"\"" withString:@""];
    
    FreeSize = [FreeSize stringByReplacingOccurrencesOfString:@";" withString:@""];
    FreeSize = [FreeSize stringByReplacingOccurrencesOfString:@"\"" withString:@""];
    
    ethLinkStatus = [ethLinkStatus stringByReplacingOccurrencesOfString:@";" withString:@""];
    ethLinkStatus = [ethLinkStatus stringByReplacingOccurrencesOfString:@"\"" withString:@""];
    
    if([ethLinkStatus isEqualToString:@"0"]) {
        ethLinkStatus = @"开";
    } else {
        ethLinkStatus = @"关";
    }
    
    upnpStatus = [upnpStatus stringByReplacingOccurrencesOfString:@";" withString:@""];
    upnpStatus = [upnpStatus stringByReplacingOccurrencesOfString:@"\"" withString:@""];
    
    if([upnpStatus isEqualToString:@"1"]) {
        upnpStatus = @"开";
    } else {
        upnpStatus = @"关";
    }
    
    WlanStatus = [WlanStatus stringByReplacingOccurrencesOfString:@";" withString:@""];
    WlanStatus = [WlanStatus stringByReplacingOccurrencesOfString:@"\"" withString:@""];
    
    if([WlanStatus isEqualToString:@"1"]) {
        WlanStatus = @"开";
    } else {
        WlanStatus = @"关";
    }
    
    p2pStatus = [p2pStatus stringByReplacingOccurrencesOfString:@";" withString:@""];
    p2pStatus = [p2pStatus stringByReplacingOccurrencesOfString:@"\"" withString:@""];
    if([p2pStatus isEqualToString:@"1"]) {
        p2pStatus = @"开";
    } else {
        p2pStatus = @"关";
    }
    DDNSDomain = [DDNSDomain stringByReplacingOccurrencesOfString:@";" withString:@""];
    DDNSDomain = [DDNSDomain stringByReplacingOccurrencesOfString:@"\"" withString:@""];
    
    //这里把DDNS改为显示UID号
    DDNSDomain = _deviceDM.uid;
    
    _contentArray = @[DevName,DevModal,SN,SoftVersion,DiskSize,FreeSize,ethLinkStatus,upnpStatus,WlanStatus,p2pStatus,DDNSDomain];
    [_infoTable reloadData];
    
    [self hideActivity];
}

#pragma mark - getter setter
- (UITableView *)infoTable {
    if (_infoTable == nil) {
        _infoTable = [[UITableView alloc] initWithFrame:(CGRect){0, 0, self.contentView.size} style:UITableViewStylePlain];
        _infoTable.delegate = self;
        _infoTable.dataSource = self;
        [_infoTable setBackgroundColor:[UIColor appBackgroundColor]];
        _infoTable.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    }
    return _infoTable;
}

@end
