//
//  KenLoginVC.m
//  KenCarcorder
//
//  Created by Ken.Liu on 2017/2/6.
//  Copyright © 2017年 Ken.Liu. All rights reserved.
//

#import "KenLoginVC.h"
#import "KenUserInfoDM.h"
#import "KenLoginDM.h"

@interface KenLoginVC ()<UITextFieldDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, strong) UITextField *accountTextField;
@property (nonatomic, strong) UITextField *pwdTextField;
@property (nonatomic, strong) UITextField *checkTextField;
@property (nonatomic, strong) UIImageView *rememberImg;
@property (nonatomic, strong) UIImageView *checkView;
@property (nonatomic, strong) UIView *inputV;
@property (nonatomic, strong) UIView *rememberV;
@property (nonatomic, strong) UIImageView *loginV;
@property (nonatomic, strong) UIImageView *registV;

@property (nonatomic, strong) UIButton *getCheckCodeBtn;
@property (nonatomic, strong) NSTimer *checkTimer;
@property (nonatomic, assign) NSInteger waitingTime;

@end

@implementation KenLoginVC

- (instancetype)init {
    self = [super init];
    if (self) {
        self.screenType = kKenViewScreenFull;
        
        KenUserInfoDM *userInfo = [KenUserInfoDM getInstance];
        if (userInfo == nil) {
            userInfo = [[KenUserInfoDM alloc] init];
            userInfo.rememberPwd = YES;
            [userInfo setInstance];
        }
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UIImageView *bgV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"login_bg"]];
    bgV.frame = (CGRect){0, 0, self.contentView.size};
    [self.contentView addSubview:bgV];
    
    UIImageView *icon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"login_icon"]];
    icon.center = CGPointMake(self.contentView.width / 2, icon.height / 2 + kKenOffsetY(170));
    [self.contentView addSubview:icon];
    
    _inputV = [self setInputV];
    _inputV.originY = icon.maxY + kKenOffsetY(76);
    
    //check
    _checkView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"login_input_bg"]];
    [_checkView setUserInteractionEnabled:YES];
    _checkView.frame = (CGRect){_inputV.originX, _inputV.maxY, _inputV.width, _inputV.height / 2};
    [self.contentView addSubview:_checkView];
    
    _checkTextField = [self addTextFiled:NO content:@"请输入验证码" text:nil parent:_checkView width:_checkView.width - 110];
    _checkTextField.height = _checkView.height - 8;
    
    _getCheckCodeBtn = [UIButton buttonWithImg:@"获取验证码" zoomIn:NO image:[UIImage imageNamed:@"login_send_code"]
                                      imagesec:[UIImage imageNamed:@"login_send_code_sec"]
                                        target:self action:@selector(getCodeBtnClicked)];
    [_getCheckCodeBtn.titleLabel setFont:[UIFont appFontSize11]];
    _getCheckCodeBtn.center = CGPointMake(_checkView.width - _getCheckCodeBtn.width / 2 - 10, _checkView.height / 2);
    [_checkView addSubview:_getCheckCodeBtn];
    
    ////
    [self initRememberWithOffsetY:_checkView.maxY];
    
    [self initBtnWithOffsetY:_checkView.maxY + kKenOffsetY(88)];
    
    [self initForgetPwd];
    
    [self showCheckView:NO];
    
    //tap gesture
    UITapGestureRecognizer *tapTouch = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    tapTouch.delegate = self;
    [self.contentView addGestureRecognizer:tapTouch];
}

#pragma mark - event
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
    
    [[KenServiceManager sharedServiceManager] accountloginWithName:_accountTextField.text pwd:_pwdTextField.text verCode:_checkTextField.text
                                                             start:^{
        [self showActivity];
    } successBlock:^(BOOL successful, NSString * _Nullable errMsg, KenLoginDM *loginDM) {
        [self hideActivity];
        if (loginDM.result == 2) {
            [self showAlert:@"" content:loginDM.message type:kToastUnkown];
            [self showCheckView:YES];
        } else {
            [self popViewController];
        }
    } failedBlock:^(NSInteger status, NSString * _Nullable errMsg) {
        [self hideActivity];
    }];
}

- (void)getCodeBtnClicked {
    
}

#pragma mark - textField
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if (textField == _accountTextField) {
        [UIView animateWithDuration:0.3f animations:^{
            self.contentView.frame = CGRectMake(0.f, -60, self.contentView.width, self.contentView.height);
        }];
    } else if (textField == _pwdTextField) {
        [UIView animateWithDuration:0.3f animations:^{
            self.contentView.frame = CGRectMake(0.f, -110, self.contentView.width, self.contentView.height);
        }];
    } else if (textField == _checkTextField) {
        [UIView animateWithDuration:0.3f animations:^{
            self.contentView.frame = CGRectMake(0.f, -170, self.contentView.width, self.contentView.height);
        }];
    }
}

- (void)hideKeyboard {
    [_accountTextField resignFirstResponder];
    [_pwdTextField resignFirstResponder];
    [_checkTextField resignFirstResponder];
    
    [UIView animateWithDuration:0.3f animations:^{
        self.contentView.frame = CGRectMake(0.f, 0, self.view.width, self.view.height);
    }];
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if ([touch.view isKindOfClass:[UIControl class]] ||
        [NSStringFromClass([touch.view class]) isEqualToString:@"UITableViewCellContentView"]) {
        return NO;
    }
    return YES;
}

