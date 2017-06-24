//
//  KenPlayItemVC.m
//  KenCarcorder
//
//  Created by 邱根友 on 2017/6/17.
//  Copyright © 2017年 Ken.Liu. All rights reserved.
//

#import "KenPlayItemVC.h"
#import "KenPlayDeviceDM.h"
#import "KenVideoV.h"
#import "KenDeviceDM.h"
#import "MJRefresh.h"
#import "KenPlayDiscussDM.h"
#import "KenPlayItemCell.h"

@interface KenPlayItemVC ()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, assign) NSUInteger currentDiscussOffset;
@property (nonatomic, strong) KenPlayDeviceItemDM *deviceItemDM;
@property (nonatomic, strong) UIView *topV;
@property (nonatomic, strong) UIView *discussV;
@property (nonatomic, strong) UITableView *discussTableV;
@property (nonatomic, strong) UITextField *inputTextField;
@property (nonatomic, strong) NSMutableArray *discussArray;

@property (nonatomic, strong) KenVideoV *videoV;
@property (nonatomic, strong) UIView *videoNav;
@property (nonatomic, strong) UILabel *speedLabebl;         //速度标签

@end

@implementation KenPlayItemVC

#pragma mark - life cycle
- (instancetype)initWithDevice:(KenPlayDeviceItemDM *)device {
    self = [super init];
    if (self) {
        _deviceItemDM = device;
        _currentDiscussOffset = 0;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setNavTitle:self.deviceItemDM.name];
    
    [self.contentView addSubview:self.videoV];
    [self.contentView addSubview:self.videoNav];
    [self.contentView addSubview:self.topV];
    [self.contentView addSubview:self.discussTableV];
    [self.contentView addSubview:self.discussV];
    
    [self setLeftNavItemWithImg:[UIImage imageNamed:@"app_back"] selector:@selector(back)];
    
    //通知后台播放了
    [[KenServiceManager sharedServiceManager] playWithId:_deviceItemDM.itemId start:^{
    } successBlock:^(BOOL successful, NSString * _Nullable errMsg, id  _Nullable responseData) {
    } failedBlock:^(NSInteger status, NSString * _Nullable errMsg) {
    }];
    
    [self loadMoreDiscuss];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    @weakify(self)
    [[KenGCDTimerManager sharedInstance] scheduledTimerWithName:@"playVideoTime" timeInterval:1 queue:nil repeats:YES
                                                   actionOption:kKenGCDTimerAbandon action:^{
                                                       @strongify(self)
                                                       [Async main:^{
                                                           self.speedLabebl.text = self.videoV.speed;
                                                       }];
                                                   }];
    SysDelegate.allowRotation = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [[KenGCDTimerManager sharedInstance] cancelTimerWithName:@"playVideoTime"];
    SysDelegate.allowRotation = NO;
}

#pragma mark - event
- (void)back {
    [_videoV finishVideo];
    [super popViewController];
}

- (void)sendDiscuss {
    if ([NSString isEmpty:_inputTextField.text]) {
        [self showToastWithMsg:@"请先输入评论"];
    }
    
    [[KenServiceManager sharedServiceManager] playDiscuss:_deviceItemDM.itemId content:_inputTextField.text start:^{
    } successBlock:^(BOOL successful, NSString * _Nullable errMsg, id  _Nullable responseData) {
        KenPlayDiscussItemDM *item = [KenPlayDiscussItemDM initWithJsonDictionary:@{}];
        item.content = self.inputTextField.text;
        item.userName = @"我";
        item.createDate = [NSDate date].timeIntervalSince1970;
        
        [self.discussArray insertObject:item atIndex:0];
        
        self.inputTextField.text = nil;
        [self.discussTableV reloadData];
    } failedBlock:^(NSInteger status, NSString * _Nullable errMsg) {
    }];

    [_inputTextField resignFirstResponder];
}

