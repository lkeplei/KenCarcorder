//
//  KenCorrectDevicePwdVC.m
//  KenCarcorder
//
//  Created by 邱根友 on 2017/4/15.
//  Copyright © 2017年 Ken.Liu. All rights reserved.
//

#import "KenCorrectDevicePwdVC.h"
#import "KenDeviceDM.h"

@interface KenCorrectDevicePwdVC ()<UIAlertViewDelegate, UITextFieldDelegate>

@property (nonatomic, strong) KenDeviceDM *deviceInfo;
@property (nonatomic, strong) UITextField *pwdTextField;

@end

@implementation KenCorrectDevicePwdVC

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
    [self setNavTitle:@"更正密码"];
    
    _pwdTextField = [self addTextFiled:@"请输入更正密码" offY:100];
    
    UIButton *showBtn = [UIButton buttonWithImg:@"显示密码" zoomIn:NO image:nil imagesec:nil target:self
                                         action:@selector(showBtnClicked)];
    [showBtn setBackgroundColor:[UIColor appMainColor]];
    showBtn.layer.cornerRadius = 6;
    showBtn.frame = CGRectMake(MainScreenWidth * 0.05, CGRectGetMaxY(_pwdTextField.frame) + 35, MainScreenWidth  * 0.9, 40);
    [self.view addSubview:showBtn];
    
    UIButton *confirmBtn = [UIButton buttonWithImg:@"确认修改" zoomIn:NO image:nil imagesec:nil target:self
                                            action:@selector(confirmBtnClicked)];
    [confirmBtn setBackgroundColor:[UIColor appMainColor]];
    confirmBtn.layer.cornerRadius = 6;
    confirmBtn.frame = (CGRect){showBtn.originX, CGRectGetMaxY(showBtn.frame) + 20, showBtn.size};
    [self.view addSubview:confirmBtn];
}

- (UITextField *)addTextFiled:(NSString *)content offY:(CGFloat)offY {
    UITextField *textField = [[UITextField alloc]initWithFrame:CGRectMake(MainScreenWidth * 0.05, offY, MainScreenWidth * 0.9, 40)];
    textField.placeholder = content;
    textField.font = [UIFont appFontSize14];
    textField.clearButtonMode = UITextFieldViewModeAlways;
    textField.secureTextEntry = NO;
    textField.clearsOnBeginEditing = NO;
    textField.textAlignment = NSTextAlignmentLeft;
    textField.delegate = self;
    [textField setBackgroundColor:[UIColor whiteColor]];
    
    textField.leftView = [[UIView alloc] initWithFrame:(CGRect){0, 0, 15, textField.height}];
    textField.leftViewMode = UITextFieldViewModeAlways;
    
    textField.layer.cornerRadius = 6;
    textField.layer.masksToBounds = YES;
    textField.layer.borderWidth = 1;
    textField.layer.borderColor = [[UIColor appSepLineColor] CGColor];
    
    [self.view addSubview:textField];
    
    return textField;
}

#pragma mark - button
- (void)confirmBtnClicked {
    if ([_pwdTextField.text length] > 0) {
        [[KenUserInfoDM sharedInstance] saveDevicePwd:[_pwdTextField text] device:_deviceInfo];
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        [self showToastWithMsg:@"请输入更正密码"];
    }
}

- (void)showBtnClicked {
    UIAlertView *dialog = [[UIAlertView alloc] initWithTitle:@"请输入登录密码" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定",nil];
    [dialog setAlertViewStyle:UIAlertViewStylePlainTextInput];
    [dialog show];
}

#pragma mark - alert delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        UITextField *pwdTextField = [alertView textFieldAtIndex:0];
        NSString *pwd = [pwdTextField text];
        if ([pwd isEqualToString:[KenUserInfoDM sharedInstance].userPwd]) {
            [_pwdTextField setText:_deviceInfo.pwd];
        } else {
            [self showToastWithMsg:@"密码输入错误"];
        }
    }
}

#pragma mark - textField
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    return YES;
}

@end
