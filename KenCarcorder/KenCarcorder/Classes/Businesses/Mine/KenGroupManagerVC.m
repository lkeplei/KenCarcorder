//
//  KenGroupManagerVC.m
//  KenCarcorder
//
//  Created by hzyouda on 2017/2/18.
//  Copyright © 2017年 Ken.Liu. All rights reserved.
//

#import "KenGroupManagerVC.h"

@interface KenGroupManagerVC ()

@property (nonatomic, strong) NSArray *groupArray;
@property (nonatomic, strong) UIView *groupBg;

@end

@implementation KenGroupManagerVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setNavTitle:@"分组管理"];
    
    float height = 44;
    _groupBg = [[UIView alloc] initWithFrame:(CGRect){0, 0, self.contentView.width, height * 4}];
    [_groupBg setBackgroundColor:[UIColor clearColor]];
    [_groupBg setUserInteractionEnabled:YES];
    [self.contentView addSubview:_groupBg];
    
    _groupArray = @[@"分组一", @"分组二", @"分组三", @"分组四"];
    
    //button
    UIButton *finishBtn = [UIButton buttonWithImg:@"确认修改" zoomIn:NO image:nil imagesec:nil target:self action:@selector(finishBtnClicked:)];
    finishBtn.backgroundColor = [UIColor appMainColor];
    finishBtn.layer.cornerRadius = 4;
    finishBtn.frame = (CGRect){0, 0, self.contentView.width - 100, 44};
    finishBtn.center = CGPointMake(self.view.centerX, CGRectGetMaxY(_groupBg.frame) + 100);
    [self.contentView addSubview:finishBtn];

    [self loadGroups];
}

#pragma mark - event
- (void)loadGroups {
    [[KenServiceManager sharedServiceManager] deviceGetGroups:^{
        [self showActivity];
    } successBlock:^(BOOL successful, NSString * _Nullable errMsg, NSArray * _Nullable responseData) {
        [self hideActivity];
        if (successful) {
            KenUserInfoDM *userInfo = [KenUserInfoDM getInstance];
            userInfo.deviceGroups = responseData;
            [userInfo setInstance];
            
            [self setGroups:responseData];
        } else {
            [self showAlert:@"" content:errMsg];
            
            [self setGroups:[KenUserInfoDM getInstance].deviceGroups];
        }
    } failedBlock:^(NSInteger status, NSString * _Nullable errMsg) {
        [self hideActivity];
        [self showAlert:@"" content:errMsg];
    }];
}

- (void)hideKeyboard {
    for (int i = 0; i < [_groupArray count]; i++) {
        UITextField *textField = (UITextField *)[_groupBg viewWithTag:1000 + i];
        [textField resignFirstResponder];
    }
    
    [UIView animateWithDuration:0.3f animations:^{
        self.view.frame = CGRectMake(0.f, 0, self.view.width, self.view.height);
    }];
}

- (void)finishBtnClicked:(UIButton *)button {
    for (int i = 0; i < [_groupArray count]; i++) {
        UITextField *textf = (UITextField *)[_groupBg viewWithTag:1000 + i];
        
        [[KenServiceManager sharedServiceManager] deviceSetGroupName:textf.text groupNo:i success:^{
            [self showActivity];
        } successBlock:^(BOOL successful, NSString * _Nullable errMsg, id  _Nullable responseData) {
            [self hideActivity];
            if (successful) {

            } else {
                [self showAlert:@"" content:errMsg];
            }
        } failedBlock:^(NSInteger status, NSString * _Nullable errMsg) {
            [self hideActivity];
            [self showAlert:@"" content:errMsg];
        }];
    }
    
    [self popViewControllerAnimated:YES];
}

#pragma mark - private method
- (void)setGroups:(NSArray *)groups {
    float height = 35;
    for (int i = 0; i < [_groupArray count]; i++) {
        UILabel *label = [UILabel labelWithTxt:[_groupArray objectAtIndex:i] frame:(CGRect){0, (height + 10) * i + 10, 70, height}
                                          font:[UIFont appFontSize16] color:[UIColor blackColor]];
        [label setTextColor:[UIColor appBlackTextColor]];
        [_groupBg addSubview:label];
        
        UITextField *textField = [[UITextField alloc]initWithFrame:CGRectMake(CGRectGetMaxX(label.frame) + 4, label.originY,
                                                                              _groupBg.width - CGRectGetMaxX(label.frame) - 30, height)];
        textField.tag = 1000 + i;
        textField.text = [groups objectAtIndex:i];
        textField.font = [UIFont appFontSize15];
        textField.clearButtonMode = UITextFieldViewModeAlways;
        textField.textAlignment = NSTextAlignmentLeft;
        textField.textColor = [UIColor appDarkGrayTextColor];
        
        textField.layer.borderColor = [UIColor appSepLineColor].CGColor;
        textField.layer.borderWidth = 1;
        textField.layer.cornerRadius = 4;
        
        textField.leftView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 15, 0)];
        //设置显示模式为永远显示(默认不显示)
        textField.leftViewMode = UITextFieldViewModeAlways;
        
        [_groupBg addSubview:textField];
    }
}

@end
