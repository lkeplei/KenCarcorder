//
//  KenPlayVC.m
//  KenCarcorder
//
//  Created by hzyouda on 2017/2/18.
//  Copyright © 2017年 Ken.Liu. All rights reserved.
//

#import "KenPlayVC.h"
#import "KenPageControl.h"
#import "KenPlayBannerDM.h"
#import "KenPlayDeviceDM.h"
#import "KenPlayCell.h"
#import "UIImageView+WebCache.h"
#import "KenPlayItemVC.h"

#define kMarketBannerElementNum     (5)

@interface KenPlayVC ()<UICollectionViewDataSource, UICollectionViewDelegate, UIScrollViewDelegate>

@property (nonatomic, assign) BOOL needReloadData;

@property (nonatomic, strong) UIView *bannerView;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) KenPageControl *pageControl;
@property (nonatomic, strong) UICollectionView *collectV;
@property (nonatomic, strong) UIImageView *bgImgView;

@property (nonatomic, strong) KenPlayBannerDM *playBannerDM;
@property (nonatomic, strong) KenPlayDeviceDM *playDeviceDM;
@property (nonatomic, assign) NSInteger currentBannerItemId;
@property (nonatomic, strong) NSMutableArray *labelArray;

@end

@implementation KenPlayVC

#pragma mark - life cycle
- (instancetype)init {
    self = [super init];
    if (self) {
        _currentBannerItemId = -1;
        _needReloadData = NO;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setNavTitle:@"直播"];
    
    [self getBannerData];
    
    [self.contentView addSubview:self.bannerView];
    [self.contentView addSubview:self.collectV];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (_needReloadData) {
        [self getBannerItemDevice];
        _needReloadData = NO;
    }
}

#pragma mark - data
- (void)getBannerData {
    [[KenServiceManager sharedServiceManager] playBanner:^{
        [self showActivity];
    } successBlock:^(BOOL successful, NSString * _Nullable errMsg, KenPlayBannerDM *responseData) {
        [self hideActivity];
        if (successful) {
            self.playBannerDM = responseData;
        } else {
            [self showToastWithMsg:errMsg];
        }
    } failedBlock:^(NSInteger status, NSString * _Nullable errMsg) {
        [self hideActivity];
        [self showToastWithMsg:errMsg];
    }];
}

- (void)getBannerItemDevice {
    [[KenServiceManager sharedServiceManager] playBannerDevice:self.currentBannerItemId start:^{
        [self showActivity];
    } successBlock:^(BOOL successful, NSString * _Nullable errMsg, id  _Nullable responseData) {
        [self hideActivity];
        if (successful) {
            self.playDeviceDM = responseData;
        } else {
            [self showToastWithMsg:errMsg];
        }
    } failedBlock:^(NSInteger status, NSString * _Nullable errMsg) {
        [self hideActivity];
        [self showToastWithMsg:errMsg];
    }];
}

#pragma mark - delegate
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _playDeviceDM.list.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    KenPlayCell *cell = (KenPlayCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"collectCell" forIndexPath:indexPath];
    
    [cell updateWithDevice:_playDeviceDM.list[indexPath.row]];
    
    return cell;
}

#pragma mark -- UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat width = (self.contentView.width - 32) / 2;
    return CGSizeMake(width, width * kAppImageHeiWid + 20);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(15, 10, 15, 10);
}

#pragma mark -- UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    _needReloadData = YES;
    
    KenPlayItemVC *itemVC = [[KenPlayItemVC alloc] initWithDevice:[self.playDeviceDM.list objectAtIndex:indexPath.row]];
    [self pushViewController:itemVC animated:YES];
}

#pragma mark - ScrollView Delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    NSUInteger pageNum = floorf((_scrollView.contentOffset.x - self.bannerView.width / 2) / self.bannerView.width) + 1;
    _pageControl.currentPage = pageNum;
}

#pragma mark - getter setter
- (void)setPlayDeviceDM:(KenPlayDeviceDM *)playDeviceDM {
    _playDeviceDM = playDeviceDM;
    
    if (_playDeviceDM.list.count > 0) {
        self.bgImgView.hidden = YES;
        self.collectV.hidden = NO;
        
        [self.collectV reloadData];
    } else {
        self.bgImgView.hidden = NO;
        self.collectV.hidden = YES;
    }
}

- (void)setCurrentBannerItemId:(NSInteger)currentBannerItemId {
    if (_currentBannerItemId != currentBannerItemId && currentBannerItemId < _playBannerDM.list.count) {
        _currentBannerItemId = currentBannerItemId;
        
        [self getBannerItemDevice];
    }
}

