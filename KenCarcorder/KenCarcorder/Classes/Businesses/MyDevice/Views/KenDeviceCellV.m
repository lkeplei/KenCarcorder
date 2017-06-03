//
//  KenDeviceCellV.m
//  KenCarcorder
//
//  Created by 邱根友 on 2017/5/6.
//  Copyright © 2017年 Ken.Liu. All rights reserved.
//

#import "KenDeviceCellV.h"
#import "KenDeviceDM.h"
#import "UIImageView+WebCache.h"

@interface KenDeviceCellV ()

@property (nonatomic, strong) KenDeviceDM *device;
@property (nonatomic, strong) UILabel *nameLabel;
//@property (nonatomic, strong) UILabel *statusLabel;
@property (nonatomic, strong) UILabel *alarmLabel;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIImageView *alarmView;

@end

@implementation KenDeviceCellV

- (void)updateWithDevice:(KenDeviceDM *)device {
    _device = device;
    
    NSString *url = [@"http://" stringByAppendingFormat:@"%@:%zd/cfg.cgi?User=%@&Psd=%@&MsgID=20&chl=1", device.currentIp, _device.httpport, device.usr, device.pwd];
    [self.imageView makeSamllToastActivity];
    @weakify(self)
    [self.imageView sd_setImageWithURL:[NSURL URLWithString:url] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        @strongify(self)
        [self.imageView hideToastActivity];
    }];
    
    self.nameLabel.text = device.name;
    self.alarmView.image = [UIImage imageNamed:device.haveUnreadAlarm ? @"home_alarm_more" : @"home_alarm"];
    
    [self setAlarmStatus:device.alarmOnoff];
    [self freshBg];
}

#pragma mark - private method
- (void)freshBg {
    self.backgroundColor = [UIColor whiteColor];
    self.layer.cornerRadius = 4;
    self.layer.masksToBounds = YES;
    self.layer.borderColor = [UIColor appSepLineColor].CGColor;
    self.layer.borderWidth = 0.5;
}

- (void)setAlarmStatus:(BOOL)on {
    self.alarmLabel.text = on ? @"关闭提醒" : @"报警提醒";
    self.alarmLabel.textColor = on ? [UIColor whiteColor] : [UIColor appMainColor];
    self.alarmLabel.backgroundColor = on ? [UIColor appMainColor] :[UIColor whiteColor];
}

#pragma mark - getter setter
- (UILabel *)alarmLabel {
    if (_alarmLabel == nil) {
        _alarmLabel = [UILabel labelWithTxt:@"" frame:(CGRect){self.width - 60, self.height - 30 + 4, 54, 22}
                                       font:[UIFont appFontSize11] color:[UIColor appWhiteTextColor]];
        _alarmLabel.layer.cornerRadius = 3;
        _alarmLabel.layer.borderColor = [UIColor appMainColor].CGColor;
        _alarmLabel.layer.borderWidth = 0.5;
        _alarmLabel.layer.masksToBounds = YES;
        [self addSubview:_alarmLabel];
        
        @weakify(self)
        [_alarmLabel clicked:^(UIView * _Nonnull view) {
            @strongify(self)
            [[KenServiceManager sharedServiceManager] alarmSetOnOff:!self.device.alarmOnoff sn:self.device.sn success:^{
            } successBlock:^(BOOL successful, NSString * _Nullable errMsg, id  _Nullable responseData) {
                if (successful) {
                    self.device.alarmOnoff = !self.device.alarmOnoff;
                    [self setAlarmStatus:self.device.alarmOnoff];
                }
            } failedBlock:^(NSInteger status, NSString * _Nullable errMsg) {
            }];
        }];
    }
    return _alarmLabel;
}

//- (UILabel *)statusLabel {
//    if (_statusLabel == nil) {
//        _statusLabel = [UILabel labelWithTxt:@"" frame:(CGRect){0, 4, self.width, self.height - 55}
//                                        font:[UIFont appFontSize16] color:[UIColor appWhiteTextColor]];
//        [self addSubview:_statusLabel];
//    }
//    return _statusLabel;
//}

- (UILabel *)nameLabel {
    if (_nameLabel == nil) {
        UIView *nameV = [[UIView alloc] initWithFrame:(CGRect){0, self.height - 55, self.width, 25}];
        nameV.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.2];
        [self addSubview:nameV];
        
        _nameLabel = [UILabel labelWithTxt:@"" frame:(CGRect){10, 0, self.width - 20, nameV.height} font:[UIFont appFontSize12] color:[UIColor appWhiteTextColor]];
        _nameLabel.textAlignment = NSTextAlignmentLeft;
        [nameV addSubview:_nameLabel];
        
        UIView *bottomV = [[UIView alloc] initWithFrame:(CGRect){0, self.height - 30, self.width, 30}];
        bottomV.backgroundColor = [UIColor whiteColor];
        [self addSubview:bottomV];
    }
    return _nameLabel;
}

- (UIImageView *)imageView {
    if (_imageView == nil) {
        _imageView = [[UIImageView alloc] initWithFrame:(CGRect){0, 0, self.width, self.height - 30}];
        _imageView.backgroundColor = [UIColor blackColor];
        
        [self addSubview:_imageView];
    }
    return _imageView;
}

- (UIImageView *)alarmView {
    if (_alarmView == nil) {
        _alarmView = [[UIImageView alloc] initWithFrame:(CGRect){0, self.height - 30, 44, 30}];
        _alarmView.contentMode = UIViewContentModeCenter;
        [self addSubview:_alarmView];
        
        @weakify(self)
        [_alarmView clicked:^(UIView * _Nonnull view) {
            @strongify(self)
            self.device.haveUnreadAlarm = NO;
            [SysDelegate.rootVC.alarmVC alarmWithDeivce:self.device.sn];
            [SysDelegate.rootVC setSelectedIndex:3];
        }];
    }
    return _alarmView;
}

@end
