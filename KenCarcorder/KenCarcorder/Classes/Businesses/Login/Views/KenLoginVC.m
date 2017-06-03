//
//  KenLoginVC.m
//  KenCarcorder
//
//  Created by Ken.Liu on 2017/2/6.
//  Copyright © 2017年 Ken.Liu. All rights reserved.
//

#import "KenLoginVC.h"
#import "KenLoginDM.h"

@interface KenLoginVC ()

@property (nonatomic, strong) UITextField *accountTextField;
@property (nonatomic, strong) UITextField *pwdTextField;
@property (nonatomic, strong) UITextField *checkTextField;
@property (nonatomic, strong) UIImageView *rememberImg;
@property (nonatomic, strong) UIView *checkView;
@property (nonatomic, strong) UIView *inputV;
@property (nonatomic, strong) UIView *rememberV;
@property (nonatomic, strong) UIButton *loginBtn;
@property (nonatomic, strong) UIButton *registBtn;
@property (nonatomic, strong) UILabel *forgetPwdL;

@property (nonatomic, strong) UIButton *getCheckCodeBtn;
@property (nonatomic, strong) NSTimer *checkTimer;
@property (nonatomic, assign) NSInteger waitingTime;

@end

@implementation KenLoginVC

- (instancetype)init {
    self = [super init];
    if (self) {
        self.screenType = kKenViewScreenFull;
        self.hideBackBtn = YES;
        
        KenUserInfoDM *userInfo = [KenUserInfoDM getInstance];
        if (userInfo == nil) {
            userInfo = [KenUserInfoDM initWithJsonDictionary:@{}];
            userInfo.rememberPwd = YES;
            [userInfo setInstance];
        }
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.contentView.backgroundColor = [UIColor colorWithHexString:@"#343642"];
    
    UIImageView *icon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"about_icon"]];
    icon.center = CGPointMake(self.contentView.width / 2, icon.height / 2 + kKenOffsetY(140));
    [self.contentView addSubview:icon];
    
    _inputV = [self setInputV];
    _inputV.originY = icon.maxY + kKenOffsetY(24);
    
    //check
    [self.contentView addSubview:self.checkView];
    
    ////
    [self initRememberWithOffsetY:_checkView.maxY];
    
    self.loginBtn.originY = _checkView.maxY + kKenOffsetY(100);
    self.registBtn.originY = self.loginBtn.maxY + 10;
    
    [self showCheckView:NO];

    //测试先自动登录
    [self loginRequest];
}

#pragma mark - event
- (void)registBtnClicked {
    [self pushViewControllerString:@"KenRegisterVC" animated:YES];
}

- (void)loginRequest {
    if ([_accountTextField.text length] <= 0) {
        [self showAlert:@"" content:@"请输入用户名/手机号" type:kToastUnkown];
        return;
    }
    if ([_pwdTextField.text length] <= 0) {
        [self showAlert:@"" content:@"请输入密码" type:kToastUnkown];
        return;
    }
    if (![_checkView isHidden] && [_checkTextField.text length] != 6) {
        [self showAlert:@"" content:@"请输入验证码" type:kToastUnkown];
        return;
    }
    
    [[KenServiceManager sharedServiceManager] accountLoginWithName:_accountTextField.text pwd:_pwdTextField.text verCode:_checkTextField.text
                                                             start:^{
        [self showActivity];
    } successBlock:^(BOOL successful, NSString * _Nullable errMsg, KenLoginDM *loginDM) {
        [self hideActivity];
        if (loginDM.result == 2) {
            [self showAlert:@"" content:loginDM.message type:kToastUnkown];
            [self showCheckView:YES];
        } else {
            [self popViewControllerAnimated:YES];
        }
    } failedBlock:^(NSInteger status, NSString * _Nullable errMsg) {
        [self hideActivity];
        
        [self showToastWithMsg:errMsg];
    }];
}

