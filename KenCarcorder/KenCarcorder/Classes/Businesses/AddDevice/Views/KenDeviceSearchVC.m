//
//  KenDeviceSearchVC.m
//  KenCarcorder
//
//  Created by 邱根友 on 2017/5/13.
//  Copyright © 2017年 Ken.Liu. All rights reserved.
//

#import "KenDeviceSearchVC.h"
#import <SystemConfiguration/CaptiveNetwork.h>

#import "thSDKlib.h"
#import "iconv.h"
#import "KenDeviceDM.h"

#define kNotificationDevice         @"notification_device"

@interface KenDeviceSearchVC ()

@property (nonatomic, strong) UITableView *deviceTable;
@property (nonatomic, strong) NSMutableArray *searchDeviceArray;

@property (assign) BOOL searching;

@end

@implementation KenDeviceSearchVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setNavTitle:@"搜索"];
    
    [self.contentView addSubview:self.deviceTable];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self searchDevice];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(searchBackDevice:) name:kNotificationDevice object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)searchBackDevice:(id)sender {
    if (!_searchDeviceArray) {
        _searchDeviceArray = [[NSMutableArray alloc] init];
    }
    
    KenDeviceDM *device = [sender object];
    for (KenDeviceDM *info in _searchDeviceArray) {
        if ([[info sn] isEqualToString:[device sn]]) {
            return;
        }
    }
    for (KenDeviceDM *info in [[KenUserInfoDM sharedInstance] deviceArray]) {
        if ([[info sn] isEqualToString:[device sn]]) {
            return;
        }
    }
    
    [_searchDeviceArray addObject:device];
    [[self deviceTable] reloadData];
    
    [self hideActivity];
    
    [self searchDevice];
}

- (void)searchDevice {
    if (_searching) {
        DebugLog("is searching");
        return;
    }
    
    [self showActivity];
    
    [NSThread detachNewThreadSelector:@selector(searchThread) toTarget:self withObject:nil];
}

#pragma mark - Table
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_searchDeviceArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *bankCellIdentifier = @"deviceCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:bankCellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:bankCellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [cell.contentView setBackgroundColor:[UIColor whiteColor]];
    }
    
    if (indexPath.row < [_searchDeviceArray count]) {
        KenDeviceDM *device = [_searchDeviceArray objectAtIndex:indexPath.row];
        [[cell textLabel] setText:[NSString stringWithFormat:@"%@（%@）", device.name, [device sn]]];
    }
    
    [cell.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    UIView *line = [[UIView alloc] initWithFrame:(CGRect){0, cell.height - 0.5, cell.contentView.width, 0.5}];
    [line setBackgroundColor:[UIColor appSepLineColor]];
    [cell.contentView addSubview:line];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.deviceSelcetBlock) {
        self.deviceSelcetBlock([_searchDeviceArray objectAtIndex:indexPath.row]);
    }
    [self popViewController];
}

#pragma mark - getter setter
- (UITableView *)deviceTable {
    if (_deviceTable == nil) {
        _deviceTable = [[UITableView alloc] initWithFrame:(CGRect){0, 0, self.contentView.size} style:UITableViewStylePlain];
        _deviceTable.delegate = self;
        _deviceTable.dataSource = self;
        _deviceTable.backgroundColor = [UIColor appBackgroundColor];
        _deviceTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    return _deviceTable;
}

#pragma mark - other
- (void)searchThread {
    _searching = true;
    
    time_t dt;
    thSearch_Init(SearchDevCallBack);
    
    thSearch_SearchDevice(NULL);
    dt = time(NULL);
    while(1) {
        usleep(1000*100);
        if (time(NULL) - dt >= 3) break;
    }
    thSearch_Free();
    
    _searching = false;
}

int code_convert(char *from_charset, char *to_charset, char *inbuf, size_t inlen, char *outbuf, size_t outlen) {
    iconv_t cd = NULL;
    cd = iconv_open(to_charset, from_charset);
    if(!cd)
        return -1;
    memset(outbuf, 0, outlen);
    if(iconv(cd, &inbuf, &inlen, &outbuf, &outlen) == -1) {
        return -1;
    }
    iconv_close(cd);
    return 0;
}

void SearchDevCallBack(int SN,int DevType, int VideoChlCount, int DataPort, int HttpPort, char* DevName,char* DevIP, char* DevMAC, char* SubMask, char* Gateway, char* DNS1,char* DDNSHost,char* UID )
{
    KenDeviceDM *device = [KenDeviceDM initWithJsonDictionary:@{}];
    [device setLanIp:[NSString stringWithUTF8String:DevIP]];
    [device setSn:[NSString stringWithFormat:@"%0.8x", SN]];
    [device setDataport:DataPort];
    [device setHttpport:HttpPort];
    
    NSString *string = nil;
    unsigned long ansiLen = strlen(DevName);
    
    unsigned long utf8Len = ansiLen * 2;
    char *utf8String = (char*)malloc(utf8Len);
    memset(utf8String, 0, utf8Len);
    int result = code_convert("gb2312", "utf8", DevName, ansiLen, utf8String, utf8Len);
    if (result == -1) {
    } else {
        string = [[NSString alloc] initWithUTF8String:utf8String];
    }
    free(utf8String);
    
    [device setName:string];
    
    if (strlen(DDNSHost) > 1) {
        [device setDdns:[NSString stringWithUTF8String:DDNSHost]];
        NSString *sn = [NSString stringWithFormat:@"%d", SN];
        NSInteger value = [[sn substringFromIndex:[sn length] - 3] integerValue];
        NSInteger dp = value + 7000;
        NSInteger hp = value + 8000;
        [device setLanDataPort:dp];
        [device setLanHttpPort:hp];
    }
    
    if (strlen(UID) > 1) {
        device.uid = [NSString stringWithUTF8String:UID];
        device.uidpsd = @"admin";
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationDevice object:device];
}
@end
