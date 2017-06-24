//
//  KenPlayCell.m
//  KenCarcorder
//
//  Created by 邱根友 on 2017/6/17.
//  Copyright © 2017年 Ken.Liu. All rights reserved.
//

#import "KenPlayCell.h"
#import "KenPlayDeviceDM.h"
#import "UIImageView+WebCache.h"

@interface KenPlayCell ()

@property (nonatomic, strong) KenPlayDeviceItemDM *device;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *discussLabel;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIImageView *alarmView;

@end

@implementation KenPlayCell

- (void)updateWithDevice:(KenPlayDeviceItemDM *)device {
    self.backgroundColor = [UIColor redColor];
    
    _device = device;
    
    [self.imageView makeSamllToastActivity];
    @weakify(self)
    [self.imageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", kAppServerHost, device.imageUrl]]
                             completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        @strongify(self)
        [self.imageView hideToastActivity];
    }];
    
    self.nameLabel.text = device.name;
    self.discussLabel.text = device.topDiscuss;
    
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
- (UIImageView *)imageView {
    if (_imageView == nil) {
        _imageView = [[UIImageView alloc] initWithFrame:(CGRect){0, 0, self.width, self.height - 20}];
        _imageView.backgroundColor = [UIColor blackColor];
        
        [self addSubview:_imageView];
    }
    return _imageView;
}

- (UILabel *)nameLabel {
    if (_nameLabel == nil) {
        UIView *nameV = [[UIView alloc] initWithFrame:(CGRect){0, self.height - 40, self.width, 20}];
        nameV.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.2];
        [self addSubview:nameV];
        
        _nameLabel = [UILabel labelWithTxt:@"" frame:(CGRect){6, 0, self.width - 12, nameV.height} font:[UIFont appFontSize12] color:[UIColor appWhiteTextColor]];
        _nameLabel.textAlignment = NSTextAlignmentLeft;
        [nameV addSubview:_nameLabel];
    }
    return _nameLabel;
}

- (UILabel *)discussLabel {
    if (_discussLabel == nil) {
        UIView *discussV = [[UIView alloc] initWithFrame:(CGRect){0, self.height - 20, self.width, 20}];
        discussV.backgroundColor = [UIColor whiteColor];
        [self addSubview:discussV];
        
        _discussLabel = [UILabel labelWithTxt:@"" frame:(CGRect){6, 0, self.width - 12, discussV.height} font:[UIFont appFontSize12] color:[UIColor appBlackTextColor]];
        _discussLabel.textAlignment = NSTextAlignmentLeft;
        [discussV addSubview:_discussLabel];
    }
    return _discussLabel;
}

@end
