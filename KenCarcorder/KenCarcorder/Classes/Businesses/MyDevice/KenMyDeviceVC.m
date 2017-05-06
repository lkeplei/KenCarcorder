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

@interface KenMyDeviceVC ()<UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, strong) KenSegmentV *segmentView;
@property (nonatomic, strong) UICollectionView *collectV;
@property (nonatomic, strong) NSMutableArray *tempArray;

@end

@implementation KenMyDeviceVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setNavTitle:@"我的设备"];
    [self setRightNavItemWithImg:[UIImage imageNamed:@"home_add"] selector:@selector(addDevice)];
    
    [self.contentView addSubview:self.segmentView];
    [self.contentView addSubview:self.collectV];
    [self changeToGroup:0];
}

#pragma mark - event
- (void)addDevice {
    [self pushViewControllerString:@"KenAddDeviceVC" animated:YES];
}

#pragma mark - delegate
//#pragma mark -- UICollectionViewDataSource
///** 每组cell的个数*/
//- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
//    return 15;
//}
//
///** cell的内容*/
//- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
//    WWCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
//    cell.backgroundColor = [UIColor yellowColor];
//    cell.topImageView.image = [UIImage imageNamed:@"1"];
//    cell.bottomLabel.text = [NSString stringWithFormat:@"%zd.png",indexPath.row];
//}
//
///** 总共多少组*/
//- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
//    return 6;
//}
//
///** 头部/底部*/
//- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
//    
//    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
//        // 头部
//        WWCollectionReusableView *view =  [collectionView dequeueReusableSupplementaryViewOfKind :kind   withReuseIdentifier:@"header"   forIndexPath:indexPath];
//        view.headerLabel.text = [NSString stringWithFormat:@"头部 - %zd",indexPath.section];
//        return view;
//        
//    }else {
//        // 底部
//        WWCollectionFooterReusableView *view =  [collectionView dequeueReusableSupplementaryViewOfKind :kind   withReuseIdentifier:@"footer"   forIndexPath:indexPath];
//        view.footerLabel.text = [NSString stringWithFormat:@"底部 - %zd",indexPath.section];
//        return view;
//    }
//}
//
//#pragma mark -- UICollectionViewDelegateFlowLayout
///** 每个cell的尺寸*/
//- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
//    return CGSizeMake(60, 60);
//}
//
///** 头部的尺寸*/
//- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
//    return CGSizeMake(self.view.bounds.size.width, 40);
//}
//
///** 顶部的尺寸*/
//- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section {
//    return CGSizeMake(self.view.bounds.size.width, 40);
//}
//
///** section的margin*/
//- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
//    return UIEdgeInsetsMake(5, 5, 5, 5);
//}

#pragma mark -- UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"点击了第 %zd组 第%zd个",indexPath.section, indexPath.row);
}

#pragma mark - privae method
- (void)changeToGroup:(NSInteger)index {
    if (self.tempArray) {
        [self.tempArray removeAllObjects];
    } else {
        self.tempArray = [[NSMutableArray alloc] init];
    }
    
    for (KenDeviceDM *device in [[KenUserInfoDM getInstance] deviceArray]) {
        if (device.groupNo == index) {
            [self.tempArray addObject:device];
        }
    }
    
    if ([self.tempArray count] > 0) {
        [self showToastWithMsg:@"拿到了设备 列表"];
    } else {
        [self showToastWithMsg:@"拿不到到设备 列表，怎么搞！！！！！！"];
    }
}

#pragma mark - getter setter
- (KenSegmentV *)segmentView {
    if (_segmentView == nil) {
        _segmentView = [[KenSegmentV alloc] initWithItem:[[KenUserInfoDM getInstance] deviceGroups] frame:(CGRect){0, 0, self.contentView.width, 35}];
        
        @weakify(self)
        _segmentView.segmentSelectChanged = ^(NSInteger index) {
            @strongify(self)
            [self changeToGroup:index];
        };
    }
    return _segmentView;
}

- (UICollectionView *)collectV {
    if (_collectV == nil) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        // 设置collectionView的滚动方向，需要注意的是如果使用了collectionview的headerview或者footerview的话， 如果设置了水平滚动方向的话，那么就只有宽度起作用了了
        [layout setScrollDirection:UICollectionViewScrollDirectionVertical];
        // layout.minimumInteritemSpacing = 10;// 垂直方向的间距
        // layout.minimumLineSpacing = 10; // 水平方向的间距
        _collectV = [[UICollectionView alloc] initWithFrame:(CGRect){0, self.segmentView.maxY, self.contentView.width, self.contentView.height - self.segmentView.maxY} collectionViewLayout:layout];
        _collectV.backgroundColor = [UIColor whiteColor];
        _collectV.dataSource = self;
        _collectV.delegate = self;
    }
    return _collectV;
}
@end
