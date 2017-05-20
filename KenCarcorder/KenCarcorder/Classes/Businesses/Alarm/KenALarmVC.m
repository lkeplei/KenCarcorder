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
#import "KenAlertView.h"
#import "KenAlarmRecordVC.h"
#import "KenSegmentV.h"

#define alarmTabBtnHeight           kKenOffsetY(78)

@interface KenALarmVC ()<UITableViewDataSource, UITableViewDelegate>

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
@property (nonatomic, strong) KenSegmentV *segmentView;

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
    self.contentView.backgroundColor = [UIColor appBackgroundColor];
    
    //右上角按钮
    UIButton *button1 = [UIButton buttonWithImg:nil zoomIn:NO image:[UIImage imageNamed:@"alarm_edit"]
                                       imagesec:nil target:self action:@selector(editBtn)];
    UIBarButtonItem *item1 = [[UIBarButtonItem alloc] initWithCustomView:button1];
    
    UIButton *button2 = [UIButton buttonWithImg:nil zoomIn:NO image:[UIImage imageNamed:@"alarm_filte"]
                                       imagesec:nil target:self action:@selector(filteBtn)];
    UIBarButtonItem *item2 = [[UIBarButtonItem alloc] initWithCustomView:button2];
    
    self.navigationItem.rightBarButtonItems = @[item1, item2];

    //视图
    [self.contentView addSubview:self.segmentView];
    [self.contentView addSubview:self.alarmTable];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [[KenServiceManager sharedServiceManager] getAarmStat];
    
    //重新设置分组标题
    NSArray *group = [KenUserInfoDM getInstance].deviceGroups;
    for (NSInteger i = 0; i < [_tabBtnArray count]; i++) {
        [_tabBtnArray[i] setTitle:[group objectAtIndex:i] forState:UIControlStateNormal];
    }
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
            [self.bgImgView setHidden:YES];
            [_alarmTable setHidden:NO];
        } else {
            [self.bgImgView setHidden:NO];
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
        cell.backgroundColor = [UIColor whiteColor];
        cell.contentView.backgroundColor = [UIColor whiteColor];
        cell.contentView.width = MainScreenWidth;
    }
    
    [cell.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    [self freshCell:cell path:indexPath];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (_editStatus) {
        KenAlarmItemDM *info = [_alarmArray objectAtIndex:indexPath.row];
        info.isSelected = !info.isSelected;
        _selectNumbers = info.isSelected ? ++_selectNumbers : --_selectNumbers;
        
        [_selectNumberLab setText:[NSString stringWithFormat:@"已选%zd个信息", _selectNumbers]];
        
        [_alarmTable reloadData];
    } else {
        KenAlarmItemDM *info = [_alarmArray objectAtIndex:indexPath.row];
        KenDeviceDM *device = [[KenUserInfoDM getInstance] deviceWithSN:info.sn];
        if (device && device.online && !device.deviceLock) {
            if (![info readed]) {
                [[KenServiceManager sharedServiceManager] alarmReadWithId:@[[NSString stringWithFormat:@"%zd", info.alarmId]]
                                                                  success:^{
                    
                } successBlock:^(BOOL successful, NSString * _Nullable errMsg, id  _Nullable responseData) {
                    info.readed = YES;
                    [KenServiceManager sharedServiceManager].alarmNumbers--;
                    [[KenServiceManager sharedServiceManager] updateAarmStat];
                } failedBlock:^(NSInteger status, NSString * _Nullable errMsg) {
                    
                }];
            }
            
            KenAlarmRecordVC *recordVC = [[KenAlarmRecordVC alloc] initWithDevice:device];
            [self pushViewController:recordVC animated:YES];
        }
    }
}

#pragma mark - event
- (void)editBtn {
    UIView *view = [SysDelegate.window viewWithTag:9999];
    if (view) return;
    
    if ([SysDelegate.rootVC.tabBar isHidden]) {
        [SysDelegate.rootVC.tabBar setHidden:NO];
        [self removeDeleteView];
        _editStatus = NO;
    } else {
        [SysDelegate.rootVC.tabBar setHidden:YES];
        [self addDeleteView];
        _editStatus = YES;
    }
}

- (void)filteBtn {
    UIView *view = [SysDelegate.window viewWithTag:9999];
    if (view) {
        [view removeFromSuperview];
    } else {
        KenSelectDeleteV *selectV = [[KenSelectDeleteV alloc] initWithFrame:(CGRect){0, self.contentView.originY, self.contentView.width,
                                                                                    self.contentView.height + kAppTabbarHeight}];
        selectV.tag = 9999;
        [SysDelegate.window addSubview:selectV];
    }
}

