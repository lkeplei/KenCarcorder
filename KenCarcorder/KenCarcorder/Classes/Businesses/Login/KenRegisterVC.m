//
//  KenRegisterVC.m
//  KenCarcorder
//
//  Created by hzyouda on 2017/2/11.
//  Copyright © 2017年 Ken.Liu. All rights reserved.
//

#import "KenRegisterVC.h"

@interface KenRegisterVC ()

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

    [self initOne];
    [self initTwo];
}

#pragma mark - event
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
    UIView *inputBg = [[UIView alloc] initWithFrame:(CGRect){0, 0, self.contentView.width, 100}];
    inputBg.backgroundColor = [UIColor whiteColor];
    [inputBg setUserInteractionEnabled:YES];
    [self.contentView addSubview:inputBg];
    
    KenUserInfoDM *userInfo = [KenUserInfoDM getInstance];
    _phoneTextField = [self addTextFiled:NO content:@"请输入您的手机号码"
                                    text:[NSString isEmpty:userInfo.userName] ? nil : userInfo.userName
                                   frame:(CGRect){0, 0, self.contentView.width, 50}];
    [inputBg addSubview:_phoneTextField];
    
    UIView *line = [[UIView alloc] initWithFrame:(CGRect){10, 50, inputBg.width, 0.5}];
    line.backgroundColor = [UIColor appSepLineColor];
    [inputBg addSubview:line];
    
    _verCodeTextField = [self addTextFiled:NO content:@"请输入验证码" text:nil frame:(CGRect){0, _phoneTextField.maxY, _phoneTextField.size}];
    [inputBg addSubview:_verCodeTextField];
    
    //验证码
    _getCheckCodeBtn = [UIButton buttonWithImg:@"获取验证码" zoomIn:NO image:[UIImage imageNamed:@"login_send_code"]
                                      imagesec:[UIImage imageNamed:@"login_send_code_sec"]
                                        target:self action:@selector(getCodeBtnClicked:)];
    [_getCheckCodeBtn.titleLabel setFont:[UIFont appFontSize11]];
    _getCheckCodeBtn.center = CGPointMake(self.contentView.width - _getCheckCodeBtn.width / 2 - 10, 75);
    [inputBg addSubview:_getCheckCodeBtn];
}

- (void)initTwo {
    UIView *inputBg = [[UIView alloc] initWithFrame:(CGRect){0, 110, self.contentView.width, 100}];
    inputBg.backgroundColor = [UIColor whiteColor];
    [inputBg setUserInteractionEnabled:YES];
    [self.contentView addSubview:inputBg];
    
    _pwdTextField = [self addTextFiled:YES content:@"输入密码" text:nil frame:(CGRect){0, 0, self.contentView.width, 50}];
    [inputBg addSubview:_pwdTextField];
    
    UIView *line = [[UIView alloc] initWithFrame:(CGRect){10, 50, inputBg.width, 0.5}];
    line.backgroundColor = [UIColor appSepLineColor];
    [inputBg addSubview:line];
    
    _pwdConfirmTextField = [self addTextFiled:YES content:@"再次输入密码" text:nil frame:(CGRect){0, _phoneTextField.maxY, _phoneTextField.size}];
    [inputBg addSubview:_pwdConfirmTextField];
    
    //button
    UIButton *finishBtn = [UIButton buttonWithImg:@"提交" zoomIn:NO image:nil imagesec:nil target:self action:@selector(registUser)];
    finishBtn.backgroundColor = [UIColor appMainColor];
    finishBtn.layer.cornerRadius = 4;
    finishBtn.frame = (CGRect){50, inputBg.maxY + 60, self.contentView.width - 100, 44};
    [self.contentView addSubview:finishBtn];
}

- (UITextField *)addTextFiled:(BOOL)secure content:(NSString *)content text:(NSString *)text frame:(CGRect)frame {
    UITextField *textField = [[UITextField alloc]initWithFrame:frame];
    textField.placeholder = content;
    if ([NSString isNotEmpty:text]) {
        textField.text = text;
    }
    textField.font = [UIFont appFontSize14];
    textField.clearButtonMode = UITextFieldViewModeAlways;
    textField.secureTextEntry = secure;
    textField.clearsOnBeginEditing = NO;
    textField.textAlignment = NSTextAlignmentLeft;
    textField.textColor = [UIColor appBlackTextColor];
    
    textField.leftView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 15, 0)];
    //设置显示模式为永远显示(默认不显示)
    textField.leftViewMode = UITextFieldViewModeAlways;
    
    return textField;
}

@end
