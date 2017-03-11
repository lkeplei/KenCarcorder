//
//  KenRegisterVC.m
//  KenCarcorder
//
//  Created by hzyouda on 2017/2/11.
//  Copyright © 2017年 Ken.Liu. All rights reserved.
//

#import "KenRegisterVC.h"
#import "KenUserInfoDM.h"

@interface KenRegisterVC ()<UITextFieldDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, strong) UITextField *phoneTextField;
@property (nonatomic, strong) UITextField *verCodeTextField;
@property (nonatomic, strong) UITextField *pwdTextField;
@property (nonatomic, strong) UITextField *pwdConfirmTextField;

@property (nonatomic, strong) UIButton *getCheckCodeBtn;
@property (nonatomic, strong) NSTimer *checkTimer;
@property (nonatomic, assign) NSInteger waitingTime;

@end

@implementation KenRegisterVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setNavTitle:@"注册"];
    
    UIImageView *bgV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"pwd_bg"]];
    bgV.frame = (CGRect){0, 0, self.contentView.size};
    [self.contentView addSubview:bgV];
    
    [self initOne];
    [self initTwo];
    
    //tap gesture
    UITapGestureRecognizer *tapTouch = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    tapTouch.delegate = self;
    [self.contentView addGestureRecognizer:tapTouch];
}

#pragma mark - event
- (void)hideKeyboard {
    [_phoneTextField resignFirstResponder];
    [_verCodeTextField resignFirstResponder];
    [_pwdTextField resignFirstResponder];
    [_pwdConfirmTextField resignFirstResponder];
}

- (void)getCodeBtnClicked:(UIButton *)button {
    if ([_phoneTextField.text length] <= 0){
        [self showAlert:@"" content:@"手机号不能为空"];
        return;
    }
    if ([_phoneTextField.text length] != 11) {
        [self showAlert:@"" content:@"请输入正确的手机号"];
        return;
    }
    
    [button setEnabled:NO];
    _waitingTime = kAppCheckCodeWaiteTime;
    [_getCheckCodeBtn setTitle:[NSString stringWithFormat:@"获取验证码(%zd)", _waitingTime] forState:UIControlStateNormal];
    _checkTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(checkCodeTimerOut) userInfo:nil repeats:YES];
    
    [[KenServiceManager sharedServiceManager] accountGetVerCode:_phoneTextField.text start:^{
        [self showActivity];
    } successBlock:^(BOOL successful, NSString * _Nullable errMsg, id  _Nullable responseData) {
        [self hideActivity];
        if (successful) {
            
        } else {
            [self showAlert:@"" content:errMsg];
        }
    } failedBlock:^(NSInteger status, NSString * _Nullable errMsg) {
        [self hideActivity];
    }];
}

- (void)checkCodeTimerOut {
    _waitingTime--;
    if (_waitingTime > 0) {
        [_getCheckCodeBtn setTitle:[NSString stringWithFormat:@"获取验证码(%zd)", _waitingTime] forState:UIControlStateNormal];
    } else {
        [_getCheckCodeBtn setEnabled:YES];
        [_getCheckCodeBtn setTitle:@"获取验证码" forState:UIControlStateNormal];
        
        [_checkTimer invalidate];
        _checkTimer = nil;
    }
}

- (void)registUser {
    if ([_phoneTextField.text length] <= 0) {
        [self showAlert:@"" content:@"手机号不能为空"];
        return;
    }
    if ([_phoneTextField.text length] != 11) {
        [self showAlert:@"" content:@"请输入正确的手机号"];
        return;
    }
    if ([_verCodeTextField.text length] != 6) {
        [self showAlert:@"" content:@"请输入正确的验证码"];
        return;
    }
    if ([_pwdTextField.text length] <= 0) {
        [self showAlert:@"" content:@"密码不能为空"];
        return;
    }
    if ([_pwdTextField.text isEqualToString:_pwdConfirmTextField.text]) {
        [[KenServiceManager sharedServiceManager] accountRegist:_phoneTextField.text pwd:_pwdTextField.text verCode:_verCodeTextField.text
                                                          reset:NO start:^{
            [self showActivity];
        } successBlock:^(BOOL successful, NSString * _Nullable errMsg, id  _Nullable responseData) {
            [self hideActivity];
            
            if (successful) {
                [self popToRootViewControllerAnimated:YES];
            }
        } failedBlock:^(NSInteger status, NSString * _Nullable errMsg) {
            [self hideActivity];
        }];
    } else {
        [self showAlert:@"" content:@"确认密码与密码不一致"];
    }
}

