//
//  KenGroupManagerVC.m
//  KenCarcorder
//
//  Created by hzyouda on 2017/2/18.
//  Copyright © 2017年 Ken.Liu. All rights reserved.
//

#import "KenGroupManagerVC.h"

@interface KenGroupManagerVC ()<UIGestureRecognizerDelegate>

@property (nonatomic, strong) NSArray *groupArray;
@property (nonatomic, strong) UIView *groupBg;

@end

@implementation KenGroupManagerVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setNavTitle:@"分组管理"];
    
    UIImageView *bgV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"group_bg"]];
    bgV.size = self.contentView.size;
    [self.contentView addSubview:bgV];
    
    float height = 44;
    _groupBg = [[UIView alloc] initWithFrame:(CGRect){0, 0, self.contentView.width, height * 4}];
    [_groupBg setBackgroundColor:[UIColor clearColor]];
    [_groupBg setUserInteractionEnabled:YES];
    [self.contentView addSubview:_groupBg];
    
    _groupArray = @[@"分组一", @"分组二", @"分组三", @"分组四"];
    
    //button
    UIButton *finishBtn = [UIButton buttonWithImg:@"确认修改" zoomIn:NO image:[UIImage imageNamed:@"login_btn_bg"]
                                         imagesec:nil target:self action:@selector(finishBtnClicked:)];
    finishBtn.center = CGPointMake(self.view.centerX, CGRectGetMaxY(_groupBg.frame) + 30);
    [self.contentView addSubview:finishBtn];
    
    //tap gesture
    UITapGestureRecognizer *tapTouch = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    tapTouch.delegate = self;
    [self.contentView addGestureRecognizer:tapTouch];
    
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
    float height = 44;
    for (int i = 0; i < [_groupArray count]; i++) {
        UIImageView *bg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"group_input_bg"]];
        bg.frame = (CGRect){0, height * i, _groupBg.width, height};
        [_groupBg addSubview:bg];
        
        UILabel *label = [UILabel labelWithTxt:[_groupArray objectAtIndex:i] frame:(CGRect){0, height * i, 70, height}
                                          font:[UIFont appFontSize16] color:[UIColor blackColor]];
        [label setTextColor:[UIColor colorWithHexString:@"#FFDD00"]];
        [_groupBg addSubview:label];
        
        UITextField *textField = [[UITextField alloc]initWithFrame:CGRectMake(CGRectGetMaxX(label.frame) + 14, height * i,
                                                                              _groupBg.width - CGRectGetMaxX(label.frame) - 20, height)];
        textField.tag = 1000 + i;
        textField.text = [groups objectAtIndex:i];
        textField.font = [UIFont appFontSize16];
        textField.clearButtonMode = UITextFieldViewModeAlways;
        textField.textAlignment = NSTextAlignmentLeft;
        textField.textColor = [UIColor appWhiteTextColor];
        [_groupBg addSubview:textField];
        
        if (i < _groupArray.count - 1) {
            UIImageView *line = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"app_sep_line"]];
            line.frame = (CGRect){10, height, _groupBg.width, line.height};
            [bg addSubview:line];
        }
    }
}

@end