- (void)deleteConfirm {
    @weakify(self)
    [KenAlertView showAlertViewWithTitle:nil contentView:nil message:@"将永久删除这些信息，是否继续？"
                            buttonTitles:@[@"取消", @"确定"]
                      buttonClickedBlock:^(KenAlertView * _Nonnull alertView, NSInteger index) {
                          @strongify(self)
                            if (index == 1) {
                                NSMutableArray *idArray = [NSMutableArray array];
                                for (KenAlarmItemDM *info in _alarmArray) {
                                    if (info.isSelected) {
                                        [idArray addObject:[NSString stringWithFormat:@"%zd", info.alarmId]];
                                    }
                                }
                                
                                if ([idArray count] > 0) {
                                    [[KenServiceManager sharedServiceManager] alarmDeleteWithId:idArray success:^{
                                        [self showActivity];
                                    } successBlock:^(BOOL successful, NSString * _Nullable errMsg, id  _Nullable responseData) {
                                        [self hideActivity];
                                        [self editBtn];

                                        _startId = 0;
                                        [self loadAlarmData];

                                        [[KenServiceManager sharedServiceManager] getAarmStat];
                                    } failedBlock:^(NSInteger status, NSString * _Nullable errMsg) {
                                        [self hideActivity];
                                    }];
                                }
                            }
                      }];
    
}

- (void)cancelBtn {
    [self editBtn];
}

