//
//  KenAddDeviceVC.m
//  KenCarcorder
//
//  Created by 邱根友 on 2017/5/6.
//  Copyright © 2017年 Ken.Liu. All rights reserved.
//

#import "KenAddDeviceVC.h"
#import "KenQRCodeVC.h"
#import "KenDeviceSearchVC.h"
#import "KenDeviceDM.h"
#import "KenUserInfoDM.h"
#import "KenActionSheet.h"

@interface KenAddDeviceVC ()<UITextFieldDelegate, UIGestureRecognizerDelegate, QRReaderDelegate>

@property (nonatomic, assign) NSUInteger groupId;
@property (nonatomic, strong) KenDeviceDM *deviceInfo;
@property (nonatomic, strong) UITextField *sequenceNumberTextField;
@property (nonatomic, strong) UITextField *deviceAccountTextField;
@property (nonatomic, strong) UITextField *devicePwdTextField;
@property (nonatomic, strong) UITextField *uidTextField;

@property (nonatomic, strong) UIView *topView;

@end

@implementation KenAddDeviceVC

- (instancetype)init {
    self = [super init];
    if (self) {
        _groupId = 0;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setNavTitle:@"添加设备"];
    
    //top view
    [self.contentView addSubview:self.topView];
    
    //account
    UIView *accountV = [[UIView alloc] initWithFrame:(CGRect){0, self.topView.maxY + 15, self.contentView.width, 100}];
    accountV.backgroundColor = [UIColor whiteColor];
    [self.contentView addSubview:accountV];
    
    CGFloat offsetx = 10;
    CGFloat height = accountV.height / 2;
    _sequenceNumberTextField = [self addTextFiled:NO content:@"设备序列号" parent:accountV
                                            frame:(CGRect){offsetx, 0, accountV.width - 30, height}];
    _uidTextField = [self addTextFiled:NO content:@"设备UID号" parent:accountV
                                 frame:(CGRect){offsetx, accountV.height / 2, _sequenceNumberTextField.size}];
    [_uidTextField setEnabled:NO];
    
    //pwd
    UIView *pwdV = [[UIView alloc] initWithFrame:(CGRect){0, accountV.maxY + 15, accountV.size}];
    pwdV.backgroundColor = [UIColor whiteColor];
    [self.contentView addSubview:pwdV];
    
    _deviceAccountTextField = [self addTextFiled:NO content:@"admin" parent:pwdV
                                           frame:(CGRect){offsetx, 0, _sequenceNumberTextField.size}];
    [_deviceAccountTextField setEnabled:NO];
    
    _devicePwdTextField = [self addTextFiled:NO content:@"设备密码" parent:pwdV
                                       frame:(CGRect){offsetx, pwdV.height / 2, _sequenceNumberTextField.size}];
    
    //finish
    UIButton *finishBtn = [UIButton buttonWithImg:@"确定" zoomIn:NO image:nil imagesec:nil target:self action:@selector(finishBtnClicked:)];
    finishBtn.frame = CGRectMake(20, pwdV.maxY + 40, self.contentView.width - 40, 44);
    finishBtn.backgroundColor = [UIColor colorWithHexString:@"#00DEC9"];
    [self.contentView addSubview:finishBtn];
    
    finishBtn.layer.masksToBounds = YES;
    finishBtn.layer.cornerRadius = 6;
    
    //tap gesture
    UITapGestureRecognizer *tapTouch = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    tapTouch.delegate = self;
    [self.contentView addGestureRecognizer:tapTouch];
}

#pragma mark - event
- (void)searchClicked {
    KenDeviceSearchVC *searchVC = [[KenDeviceSearchVC alloc] init];
    [self pushViewController:searchVC animated:YES];
    
    @weakify(self)
    searchVC.deviceSelcetBlock = ^(KenDeviceDM *device) {
        @strongify(self)
        [self.sequenceNumberTextField setText:device.sn];
        [self.deviceAccountTextField setText:device.usr];
        [self.devicePwdTextField setText:device.pwd];
        [self.uidTextField setPlaceholder:device.uid];

        self.deviceInfo = device;
        [self.sequenceNumberTextField setEnabled:NO];
    };
}

- (void)qrcodeClicked {
    KenQRCodeVC *qrCodeVC = [[KenQRCodeVC alloc] init];
    qrCodeVC.delegate = self;
    [self pushViewController:qrCodeVC animated:YES];
}