- (void)likeBtnClicked:(UIButton *)button {
    //点赞
    [[KenServiceManager sharedServiceManager] playPraiseWithId:_deviceItemDM.itemId start:^{
    } successBlock:^(BOOL successful, NSString * _Nullable errMsg, id  _Nullable responseData) {
        if (successful) {
            button.enabled = NO;
            
            UILabel *label = (UILabel *)[button viewWithTag:1001];
            label.text = [NSString stringWithFormat:@"%zd", _deviceItemDM.praiseCount + 1];
            label.alpha = 0.5;
        }
    } failedBlock:^(NSInteger status, NSString * _Nullable errMsg) {
    }];
}

- (void)loadMoreDiscuss {
    [[KenServiceManager sharedServiceManager] playDiscussDataWithId:_deviceItemDM.itemId offset:_currentDiscussOffset start:^{
        [self showActivity];
    } successBlock:^(BOOL successful, NSString * _Nullable errMsg, KenPlayDiscussDM *responseData) {
        [self hideActivity];
        if (successful) {
            if (_currentDiscussOffset == 0) {
             [self.discussArray removeAllObjects];
            }
            
            [self.discussArray addObjectsFromArray:responseData.list];
            
            self.currentDiscussOffset = _discussArray.count;
            
            if (responseData.haveMore) {
                [self.discussTableV.mj_footer resetNoMoreData];
            } else {
                [self.discussTableV.mj_footer endRefreshingWithNoMoreData];
            }
        } else {
            [self showToastWithMsg:errMsg];
        }
        
        //结束刷新
        [self.discussTableV.mj_header endRefreshing];
        [self.discussTableV.mj_footer endRefreshing];
        
        [self.discussTableV reloadData];
    } failedBlock:^(NSInteger status, NSString * _Nullable errMsg) {
        [self hideActivity];
        [self showToastWithMsg:errMsg];
        
        //结束刷新
        [self.discussTableV.mj_header endRefreshing];
        [self.discussTableV.mj_footer endRefreshing];
    }];
}

- (void)loadNewDiscuss {
    _currentDiscussOffset = 0;
    [self loadMoreDiscuss];
}

- (void)navBtnClicked:(UIButton *)button {
    NSUInteger type = button.tag - 1100;
    if (type == 0) {
        //全屏
        [KenCarcorder setOrientation:UIInterfaceOrientationPortrait];
    } else if (type == 1) {
        [_videoV recordVideo];
    } else if (type == 2) {
        //拍照
        [_videoV capture];
        [self showToastWithMsg:@"抓拍成功"];
        [[KenCarcorder shareCarcorder] playVoiceByType:kKenVoiceCapture];
    }
}

#pragma mark - rotate
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    if (toInterfaceOrientation == UIInterfaceOrientationPortrait) {
        [self exitFullscreen];
    } else {
        if (self.interfaceOrientation == UIInterfaceOrientationPortrait) {
            [self enterFullscreen];
        }
    }
}

- (void)enterFullscreen {
    [self.videoV removeFromSuperview];
    [self.videoNav removeFromSuperview];
    
    self.videoV.frame = (CGRect){CGPointZero, SysDelegate.window.height, SysDelegate.window.width};
    [SysDelegate.window addSubview:self.videoV];
}

- (void)exitFullscreen {
    [self.videoV removeFromSuperview];
    
    self.videoV.frame = (CGRect){0, 0, MainScreenHeight, ceilf(MainScreenHeight * kAppImageHeiWid)};
    [self.contentView addSubview:self.videoV];
    [self.contentView addSubview:self.videoNav];
}

