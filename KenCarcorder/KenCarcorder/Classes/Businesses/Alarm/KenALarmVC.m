//
//  KenALarmVC.m
//  KenCarcorder
//
//  Created by Ken.Liu on 2017/2/6.
//  Copyright © 2017年 Ken.Liu. All rights reserved.
//

#import "KenALarmVC.h"

#import "KenAlarmDM.h"
#import "UIImageView+WebCache.h"
#import "KenSelectDeleteV.h"
#import "MJRefresh.h"

static const int alarmTabBtnHeight = 34;

@interface KenALarmVC ()<UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate>

@property (nonatomic, assign) BOOL isLoading;
@property (nonatomic, assign) BOOL editStatus;
@property (nonatomic, assign) NSInteger startId;
@property (nonatomic, assign) NSInteger selectTab;
@property (nonatomic, assign) NSInteger selectNumbers;

@property (nonatomic, strong) UITableView *alarmTable;
@property (nonatomic, strong) NSMutableArray *alarmArray;
@property (nonatomic, strong) NSMutableArray *tabBtnArray;
@property (nonatomic, strong) UILabel *selectNumberLab;
@property (nonatomic, strong) UIView *deleteView;
@property (nonatomic, strong) UIView *deleteTopView;
@property (nonatomic, strong) UIImageView *bgImgView;
@property (nonatomic, strong) UIButton *selectAllBtn;

@property (nonatomic, copy) NSString *selectSN;

@property (nonatomic, strong) UIView *groupV;

@end

@implementation KenALarmVC

- (instancetype)init {
    self = [super init];
    if (self) {
        _startId = 0;
        _selectTab = -1;
        _editStatus = NO;
        _selectNumbers = 0;
        _isLoading = NO;
        
        _tabBtnArray = [NSMutableArray array];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setNavTitle:@"报警信息"];
    self.contentView.backgroundColor = [UIColor colorWithHexString:@"#051A28"];
    
    //右上角按钮
    UIButton *button1 = [UIButton buttonWithImg:nil zoomIn:NO image:[UIImage imageNamed:@"alarm_edit"]
                                       imagesec:nil target:self action:@selector(editBtn)];
    UIBarButtonItem *item1 = [[UIBarButtonItem alloc] initWithCustomView:button1];
    
    UIButton *button2 = [UIButton buttonWithImg:nil zoomIn:NO image:[UIImage imageNamed:@"alarm_filte"]
                                       imagesec:nil target:self action:@selector(filteBtn)];
    UIBarButtonItem *item2 = [[UIBarButtonItem alloc] initWithCustomView:button2];
    
    self.navigationItem.rightBarButtonItems = @[item1, item2];

    //视图
    [self.contentView addSubview:self.groupV];
    [self.contentView addSubview:self.alarmTable];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self loadAlarmData];
//    [SysDelegate getAlarmStat];
}

