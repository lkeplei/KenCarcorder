//
//  KenDeviceSettingVC.m
//  KenCarcorder
//
//  Created by hzyouda on 2017/3/11.
//  Copyright © 2017年 Ken.Liu. All rights reserved.
//

#import "KenDeviceSettingVC.h"
#import "KenDeviceDM.h"
#import "KenAlertView.h"
#import "KenUserInfoDM.h"

@interface KenDeviceSettingVC ()<UIPickerViewDelegate, UIPickerViewDataSource, UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) KenDeviceDM *deviceInfo;
@property (nonatomic, strong) UITableView *settingTable;
@property (nonatomic, strong) NSArray *dataArray;
@property (nonatomic, strong) UIButton *dayRecord;
@property (nonatomic, strong) UIButton *alarmRecord;
@property (nonatomic, strong) NSString *deviceStatusInfo;

@property (nonatomic, assign) NSInteger moveSensitive;
@property (nonatomic, assign) NSInteger audioSensitive;
@property (nonatomic, assign) NSInteger recordType;                  //0不录像、1全天录像、2定时录像、3报警录像
@property (nonatomic, assign) BOOL existWifi;
@property (nonatomic, assign) BOOL moveOpen;
@property (nonatomic, assign) BOOL audioOpen;
@property (nonatomic, assign) BOOL ledOpen;           //指示灯
@property (nonatomic, assign) BOOL ircutOpen;         //夜光灯
@property (nonatomic, assign) BOOL alarmOpen;         //警报声
@property (nonatomic, assign) BOOL voiceSetting;
@property (nonatomic, assign) BOOL disableTopSection;          //直连设备时顶部功能是否可用

//time select
@property (nonatomic, strong) UIView *timePickerV;
@property (nonatomic, strong) NSString *startHour;
@property (nonatomic, strong) NSString *startMinute;
@property (nonatomic, strong) NSString *endHour;
@property (nonatomic, strong) NSString *endMinute;
@property (nonatomic, strong) NSString *timeString;
@property (nonatomic, strong) NSArray *hourArray;
@property (nonatomic, strong) NSArray *minuteArray;

@end

@implementation KenDeviceSettingVC

- (instancetype)initWithDevice:(KenDeviceDM *)device {
    self = [super init];
    if (self) {
        _deviceInfo = device;
        
        _existWifi = YES;
        _moveOpen = NO;
        _audioOpen = NO;
        _ledOpen = NO;
        _ircutOpen = NO;
        _alarmOpen = NO;
        _voiceSetting = NO;
        _deviceStatusInfo = nil;
        
        _startHour = @"0";
        _startMinute = @"0";
        _endHour = @"0";
        _endMinute = @"0";
        _timeString = @"00:00 - 00:00";
        
        _disableTopSection = [KenCarcorder validateIPCAM:[KenCarcorder getCurrentSSID]];
        
        _dataArray = @[@[@{@"image":[UIImage imageNamed:@"setting_change_name"], @"title":@"修改名称"},
                         @{@"image":[UIImage imageNamed:@"setting_change_pwd"], @"title":@"修改密码"},
                         @{@"image":[UIImage imageNamed:@"setting_correct_pwd"], @"title":@"更正密码"},
                         @{@"image":[UIImage imageNamed:@"setting_change_group"], @"title":@"分组切换"}],
                       @[@{@"image":[UIImage imageNamed:@"setting_info"], @"title":@"设备信息"}],
                       @[@{@"image":[UIImage imageNamed:@"setting_wifi"], @"title":@"无线局域网"},
                         @{@"image":[UIImage imageNamed:@"setting_clear_sd"], @"title":@"格式化SD卡"},
                         @{@"image":[UIImage imageNamed:@"setting_info"], @"title":@"报警时段"}],
                       @[@[@"全天录像", @"报警录像"]],
                       @[@"移动侦测报警", @"声音侦测报警"],
                       @[@"指示灯", @"夜光灯", @"警报声"]];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setNavTitle:@"设备设置"];

    [self.contentView addSubview:self.settingTable];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self getCurrentDeviceInfo];
    [self getAlarmSet];
}

- (void)getCurrentDeviceInfo {
    if (_deviceInfo.online) {
        [[KenServiceManager sharedServiceManager] deviceLoadInfo:_deviceInfo start:^{
            [self showActivity];
        } success:^(BOOL successful, NSString * _Nullable errMsg, id _Nullable info) {
            [self hideActivity];
            if (successful) {
                [self loadData:info];
            }
        } failed:^(NSInteger status, NSString * _Nullable errMsg) {
            [self hideActivity];
        }];
    }
}