- (void)getCodeBtnClicked:(UIButton *)button {
    if ([_accountTextField.text length] <= 0){
        [self showAlert:@"" content:@"手机号不能为空"];
        return;
    }
    if ([_accountTextField.text length] != 11) {
        [self showAlert:@"" content:@"请输入正确的手机号"];
        return;
    }
    
    [button setEnabled:NO];
    _waitingTime = kAppCheckCodeWaiteTime;
    [_getCheckCodeBtn setTitle:[NSString stringWithFormat:@"获取验证码(%zd)", _waitingTime] forState:UIControlStateNormal];
    _checkTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(checkCodeTimerOut) userInfo:nil repeats:YES];
    
    [[KenServiceManager sharedServiceManager] accountGetVerCode:_accountTextField.text start:^{
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

#pragma mark - private method
- (UITextField *)addTextFiled:(BOOL)secure content:(NSString *)content text:(NSString *)text parent:(UIView *)parent width:(CGFloat)width {
    UITextField *textField = [[UITextField alloc]initWithFrame:CGRectMake(80, 2, width, parent.height / 2 - 4)];
    textField.placeholder = content;
    if ([NSString isNotEmpty:text]) {
        textField.text = text;
    }
    textField.font = [UIFont appFontSize14];
    textField.clearButtonMode = UITextFieldViewModeAlways;
    textField.secureTextEntry = secure;
    textField.clearsOnBeginEditing = NO;
    textField.textAlignment = NSTextAlignmentLeft;
    textField.textColor = [UIColor appGrayTextColor];
    [textField setValue:[UIColor colorWithHexString:@"#626262"] forKeyPath:@"_placeholderLabel.textColor"];
    [parent addSubview:textField];
    
    return textField;
}

- (void)showCheckView:(BOOL)show {
    BOOL isShow = !_checkView.isHidden;
    if (isShow == show) {
        return;
    }
    
    [_checkView setHidden:!show];
    
    if (show) {
        _rememberV.originY = _checkView.maxY;
        _forgetPwdL.originY = _checkView.maxY;
        _loginBtn.originY = _checkView.maxY + kKenOffsetY(88);
    } else {
        _rememberV.originY = _inputV.maxY;
        _forgetPwdL.originY = _inputV.maxY;
        _loginBtn.originY = _inputV.maxY + kKenOffsetY(88);
    }
    _registBtn.originY = _loginBtn.maxY + kKenOffset;
}

- (UIView *)setInputV {
    UIView *inputBg = [[UIView alloc] initWithFrame:(CGRect){0, 0, self.contentView.width, 110}];
    [inputBg setUserInteractionEnabled:YES];
    [self.contentView addSubview:inputBg];

    //account
    UIImageView *account = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"login_user"]];
    account.center = CGPointMake(50, inputBg.height / 4);
    [inputBg addSubview:account];
    
    UIView *line = [[UIView alloc] initWithFrame:(CGRect){10, inputBg.height / 2 - 10, self.contentView.width - 20, 0.5}];
    line.backgroundColor = [UIColor colorWithHexString:@"#626262"];
    [inputBg addSubview:line];
    
    KenUserInfoDM *userInfo = [KenUserInfoDM getInstance];
    _accountTextField = [self addTextFiled:NO content:@"请输入用户名或手机号" text:userInfo.userName parent:inputBg width:inputBg.width - 110];
    _accountTextField.keyboardType = UIKeyboardTypeNumberPad;
    
    //password
    UIImageView *pwd = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"login_pwd"]];
    pwd.center = CGPointMake(50, inputBg.height * 0.75 - 4);
    [inputBg addSubview:pwd];
    
    _pwdTextField = [self addTextFiled:YES content:@"请输入密码" text:userInfo.userPwd parent:inputBg width:inputBg.width - 110];
    _pwdTextField.originY = inputBg.height / 2;
    
    UIView *line1 = [[UIView alloc] initWithFrame:(CGRect){10, inputBg.height - 10, self.contentView.width - 20, 0.5}];
    line1.backgroundColor = [UIColor colorWithHexString:@"#626262"];
    [inputBg addSubview:line1];
    
    return inputBg;
}