#pragma mark - textField
- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if (textField == _sequenceNumberTextField) {
        [UIView animateWithDuration:0.3f animations:^{
            self.contentView.frame = CGRectMake(0.f, -60, self.view.width, self.view.height);
        }];
    } else if (textField == _uidTextField) {
        [UIView animateWithDuration:0.3f animations:^{
            self.contentView.frame = CGRectMake(0.f, -120, self.view.width, self.view.height);
        }];
    } else if (textField == _devicePwdTextField) {
        [UIView animateWithDuration:0.3f animations:^{
            self.contentView.frame = CGRectMake(0.f, -160, self.view.width, self.view.height);
        }];
    }
}

- (void)hideKeyboard {
    [_devicePwdTextField resignFirstResponder];
    [_sequenceNumberTextField resignFirstResponder];
    [_uidTextField resignFirstResponder];
    
    [UIView animateWithDuration:0.3f animations:^{
        self.contentView.frame = CGRectMake(0.f, 0, self.view.width, self.view.height);
    }];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if ([touch.view isKindOfClass:[UIControl class]] ||
        [NSStringFromClass([touch.view class]) isEqualToString:@"UITableViewCellContentView"]) {
        return NO;
    }
    return YES;
}

#pragma mark - button
- (void)finishBtnClicked:(UIButton *)button {
    if (_deviceInfo == nil && !([[_sequenceNumberTextField text] length] > 0 && [[_devicePwdTextField text] length] > 0)) {
        [self showToastWithMsg:@"请输入正确的设备信息"];
        return;
    }
    
    [self hideKeyboard];
    
    [KenActionSheet showActionSheetViewWithTitle:nil cancelButtonTitle:nil otherButtonTitles:[KenUserInfoDM getInstance].deviceGroups
                                selectSheetBlock:^(KenActionSheet *actionSheetV, NSInteger index) {
        if (index >= 0) {
            _groupId = index;
            [self addDevice];
        }
    }];
}

- (void)addDevice {
    if (_deviceInfo) {
        NSDictionary *params = @{@"groupNo":[NSNumber numberWithUnsignedInteger:_groupId],
                                 @"sn":[_deviceInfo sn],
                                 @"name" : _deviceInfo.name,
                                 @"uid" : _deviceInfo.uid,
                                 @"uidpsd" : _deviceInfo.uidpsd,
                                 @"usr" : _deviceInfo.usr,
                                 @"pwd" : _deviceInfo.pwd,
                                 @"lanIp" : _deviceInfo.lanIp,
                                 @"ddns" : _deviceInfo.ddns,
                                 @"dataport" : [NSNumber numberWithInteger:[_deviceInfo dataport]],
                                 @"httpport" : [NSNumber numberWithInteger:[_deviceInfo httpport]]};
        [[KenServiceManager sharedServiceManager] deviceSaveInfo:params start:^{
            [self showActivity];
        } success:^(BOOL successful, NSString * _Nullable errMsg, KenDeviceDM *device) {
            [self hideActivity];
            if (successful) {
                if (device) {
                    _deviceInfo = device;
                }
                [self addSuccess];
            }
        } failed:^(NSInteger status, NSString * _Nullable errMsg) {
            [self hideActivity];
            [self showToastWithMsg:@"设备添加失败"];
        }];
    } else {
        if ([[_sequenceNumberTextField text] length] > 0 && [[_devicePwdTextField text] length] > 0) {
            [self addInputDevice];
        } else {
            [self showToastWithMsg:@"请输入正确的设备信息"];
        }
    }
}

- (void)addInputDevice {
    NSString *sn = [_sequenceNumberTextField text];

    int value = [[sn substringFromIndex:[sn length] - 3] intValue];
    
    NSDictionary *params = @{@"groupNo":[NSNumber numberWithUnsignedInteger:_groupId],
                             @"sn":sn,
                             @"name":@"",
                             @"uid":[NSString isEmpty:[_uidTextField placeholder]] ? @"" : [_uidTextField placeholder],
                             @"uidpsd":@"admin",
                             @"usr":@"admin",
                             @"pwd":[NSString isEmpty:[_devicePwdTextField text]] ? @"admin" : [_devicePwdTextField text],
                             @"lanIp":@"",
                             @"ddns":[sn stringByAppendingString:@".7cyun.net"],
                             @"dataport":[NSNumber numberWithInteger:value + 7000],
                             @"httpport":[NSNumber numberWithInteger:value + 8000]};
    
    _deviceInfo = [KenDeviceDM initWithJsonDictionary:params];
    
    [[KenServiceManager sharedServiceManager] deviceSaveInfo:params start:^{
        [self showActivity];
    } success:^(BOOL successful, NSString * _Nullable errMsg, KenDeviceDM *device) {
        [self hideActivity];
        if (successful) {
            if (device) {
                _deviceInfo = device;
            }
            [self addSuccess];
        }
    } failed:^(NSInteger status, NSString * _Nullable errMsg) {
        [self hideActivity];
        [self showToastWithMsg:@"设备添加失败"];
    }];
}