- (void)loadData:(NSString *)data {
    NSArray *array = [data componentsSeparatedByString:@"\r\n"];
    
    _deviceStatusInfo = data;
    
    NSString *ExistWiFi =@"";
    NSString *move = @"";
    NSString *audio = @"";
    NSString *led = @"";
    NSString *ircut = @"";
    NSString *alarm = @"";
    NSString *soundSensitive = @"";
    NSString *mdSensitive = @"";
    NSString *recType = @"";
    NSString *alarmTime = @"";
    for (int i = 0; i< [array count]; i++) {
        NSString * tmp = [array objectAtIndex:i];
        if ([tmp rangeOfString:@"INFO_ExistWiFi"].length > 0) {
            ExistWiFi = [[[array objectAtIndex:i] componentsSeparatedByString:@"="] objectAtIndex:1];
        }
        
        if (([tmp rangeOfString:@"MD_Active"].length > 0)
            && ([tmp rangeOfString:@"MD_ActiveDO"].length==0)) {
            move = [[[array objectAtIndex:i] componentsSeparatedByString:@"="] objectAtIndex:1];
        }
        
        if ([tmp rangeOfString:@"AUDIO_SoundTriggerActive"].length > 0) {
            audio = [[[array objectAtIndex:i] componentsSeparatedByString:@"="] objectAtIndex:1];
        }
        
        if ([tmp rangeOfString:@"INFO_Led_Onoff"].length > 0) {
            led = [[[array objectAtIndex:i] componentsSeparatedByString:@"="] objectAtIndex:1];
        }
        
        if ([tmp rangeOfString:@"INFO_IRCut_Onoff"].length > 0) {
            ircut = [[[array objectAtIndex:i] componentsSeparatedByString:@"="] objectAtIndex:1];
        }
        
        if ([tmp rangeOfString:@"INFO_Alarm_Sound_Onoff"].length > 0) {
            alarm = [[[array objectAtIndex:i] componentsSeparatedByString:@"="] objectAtIndex:1];
        }
        
        if ([tmp rangeOfString:@"SoundTriggerSensitive"].length > 0) {
            soundSensitive = [[[array objectAtIndex:i] componentsSeparatedByString:@"="] objectAtIndex:1];
        }
        
        if ([tmp rangeOfString:@"MD_Sensitive"].length > 0) {
            mdSensitive = [[[array objectAtIndex:i] componentsSeparatedByString:@"="] objectAtIndex:1];
        }
        
        if ([tmp rangeOfString:@"Rec_RecStyle"].length > 0) {
            recType = [[[array objectAtIndex:i] componentsSeparatedByString:@"="] objectAtIndex:1];
        }
        
        if ([tmp rangeOfString:@"Alarm_Time"].length > 0) {
            alarmTime = [[[array objectAtIndex:i] componentsSeparatedByString:@"="] objectAtIndex:1];
        }
    }
    
    ExistWiFi = [ExistWiFi stringByReplacingOccurrencesOfString:@";" withString:@""];
    ExistWiFi = [ExistWiFi stringByReplacingOccurrencesOfString:@"\"" withString:@""];
    
    move = [move stringByReplacingOccurrencesOfString:@";" withString:@""];
    move = [move stringByReplacingOccurrencesOfString:@"\"" withString:@""];
    
    audio = [audio stringByReplacingOccurrencesOfString:@";" withString:@""];
    audio = [audio stringByReplacingOccurrencesOfString:@"\"" withString:@""];
    
    led = [led stringByReplacingOccurrencesOfString:@";" withString:@""];
    led = [led stringByReplacingOccurrencesOfString:@"\"" withString:@""];
    
    ircut = [ircut stringByReplacingOccurrencesOfString:@";" withString:@""];
    ircut = [ircut stringByReplacingOccurrencesOfString:@"\"" withString:@""];
    
    alarm = [alarm stringByReplacingOccurrencesOfString:@";" withString:@""];
    alarm = [alarm stringByReplacingOccurrencesOfString:@"\"" withString:@""];
    
    soundSensitive = [soundSensitive stringByReplacingOccurrencesOfString:@";" withString:@""];
    soundSensitive = [soundSensitive stringByReplacingOccurrencesOfString:@"\"" withString:@""];
    
    mdSensitive = [mdSensitive stringByReplacingOccurrencesOfString:@";" withString:@""];
    mdSensitive = [mdSensitive stringByReplacingOccurrencesOfString:@"\"" withString:@""];
    
    recType = [recType stringByReplacingOccurrencesOfString:@";" withString:@""];
    recType = [recType stringByReplacingOccurrencesOfString:@"\"" withString:@""];
    
    alarmTime = [alarmTime stringByReplacingOccurrencesOfString:@";" withString:@""];
    alarmTime = [alarmTime stringByReplacingOccurrencesOfString:@"\"" withString:@""];
    
    _moveSensitive = [mdSensitive intValue];
    _audioSensitive = [soundSensitive intValue];
    _recordType = [recType intValue] == 1 ? 1 : 3;
    _moveOpen = [move isEqualToString:@"1"] ? YES : NO;
    _audioOpen = [audio isEqualToString:@"1"] ? YES : NO;
    _ledOpen = [led isEqualToString:@"1"] ? YES : NO;
    _ircutOpen = [ircut isEqualToString:@"40"] ? YES : NO;
    _alarmOpen = [alarm isEqualToString:@"1"] ? YES : NO;
    _timeString = [alarmTime length] > 1 ? alarmTime : _timeString;
    
    if([ExistWiFi isEqualToString:@"1"]) {
        _existWifi = YES;
    } else {
        _existWifi = NO;
    }
    
    [_settingTable reloadData];
    
    [self hideActivity];
}

