//
//  KenMyDeviceVC.m
//  KenCarcorder
//
//  Created by 邱根友 on 2017/5/6.
//  Copyright © 2017年 Ken.Liu. All rights reserved.
//

#import "KenMyDeviceVC.h"
#import "KenSegmentV.h"
#import "KenDeviceDM.h"
#import "KenDeviceCellV.h"
#import "KenMiniVideoVC.h"

@interface KenMyDeviceVC ()<UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, assign) NSUInteger currentGroup;
@property (nonatomic, strong) KenSegmentV *segmentView;
@property (nonatomic, strong) UICollectionView *collectV;
@property (nonatomic, strong) NSMutableArray *tempArray;
@property (nonatomic, strong) UIImageView *bgImgView;
@property (nonatomic, strong) UIWebView *webV;

@end

@implementation KenMyDeviceVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setNavTitle:@"我的设备"];
    [self setRightNavItemWithImg:[UIImage imageNamed:@"home_add"] selector:@selector(addDevice)];
    
    [self.contentView addSubview:self.webV];
    [self.contentView addSubview:self.segmentView];
    [self.contentView addSubview:self.collectV];
    self.currentGroup = 0;
    
    [self pushViewControllerString:@"KenLoginVC" animated:NO];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.currentGroup = _currentGroup;
    [self.webV reload];
}

#pragma mark - event
- (void)addDevice {
    [self pushViewControllerString:@"KenAddDeviceVC" animated:YES];
}

#pragma mark - delegate
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _tempArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    KenDeviceCellV *cell = (KenDeviceCellV *)[collectionView dequeueReusableCellWithReuseIdentifier:@"collectCell" forIndexPath:indexPath];
    
    [cell updateWithDevice:_tempArray[indexPath.row]];
    
    return cell;
}

#pragma mark -- UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat width = (self.contentView.width - 48) / 2;
    return CGSizeMake(width, width * kAppImageHeiWid + 30);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(15, 15, 15, 15);
}

#pragma mark -- UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    KenMiniVideoVC *videoVC = [[KenMiniVideoVC alloc] init];
    [self pushViewController:videoVC animated:YES];
    videoVC.device = [_tempArray objectAtIndex:indexPath.row];
}

#pragma mark - privae method
- (void)changeToGroup:(NSInteger)index {
    if (self.tempArray) {
        [self.tempArray removeAllObjects];
    } else {
        self.tempArray = [[NSMutableArray alloc] init];
    }
    
    for (KenDeviceDM *device in [[KenUserInfoDM sharedInstance] deviceArray]) {
        if (device.groupNo == index) {
            [self.tempArray addObject:device];
        }
    }
    
    if ([self.tempArray count] > 0) {
        self.bgImgView.hidden = YES;
        self.collectV.hidden = NO;
        [self.collectV reloadData];
    } else {
        self.bgImgView.hidden = NO;
        self.collectV.hidden = YES;
    }
}

#pragma mark - getter setter
- (void)setCurrentGroup:(NSUInteger)currentGroup {
    _currentGroup = currentGroup;
    [self changeToGroup:_currentGroup];
}

- (UIWebView *)webV {
    if (_webV == nil) {
        _webV = [[UIWebView alloc] initWithFrame:(CGRect){0, 0, self.contentView.width, 0.56 * MainScreenWidth}];
        
        NSURL *url = [NSURL URLWithString:@"http://139.224.65.108/hls/vomont/562_1_0.m3u8"];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        [_webV loadRequest:request];
    }
    return _webV;
}

- (KenSegmentV *)segmentView {
    if (_segmentView == nil) {
        _segmentView = [[KenSegmentV alloc] initWithItem:[[KenUserInfoDM sharedInstance] deviceGroups] frame:(CGRect){0, self.webV.maxY, self.contentView.width, 35}];
        
        @weakify(self)
        _segmentView.segmentSelectChanged = ^(NSInteger index) {
            @strongify(self)
            self.currentGroup = index;
        };
    }
    return _segmentView;
}

- (UICollectionView *)collectV {
    if (_collectV == nil) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        // 设置collectionView的滚动方向，需要注意的是如果使用了collectionview的headerview或者footerview的话， 如果设置了水平滚动方向的话，那么就只有宽度起作用了了
//        [layout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
//        layout.itemSize = CGSizeMake((self.contentView.width - 50) / 2, 36);
//        layout.minimumInteritemSpacing = 15;// 垂直方向的间距
//        layout.minimumLineSpacing = 25; // 水平方向的间距
//        layout.sectionInset = UIEdgeInsetsMake(0.f, 0, 9.f, 0);
        
        _collectV = [[UICollectionView alloc] initWithFrame:(CGRect){0, self.segmentView.maxY + 10, self.contentView.width, self.contentView.height - self.segmentView.maxY - 10} collectionViewLayout:layout];
        _collectV.backgroundColor = [UIColor whiteColor];
        _collectV.dataSource = self;
        _collectV.delegate = self;
        
        [_collectV registerClass:[KenDeviceCellV class] forCellWithReuseIdentifier:@"collectCell"];
    }
    return _collectV;
}

- (UIImageView *)bgImgView {
    if (_bgImgView == nil) {
        _bgImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"app_default_bg"]];
        _bgImgView.center = CGPointMake(self.contentView.width / 2, self.contentView.height / 2);
        [self.contentView addSubview:_bgImgView];
    }
    return _bgImgView;
}

@end
