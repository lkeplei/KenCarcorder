//
//  KenWifiSetStep42V.m
//  KenCarcorder
//
//  Created by Ken.Liu on 2017/2/25.
//  Copyright © 2017年 Ken.Liu. All rights reserved.
//

#import "KenWifiSetStep42V.h"
#import "Masonry.h"
#import "KenWifiSetStep4VC.h"

@interface KenWifiSetStep42V ()

@property (nonatomic, weak) KenWifiSetStep4VC *parentVC;

@end

@implementation KenWifiSetStep42V

- (instancetype)initWithParentVC:(KenWifiSetStep4VC *)parentVC frame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.userInteractionEnabled = YES;
        
        _parentVC = parentVC;
        
        [self initView];
    }
    return self;
}

#pragma mark - private method
- (void)initView {

}

@end