- (UIView *)getFootView {
    UIView *footV = [[UIView alloc] initWithFrame:(CGRect){0,0,self.view.width, 190}];
    
    UIButton *reboot = [UIButton buttonWithImg:@"设备重启" zoomIn:NO image:nil imagesec:nil target:self action:@selector(rebootDevice)];
    [reboot setBackgroundColor:[UIColor colorWithHexString:@"#419FFF"]];
    reboot.frame = CGRectMake(15, 20, footV.width - 30, 44);
    
    reboot.layer.cornerRadius = 8.f;
    [footV addSubview:reboot];
    
    UIButton *button = [UIButton buttonWithImg:@"删除设备" zoomIn:NO image:nil imagesec:nil target:self action:@selector(deleteDevice)];
    [button setBackgroundColor:[UIColor colorWithHexString:@"#FA673E"]];
    button.frame = CGRectMake(15, CGRectGetMaxY(reboot.frame) + 10, footV.width - 30, 44);
    
    button.layer.cornerRadius = 8.f;
    [footV addSubview:button];
    
    UIButton *setting = [UIButton buttonWithImg:@"设置时间" zoomIn:NO image:nil imagesec:nil target:self action:@selector(setTime)];
    [setting setBackgroundColor:[UIColor colorWithHexString:@"#419FFF"]];
    setting.frame = CGRectMake(15, CGRectGetMaxY(button.frame) + 10, footV.width - 30, 44);
    
    setting.layer.cornerRadius = 8.f;
    [footV addSubview:setting];
    
    return footV;
}