#pragma mark - private method
- (UITextField *)addTextFiled:(BOOL)secure content:(NSString *)content text:(NSString *)text parent:(UIView *)parent width:(CGFloat)width{
    UITextField *textField = [[UITextField alloc]initWithFrame:CGRectMake(56, 4, width, parent.height / 2 - 8)];
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
        _loginV.originY = _checkView.maxY + kKenOffsetY(88);
    } else {
        _rememberV.originY = _inputV.maxY;
        _loginV.originY = _inputV.maxY + kKenOffsetY(88);
    }
    _registV.originY = _loginV.maxY + kKenOffset;
}

- (UIView *)setInputV {
    UIImageView *inputBg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"login_input_bg"]];
    inputBg.centerX = self.contentView.width / 2;
    [inputBg setUserInteractionEnabled:YES];
    [self.contentView addSubview:inputBg];

    //account
    UIImageView *account = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"login_user"]];
    account.center = CGPointMake(28, inputBg.height / 4);
    [inputBg addSubview:account];
    
    KenUserInfoDM *userInfo = [KenUserInfoDM getInstance];
    _accountTextField = [self addTextFiled:NO content:@"请输入用户名" text:userInfo.userName parent:inputBg width:inputBg.width - 110];
    _accountTextField.keyboardType = UIKeyboardTypeNumberPad;
    
    //password
    UIImageView *pwd = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"login_pwd"]];
    pwd.center = CGPointMake(28, inputBg.height * 0.75 - 4);
    [inputBg addSubview:pwd];
    
    _pwdTextField = [self addTextFiled:YES content:@"请输入密码" text:userInfo.userPwd parent:inputBg width:inputBg.width - 110];
    _pwdTextField.originY = inputBg.height / 2;
    
    return inputBg;
}

- (void)initRememberWithOffsetY:(CGFloat)offsetY {
    UIImage *img = [UIImage imageNamed:@"login_register_btn_bg"];
    _rememberV = [[UIView alloc] initWithFrame:(CGRect){(self.contentView.width - img.size.width) / 2, offsetY - kKenOffset, img.size}];
    _rememberV.backgroundColor = [UIColor clearColor];
    [self.contentView addSubview:_rememberV];
 
    KenUserInfoDM *user = [KenUserInfoDM getInstance];
    _rememberImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:user.rememberPwd ? @"login_remember_yes" : @"login_remember_no"]];
    _rememberImg.centerY = _rememberV.height / 2;
    [_rememberV addSubview:_rememberImg];
    
    UILabel *label = [UILabel labelWithTxt:@"记住密码" frame:(CGRect){_rememberImg.maxX + kKenOffset, 0, _rememberV.size}
                                      font:[UIFont appFontSize14] color:[UIColor whiteColor]];
    label.textAlignment = NSTextAlignmentLeft;
    [_rememberV addSubview:label];

    [_rememberV clicked:^(UIView * _Nonnull view) {
        user.rememberPwd = !user.rememberPwd;
        [_rememberImg setImage:[UIImage imageNamed:user.rememberPwd ? @"login_remember_yes" : @"login_remember_no"]];
        [user setInstance];
    }];
}

- (void)initBtnWithOffsetY:(CGFloat)offsetY {
    _loginV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"login_btn_bg"]];
    _loginV.center = CGPointMake(self.contentView.width / 2, _loginV.height / 2 + offsetY);
    [_loginV setUserInteractionEnabled:YES];
    [self.contentView addSubview:_loginV];
    
    UILabel *loginLabel = [UILabel labelWithTxt:@"登录" frame:(CGRect){0, 0, _loginV.size} font:[UIFont appFontSize17]
                                          color:[UIColor whiteColor]];
    [_loginV addSubview:loginLabel];
    @weakify(self)
    [loginLabel clicked:^(UIView * _Nonnull view) {
        @strongify(self)
        [self loginRequest];
    }];
    
    _registV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"login_register_btn_bg"]];
    _registV.center = CGPointMake(self.contentView.width / 2, _registV.height / 2 + CGRectGetMaxY(_loginV.frame) + kKenOffset);
    [_registV setUserInteractionEnabled:YES];
    [self.contentView addSubview:_registV];
    
    UILabel *registerLabel = [UILabel labelWithTxt:@"注册" frame:(CGRect){0, 0, _registV.size} font:[UIFont appFontSize17]
                                          color:[UIColor whiteColor]];
    [_registV addSubview:registerLabel];
    [registerLabel clicked:^(UIView * _Nonnull view) {
        
    }];
}

- (void)initForgetPwd {
    UIImageView *forgetBg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"login_forget_bg"]];
    forgetBg.frame = (CGRect){0, self.contentView.height - forgetBg.height, self.contentView.width, forgetBg.height};
    [self.contentView addSubview:forgetBg];
    
    UILabel *label = [UILabel labelWithTxt:@"忘记密码？" frame:(CGRect){0, 0, forgetBg.size} font:[UIFont appFontSize14]
                                          color:[UIColor whiteColor]];
    [forgetBg addSubview:label];
    [label clicked:^(UIView * _Nonnull view) {
        
    }];
}

@end