- (void)setPlayBannerDM:(KenPlayBannerDM *)playBannerDM {
    _playBannerDM = playBannerDM;
    
    int pages = _playBannerDM.list.count % kMarketBannerElementNum > 0 ? 1 : 0;
    pages += _playBannerDM.list.count / kMarketBannerElementNum;
    
    //scroll
    NSUInteger j = 0;
    float width = _bannerView.width / kMarketBannerElementNum;
    UIImage *image = [UIImage imageNamed:@"play_banner"];
    UIView *tempView;
    
    _labelArray = [NSMutableArray array];
    @weakify(self)
    for (NSUInteger i = 0; i < _playBannerDM.list.count; i++) {
        if (i % kMarketBannerElementNum == 0) {
            tempView = [[UIView alloc] initWithFrame:(CGRect){self.bannerView.width * j, 0, _bannerView.width, _bannerView.height - 20}];
            [tempView setBackgroundColor:[UIColor whiteColor]];
            
            [_scrollView addSubview:tempView];
        }
        
        KenPlayBannerItemDM *info = [_playBannerDM.list objectAtIndex:i];
        
        //image
        UIImageView *imageV = [[UIImageView alloc] initWithFrame:(CGRect){width * (i - j * kMarketBannerElementNum) + (width - image.size.width) / 2, 10, image.size}];
        [imageV sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", kAppServerHost, info.imageUrl]]];
        imageV.tag = info.itemId;
        [tempView addSubview:imageV];
        
        [imageV clicked:^(UIView * _Nonnull view) {
            if (view.tag != self.currentBannerItemId) {
                @strongify(self)
                for (UILabel *object in self.labelArray) {
                    if (object.tag == 1100 + self.currentBannerItemId) {
                        object.textColor = [UIColor appBlackTextColor];
                        break;
                    }
                }
                self.currentBannerItemId = view.tag;
                
                UILabel *label = (UILabel *)[view viewWithTag:1100 + self.currentBannerItemId];
                label.textColor = [UIColor colorWithHexString:@"#419FFF"];
            }
        }];
        
        //label
        UILabel *label = [UILabel labelWithTxt:info.name frame:(CGRect){0, imageV.maxY, imageV.width, 12}
                                          font:[UIFont appFontSize12] color:[UIColor appBlackTextColor]];
        label.tag = 1100 + info.itemId;
        [imageV addSubview:label];
        
        [self.labelArray addObject:label];
        
        if (i % kMarketBannerElementNum == kMarketBannerElementNum - 1) {
            j++;
        }
        
        if (i == 0) {
            self.currentBannerItemId = info.itemId;
            label.textColor = [UIColor colorWithHexString:@"#419FFF"];
        }
    }
    
    _scrollView.contentSize = CGSizeMake(self.bannerView.width * pages, _scrollView.height);
    _pageControl.numberOfPages = pages;
    _pageControl.currentPage = 0;
}

- (UIView *)bannerView {
    if (_bannerView == nil) {
        _bannerView = [[UIView alloc] initWithFrame:(CGRect){0, 0, self.contentView.width, 90}];
        _bannerView.backgroundColor = [UIColor whiteColor];
        
        _scrollView = [[UIScrollView alloc] initWithFrame:(CGRect){0, 0, _bannerView.width, _bannerView.height - 20}];
        _scrollView.delegate = self;
        _scrollView.backgroundColor = [UIColor whiteColor];
        _scrollView.pagingEnabled = YES;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.showsVerticalScrollIndicator = NO;
        [_bannerView addSubview:_scrollView];
        
        //page control
        _pageControl = [[KenPageControl alloc] initWithActiveImg:CGRectMake(0, _scrollView.height, _bannerView.width, 20)
                                                       activeImg:@"play_active_point"
                                                     inactiveImg:@"play_normal_point"];
        [_pageControl setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
        [_bannerView addSubview:_pageControl];
    }
    return _bannerView;
}

- (UICollectionView *)collectV {
    if (_collectV == nil) {
        _collectV = [[UICollectionView alloc] initWithFrame:(CGRect){0, self.bannerView.maxY + 10, self.contentView.width, self.contentView.height - self.bannerView.maxY - 10}
                                       collectionViewLayout:[[UICollectionViewFlowLayout alloc] init]];
        _collectV.backgroundColor = [UIColor whiteColor];
        _collectV.dataSource = self;
        _collectV.delegate = self;
        
        [_collectV registerClass:[KenPlayCell class] forCellWithReuseIdentifier:@"collectCell"];
    }
    return _collectV;
}

- (UIImageView *)bgImgView {
    if (_bgImgView == nil) {
        _bgImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"app_default_bg"]];
        _bgImgView.frame = self.collectV.frame;
        [self.contentView addSubview:_bgImgView];
    }
    return _bgImgView;
}

@end