- (void)resetAlarmData {
    _startId = 0;
    _selectTab = -1;
    for (UIButton *btn in _tabBtnArray) {
        [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
        [btn setBackgroundColor:[UIColor whiteColor]];
    }
}

- (void)alarmWithDeivce:(NSString *)sn {
    [self resetAlarmData];
    
    _selectSN = sn;
    [self loadAlarmData];
}

- (void)loadAlarmData {
    @weakify(self)
    [[KenServiceManager sharedServiceManager] alarmWithCondition:_startId sn:_selectSN readed:nil groupNo:_selectNumbers success:^{
        @strongify(self)
        [self showActivity];
    } successBlock:^(BOOL successful, NSString * _Nullable errMsg, KenAlarmDM *  _Nullable alarmDM) {
        @strongify(self)
        [self hideActivity];
        
        if (_alarmArray == nil) {
            _alarmArray = [NSMutableArray array];
        } else {
            if (_startId <= 0) {
                [_alarmArray removeAllObjects];
            }
        }

        if (alarmDM.list.count > 0) {
            _startId = [[alarmDM.list lastObject] alarmId];
            [_alarmArray addObjectsFromArray:alarmDM.list];
            [_alarmTable reloadData];
        }

        if ([_alarmArray count] > 0) {
            [_bgImgView setHidden:YES];
            [_alarmTable setHidden:NO];
        } else {
            [_bgImgView setHidden:NO];
            [_alarmTable setHidden:YES];
        }

        //结束刷新
        [self.alarmTable.mj_header endRefreshing];
        [self.alarmTable.mj_footer endRefreshing];
    } failedBlock:^(NSInteger status, NSString * _Nullable errMsg) {
        @strongify(self)
        [self hideActivity];
        
        //结束刷新
        [self.alarmTable.mj_header endRefreshing];
        [self.alarmTable.mj_footer endRefreshing];
    }];
}

- (void)setAlarmNum {
//    if (SysDelegate.alarmNumbers > 0) {
//        NSString *badge = SysDelegate.alarmNumbers > 99 ? @"99+": [NSString stringWithFormat:@"%d", (int)SysDelegate.alarmNumbers];
//        self.tabBarItem.badgeValue = badge;
//    }
}

#pragma mark - Table
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _alarmArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *bankCellIdentifier = @"videoCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:bankCellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:bankCellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor clearColor];
        cell.contentView.backgroundColor = [UIColor clearColor];
        cell.contentView.width = MainScreenWidth;
    }
    
    [cell.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    [self freshCell:cell path:indexPath];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    if (_editStatus) {
//        YDAlarmInfo *info = [_alarmArray objectAtIndex:indexPath.row];
//        info.isSelected = !info.isSelected;
//        _selectNumbers = info.isSelected ? ++_selectNumbers : --_selectNumbers;
//        
//        [_selectNumberLab setText:[NSString stringWithFormat:@"已选%zd个信息", _selectNumbers]];
//        
//        [_alarmTable reloadData];
//    } else {
//        YDAlarmInfo *info = [_alarmArray objectAtIndex:indexPath.row];
//        YDDeviceInfo *deviceInfo = [[YDModel shareModel] getDeviceBySn:info.deviceSn];
//        if ([deviceInfo deviceOnline] && ![deviceInfo deviceLock]) {
//            YDAlarmInfo *alarm = [_alarmArray objectAtIndex:indexPath.row];
//            if (![alarm alarmReaded]) {
//                [[YDController shareController] sendReadedWithAlarmId:@[[NSString stringWithFormat:@"%d", (int)[alarm alarmId]]] success:^() {
//                    [alarm setAlarmReaded:YES];
//                    SysDelegate.alarmNumbers--;
//                    [self setAlarmNum];
//                } failure:^(HttpServiceStatus serviceCode, AFHTTPRequestOperation *requestOP, NSError *error) {
//                    
//                }];
//            }
//            
//            YDAlarmRecordVC *recordVc = [[YDAlarmRecordVC alloc] initWithAlarm:indexPath.row alarmArray:_alarmArray];
//            [self pushViewController:recordVc];
//        }
//    }
}

#pragma mark - event
- (void)editBtn {
    UIView *view = [self.view viewWithTag:9999];
    if (view) return;
    
//    if ([SysDelegate.tabBarVC.tabBar isHidden]) {
//        [SysDelegate.tabBarVC.tabBar setHidden:NO];
//        [self removeDeleteView];
//        _editStatus = NO;
//    } else {
//        [SysDelegate.tabBarVC.tabBar setHidden:YES];
//        [self addDeleteView];
//        _editStatus = YES;
//    }
}

- (void)filteBtn {
//    if (![SysDelegate.tabBarVC.tabBar isHidden]) {
//        [SysDelegate.tabBarVC.tabBar setHidden:YES];
//        YDSelectDeleteV *selectV = [[YDSelectDeleteV alloc] initWithFrame:(CGRect){0, kAppViewOrginY, self.view.width,
//            kGSize.height - kAppViewOrginY}];
//        selectV.tag = 9999;
//        [self.view addSubview:selectV];
//    }
}

- (void)tabClicked:(UIButton *)button {
    if (_selectTab == button.tag - 1000 || _editStatus) return;
    
    _selectNumbers = button.tag - 1000;
    _startId = 0;
    _selectSN = nil;
    
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    
    for (UIButton *btn in _tabBtnArray){
        if (btn != button) {
            [btn setTitleColor:[UIColor colorWithHexString:@"#94C6E8"] forState:UIControlStateNormal];
        }
    }
    
    [self loadAlarmData];
    
}

- (void)deleteConfirm {
    [self showConfirmAlert];
}

- (void)cancelBtn {
    [self editBtn];
}

- (void)selectAllBtn:(UIButton *)button {
//    if ([button isSelected]) {
//        [button setSelected:NO];
//        
//        for (YDAlarmInfo *info in _alarmArray) {
//            info.isSelected = NO;
//        }
//        _selectNumbers = 0;
//    } else {
//        [button setSelected:YES];
//        
//        for (YDAlarmInfo *info in _alarmArray) {
//            info.isSelected = YES;
//        }
//        _selectNumbers = [_alarmArray count];
//    }
//    
//    [_alarmTable reloadData];
//    [_selectNumberLab setText:[NSString stringWithFormat:@"已选%zd个信息", _selectNumbers]];
}

- (void)loadNewTopic {
    _startId = 0;
    [self loadAlarmData];
}

- (void)loadMoreTopic {
    [self loadAlarmData];
}

#pragma mark - other
- (void)addDeleteView {
//    if (_deleteView) {
//        [self.view addSubview:_deleteView];
//        [self.view addSubview:_deleteTopView];
//        
//        [_selectNumberLab setText:[NSString stringWithFormat:@"已选%zd个信息", _selectNumbers]];
//    } else {
//        //top
//        _deleteTopView = [[UIView alloc] initWithFrame:(CGRect){0, kAppViewOrginY + alarmTabBtnHeight, self.view.width, alarmTabBtnHeight}];
//        [self.view addSubview:_deleteTopView];
//        
//        UILabel *lable = [KenUtils labelWithTxt:@"全选" frame:(CGRect){0, 0, 70, alarmTabBtnHeight}
//                                           font:kKenFontHelvetica(16) color:[UIColor grayColor]];
//        [_deleteTopView addSubview:lable];
//        
//        _selectNumberLab = [KenUtils labelWithTxt:[NSString stringWithFormat:@"已选%zd个信息", _selectNumbers]
//                                            frame:(CGRect){0, 0, _deleteTopView.width, alarmTabBtnHeight}
//                                             font:kKenFontHelvetica(16) color:[UIColor grayColor]];
//        [_deleteTopView addSubview:_selectNumberLab];
//        
//        _selectAllBtn = [KenUtils buttonWithImg:nil off:0 zoomIn:YES image:[UIImage imageNamed:@"select_none"]
//                                       imagesec:[UIImage imageNamed:@"select_green"] target:self action:@selector(selectAllBtn:)];
//        _selectAllBtn.frame = CGRectMake(_deleteTopView.width - _deleteTopView.height * 1.5, 0, _deleteTopView.height * 1.5, _deleteTopView.height);
//        [_deleteTopView addSubview:_selectAllBtn];
//        
//        //
//        _deleteView = [[UIView alloc] initWithFrame:(CGRect){0, self.view.height - 100, self.view.width, 100}];
//        [self.view addSubview:_deleteView];
//        
//        UIButton *delete = [KenUtils buttonWithImg:@"删除" off:0 zoomIn:NO image:nil
//                                          imagesec:nil target:self action:@selector(deleteConfirm)];
//        delete.frame = (CGRect){0, 14, _deleteView.width, 40};
//        [delete.titleLabel setFont:kKenFontHelvetica(18)];
//        [delete setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
//        [delete setBackgroundColor:[UIColor whiteColor]];
//        [_deleteView addSubview:delete];
//        
//        UIButton *cancel = [KenUtils buttonWithImg:@"取消" off:0 zoomIn:NO image:nil
//                                          imagesec:nil target:self action:@selector(cancelBtn)];
//        cancel.frame = (CGRect){0, _deleteView.height - 40, _deleteView.width, 40};
//        [cancel.titleLabel setFont:kKenFontHelvetica(18)];
//        [cancel setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
//        [cancel setBackgroundColor:[UIColor whiteColor]];
//        [_deleteView addSubview:cancel];
//    }
//    
//    _alarmTable.frame = CGRectMake(0, kAppViewOrginY + alarmTabBtnHeight * 2, kGSize.width,
//                                   kGSize.height - kAppViewOrginY - _deleteView.height - alarmTabBtnHeight * 2);
//    [_alarmTable reloadData];
}

- (void)removeDeleteView {
//    if (_deleteView) {
//        [_deleteView removeFromSuperview];
//        [_deleteTopView removeFromSuperview];
//    }
//    
//    for (YDAlarmInfo *info in _alarmArray) {
//        info.isSelected = NO;
//    }
//    
//    _selectNumbers = 0;
//    [_selectAllBtn setSelected:NO];
//    
//    _alarmTable.frame = CGRectMake(0, kAppViewOrginY + 44, kGSize.width, kGSize.height - kAppViewOrginY - kAppTabbarHeight - 44);
//    [_alarmTable reloadData];
}

- (void)showConfirmAlert {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"将永久删除这些信息，是否继续？"
                                                       delegate:self cancelButtonTitle:@"取消"
                                              otherButtonTitles:@"确定", nil];
    [alertView show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
//    if (buttonIndex == 1) {
//        NSMutableArray *idArray = [NSMutableArray array];
//        for (YDAlarmInfo *info in _alarmArray) {
//            if (info.isSelected) {
//                [idArray addObject:[NSString stringWithFormat:@"%zd", info.alarmId]];
//            }
//        }
//        
//        [[YDController shareController] showLoadingV:self.view content:nil picS:NO];
//        if ([idArray count] > 0) {
//            [[YDController shareController] deleteAlarmWithAlarmId:idArray success:^{
//                [[YDController shareController] hideLoadingV:self.view];
//                [self editBtn];
//                
//                _startId = 0;
//                [self loadAlarmData];
//                
//                [SysDelegate getAlarmStat];
//            } failure:^(HttpServiceStatus serviceCode, AFHTTPRequestOperation *requestOP, NSError *error) {
//                [[YDController shareController] hideLoadingV:self.view];
//            }];
//        }
//    }
}

#pragma mark - private method
- (void)freshCell:(UITableViewCell *)cell path:(NSIndexPath *)indexPath {
    KenAlarmItemDM *info = [_alarmArray objectAtIndex:indexPath.row];
    
    CGFloat cellHeight = kKenOffsetY(216);
    
    if (_editStatus) {
        cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:info.isSelected ? @"select_green" : @"select_none"]];
    } else {
        cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"alarm_arrow"]];
    }
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:(CGRect){10, 10, kKenOffsetX(276), cellHeight - 20}];
    [cell.contentView addSubview:imageView];
    [imageView setBackgroundColor:[UIColor blackColor]];
    [self setCellImage:imageView alarm:info];
    
    ////////////////
    float height = imageView.height / 3;
    float originx = CGRectGetMaxX(imageView.frame) + 6;
    NSString *content = [NSString stringWithFormat:@"设备名称:%@", [info getDeviceName]];
    UILabel *deviceName = [UILabel labelWithTxt:content frame:(CGRect){originx, 10, MainScreenWidth - originx - 30, height}
                                           font:[UIFont appFontSize12] color:[UIColor colorWithHexString:@"#64E0F2"]];
    deviceName.textAlignment = NSTextAlignmentLeft;
    [cell.contentView addSubview:deviceName];
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:content];
    [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor yellowColor] range:NSMakeRange(5, content.length - 5)];
    deviceName.attributedText = attributedString;
    
    /////////////
    content = [NSString stringWithFormat:@"设备ID号:%@", [info sn]];
    UILabel *deviceID = [UILabel labelWithTxt:content
                                        frame:(CGRect){originx, CGRectGetMaxY(deviceName.frame), deviceName.width, height}
                                         font:[UIFont appFontSize12] color:[UIColor colorWithHexString:@"#64E0F2"]];
    deviceID.textAlignment = NSTextAlignmentLeft;
    [cell.contentView addSubview:deviceID];
    
    attributedString = [[NSMutableAttributedString alloc] initWithString:content];
    [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor yellowColor] range:NSMakeRange(5, content.length - 5)];
    deviceID.attributedText = attributedString;
    
    //////////////
    content = [NSString stringWithFormat:@"报警时间:%@", [info getAlarmTimeString]];
    UILabel *time = [UILabel labelWithTxt:content frame:(CGRect){originx, CGRectGetMaxY(deviceID.frame), deviceName.width, height}
                                     font:[UIFont appFontSize12] color:[UIColor colorWithHexString:@"#64E0F2"]];
    time.textAlignment = NSTextAlignmentLeft;
    [cell.contentView addSubview:time];
    
    attributedString = [[NSMutableAttributedString alloc] initWithString:content];
    [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor yellowColor] range:NSMakeRange(5, content.length - 5)];
    time.attributedText = attributedString;
    
    ///////////////
    NSString* name = @"alarm_person";
    if (info.almType == kKenAlarmVoice) {
        name = @"alarm_voice";
    }
    UIImageView *typeImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:name]];
    typeImg.originX = time.originX + [content widthForFont:[UIFont appFontSize12]] + 10;
    typeImg.centerY = time.centerY;
    [cell.contentView addSubview:typeImg];
    
    UILabel *label = [UILabel labelWithTxt:[info getAlarmTypeString] frame:(CGRect){0, 0, typeImg.size}
                                      font:[UIFont appFontSize11] color:[UIColor whiteColor]];
    [typeImg addSubview:label];
    
    //line
    if (indexPath.row == 0) {
        UIView *line = [[UIView alloc] initWithFrame:(CGRect){CGPointZero, MainScreenWidth, 0.5}];
        [line setBackgroundColor:[UIColor colorWithHexString:@"#074F7A"]];
        [cell.contentView addSubview:line];
    }
    
    UIView *line = [[UIView alloc] initWithFrame:(CGRect){0, cellHeight - 0.5, MainScreenWidth, 0.5}];
    [line setBackgroundColor:[UIColor colorWithHexString:@"#074F7A"]];
    [cell.contentView addSubview:line];
}