#pragma mark - private method
- (void)initOne {
    UIImageView *inputBg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"pwd_input_bg"]];
    [inputBg setUserInteractionEnabled:YES];
    inputBg.width = self.contentView.width;
    [self.contentView addSubview:inputBg];
    
    UILabel *phone = [UILabel labelWithTxt:@"手机号" frame:(CGRect){0, 0, kKenOffsetX(160), inputBg.height / 2}
                                      font:[UIFont appFontSize15] color:[UIColor appWhiteTextColor]];
    [inputBg addSubview:phone];
    
    _phoneTextField = [self addTextFiled:NO content:@"请输入您的手机号码" text:nil
                                    size:(CGSize){inputBg.width - kKenOffsetX(180) * 2, 30}];
    _phoneTextField.centerY = phone.centerY;
    [inputBg addSubview:_phoneTextField];
    
    UILabel *verCode = [UILabel labelWithTxt:@"验证码" frame:phone.frame font:[UIFont appFontSize15] color:[UIColor appWhiteTextColor]];
    verCode.originY = phone.maxY;
    [inputBg addSubview:verCode];
    
    _verCodeTextField = [self addTextFiled:NO content:@"请输入验证码" text:nil size:(CGSize){inputBg.width - kKenOffsetX(180) * 2, 40}];
    _verCodeTextField.centerY = verCode.centerY;
    [inputBg addSubview:_verCodeTextField];
    
    //验证码
    _getCheckCodeBtn = [UIButton buttonWithImg:@"获取验证码" zoomIn:NO image:[UIImage imageNamed:@"login_send_code"]
                                      imagesec:[UIImage imageNamed:@"login_send_code_sec"]
                                        target:self action:@selector(getCodeBtnClicked:)];
    [_getCheckCodeBtn.titleLabel setFont:[UIFont appFontSize11]];
    _getCheckCodeBtn.center = CGPointMake(inputBg.width - _getCheckCodeBtn.width / 2 - 10, inputBg.height * 0.75);
    [inputBg addSubview:_getCheckCodeBtn];
}

- (void)initTwo {
    UIImageView *inputBg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"pwd_confirm_bg"]];
    [inputBg setUserInteractionEnabled:YES];
    inputBg.width = self.contentView.width;
    inputBg.originY = inputBg.height + kKenOffset;
    [self.contentView addSubview:inputBg];
    
    UILabel *phone = [UILabel labelWithTxt:@"设置密码" frame:(CGRect){15, 0, kKenOffsetX(160), inputBg.height / 2}
                                      font:[UIFont appFontSize15] color:[UIColor appWhiteTextColor]];
    phone.textAlignment = NSTextAlignmentLeft;
    [inputBg addSubview:phone];
    
    _pwdTextField = [self addTextFiled:YES content:@"输入密码" text:nil
                                    size:(CGSize){inputBg.width - kKenOffsetX(210) * 2, 30}];
    _pwdTextField.centerY = phone.centerY;
    _pwdTextField.originX = kKenOffsetX(210);
    [inputBg addSubview:_pwdTextField];
    
    UILabel *verCode = [UILabel labelWithTxt:@"确认密码" frame:phone.frame font:[UIFont appFontSize15] color:[UIColor appWhiteTextColor]];
    verCode.originY = phone.maxY;
    verCode.textAlignment = NSTextAlignmentLeft;
    [inputBg addSubview:verCode];
    
    _pwdConfirmTextField = [self addTextFiled:YES content:@"再次输入密码" text:nil size:(CGSize){inputBg.width - kKenOffsetX(210) * 2, 40}];
    _pwdConfirmTextField.centerY = verCode.centerY;
    _pwdConfirmTextField.originX = kKenOffsetX(210);
    [inputBg addSubview:_pwdConfirmTextField];
    
    //验证码
    UILabel *confirmLabel = [UILabel labelWithTxt:@"注册" frame:(CGRect){15, inputBg.maxY + kKenOffset, self.contentView.width - 30, 44}
                                             font:[UIFont appFontSize17] color:[UIColor colorWithHexString:@"1969DB"]];
    confirmLabel.backgroundColor = [UIColor whiteColor];
    confirmLabel.layer.cornerRadius = 6;
    [confirmLabel.layer setMasksToBounds:YES];
    [self.contentView addSubview:confirmLabel];
    
    @weakify(self)
    [confirmLabel clicked:^(UIView * _Nonnull view) {
        @strongify(self)
        [self registUser];
    }];
}

- (UITextField *)addTextFiled:(BOOL)secure content:(NSString *)content text:(NSString *)text size:(CGSize)size {
    UITextField *textField = [[UITextField alloc]initWithFrame:CGRectMake(kKenOffsetX(180), 0, size.width, size.height / 2)];
    textField.placeholder = content;
    if ([NSString isNotEmpty:text]) {
        textField.text = text;
    }
    textField.font = [UIFont appFontSize14];
    textField.clearButtonMode = UITextFieldViewModeAlways;
    textField.secureTextEntry = secure;
    textField.clearsOnBeginEditing = NO;
    textField.textAlignment = NSTextAlignmentLeft;
    textField.delegate = self;
    textField.textColor = [UIColor appWhiteTextColor];
    
    return textField;
}

@end
