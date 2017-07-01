//
//  KenDeviceChangeGroupVC.m
//  KenCarcorder
//
//  Created by 邱根友 on 2017/4/15.
//  Copyright © 2017年 Ken.Liu. All rights reserved.
//

#import "KenDeviceChangeGroupVC.h"
#import "KenDeviceDM.h"

@interface KenDeviceChangeGroupVC ()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) KenDeviceDM *deviceInfo;
@property (nonatomic, assign) NSInteger currentSlectedIndex;
@property (nonatomic, strong) NSArray *groupArray;

@end

@implementation KenDeviceChangeGroupVC

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
    [self setNavTitle:@"分组切换"];
    
    UITableView *table = [[UITableView alloc] initWithFrame:(CGRect){0, 0, self.contentView.size} style:UITableViewStyleGrouped];
    table.delegate = self;
    table.dataSource = self;
    [table setBackgroundColor:[UIColor appBackgroundColor]];
    table.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    [table setScrollEnabled:NO];
    [self.contentView addSubview:table];
    [table reloadData];
    
    _currentSlectedIndex = _deviceInfo.groupNo;

    KenUserInfoDM *userInfo = [KenUserInfoDM sharedInstance];
    if (userInfo.deviceGroups.count > 0) {
        _groupArray = [NSArray arrayWithArray:userInfo.deviceGroups];
    } else {
        [self loadGroups];
    }
}

#pragma mark - event
- (void)loadGroups {
    [[KenServiceManager sharedServiceManager] deviceGetGroups:^{
        [self showActivity];
    } successBlock:^(BOOL successful, NSString * _Nullable errMsg, NSArray * _Nullable responseData) {
        [self hideActivity];
        if (successful) {
            KenUserInfoDM *userInfo = [KenUserInfoDM sharedInstance];
            userInfo.deviceGroups = responseData;
            [userInfo setInstance];
            
            _groupArray = [NSArray arrayWithArray:userInfo.deviceGroups];
        } else {
            [self showAlert:@"" content:errMsg];
        }
    } failedBlock:^(NSInteger status, NSString * _Nullable errMsg) {
        [self hideActivity];
        [self showAlert:@"" content:errMsg];
    }];
}

#pragma mark - Table
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_groupArray count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *bankCellIdentifier = @"videoCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:bankCellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:bankCellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [cell setBackgroundColor:[UIColor whiteColor]];
    }
    
    if (_currentSlectedIndex == indexPath.row) {
        cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"setting_selected"]];
    } else {
        [cell setAccessoryType:UITableViewCellAccessoryNone];
    }
    
    [cell.textLabel setText:[_groupArray objectAtIndex:indexPath.row]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    _currentSlectedIndex = indexPath.row;
    [tableView reloadData];
    
    @weakify(self)
    [[KenServiceManager sharedServiceManager] deviceChangeGroup:self.deviceInfo.sn group:_currentSlectedIndex start:^{
        
    } success:^(BOOL successful, NSString * _Nullable errMsg, id  _Nullable responseData) {
        @strongify(self)
        [self popViewController];
    } failed:^(NSInteger status, NSString * _Nullable errMsg) {
    }];
}

@end