- (void)initRememberWithOffsetY:(CGFloat)offsetY {
    _rememberV = [[UIView alloc] initWithFrame:(CGRect){self.loginBtn.originX, offsetY - kKenOffset, self.loginBtn.width / 2, self.loginBtn.height}];
    _rememberV.backgroundColor = [UIColor clearColor];
    [self.contentView addSubview:_rememberV];
 
    KenUserInfoDM *user = [KenUserInfoDM getInstance];
    _rememberImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:user.rememberPwd ? @"login_remember_yes" : @"login_remember_no"]];
    _rememberImg.centerY = _rememberV.height / 2;
    [_rememberV addSubview:_rememberImg];
    
    UILabel *label = [UILabel labelWithTxt:@"记住密码" frame:(CGRect){_rememberImg.maxX + kKenOffset, 0, _rememberV.size}
                                      font:[UIFont appFontSize14] color:[UIColor colorWithHexString:@"#626262"]];
    label.textAlignment = NSTextAlignmentLeft;
    [_rememberV addSubview:label];

    [_rememberV clicked:^(UIView * _Nonnull view) {
        user.rememberPwd = !user.rememberPwd;
        [_rememberImg setImage:[UIImage imageNamed:user.rememberPwd ? @"login_remember_yes" : @"login_remember_no"]];
        [user setInstance];
    }];
    
    _forgetPwdL = [UILabel labelWithTxt:@"忘记密码？" frame:(CGRect){_rememberV.maxX, _rememberV.originY, _rememberV.size} font:[UIFont appFontSize14]
                                  color:[UIColor colorWithHexString:@"#626262"]];
    _forgetPwdL.textAlignment = NSTextAlignmentRight;
    [self.contentView addSubview:_forgetPwdL];
    @weakify(self)
    [_forgetPwdL clicked:^(UIView * _Nonnull view) {
        @strongify(self)
        [self pushViewControllerString:@"KenForgetPwdVC" animated:YES];
    }];
}

#pragma mark - getter setter 
- (UIView *)checkView {
    if (_checkView == nil) {
        _checkView = [[UIView alloc] initWithFrame:(CGRect){_inputV.originX, _inputV.maxY, _inputV.width, _inputV.height / 2}];
        [_checkView setUserInteractionEnabled:YES];
        [self.contentView addSubview:_checkView];
        
        UIImageView *account = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"login_code"]];
        account.center = CGPointMake(50, _checkView.height / 2);
        [_checkView addSubview:account];
        
        _checkTextField = [self addTextFiled:NO content:@"请输入验证码" text:nil parent:_checkView width:_checkView.width - 110];
        _checkTextField.height = _checkView.height - 4;
        
        _getCheckCodeBtn = [UIButton buttonWithImg:@"获取验证码" zoomIn:NO image:[UIImage imageNamed:@"login_send_code"]
                                          imagesec:[UIImage imageNamed:@"login_send_code_sec"]
                                            target:self action:@selector(getCodeBtnClicked:)];
        [_getCheckCodeBtn.titleLabel setFont:[UIFont appFontSize11]];
        _getCheckCodeBtn.center = CGPointMake(_checkView.width - _getCheckCodeBtn.width / 2 - 10, _checkView.height / 2 - 6);
        [_checkView addSubview:_getCheckCodeBtn];
        
        UIView *line = [[UIView alloc] initWithFrame:(CGRect){10, _checkView.height - 10, self.contentView.width - 20, 0.5}];
        line.backgroundColor = [UIColor colorWithHexString:@"#626262"];
        [_checkView addSubview:line];
    }
    return _checkView;
}
- (UIButton *)loginBtn {
    if (_loginBtn == nil) {
        _loginBtn = [UIButton buttonWithImg:@"登录" zoomIn:NO image:nil imagesec:nil target:self action:@selector(loginRequest)];
        _loginBtn.backgroundColor = [UIColor colorWithHexString:@"#454752"];
        _loginBtn.layer.cornerRadius = 4;
        _loginBtn.frame = (CGRect){40, 0, self.contentView.width - 80, 40};
        [self.contentView addSubview:_loginBtn];
    }
    return _loginBtn;
}

- (UIButton *)registBtn {
    if (_registBtn == nil) {
        _registBtn = [UIButton buttonWithImg:@"注册" zoomIn:NO image:nil imagesec:nil target:self action:@selector(registBtnClicked)];
        _registBtn.backgroundColor = [UIColor colorWithHexString:@"#454752"];
        _registBtn.layer.cornerRadius = 4;
        _registBtn.frame = (CGRect){40, 0, _loginBtn.size};
        [self.contentView addSubview:_registBtn];
    }
    return _registBtn;
}

@end
