//
//  KenDeviceChangePwdVC.m
//  KenCarcorder
//
//  Created by 邱根友 on 2017/4/15.
//  Copyright © 2017年 Ken.Liu. All rights reserved.
//

#import "KenDeviceChangePwdVC.h"
#import "KenDeviceDM.h"

@interface KenDeviceChangePwdVC ()<UITextFieldDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, strong) KenDeviceDM *deviceInfo;
@property (nonatomic, strong) UITextField *oldTextField;
@property (nonatomic, strong) UITextField *pwdTextField;
@property (nonatomic, strong) UITextField *confirmTextField;

@end

@implementation KenDeviceChangePwdVC

#pragma mark - life cycle
- (instancetype)initWithDevice:(KenDeviceDM *)device {
    self = [super init];
    if (self) {
        _deviceInfo = device;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setNavTitle:@"修改密码"];

    _oldTextField = [self addTextFiled:@"请输入原密码" offY:100];
    _pwdTextField = [self addTextFiled:@"请输入新密码" offY:CGRectGetMaxY(_oldTextField.frame) + 15];
    _confirmTextField = [self addTextFiled:@"确认新密码" offY:CGRectGetMaxY(_pwdTextField.frame) + 15];
    
    UIButton *confirmBtn = [UIButton buttonWithImg:@"确认修改" zoomIn:NO image:nil imagesec:nil target:self
                                            action:@selector(confirmBtnClicked)];
    [confirmBtn setBackgroundColor:[UIColor colorWithHexString:@"#419FFF"]];
    confirmBtn.layer.cornerRadius = 6;
    confirmBtn.frame = CGRectMake(MainScreenWidth * 0.05, CGRectGetMaxY(_confirmTextField.frame) + 35, MainScreenWidth * 0.9, 40);
    [self.view addSubview:confirmBtn];
    
    //tap gesture
    UITapGestureRecognizer *tapTouch = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    tapTouch.delegate = self;
    [self.view addGestureRecognizer:tapTouch];
}

- (UITextField *)addTextFiled:(NSString *)content offY:(CGFloat)offY {
    UITextField *textField = [[UITextField alloc]initWithFrame:CGRectMake(MainScreenWidth * 0.05, offY, MainScreenWidth * 0.9, 40)];
    textField.placeholder = content;
    textField.font = [UIFont appFontSize14];
    textField.clearButtonMode = UITextFieldViewModeAlways;
    textField.secureTextEntry = YES;
    textField.clearsOnBeginEditing = NO;
    textField.textAlignment = NSTextAlignmentLeft;
    textField.delegate = self;
    [textField setBackgroundColor:[UIColor whiteColor]];
    
    textField.leftView = [[UIView alloc] initWithFrame:(CGRect){0, 0, 15, textField.height}];
    textField.leftViewMode = UITextFieldViewModeAlways;
    
    textField.layer.cornerRadius = 6;
    textField.layer.masksToBounds = YES;
    textField.layer.borderWidth = 1;
    textField.layer.borderColor = [UIColor appSepLineColor].CGColor;
    
    [self.view addSubview:textField];
    
    return textField;
}

- (void)confirmBtnClicked {
    if ([_oldTextField.text length] > 0) {
        if ([_oldTextField.text isEqualToString:_deviceInfo.pwd]) {
            if ([_pwdTextField.text length] > 0) {
                if ([_pwdTextField.text isEqualToString:_confirmTextField.text]) {
                    [self changePwd];
                } else {
                    [self showToastWithMsg:@"两次密码不致"];
                }
            } else {
                [self showToastWithMsg:@"请输入新密码"];
            }
        } else {
            [self showToastWithMsg:@"旧密码错误"];
        }
    } else {
        [self showToastWithMsg:@"请输入旧密码"];
    }
}

- (void)changePwd {
    [[KenServiceManager sharedServiceManager] deviceRepwd:_deviceInfo pwd:[_pwdTextField text] start:^{
        [self showActivity];
    } success:^(BOOL successful, NSString * _Nullable errMsg, id  _Nullable responseData) {
        [self hideActivity];
        
        [[KenUserInfoDM getInstance] saveDevicePwd:[_pwdTextField text] device:_deviceInfo];
        [self popViewController];
    } failed:^(NSInteger status, NSString * _Nullable errMsg) {
        [self hideActivity];
        [self showToastWithMsg:@"当前服务器繁忙，请稍后重试"];
    }];
}

#pragma mark - textField
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    
}

- (void)hideKeyboard {
    [_oldTextField resignFirstResponder];
    [_pwdTextField resignFirstResponder];
    [_confirmTextField resignFirstResponder];
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if ([touch.view isKindOfClass:[UIControl class]] ||
        [NSStringFromClass([touch.view class]) isEqualToString:@"UITableViewCellContentView"]) {
        return NO;
    }
    return YES;
}
@end