#pragma mark - Table
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[_dataArray objectAtIndex:section] count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [_dataArray count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 12;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *bankCellIdentifier = @"videoCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:bankCellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:bankCellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        if (indexPath.section <= 2)
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    cell.accessoryView = nil;
    
    if (indexPath.section <= 2) {
        if (indexPath.section == 0 && _disableTopSection) {
            [cell.contentView setBackgroundColor:[UIColor appBackgroundColor]];
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        [cell.imageView setImage:[[[_dataArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] objectForKey:@"image"]];
        [cell.textLabel setText:[[[_dataArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] objectForKey:@"title"]];
        
        if (indexPath.section == 2 && indexPath.row == 2) {
            cell.accessoryView = [UILabel labelWithTxt:_timeString frame:(CGRect){_settingTable.width - 180, 0, 120, cell.height}
                                                  font:[UIFont appFontSize16] color:[UIColor colorWithHexString:@"#999999"]];
        } else {
            cell.accessoryView = nil;
        }
    } else {
        if (indexPath.section == 3) {
            float width = cell.contentView.width / 2;
            if (_dayRecord == nil) {
                _dayRecord = [UIButton buttonWithImg:@"全天录像" zoomIn:YES image:[UIImage imageNamed:@"setting_radio_unselect"]
                                            imagesec:[UIImage imageNamed:@"setting_radio_select"] target:self action:@selector(dayRecordBtn)];
                _dayRecord.imageEdgeInsets = UIEdgeInsetsMake(0, -20, 0, 0);//上top，左left，下bottom，右right
                _dayRecord.frame = CGRectMake(0, 0, width, cell.contentView.height);
                [_dayRecord setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
                _dayRecord.titleLabel.font = [UIFont appFontSize16];
                
                _alarmRecord = [UIButton buttonWithImg:@"报警时录像" zoomIn:YES image:[UIImage imageNamed:@"setting_radio_select"]
                                              imagesec:[UIImage imageNamed:@"setting_radio_select"] target:self action:@selector(alarmRecordBtn)];
                _alarmRecord.imageEdgeInsets = UIEdgeInsetsMake(0, -20, 0, 0);//上top，左left，下bottom，右right
                _alarmRecord.frame = CGRectMake(width, 0, width, _dayRecord.height);
                [_alarmRecord setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
                _alarmRecord.titleLabel.font = [UIFont appFontSize16];
            }
            [cell.contentView addSubview:_dayRecord];
            [_dayRecord setImage:[UIImage imageNamed:_recordType == 1 ? @"setting_radio_select" : @"setting_radio_unselect"]
                        forState:UIControlStateNormal];
            
            [cell.contentView addSubview:_alarmRecord];
            [_alarmRecord setImage:[UIImage imageNamed:_recordType == 3 ? @"setting_radio_select" : @"setting_radio_unselect"]
                          forState:UIControlStateNormal];
            
            cell.accessoryView = nil;
        } else if (indexPath.section == 4 || indexPath.section == 5) {
            [cell.imageView setImage:nil];
            [cell.textLabel setText:[[_dataArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row]];
            
            UISwitch *switchMov = [[UISwitch alloc] initWithFrame:CGRectMake(0,0,0,0)];
            if (indexPath.section == 4) {
                if (indexPath.row == 0) {
                    [switchMov setOn:_moveOpen];
                    [switchMov addTarget:self action:@selector(switchMove:) forControlEvents:UIControlEventValueChanged];
                } else {
                    [switchMov setOn:_audioOpen];
                    [switchMov addTarget:self action:@selector(switchAudio:) forControlEvents:UIControlEventValueChanged];
                }
            } else if (indexPath.section == 5) {
                if (indexPath.row == 0) {
                    [switchMov setOn:_ledOpen];
                    [switchMov addTarget:self action:@selector(switchLed:) forControlEvents:UIControlEventValueChanged];
                } else if (indexPath.row == 1) {
                    [switchMov setOn:_ircutOpen];
                    [switchMov addTarget:self action:@selector(switchIrcut:) forControlEvents:UIControlEventValueChanged];
                } else if (indexPath.row == 2) {
                    [switchMov setOn:_alarmOpen];
                    [switchMov addTarget:self action:@selector(switchAlram:) forControlEvents:UIControlEventValueChanged];
                }
            }
            
            cell.accessoryView = switchMov;
        }
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case 0: {
            if (!_disableTopSection) {
//                YDBaseViewController *vc;
//                if (indexPath.row == 0) {
//                    vc = [[YDChangeDeviceNameVC alloc] initWithDevice:_deviceInfo];
//                } else if (indexPath.row == 1) {
//                    vc = [[YDChangeDevicePwdVC alloc] initWithDevice:_deviceInfo];
//                } else if (indexPath.row == 2) {
//                    vc = [[YDCorrectDevicePwdVC alloc] initWithDevice:_deviceInfo];
//                } else {
//                    vc = [[YDChangeDeviceGroupVC alloc] initWithDevice:_deviceInfo];
//                }
//                
//                [self pushViewController:vc];
            }
        }
            break;
        case 1: {
//            YDDeviceInfoVC *infoVC = [[YDDeviceInfoVC alloc] initWithDevice:_deviceInfo];
//            [infoVC setDeviceStatusInfo:_deviceStatusInfo];
//            [self pushViewController:infoVC];
        }
            break;
        case 2: {
            if (indexPath.row == 0) {
                if (_existWifi) {
//                    YDWifiSettingVC *wifiVC = [[YDWifiSettingVC alloc] initWithDevice:_deviceInfo];
//                    [self pushViewController:wifiVC];
                } else {
                    [self showAlert:nil content:@"当前设备没有WIFI模组!"];
                }
            } else if (indexPath.row == 1) {
                [KenAlertView showAlertViewWithTitle:nil contentView:nil message:@"是否确认清空所有数据？" buttonTitles:@[@"取消", @"确定"] buttonClickedBlock:^(KenAlertView * _Nonnull alertView, NSInteger index) {
                    if (index == 1) {
                        [[KenServiceManager sharedServiceManager] deviceClearSDCard:self.deviceInfo start:^{
                            [self showActivity];
                        } success:^(BOOL successful, NSString * _Nullable errMsg, id  _Nullable responseData) {
                            [self hideActivity];
                            if (successful) {
                                [self showToastWithMsg:@"格式化成功"];
                            } else {
                                [self showToastWithMsg:@"格式化失败"];
                            }
                        } failed:^(NSInteger status, NSString * _Nullable errMsg) {
                            [self hideActivity];
                        }];
                    }
                }];
            } else if (indexPath.row == 2) {
                [self showTimeSelect];
            }
        }
            break;
        default:
            break;
    }
}

- (void)urlConnectWithcUrl:(NSString *)url {
    NSURLRequest *theRequest=[NSURLRequest requestWithURL:[NSURL URLWithString:url]
                                              cachePolicy:NSURLRequestUseProtocolCachePolicy
                                          timeoutInterval:60.0];
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
    [connection start];
}

#pragma mark - switch
- (void)switchLed:(UISwitch *)switchObject {
    [[KenServiceManager sharedServiceManager] deviceSetLed:self.deviceInfo isOn:[switchObject isOn] start:^{
    } success:^(BOOL successful, NSString * _Nullable errMsg, id  _Nullable responseData) {
        if (successful) {
            [self showToastWithMsg:@"设置成功"];
        } else {
            [self showToastWithMsg:@"设置失败"];
            [switchObject setOn:![switchObject isOn]];
        }
    } failed:^(NSInteger status, NSString * _Nullable errMsg) {
        [self showToastWithMsg:@"设置失败"];
        [switchObject setOn:![switchObject isOn]];
    }];
}

- (void)switchIrcut:(UISwitch *)switchObject {
    [[KenServiceManager sharedServiceManager] deviceSetIrcut:self.deviceInfo isOn:[switchObject isOn] start:^{
    } success:^(BOOL successful, NSString * _Nullable errMsg, id  _Nullable responseData) {
        if (successful) {
            [self showToastWithMsg:@"设置成功"];
        } else {
            [self showToastWithMsg:@"设置失败"];
            [switchObject setOn:![switchObject isOn]];
        }
    } failed:^(NSInteger status, NSString * _Nullable errMsg) {
        [self showToastWithMsg:@"设置失败"];
        [switchObject setOn:![switchObject isOn]];
    }];
}

- (void)switchAlram:(UISwitch *)switchObject {
    [[KenServiceManager sharedServiceManager] deviceSetAlarm:self.deviceInfo isOn:[switchObject isOn] start:^{
    } success:^(BOOL successful, NSString * _Nullable errMsg, id  _Nullable responseData) {
        if (successful) {
            [self showToastWithMsg:@"设置成功"];
        } else {
            [self showToastWithMsg:@"设置失败"];
            [switchObject setOn:![switchObject isOn]];
        }
    } failed:^(NSInteger status, NSString * _Nullable errMsg) {
        [self showToastWithMsg:@"设置失败"];
        [switchObject setOn:![switchObject isOn]];
    }];
}

- (void)switchMove:(UISwitch *)switchMov {
    if ([switchMov isOn]) {
        [KenAlertView showAlertViewWithTitle:nil contentView:nil message:@"请选择您所需要的灵敏度" buttonTitles:@[@"低", @"高"]
                          buttonClickedBlock:^(KenAlertView * _Nonnull alertView, NSInteger index) {
            [self setDeviceMove:switchMov sensitive:index == 0 ? 35 : 5];
        }];
    } else {
        [self setDeviceMove:switchMov sensitive:_moveSensitive];
    }
}

- (void)setDeviceMove:(UISwitch *)switchMove sensitive:(NSInteger)sensitive {
    [[KenServiceManager sharedServiceManager] deviceSetMove:self.deviceInfo isOn:[switchMove isOn] sensitive:sensitive start:^{
    } success:^(BOOL successful, NSString * _Nullable errMsg, id  _Nullable responseData) {
        if (successful) {
            [self showToastWithMsg:@"设置成功"];
        } else {
            [self showToastWithMsg:@"设置失败"];
            [switchMove setOn:![switchMove isOn]];
        }
    } failed:^(NSInteger status, NSString * _Nullable errMsg) {
        [self showToastWithMsg:@"设置失败"];
        [switchMove setOn:![switchMove isOn]];
    }];
}

- (void)switchAudio:(UISwitch *)switchAud {
    if ([switchAud isOn]) {
        [KenAlertView showAlertViewWithTitle:nil contentView:nil message:@"请选择您所需要的灵敏度" buttonTitles:@[@"低", @"高"]
                          buttonClickedBlock:^(KenAlertView * _Nonnull alertView, NSInteger index) {
                              [self setDeviceAudio:switchAud sensitive:index == 0 ? 50 : 20];
                          }];
    } else {
        [self setDeviceAudio:switchAud sensitive:_audioSensitive];
    }
}

- (void)setDeviceAudio:(UISwitch *)switchAudio sensitive:(NSInteger)sensitive {
    [[KenServiceManager sharedServiceManager] deviceSetAudio:self.deviceInfo isOn:[switchAudio isOn] sensitive:sensitive start:^{
    } success:^(BOOL successful, NSString * _Nullable errMsg, id  _Nullable responseData) {
        if (successful) {
            [self showToastWithMsg:@"设置成功"];
        } else {
            [self showToastWithMsg:@"设置失败"];
            [switchAudio setOn:![switchAudio isOn]];
        }
    } failed:^(NSInteger status, NSString * _Nullable errMsg) {
        [self showToastWithMsg:@"设置失败"];
        [switchAudio setOn:![switchAudio isOn]];
    }];
}

- (void)switchVoice:(UISwitch *)switchVoice {
    _voiceSetting = [switchVoice isOn];
    
    NSMutableArray *alarm =  [[NSMutableArray alloc] init] ;
    NSDictionary *content = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:_voiceSetting], @"vib",
                             [NSNumber numberWithBool:NO], @"cap",
                             nil];
    [alarm addObject:content];
    
    NSArray *storeFilePath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *doucumentsDirectiory = [storeFilePath objectAtIndex:0];
    
    NSString *appPath=[doucumentsDirectiory stringByAppendingPathComponent:@"alarm.plist"];
    BOOL fileExists = [alarm writeToFile:appPath atomically:YES];
    
    if(fileExists) {
        DebugLog("successfully written");
    } else {
        DebugLog("failed to write");
    }
}

- (NSMutableArray*)ReadAlmFromPlist {
    NSArray *storeFilePath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *doucumentsDirectiory = [storeFilePath objectAtIndex:0];
    NSString *appPath = [doucumentsDirectiory stringByAppendingPathComponent:@"alarm.plist"];
    NSMutableArray *coolArray = [NSMutableArray arrayWithContentsOfFile:appPath];
    return coolArray;
}

- (void)getAlarmSet {
    NSMutableArray *alarm;
    alarm =  [[NSMutableArray alloc] initWithArray:[self ReadAlmFromPlist] copyItems:YES];
    if ([alarm count] == 0) {
        _voiceSetting = NO;
    } else {
        NSDictionary *Content = [alarm objectAtIndex:0];
        _voiceSetting = [[Content objectForKey:@"vib"] boolValue];
    }
}

#pragma mark - button
- (void)rebootDevice {
    [KenAlertView showAlertViewWithTitle:nil contentView:nil message:@"确认重新启动这台设备吗？" buttonTitles:@[@"取消", @"确定"]
                      buttonClickedBlock:^(KenAlertView * _Nonnull alertView, NSInteger index) {
                          if (index == 1) {
                              [[KenServiceManager sharedServiceManager] deviceReboot:self.deviceInfo start:^{
                              } success:^(BOOL successful, NSString * _Nullable errMsg, id  _Nullable responseData) {
                              } failed:^(NSInteger status, NSString * _Nullable errMsg) {
                              }];
                          }
                      }];
}

- (void)deleteDevice {
    [KenAlertView showAlertViewWithTitle:nil contentView:nil message:@"确认永久删除这台设备吗？" buttonTitles:@[@"取消", @"确定"]
                      buttonClickedBlock:^(KenAlertView * _Nonnull alertView, NSInteger index) {
                          if (index == 1) {
                              [[KenServiceManager sharedServiceManager] deviceRemoveBySn:self.deviceInfo.sn start:^{
                              } success:^(BOOL successful, NSString * _Nullable errMsg, id  _Nullable responseData) {
                                  if (successful) {
                                      [self showToastWithMsg:@"设备删除成功"];
                                      
                                      KenUserInfoDM *userinfo = [KenUserInfoDM getInstance];
                                      [userinfo removeDevice:self.deviceInfo];
                                      
                                      [self popToRootViewControllerAnimated:YES];
                                  }
                              } failed:^(NSInteger status, NSString * _Nullable errMsg) {
                              }];
                          }
                      }];
}

- (void)setTime {
    NSString *time = [[NSDate date] stringWithFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *message = [NSString stringWithFormat:@"确定要将设备时间设置为（%@）吗？", time];
    [KenAlertView showAlertViewWithTitle:nil contentView:nil message:message buttonTitles:@[@"取消", @"确定"]
                      buttonClickedBlock:^(KenAlertView * _Nonnull alertView, NSInteger index) {
                          if (index == 1) {
                              [[KenServiceManager sharedServiceManager] deviceSetTime:self.deviceInfo start:^{
                              } success:^(BOOL successful, NSString * _Nullable errMsg, id  _Nullable responseData) {
                                  if (successful) {
                                      [self showToastWithMsg:@"时间设置成功"];
                                  }
                              } failed:^(NSInteger status, NSString * _Nullable errMsg) {
                              }];
                          }
                      }];
}

- (void)dayRecordBtn {
    if (_recordType != 1) {
        [[KenServiceManager sharedServiceManager] deviceSetRecordType:self.deviceInfo type:1 start:^{
        } success:^(BOOL successful, NSString * _Nullable errMsg, id  _Nullable responseData) {
            if (successful) {
                [self resetRecodStatus:1];
                [self showToastWithMsg:@"设置成功"];
            } else {
                [self resetRecodStatus:3];
                [self showToastWithMsg:@"设置失败"];
            }
        } failed:^(NSInteger status, NSString * _Nullable errMsg) {
        }];
    }
}

- (void)resetRecodStatus:(NSInteger)type {
    _recordType = type;
    [_dayRecord setImage:[UIImage imageNamed:_recordType == 1 ? @"setting_radio_select" : @"setting_radio_unselect"]
                forState:UIControlStateNormal];
    [_alarmRecord setImage:[UIImage imageNamed:_recordType == 3 ? @"setting_radio_select" : @"setting_radio_unselect"]
                  forState:UIControlStateNormal];
}

- (void)alarmRecordBtn {
    if (_recordType != 3) {
        [[KenServiceManager sharedServiceManager] deviceSetRecordType:self.deviceInfo type:3 start:^{
        } success:^(BOOL successful, NSString * _Nullable errMsg, id  _Nullable responseData) {
            if (successful) {
                [self resetRecodStatus:3];
                [self showToastWithMsg:@"设置成功"];
            } else {
                [self resetRecodStatus:1];
                [self showToastWithMsg:@"设置失败"];
            }
        } failed:^(NSInteger status, NSString * _Nullable errMsg) {
        }];
    }
}

#pragma mark - time picker
- (void)showTimeSelect {
    if (_timePickerV) {
        [_timePickerV setHidden:NO];
    } else {
        _hourArray = @[@"0", @"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", @"10", @"11",
                       @"12", @"13", @"14", @"15", @"16", @"17", @"18", @"19", @"20", @"21", @"22", @"23"];
        _minuteArray = @[@"0", @"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", @"10", @"11",
                         @"12", @"13", @"14", @"15", @"16", @"17", @"18", @"19", @"20", @"21", @"22", @"23",
                         @"24", @"25", @"26", @"27", @"28", @"29", @"30", @"31", @"32", @"33", @"34", @"35",
                         @"36", @"37", @"38", @"39", @"40", @"41", @"42", @"43", @"44", @"45", @"46", @"47",
                         @"48", @"49", @"50", @"51", @"52", @"53", @"54", @"55", @"56", @"57", @"58", @"59"];
        
        _timePickerV = [[UIView alloc] initWithFrame:(CGRect){0, 0, self.view.size}];
        [_timePickerV setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.5]];
        [self.view addSubview:_timePickerV];
        
        UIPickerView *timePickerS = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 0, (_timePickerV.width - 40) / 2, 180)];
        timePickerS.centerY = self.view.centerY;
        timePickerS.tag = 1001;
        timePickerS.delegate = self;
        timePickerS.dataSource = self;
        [timePickerS setBackgroundColor:[UIColor colorWithHexString:@"#EEEEEE"]];
        [timePickerS reloadAllComponents];
        [_timePickerV addSubview:timePickerS];
        
        UILabel *label = [UILabel labelWithTxt:@"至" frame:(CGRect){CGRectGetMaxX(timePickerS.frame), timePickerS.originY, 40, timePickerS.height}
                                          font:[UIFont appFontSize16] color:[UIColor colorWithHexString:@"#666666"]];
        [label setBackgroundColor:[UIColor colorWithHexString:@"#EEEEEE"]];
        [_timePickerV addSubview:label];
        
        UIPickerView *timePickerE = [[UIPickerView alloc] initWithFrame:(CGRect){CGRectGetMaxX(label.frame),
            timePickerS.originY, timePickerS.size}];
        timePickerE.tag = 1002;
        timePickerE.delegate = self;
        timePickerE.dataSource = self;
        [timePickerE setBackgroundColor:[UIColor colorWithHexString:@"#EEEEEE"]];
        [timePickerE reloadAllComponents];
        [_timePickerV addSubview:timePickerE];
        
        //button
        UIButton *cancelBtn = [UIButton buttonWithImg:@"取消" zoomIn:NO image:nil imagesec:nil target:self action:@selector(cancelBtn:)];
        cancelBtn.frame = (CGRect){0, CGRectGetMaxY(timePickerS.frame), _timePickerV.width / 2, 40};
        [cancelBtn setBackgroundColor:[UIColor colorWithHexString:@"#EEEEEE"]];
        [cancelBtn setTitleColor:[UIColor colorWithHexString:@"#419FFF"] forState:UIControlStateNormal];
        [cancelBtn setTitleColor:[UIColor colorWithHexString:@"#999999"] forState:UIControlStateHighlighted];
        [_timePickerV addSubview:cancelBtn];
        
        UIButton *confirmBtn = [UIButton buttonWithImg:@"确定" zoomIn:NO image:nil imagesec:nil target:self action:@selector(confirmBtn:)];
        confirmBtn.frame = (CGRect){CGRectGetMaxX(cancelBtn.frame), cancelBtn.originY, cancelBtn.size};
        [confirmBtn setBackgroundColor:[UIColor colorWithHexString:@"#EEEEEE"]];
        [confirmBtn setTitleColor:[UIColor colorWithHexString:@"#419FFF"] forState:UIControlStateNormal];
        [confirmBtn setTitleColor:[UIColor colorWithHexString:@"#999999"] forState:UIControlStateHighlighted];
        [_timePickerV addSubview:confirmBtn];
    }
}

#pragma mark Picker Date Source Methods
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 2;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    if (component == 0) {
        return [_hourArray count];
    } else {
        return [_minuteArray count];
    }
}

#pragma mark Picker Delegate Methods
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    if (component == 0) {
        return _hourArray[row];
    } else {
        return _minuteArray[row];
    }
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    if (component == 0) {
        if (pickerView.tag == 1001) {
            _startHour = _hourArray[row];
        } else {
            _endHour = _hourArray[row];
        }
    } else {
        if (pickerView.tag == 1001) {
            _startMinute = _minuteArray[row];
        } else {
            _endMinute = _minuteArray[row];
        }
    }
}

