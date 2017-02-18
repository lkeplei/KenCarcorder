//
//  KenAboutUsVC.m
//  KenCarcorder
//
//  Created by hzyouda on 2017/2/18.
//  Copyright © 2017年 Ken.Liu. All rights reserved.
//

#import "KenAboutUsVC.h"
#import "KenAlertView.h"

@interface KenAboutUsVC ()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *informationTable;

@end

@implementation KenAboutUsVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setNavTitle:@"关于七彩云"];

    _informationTable = [[UITableView alloc] initWithFrame:(CGRect){0,0,self.contentView.size} style:UITableViewStylePlain];
    _informationTable.delegate = self;
    _informationTable.dataSource = self;
    _informationTable.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"about_bg"]];
    _informationTable.backgroundColor = [UIColor clearColor];
    _informationTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    _informationTable.tableHeaderView = [self getTableHeadView];
    [self.contentView addSubview:_informationTable];
}

- (UIView *)getTableHeadView {
    UIView *headV = [[UIView alloc] initWithFrame:(CGRect){CGPointZero, _informationTable.width, 226}];
    headV.backgroundColor = [UIColor clearColor];;
    
    UIImageView *logo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"about_icon"]];
    logo.center = CGPointMake(headV.width / 2, headV.height / 2);
    [headV addSubview:logo];
    
    return headV;
}

#pragma mark - Table delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *bankCellIdentifier = @"aboutCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:bankCellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:bankCellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.1];
        cell.textLabel.textColor = [UIColor appWhiteTextColor];
    }
    
    if (indexPath.row == 0) {
        [cell.textLabel setText:@"功能介绍"];
        [cell.imageView setImage:[UIImage imageNamed:@"about_item1"]];
    } else if (indexPath.row == 1) {
        [cell.textLabel setText:@"给我评分"];
        [cell.imageView setImage:[UIImage imageNamed:@"about_item2"]];
    } else if (indexPath.row == 2) {
        [cell.textLabel setText:@"联系我们"];
        [cell.imageView setImage:[UIImage imageNamed:@"about_item3"]];
    }
    
    if (indexPath.row != 2) {
        UIView *line = [[UIView alloc] initWithFrame:(CGRect){cell.imageView.maxX, cell.height, MainScreenWidth, 0.5}];
        line.backgroundColor = [UIColor appSepLineColor];
        [cell.contentView addSubview:line];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0 && indexPath.row == 1) {
        
    } else if (indexPath.section == 0 && indexPath.row == 1) {
        
    } else if (indexPath.section == 0 && indexPath.row == 2) {
        [KenAlertView showAlertViewWithTitle:@"温馨提示" contentView:nil message:@"拨打七彩云客服电话-4008008571"
                                buttonTitles:@[@"取消", @"拨打"]
                          buttonClickedBlock:^(KenAlertView * _Nonnull alertView, NSInteger index) {
                              if (index == 1) {
                                  if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"tel:4008008571"]]) {
                                      [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"tel:4008008571"]];
                                  }
                              }
                          }];
    }
}

@end