- (void)setCellImage:(UIImageView *)imageView alarm:(KenAlarmItemDM *)info {
    KenDeviceDM *deviceInfo = info.deviceInfo;
    if ([deviceInfo online]) {
        if (deviceInfo.deviceLock) {
            UILabel *label = [UILabel labelWithTxt:@"图像已加密" frame:(CGRect){CGPointZero, imageView.size}
                                              font:[UIFont appFontSize16] color:[UIColor redColor]];
            [imageView addSubview:label];
        } else {
            NSString *jpgPath = [NSString stringWithFormat:@"%@/%@", [[KenCarcorder shareCarcorder] getAlarmFolder], [info getImageName]];
            if ([KenCarcorder fileExistsAtPath:jpgPath]) {
                [imageView setImage:[UIImage imageNamed:jpgPath]];
            } else {
                __weak UIImageView *weakImgV = imageView;
                [imageView setImageWithURL:[NSURL URLWithString:[info getAlarmImg]]
                          placeholderImage:[UIImage imageNamed:@"alarm_default_bg"]
                                 completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
                                     if (image) {
                                         [image writeFileWithPath:jpgPath]; //将新缩略图存储到本地
                                     } else {
                                         [weakImgV setImage:nil];
                                     }
                                 }];
            }
        }
    } else {
        UILabel *label = [UILabel labelWithTxt:@"不在线" frame:(CGRect){CGPointZero, imageView.size}
                                          font:[UIFont appFontSize22] color:[UIColor whiteColor]];
        [imageView addSubview:label];
    }
}