#pragma mark - select picker button
- (void)cancelBtn:(UIButton *)button {
    [_timePickerV setHidden:YES];
}

- (void)confirmBtn:(UIButton *)button {
    [_timePickerV setHidden:YES];
    
    _timeString = [NSString stringWithFormat:@"%02d:%02d - %02d:%02d", [_startHour intValue],
                   [_startMinute intValue], [_endHour intValue], [_endMinute intValue]];
    
    [[KenServiceManager sharedServiceManager] deviceSetAlarmTime:self.deviceInfo startH:_startHour startM:_startMinute endH:_endHour endM:_endMinute start:^{
    } success:^(BOOL successful, NSString * _Nullable errMsg, id  _Nullable responseData) {
        if (successful) {
            [self.settingTable reloadData];
            [self showToastWithMsg:@"设置成功"];
        } else {
            [self showToastWithMsg:@"设置失败"];
        }
    } failed:^(NSInteger status, NSString * _Nullable errMsg) {
        [self showToastWithMsg:@"设置失败"];
    }];
}

#pragma mark - getter setter 
- (UITableView *)settingTable {
    if (_settingTable == nil) {
        _settingTable = [[UITableView alloc] initWithFrame:(CGRect){0, 0, self.contentView.size} style:UITableViewStylePlain];
        _settingTable.delegate = self;
        _settingTable.dataSource = self;
        [_settingTable setBackgroundColor:[UIColor appBackgroundColor]];
        _settingTable.tableFooterView = [self getFootView];
        _settingTable.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    }
    return _settingTable;
}
@end