#pragma mark - Table
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.discussArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *bankCellIdentifier = @"playCell";
    KenPlayItemCell *cell = [tableView dequeueReusableCellWithIdentifier:bankCellIdentifier];
    if (cell == nil) {
        cell = [[KenPlayItemCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:bankCellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor clearColor];
        cell.contentView.backgroundColor = [UIColor clearColor];
    }
    
    cell.discussItem = [self.discussArray objectAtIndex:indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    KenPlayDiscussItemDM *discuss = [_discussArray objectAtIndex:indexPath.row];
    if (discuss) {
        _inputTextField.text = [NSString stringWithFormat:@"@%@ %@", discuss.userName, _inputTextField.text];
        [_inputTextField becomeFirstResponder];
    }
}

#pragma mark - getter setter
- (KenVideoV *)videoV {
    if (_videoV == nil) {
        KenDeviceDM *device = [KenDeviceDM initWithJsonDictionary:@{}];
        device.netStat = kKenNetworkDdns;
        device.online = YES;
        device.dataport = _deviceItemDM.serverPort;
        device.ddns = _deviceItemDM.serverHost;
        device.isSubStream = !_deviceItemDM.isMainStream;
        device.usr = _deviceItemDM.name;
        device.pwd = _deviceItemDM.password;

        _videoV = [[KenVideoV alloc] initWithFrame:(CGRect){0, 0, MainScreenWidth, ceilf(MainScreenWidth * kAppImageHeiWid)}];
        [_videoV showVideoWithDevice:device];
    }
    return _videoV;
}

- (UIView *)videoNav {
    if (_videoNav == nil) {
        _videoNav = [[UIView alloc] initWithFrame:(CGRect){0, self.videoV.maxY - kKenOffsetY(86),
            self.contentView.width, kKenOffsetY(86)}];
        _videoNav.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.4];
        
        _speedLabebl = [UILabel labelWithTxt:@"" frame:(CGRect){20, 0, 80, _videoNav.height}
                                        font:[UIFont appFontSize12] color:[UIColor appWhiteTextColor]];
        _speedLabebl.numberOfLines = 0;
        [_videoNav addSubview:_speedLabebl];
        
        NSArray *btnArr = @[@"history_full", @"history_video", @"history_photo"];
        CGFloat offsetX = _videoV.width;
        for (NSUInteger i = 0; i < btnArr.count; i++) {
            UIButton *button = [UIButton buttonWithImg:nil zoomIn:YES image:[UIImage imageNamed:btnArr[i]]
                                              imagesec:nil target:self action:@selector(navBtnClicked:)];
            CGFloat width = button.width + kKenOffsetX(50);
            button.frame = (CGRect){offsetX - width, 0, width, _videoNav.height};
            offsetX = button.originX;
            
            button.tag = 1100 + i;
            
            [_videoNav addSubview:button];
        }
    }
    return _videoNav;
}

- (UIView *)topV {
    if (_topV == nil) {
        _topV = [[UIView alloc] initWithFrame:(CGRect){0, self.videoV.maxY, self.contentView.width, 50}];
        _topV.backgroundColor = [UIColor appBackgroundColor];
        
        UIImageView *discussImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"play_discuss"]];
        discussImg.origin = CGPointMake(20, (_topV.height - discussImg.height) / 2);
        [_topV addSubview:discussImg];
        
        UILabel *label = [UILabel labelWithTxt:@"最新评论" frame:(CGRect){discussImg.maxX + 6, 0, 80, _topV.height}
                                           font:[UIFont appFontSize16] color:[UIColor appBlackTextColor]];
        label.textAlignment = NSTextAlignmentLeft;
        [_topV addSubview:label];
        
        //点赞
        UIButton *likeBtn = [UIButton buttonWithImg:nil zoomIn:YES image:[UIImage imageNamed:@"play_like"]
                                           imagesec:nil target:self action:@selector(likeBtnClicked:)];
        likeBtn.frame = (CGRect){_topV.width - _topV.height, 0, _topV.height, _topV.height};
        likeBtn.imageEdgeInsets = UIEdgeInsetsMake(-14, 0, 0, 0);
        likeBtn.titleLabel.textColor = [UIColor appMainColor];
        [_topV addSubview:likeBtn];
        
        UILabel *praiseL = [UILabel labelWithTxt:[NSString stringWithFormat:@"%zd", _deviceItemDM.praiseCount]
                                             frame:(CGRect){0, 25, likeBtn.width, 18}
                                              font:[UIFont appFontSize12] color:[UIColor appMainColor]];
        praiseL.tag = 1001;
        [likeBtn addSubview:praiseL];

        //play times label
        UILabel *playTimes = [UILabel labelWithTxt:[NSString stringWithFormat:@"%zd次播放", _deviceItemDM.pageView]
                                              frame:(CGRect){label.maxX, 0, likeBtn.originX - label.maxX, _topV.height}
                                               font:[UIFont appFontSize14] color:[UIColor appGrayTextColor]];
        [_topV addSubview:playTimes];

        UIView *line = [[UIView alloc] initWithFrame:(CGRect){6, _topV.height - 1, _topV.width - 12, 1}];
        line.backgroundColor = [UIColor appSepLineColor];
        [_topV addSubview:line];
    }
    return _topV;
}

