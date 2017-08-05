//
//  KenMineVC.m
//  KenCarcorder
//
//  Created by Ken.Liu on 2017/2/6.
//  Copyright © 2017年 Ken.Liu. All rights reserved.
//

#import "KenMineVC.h"
#import "KenForgetPwdVC.h"

@interface KenMineVC ()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *informationTable;
@property (nonatomic, strong) NSArray *imageArray;
@property (nonatomic, strong) NSArray *contentArray;

@end

@implementation KenMineVC
#pragma mark - life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setNavTitle:@"我"];
    
    _imageArray = @[@[@"mine_icon1", @"mine_icon2"],
                    @[@"mine_icon3", @"mine_icon4", @"mine_icon5"],
                    @[@"mine_icon6", @"mine_icon7"]];
    _contentArray = @[@[[KenUserInfoDM sharedInstance].userName, @"修改密码"],
                      @[@"组名维护", @"终端维护", @"清除缓存"],
                      @[@"关于七彩", @"退出登录"]];
    
    _informationTable = [[UITableView alloc] initWithFrame:(CGRect){0,0,self.contentView.size} style:UITableViewStyleGrouped];
    _informationTable.delegate = self;
    _informationTable.dataSource = self;
    _informationTable.backgroundColor = [UIColor appBackgroundColor];
    _informationTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.contentView addSubview:_informationTable];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (_informationTable) {
        [_informationTable reloadData];
    }
}

#pragma mark - Table delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[_imageArray objectAtIndex:section] count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _imageArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return 0.1;
    }
    return 10;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *bankCellIdentifier = @"mineCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:bankCellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:bankCellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        if (!(indexPath.section == 0 && indexPath.row == 0))
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        if (indexPath.row > 0) {
            UIView *line = [[UIView alloc] initWithFrame:(CGRect){10, 0, self.contentView.width, 0.5}];
            line.backgroundColor = [UIColor appSepLineColor];
            [cell.contentView addSubview:line];
        }
    }
    
    [cell.imageView setImage:[UIImage imageNamed:_imageArray[indexPath.section][indexPath.row]]];
    
    NSString *contentText = _contentArray[indexPath.section][indexPath.row];
    if (indexPath.section == 1 && indexPath.row == 2) {
        NSString *str = @"M";
        float totalSize = [KenCarcorder getCachFolderSize];
        float base = 1024 * 1024;
        if (totalSize < base) {
            str = @"K";
            base = 1024;
        }
        totalSize = totalSize / base;
        contentText = [contentText stringByAppendingFormat:@" (%.1f%@)", totalSize, str];
    }
    cell.textLabel.textColor = [UIColor appBlackTextColor];
    [cell.textLabel setText:contentText];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1 && indexPath.row == 2) {
        [KenCarcorder deleteCachFolder];
        
        [_informationTable reloadData];
    } else {
        if (indexPath.section == 0 && indexPath.row == 1) {
            KenForgetPwdVC *pwdVC = [[KenForgetPwdVC alloc] initWithTitle:@"修改密码"];
            [self pushViewController:pwdVC animated:YES];
        } else if (indexPath.section == 1 && indexPath.row == 0) {
            [self pushViewControllerString:@"KenGroupManagerVC" animated:YES];
        } else if (indexPath.section == 1 && indexPath.row == 1) {
            [self pushViewControllerString:@"KenDeviceManagerVC" animated:YES];
        } else if (indexPath.section == 2 && indexPath.row == 0) {
            [self pushViewControllerString:@"KenAboutUsVC" animated:YES];
        } else if (indexPath.section == 2 && indexPath.row == 1) {
            [[KenServiceManager sharedServiceManager] accountLogout];
            
            [SysDelegate.rootVC changToHome];
            [[SysDelegate.rootVC currentSelectedVC] pushViewControllerString:@"KenLoginVC" animated:NO];
        }
    }
}

@end
