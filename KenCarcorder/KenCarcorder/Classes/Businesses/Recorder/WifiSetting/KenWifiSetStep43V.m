//
//  KenWifiSetStep43V.m
//  KenCarcorder
//
//  Created by Ken.Liu on 2017/2/25.
//  Copyright © 2017年 Ken.Liu. All rights reserved.
//

#import "KenWifiSetStep43V.h"
#import "Masonry.h"
#import "KenWifiSetStep4VC.h"
#import "KenRadarV.h"

@interface KenWifiSetStep43V ()

@property (nonatomic, weak) KenWifiSetStep4VC *parentVC;
@property (nonatomic, strong) UILabel *label3;
@property (nonatomic, strong) UIButton *sendBtn;

@end

@implementation KenWifiSetStep43V

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
    UILabel *label1 = [UILabel labelWithTxt:@"长按 '声波发送按钮' 直到声波发送完毕，让行车记录仪连接上WIFI无线网"
                                      frame:(CGRect){20, 100, self.width - 40, 60}
                                       font:[UIFont appFontSize16] color:[UIColor appWhiteTextColor]];
    label1.numberOfLines = 0;
    [self addSubview:label1];
    
    UILabel *label2 = [UILabel labelWithTxt:@"没有听到声波信号？" frame:(CGRect){20, self.height - kKenOffsetY(300), self.width - 40, 20}
                                       font:[UIFont appFontSize12] color:[UIColor appWhiteTextColor]];
    [self addSubview:label2];
    
    _label3 = [UILabel labelWithTxt:@"" frame:(CGRect){20, self.height - kKenOffsetY(220), self.width - 40, 54}
                               font:[UIFont appFontSize15] color:[UIColor colorWithHexString:@"#DAF23F"]];
    _label3.numberOfLines = 0;
    [self addSubview:_label3];

    ////////////////////
    _sendBtn = [UIButton buttonWithImg:@"声波发送" zoomIn:NO image:nil imagesec:nil target:self action:@selector(sendVoice:)];
    CGFloat width = self.width / 4;
    _sendBtn.frame = (CGRect){(self.width - width) / 2, (self.height - width) / 2, width, width};
    _sendBtn.backgroundColor = [UIColor colorWithRed:28 / 255.0 green:49 / 255.0 blue:71 / 255.0 alpha:1.0];
    _sendBtn.layer.cornerRadius = _sendBtn.width / 2;
    [self addSubview:_sendBtn];
    /////////////////////
}

- (void)sendVoice:(UIButton *)button {
    button.backgroundColor = [UIColor clearColor];
    
    CGFloat sw = self.width / 2;
    dispatch_source_t disTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_main_queue());
    __block int i = 10;
    dispatch_source_set_timer(disTimer, dispatch_walltime(NULL, 0), 0.5 * NSEC_PER_SEC, 0ull * NSEC_PER_SEC);
    dispatch_source_set_event_handler(disTimer, ^{
        KenRadarV *rv = [[KenRadarV alloc] initWithFrame:CGRectMake(0 , 0, sw / 2, sw / 2)];
        if (--i > 0) {
            [rv animationWithDuraton:4.0];
            rv.center = _sendBtn.center;
            [self addSubview:rv];
        } else {
            dispatch_source_cancel(disTimer);
        }
    });
    dispatch_source_set_cancel_handler(disTimer, ^{
        _label3.text = @"绿灯已灭，设置成功，等待重启，选择将行车记录仪加入我的APP，进行远程连接";
        button.backgroundColor = [UIColor colorWithRed:28 / 255.0 green:49 / 255.0 blue:71 / 255.0 alpha:1.0];
    });
    dispatch_resume(disTimer);
}

@end