- (UITableView *)discussTableV {
    if (_discussTableV == nil) {
        _discussTableV = [[UITableView alloc] initWithFrame:(CGRect){0, self.topV.maxY, self.contentView.width, self.contentView.height - self.topV.maxY - self.discussV.height}
                                                      style:UITableViewStylePlain];
        _discussTableV.delegate = self;
        _discussTableV.dataSource = self;
        _discussTableV.backgroundColor = [UIColor appBackgroundColor];
        _discussTableV.rowHeight = 110;
        _discussTableV.separatorStyle = UITableViewCellSeparatorStyleNone;
        
        //下拉刷新
        _discussTableV.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadNewDiscuss)];
        //上拉刷新
        _discussTableV.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreDiscuss)];
    }
    return _discussTableV;
}

- (UIView *)discussV {
    if (_discussV == nil) {
        _discussV = [[UIView alloc] initWithFrame:(CGRect){0, self.contentView.height - 45, self.contentView.width, 45}];
        _discussV.backgroundColor = [UIColor whiteColor];
        
        UIButton *sendBtn = [UIButton buttonWithImg:@"发送" zoomIn:NO image:nil imagesec:nil target:self action:@selector(sendDiscuss)];
        sendBtn.frame = (CGRect){_discussV.width - 60, 8, 50, 30};
        sendBtn.backgroundColor = [UIColor appMainColor];
        sendBtn.titleLabel.textColor = [UIColor appWhiteTextColor];
        sendBtn.layer.cornerRadius = 6;
        sendBtn.layer.masksToBounds = YES;
        [_discussV addSubview:sendBtn];
        
        _inputTextField = [[UITextField alloc]initWithFrame:CGRectMake(20, sendBtn.originY, sendBtn.minX - 10 - 20, sendBtn.height)];
        _inputTextField.font = [UIFont appFontSize14];
        _inputTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
        _inputTextField.clearsOnBeginEditing = NO;
        _inputTextField.textAlignment = NSTextAlignmentLeft;
        
        _inputTextField.layer.cornerRadius = _inputTextField.height / 2;
        _inputTextField.layer.masksToBounds = YES;
        _inputTextField.layer.borderColor = [UIColor appSepLineColor].CGColor;
        _inputTextField.layer.borderWidth = 0.5;
        
        [_inputTextField setValue:[NSNumber numberWithInt:15] forKey:@"paddingLeft"];
        [_inputTextField setValue:[NSNumber numberWithInt:15] forKey:@"paddingRight"];
        
        [_discussV addSubview:_inputTextField];
    }
    return _discussV;
}

- (NSMutableArray *)discussArray {
    if (_discussArray == nil) {
        _discussArray = [NSMutableArray array];
    }
    return _discussArray;
}
@end