- (void)selectAllBtn:(UIButton *)button {
    if ([button isSelected]) {
        [button setSelected:NO];
        
        for (KenAlarmItemDM *info in _alarmArray) {
            info.isSelected = NO;
        }
        _selectNumbers = 0;
    } else {
        [button setSelected:YES];
        
        for (KenAlarmItemDM *info in _alarmArray) {
            info.isSelected = YES;
        }
        _selectNumbers = [_alarmArray count];
    }
    
    [_alarmTable reloadData];
    [_selectNumberLab setText:[NSString stringWithFormat:@"已选%zd个信息", _selectNumbers]];
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
    self.contentView.height = MainScreenHeight - 64;
    
    if (_deleteView) {
        [self.contentView addSubview:_deleteView];
        [self.contentView addSubview:_deleteTopView];
        
        [_selectNumberLab setText:[NSString stringWithFormat:@"已选%zd个信息", _selectNumbers]];
    } else {
        //top
        _deleteTopView = [[UIView alloc] initWithFrame:(CGRect){0, alarmTabBtnHeight, self.contentView.width, alarmTabBtnHeight}];
        [self.contentView addSubview:_deleteTopView];
        
        UILabel *lable = [UILabel labelWithTxt:@"全选" frame:(CGRect){0, 0, 70, alarmTabBtnHeight}
                                          font:[UIFont appFontSize16] color:[UIColor grayColor]];
        [_deleteTopView addSubview:lable];
        
        _selectNumberLab = [UILabel labelWithTxt:[NSString stringWithFormat:@"已选%zd个信息", _selectNumbers]
                                           frame:(CGRect){0, 0, _deleteTopView.width, alarmTabBtnHeight}
                                            font:[UIFont appFontSize16] color:[UIColor grayColor]];
        [_deleteTopView addSubview:_selectNumberLab];
        
        _selectAllBtn = [UIButton buttonWithImg:nil zoomIn:YES image:[UIImage imageNamed:@"alarm_select_none"]
                                       imagesec:[UIImage imageNamed:@"alarm_select_green"] target:self action:@selector(selectAllBtn:)];
        _selectAllBtn.frame = CGRectMake(_deleteTopView.width - _deleteTopView.height * 1.5, 0, _deleteTopView.height * 1.5, _deleteTopView.height);
        [_deleteTopView addSubview:_selectAllBtn];
        
        //
        _deleteView = [[UIView alloc] initWithFrame:(CGRect){0, self.contentView.height - 100, self.contentView.width, 100}];
        [self.contentView addSubview:_deleteView];
        
        UIButton *delete = [UIButton buttonWithImg:@"删除" zoomIn:NO image:nil
                                          imagesec:nil target:self action:@selector(deleteConfirm)];
        delete.frame = (CGRect){0, 14, _deleteView.width, 40};
        [delete.titleLabel setFont:[UIFont appFontSize17]];
        [delete setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        [delete setBackgroundColor:[UIColor whiteColor]];
        [_deleteView addSubview:delete];
        
        UIButton *cancel = [UIButton buttonWithImg:@"取消" zoomIn:NO image:nil
                                          imagesec:nil target:self action:@selector(cancelBtn)];
        cancel.frame = (CGRect){0, _deleteView.height - 40, _deleteView.width, 40};
        [cancel.titleLabel setFont:[UIFont appFontSize17]];
        [cancel setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [cancel setBackgroundColor:[UIColor whiteColor]];
        [_deleteView addSubview:cancel];
    }
    
    _alarmTable.frame = CGRectMake(0, alarmTabBtnHeight * 2, self.contentView.width,
                                   self.contentView.height - _deleteView.height - alarmTabBtnHeight * 2);
    [_alarmTable reloadData];
}

- (void)removeDeleteView {
    if (_deleteView) {
        [_deleteView removeFromSuperview];
        [_deleteTopView removeFromSuperview];
    }
    
    for (KenAlarmItemDM *info in _alarmArray) {
        info.isSelected = NO;
    }
    
    _selectNumbers = 0;
    [_selectAllBtn setSelected:NO];
    
    self.contentView.height = MainScreenHeight - 64 - kAppTabbarHeight;
    _alarmTable.frame = CGRectMake(0, self.segmentView.maxY, self.contentView.width, self.contentView.height - self.segmentView.height);
    [_alarmTable reloadData];
}

#pragma mark - private method
- (void)freshCell:(UITableViewCell *)cell path:(NSIndexPath *)indexPath {
    KenAlarmItemDM *info = [_alarmArray objectAtIndex:indexPath.row];
    
    CGFloat cellHeight = kKenOffsetY(216);
    
    if (_editStatus) {
        cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:info.isSelected ? @"alarm_select_green" : @"alarm_select_none"]];
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
                                           font:[UIFont appFontSize12] color:[UIColor appGrayTextColor]];
    deviceName.textAlignment = NSTextAlignmentLeft;
    [cell.contentView addSubview:deviceName];
    
//    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:content];
//    [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor appGrayTextColor] range:NSMakeRange(5, content.length - 5)];
//    deviceName.attributedText = attributedString;
    
    /////////////
    content = [NSString stringWithFormat:@"设备ID号:%@", [info sn]];
    UILabel *deviceID = [UILabel labelWithTxt:content
                                        frame:(CGRect){originx, CGRectGetMaxY(deviceName.frame), deviceName.width, height}
                                         font:[UIFont appFontSize12] color:[UIColor appGrayTextColor]];
    deviceID.textAlignment = NSTextAlignmentLeft;
    [cell.contentView addSubview:deviceID];
    
//    attributedString = [[NSMutableAttributedString alloc] initWithString:content];
//    [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor appGrayTextColor] range:NSMakeRange(5, content.length - 5)];
//    deviceID.attributedText = attributedString;
    
    //////////////
    content = [NSString stringWithFormat:@"报警时间:%@", [info getAlarmTimeString]];
    UILabel *time = [UILabel labelWithTxt:content frame:(CGRect){originx, CGRectGetMaxY(deviceID.frame), deviceName.width, height}
                                     font:[UIFont appFontSize12] color:[UIColor appGrayTextColor]];
    time.textAlignment = NSTextAlignmentLeft;
    [cell.contentView addSubview:time];
    
//    attributedString = [[NSMutableAttributedString alloc] initWithString:content];
//    [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor appGrayTextColor] range:NSMakeRange(5, content.length - 5)];
//    time.attributedText = attributedString;
    
    ///////////////
    UIView *typeImg = [[UIView alloc] initWithFrame:(CGRect){0, 0, 32, 14}];
    typeImg.originX = time.originX + [content widthForFont:[UIFont appFontSize12]] + 6;
    typeImg.centerY = time.centerY;
    typeImg.layer.cornerRadius = 6;
    typeImg.layer.borderColor = [UIColor appMainColor].CGColor;
    typeImg.layer.masksToBounds = YES;
    typeImg.layer.borderWidth = 0.5;
    [cell.contentView addSubview:typeImg];
    
    UILabel *label = [UILabel labelWithTxt:[info getAlarmTypeString] frame:(CGRect){0, 0, typeImg.size}
                                      font:[UIFont appFontSize10] color:[UIColor appMainColor]];
    [typeImg addSubview:label];
    
    //line
    UIView *line = [[UIView alloc] initWithFrame:(CGRect){0, cellHeight - 0.5, MainScreenWidth, 0.5}];
    [line setBackgroundColor:[UIColor appSepLineColor]];
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
            [imageView sd_setImageWithURL:[NSURL URLWithString:[info getAlarmImg]] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                
            }];
        }
    } else {
        UILabel *label = [UILabel labelWithTxt:@"不在线" frame:(CGRect){CGPointZero, imageView.size}
                                          font:[UIFont appFontSize22] color:[UIColor whiteColor]];
        [imageView addSubview:label];
    }
}

#pragma mark - getter setter
- (KenSegmentV *)segmentView {
    if (_segmentView == nil) {
        _segmentView = [[KenSegmentV alloc] initWithItem:[[KenUserInfoDM getInstance] deviceGroups] frame:(CGRect){0, 0, self.contentView.width, 35}];
        
        [self loadAlarmData];
        
        @weakify(self)
        _segmentView.segmentSelectChanged = ^(NSInteger index) {
            @strongify(self)
            _selectNumbers = index;
            _startId = 0;
            _selectSN = nil;
            
            [self loadAlarmData];
            
        };
    }
    return _segmentView;
}

- (UITableView *)alarmTable {
    if (_alarmTable == nil) {
        _alarmTable = [[UITableView alloc] initWithFrame:(CGRect){0, self.segmentView.maxY + 10, self.contentView.width, self.contentView.height - self.segmentView.height}
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

- (UIImageView *)bgImgView {
    if (_bgImgView == nil) {
        _bgImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"default_bg"]];
        _bgImgView.center = CGPointMake(self.contentView.width / 2, self.contentView.height / 2);
        [self.contentView addSubview:_bgImgView];
    }
    return _bgImgView;
}
@end