- (void)addSuccess {
    if (_deviceInfo) {
        [[KenUserInfoDM getInstance] addDevice:_deviceInfo];
    }
    
    [self showToastWithMsg:@"设备添加成功"];
    
    _deviceInfo = nil;
    [_uidTextField setPlaceholder:@"设备UID号"];
    [_sequenceNumberTextField setText:nil];
    [_devicePwdTextField setText:nil];
}

#pragma mark - qrReader delegate
- (void)qrReaderViewController:(UIViewController *)view didFinishPickingInformation:(NSString *)info {
    [view.navigationController popViewControllerAnimated:YES];
    DebugLog("info = %@", info);
    
    NSArray *array = [info split:@":"];
    if (array && [array count] > 0) {
        [_sequenceNumberTextField setText:[array objectAtIndex:0]];
        if ([array count] > 1) {
            [_uidTextField setPlaceholder:[array objectAtIndex:1]];
        }
    }
}

- (void)qrReaderDismiss:(UIViewController *)view {
    [view dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - private method
- (UITextField *)addTextFiled:(BOOL)secure content:(NSString *)content parent:(UIView *)parent frame:(CGRect)frame{
    UITextField *textField = [[UITextField alloc]initWithFrame:frame];
    textField.placeholder = content;
    textField.font = [UIFont appFontSize14];
    textField.clearButtonMode = UITextFieldViewModeAlways;
    textField.secureTextEntry = secure;
    textField.clearsOnBeginEditing = NO;
    textField.textAlignment = NSTextAlignmentLeft;
    textField.delegate = self;
    [parent addSubview:textField];
    
    UIView *line = [[UIView alloc] initWithFrame:(CGRect){textField.originX, textField.maxY, textField.width, 0.5}];
    line.backgroundColor = [UIColor appSepLineColor];
    [parent addSubview:line];
    
    return textField;
}

#pragma mark - getter setter 
- (UIView *)topView {
    if (_topView == nil) {
        _topView = [[UIView alloc] initWithFrame:(CGRect){0, 0, MainScreenWidth, 120}];
        
        [_topView setBackgroundColor:[UIColor whiteColor]];
        
        UIView *line = [[UIView alloc] initWithFrame:(CGRect){0, _topView.height - 1, _topView.width, 1}];
        [line setBackgroundColor:[UIColor appSepLineColor]];
        [_topView addSubview:line];
        
        line = [[UIView alloc] initWithFrame:(CGRect){(_topView.width / 2) - 1, 0, 1, _topView.height}];
        [line setBackgroundColor:[UIColor appSepLineColor]];
        [_topView addSubview:line];
        
        UIButton *searchBtn = [UIButton buttonWithImg:nil zoomIn:YES image:[UIImage imageNamed:@"add_device_search.png"]
                                             imagesec:[UIImage imageNamed:@"add_device_search_sec.png"]
                                               target:self action:@selector(searchClicked)];
        searchBtn.center = CGPointMake(_topView.width / 4, _topView.height / 2 - 10);
        [_topView addSubview:searchBtn];
        
        UILabel *searchLab = [UILabel labelWithTxt:@"搜一搜" frame:(CGRect){0, CGRectGetMaxY(searchBtn.frame) + 10, _topView.width / 2, 20}
                                               font:[UIFont appFontSize12] color:[UIColor appBlackTextColor]];
        [_topView addSubview:searchLab];
        
        UIButton *shaoBtn = [UIButton buttonWithImg:nil zoomIn:YES image:[UIImage imageNamed:@"add_device_shao.png"]
                                           imagesec:[UIImage imageNamed:@"add_device_shao_sec.png"]
                                             target:self action:@selector(qrcodeClicked)];
        shaoBtn.center = CGPointMake(_topView.width * 0.75, searchBtn.centerY);
        [_topView addSubview:shaoBtn];
        
        UILabel *shaoLab = [UILabel labelWithTxt:@"扫一扫" frame:(CGRect){_topView.width / 2, searchLab.originY, _topView.width / 2, 20}
                                             font:[UIFont appFontSize12] color:[UIColor appBlackTextColor]];
        [_topView addSubview:shaoLab];
    }
    return _topView;
}

@end
