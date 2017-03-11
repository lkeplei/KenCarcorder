//
//  KenWifiSetStep41V.m
//  KenCarcorder
//
//  Created by Ken.Liu on 2017/2/25.
//  Copyright © 2017年 Ken.Liu. All rights reserved.
//

#import "KenWifiSetStep41V.h"
#import "Masonry.h"
#import "KenWifiSetStep4VC.h"

@interface KenWifiSetStep41V ()<UITextFieldDelegate>

@property (nonatomic, weak) KenWifiSetStep4VC *parentVC;

@property (nonatomic, strong) UITextField *wifiName;
@property (nonatomic, strong) UITextField *wifiPwd;

@end

@implementation KenWifiSetStep41V

- (instancetype)initWithParentVC:(KenWifiSetStep4VC *)parentVC frame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.userInteractionEnabled = YES;
        
        _parentVC = parentVC;
        
        [self initView];
    }
    return self;
}

#pragma mark - textField delegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    //    if (textField == _accountTextField) {
    //        [UIView animateWithDuration:0.3f animations:^{
    //            self.view.frame = CGRectMake(0.f, -60, self.view.width, self.view.height);
    //        }];
    //    }
}

#pragma mark - event
- (void)collectWifiBtnClicked {
    if ([NSString isEmpty:_wifiName.text]) {
        [_parentVC showAlert:@"" content:@"请输入wifi名称"];
        return;
    }
    
    if ([NSString isEmpty:_wifiPwd.text]) {
        [_parentVC showAlert:@"" content:@"请输入wifi密码"];
        return;
    }
    
    [self hideKeyboard];
    
    [_parentVC inputConfirm:_wifiName.text pwd:_wifiPwd.text];
}

- (void)hideKeyboard {
    [_wifiName resignFirstResponder];
    [_wifiPwd resignFirstResponder];
    
//    [UIView animateWithDuration:0.3f animations:^{
//        self.frame = CGRectMake(0.f, 0, self.width, self.height);
//    }];
}

#pragma mark - private method
- (void)initView {
    UILabel *label = [UILabel labelWithTxt:@"    选择行车记录仪要连接WIFI网络，用于远程连接观看，如果行车记录仪只用于本地与手机直连，请断电重启行记录仪即可，如果行车记录仪已经加入过WIFI，那么请重新从第一 步开始。"
                                     frame:(CGRect){30, 100, self.width - 60, 120}
                                      font:[UIFont appFontSize16] color:[UIColor appWhiteTextColor]];
    label.numberOfLines = 0;
    label.textAlignment = NSTextAlignmentLeft;
    [self addSubview:label];
    
    UIView *inputV = [self resetInputV];
    [self addSubview:inputV];
    
    UIButton *button = [UIButton buttonWithImg:@"连接WIFI" zoomIn:NO image:[UIImage imageNamed:@"wifi_1_btn"]
                                      imagesec:nil target:self action:@selector(collectWifiBtnClicked)];
    button.titleLabel.font = [UIFont appFontSize15];
    [self addSubview:button];
    
    //autolayout
    [inputV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(label.mas_bottom).offset(kKenOffsetY(50));
        make.centerX.equalTo(self.mas_centerX);
        make.width.mas_equalTo(self.mas_width);
    }];
    
    [button mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(inputV.mas_bottom).offset(kKenOffsetY(30));
        make.centerX.equalTo(self.mas_centerX);
    }];
    
    //tap gesture
    UITapGestureRecognizer *tapTouch = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    [self addGestureRecognizer:tapTouch];
}

- (UIView *)resetInputV {
    UIImageView *inputBg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"wifi_4_input_bg"]];
    inputBg.userInteractionEnabled = YES;
    
    UIImageView *wifiLogoV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"wifi_4_wifi"]];
    [inputBg addSubview:wifiLogoV];
    
    _wifiName = [self addTextFiled:NO content:@"请输入wifi名称" text:[KenCarcorder getCurrentSSID]];
    [inputBg addSubview:_wifiName];
    
    UIImageView *pwdLogoV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"wifi_4_pwd"]];
    [inputBg addSubview:pwdLogoV];
    
    _wifiPwd = [self addTextFiled:NO content:@"请输入wifi密码" text:nil];
    _wifiPwd.secureTextEntry = YES;
    [inputBg addSubview:_wifiPwd];
    
    UIImageView *eyeV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"wifi_4_eye"]];
    [inputBg addSubview:eyeV];
    
    //autolayout
    [_wifiPwd mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(inputBg.mas_left).offset(kKenOffsetX(110));
        make.top.mas_equalTo(inputBg.height / 2);
        make.right.equalTo(inputBg.mas_right).offset(kKenOffsetX(-100));
        make.height.mas_equalTo(inputBg.height / 2);
    }];
    
    [eyeV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(inputBg.mas_right).offset(-15);
        make.centerY.equalTo(_wifiPwd.mas_centerY);
    }];
    
    [_wifiName mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_wifiPwd.mas_left);
        make.top.equalTo(inputBg.mas_top);
        make.height.mas_equalTo(inputBg.height / 2);
        make.right.equalTo(_wifiPwd.mas_right);
    }];
    
    [wifiLogoV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(kKenOffsetX(26));
        make.centerY.equalTo(_wifiName.mas_centerY);
    }];
    
    [pwdLogoV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(kKenOffsetX(26));
        make.centerY.equalTo(_wifiPwd.mas_centerY);
    }];
    
    //event
    @weakify(self)
    [eyeV clicked:^(UIView * _Nonnull view) {
        @strongify(self)
        self.wifiPwd.secureTextEntry = !self.wifiPwd.secureTextEntry;
    }];
    
    return inputBg;
}

- (UITextField *)addTextFiled:(BOOL)secure content:(NSString *)content text:(NSString *)text {
    UITextField *textField = [[UITextField alloc] init];
    textField.placeholder = content;
    if (![NSString isEmpty:text]) {
        textField.text = text;
    }
    textField.font = [UIFont appFontSize14];
    textField.clearButtonMode = UITextFieldViewModeAlways;
    textField.secureTextEntry = secure;
    textField.clearsOnBeginEditing = NO;
    textField.textAlignment = NSTextAlignmentLeft;
    textField.delegate = self;
    
    return textField;
}

@end
