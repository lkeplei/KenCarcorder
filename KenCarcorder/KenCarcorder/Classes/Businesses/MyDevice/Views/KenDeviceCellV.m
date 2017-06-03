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
@property (nonatomic, strong) UIImageView *imageView;

@end

@implementation KenDeviceCellV

- (void)updateWithDevice:(KenDeviceDM *)device {
    _device = device;
    
    NSString *url = [@"http://" stringByAppendingFormat:@"%@:%zd/cfg.cgi?User=%@&Psd=%@&MsgID=20&chl=1", device.currentIp, _device.httpport, device.usr, device.pwd];
    [self.imageView sd_setImageWithURL:[NSURL URLWithString:url] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        
    }];
    
    self.nameLabel.text = device.name;
    
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

#pragma mark - getter setter
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

@end
