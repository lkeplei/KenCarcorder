//
//  KenDeviceManagerVC.m
//  KenCarcorder
//
//  Created by hzyouda on 2017/2/18.
//  Copyright © 2017年 Ken.Liu. All rights reserved.
//

#import "KenDeviceManagerVC.h"
#import "KenMobileListDM.h"

@interface KenDeviceManagerVC ()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *informationTable;
@property (nonatomic, strong) NSArray *terminalArray;

@end

@implementation KenDeviceManagerVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setNavTitle:@"终端管理"];
    
    _informationTable = [[UITableView alloc] initWithFrame:(CGRect){0,0,self.contentView.size} style:UITableViewStylePlain];
    _informationTable.delegate = self;
    _informationTable.dataSource = self;
    _informationTable.backgroundColor = [UIColor clearColor];
    _informationTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.contentView addSubview:_informationTable];
    
    [self loadPhoneData];
}

#pragma mark - event
- (void)loadPhoneData {
    [[KenServiceManager sharedServiceManager] deviceLoad:^{
        [self showActivity];
    } successBlock:^(BOOL successful, NSString * _Nullable errMsg, KenMobileListDM * _Nullable responseData) {
        [self hideActivity];
        if (successful) {
            if (responseData.list.count > 0) {
                _terminalArray = [NSArray arrayWithArray:responseData.list];
                
                [_informationTable reloadData];
            }
        } else {
            [self showAlert:@"" content:errMsg];
        }
    } failedBlock:^(NSInteger status, NSString * _Nullable errMsg) {
        [self hideActivity];
        [self showAlert:@"" content:errMsg];
    }];
}

#pragma mark - Table delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_terminalArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *bankCellIdentifier = @"deviceManagerCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:bankCellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:bankCellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.1];
        cell.textLabel.textColor = [UIColor appWhiteTextColor];
        
        UIView *line = [[UIView alloc] initWithFrame:(CGRect){10, cell.height, MainScreenWidth, 0.5}];
        line.backgroundColor = [UIColor appSepLineColor];
        [cell.contentView addSubview:line];
    }
    
    [cell.imageView setImage:[UIImage imageNamed:@"device_item"]];

    KenMobileItemDM *info = [_terminalArray objectAtIndex:indexPath.row]; //设备信息
    [cell.textLabel setText:[NSString stringWithFormat:@"%@(%@)", info.brand, info.model]];
    cell.textLabel.textColor = [UIColor appDarkGrayTextColor];

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [[KenServiceManager sharedServiceManager] deviceRemove:[[_terminalArray objectAtIndex:indexPath.row] tokenOrMac]
                                                   success:^{
        [self showActivity];
    } successBlock:^(BOOL successful, NSString * _Nullable errMsg, KenMobileListDM * _Nullable responseData) {
        [self hideActivity];
        if (successful) {
            _terminalArray = [NSArray arrayWithArray:responseData.list];
            
            [_informationTable reloadData];
        } else {
            [self showAlert:@"" content:errMsg];
        }
    } failedBlock:^(NSInteger status, NSString * _Nullable errMsg) {
        [self hideActivity];
        [self showAlert:@"" content:errMsg];
    }];}

@end
