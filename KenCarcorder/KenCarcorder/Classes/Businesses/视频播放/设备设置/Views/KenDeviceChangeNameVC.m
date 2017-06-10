//
//  KenDeviceChangeNameVC.m
//  KenCarcorder
//
//  Created by 邱根友 on 2017/4/15.
//  Copyright © 2017年 Ken.Liu. All rights reserved.
//

#import "KenDeviceChangeNameVC.h"
#import "KenDeviceDM.h"

#import <iconv.h>

@interface KenDeviceChangeNameVC ()<UITextFieldDelegate>

@property (nonatomic, strong) KenDeviceDM *deviceInfo;
@property (nonatomic, strong) UITextField *nameTextField;

@end

@implementation KenDeviceChangeNameVC

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
    [self setNavTitle:@"设备名称"];

    _nameTextField = [self addTextFiled:_deviceInfo.name offY:100];
    
    UIButton *confirmBtn = [UIButton buttonWithImg:@"确认修改" zoomIn:NO image:nil imagesec:nil target:self
                                            action:@selector(confirmBtnClicked)];
    [confirmBtn setBackgroundColor:[UIColor appMainColor]];
    confirmBtn.layer.cornerRadius = 6;
    confirmBtn.frame = CGRectMake(MainScreenWidth * 0.05, CGRectGetMaxY(_nameTextField.frame) + 35, MainScreenWidth * 0.9, 40);
    [self.view addSubview:confirmBtn];
}

- (UITextField *)addTextFiled:(NSString *)content offY:(CGFloat)offY {
    UITextField *textField = [[UITextField alloc]initWithFrame:CGRectMake(MainScreenWidth * 0.05, offY, MainScreenWidth * 0.9, 40)];
    textField.text = content;
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
    textField.layer.borderColor = [UIColor appSepLineColor].CGColor;
    
    [self.view addSubview:textField];
    
    return textField;
}

#pragma mark - textField
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if ([textField.text length] >= 8 && [NSString isNotEmpty:string]) {
        return NO;
    }
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    
}

#pragma mark - button
- (void)confirmBtnClicked {
    if ([[_nameTextField text] length] > 0) {
        [[KenServiceManager sharedServiceManager] deviceRename:_deviceInfo name:[KenCarcorder EncodeGB2312Str:[_nameTextField text]] start:^{
            [self showActivity];
        } success:^(BOOL successful, NSString * _Nullable errMsg, id  _Nullable responseData) {
            [self saveDeviceInfo];
        } failed:^(NSInteger status, NSString * _Nullable errMsg) {
            [self hideActivity];
            [self showToastWithMsg:@"当前服务器繁忙，请稍后重试"];
        }];
    } else {
        [self showToastWithMsg:@"请输入设备名"];
    }
}

- (void)saveDeviceInfo {
    [[KenServiceManager sharedServiceManager] deviceRenameToServer:_deviceInfo name:[_nameTextField text] start:^{
        
    } success:^(BOOL successful, NSString * _Nullable errMsg, id  _Nullable responseData) {
        [self hideActivity];
        if (successful) {
            [self popViewController];
        }
    } failed:^(NSInteger status, NSString * _Nullable errMsg) {
        [self hideActivity];
        [self showToastWithMsg:@"当前服务器繁忙，请稍后重试"];
    }];
}
@end