#pragma mark - getter setter
- (UIView *)groupV {
    if (_groupV == nil) {
        _groupV = [[UIView alloc] initWithFrame:(CGRect){0, 0, self.contentView.width, kKenOffsetY(78)}];
        _groupV.backgroundColor = [UIColor colorWithHexString:@"#084AAB"];
        
        NSArray *group = [KenUserInfoDM getInstance].deviceGroups;
        float width = self.view.width / [group count];
        for (NSInteger i = 0; i < [group count]; i++) {
            NSString *name = [group objectAtIndex:i];
            UIButton *button = [UIButton buttonWithImg:name zoomIn:NO image:nil imagesec:nil
                                                target:self action:@selector(tabClicked:)];
            button.tag = 1000 + i;
            button.frame = (CGRect){width * i, 0, width, _groupV.height};
            [button setTitleColor:[UIColor colorWithHexString:@"#94C6E8"] forState:UIControlStateNormal];
            
            [_groupV addSubview:button];
            
            [_tabBtnArray addObject:button];
        }
    }
    return _groupV;
}

- (UITableView *)alarmTable {
    if (_alarmTable == nil) {
        _alarmTable = [[UITableView alloc] initWithFrame:(CGRect){0, self.groupV.maxY, self.contentView.width,
            self.contentView.height - self.groupV.height}
                                                   style:UITableViewStylePlain];
        _alarmTable.delegate = self;
        _alarmTable.dataSource = self;
        _alarmTable.rowHeight = kKenOffsetY(216);
        _alarmTable.backgroundColor = [UIColor clearColor];
        _alarmTable.separatorStyle = UITableViewCellSeparatorStyleNone;
        
        //下拉刷新
        _alarmTable.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadNewTopic)];
        //上拉刷新
        _alarmTable.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreTopic)];
    }
    return _alarmTable;
}

@end
