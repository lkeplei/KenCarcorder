//
//  KenScanningV.m
//  KenCarcorder
//
//  Created by 邱根友 on 2017/5/13.
//  Copyright © 2017年 Ken.Liu. All rights reserved.
//

#import "KenScanningV.h"

#define kXHQRCodeTipString @"将二维码/条码放入框内，即可自动扫描"
#define kXHBookTipString @"将书、CD、电影海报放入框内，即可自动扫描"
#define kXHStreetTipString @"扫一下周围环境，讯在附近街景"
#define kXHWordTipString @"将英文单词放入框内"

#define kXHQRCodeRectPaddingX 55

typedef void(^TransformScanningAnimationBlock)(void);

@interface KenScanningV ()

@property (nonatomic, assign, readwrite) KenScanningStyle scanningStyle;
@property (nonatomic, strong) UIImageView *scanningImageView;
@property (nonatomic, assign) CGRect clearRect;
@property (nonatomic, strong) UILabel *QRCodeTipLabel;
@property (nonatomic, strong) UIButton *myQRCodeButton;

@end

@implementation KenScanningV
- (void)scanning {
    CGRect animationRect = self.scanningImageView.frame;
    animationRect.origin.y += CGRectGetWidth(self.bounds) - CGRectGetMinX(animationRect) * 2 - CGRectGetHeight(animationRect);
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDelay:0];
    [UIView setAnimationDuration:1.2];
    [UIView setAnimationCurve:UIViewAnimationCurveLinear];
    [UIView setAnimationRepeatCount:FLT_MAX];
    [UIView setAnimationRepeatAutoreverses:NO];
    
    self.scanningImageView.hidden = NO;
    self.scanningImageView.frame = animationRect;
    [UIView commitAnimations];
}

#pragma mark - Propertys
static CGFloat ScanningOffetY = 130;
- (UIImageView *)scanningImageView {
    if (!_scanningImageView) {
        _scanningImageView = [[UIImageView alloc] initWithFrame:CGRectMake(55, ScanningOffetY, CGRectGetWidth(self.bounds) - 110, 3)];
        [_scanningImageView setImage:[UIImage imageNamed:@"scan_sanning_line.png"]];
    }
    return _scanningImageView;
}

- (UILabel *)QRCodeTipLabel {
    if (!_QRCodeTipLabel) {
        _QRCodeTipLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(self.clearRect) + ScanningOffetY, CGRectGetWidth(self.bounds) - 20, 20)];
        _QRCodeTipLabel.text = kXHQRCodeTipString;
        _QRCodeTipLabel.numberOfLines = 0;
        _QRCodeTipLabel.textColor = [UIColor whiteColor];
        _QRCodeTipLabel.backgroundColor = [UIColor clearColor];
        _QRCodeTipLabel.textAlignment = NSTextAlignmentCenter;
        _QRCodeTipLabel.font = [UIFont systemFontOfSize:12];
    }
    return _QRCodeTipLabel;
}

- (UIButton *)myQRCodeButton {
    if (!_myQRCodeButton) {
        _myQRCodeButton = [[UIButton alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_QRCodeTipLabel.frame) + ScanningOffetY, 80, 20)];
        _myQRCodeButton.center = CGPointMake(CGRectGetWidth(self.bounds) / 2.0, _myQRCodeButton.center.y);
        [_myQRCodeButton setTitle:@"我的二维码" forState:UIControlStateNormal];
        [_myQRCodeButton setTitleColor:[UIColor colorWithRed:0.275 green:0.491 blue:1.000 alpha:1.000] forState:UIControlStateNormal];
        _myQRCodeButton.backgroundColor = [UIColor clearColor];
        _myQRCodeButton.titleLabel.font = [UIFont systemFontOfSize:14];
    }
    return _myQRCodeButton;
}

#pragma mark - Public Api
- (void)transformScanningTypeWithStyle:(KenScanningStyle)style {
    self.scanningStyle = style;
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        [self setNeedsDisplay];
    } completion:^(BOOL finished) {
        
    }];
}

#pragma mark - Life Cycle
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor colorWithWhite:0.000 alpha:0.500];
        
        self.clearRect = CGRectMake(kXHQRCodeRectPaddingX, ScanningOffetY, CGRectGetWidth(frame) - kXHQRCodeRectPaddingX * 2, CGRectGetWidth(frame) - kXHQRCodeRectPaddingX * 2);
        
        [self addSubview:self.scanningImageView];
        [self addSubview:self.QRCodeTipLabel];
        [self.QRCodeTipLabel setHidden:YES];
        
        UIImageView *qrTipImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"scan_desc.png"]];
        qrTipImg.frame = (CGRect){(self.width - qrTipImg.width) / 2, CGRectGetMaxY(self.clearRect) + 30, qrTipImg.size};
        [self addSubview:qrTipImg];
        
        UIImageView *tipBg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"scan_bg.png"]];
        tipBg.frame = self.clearRect;
        [self addSubview:tipBg];
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, self.backgroundColor.CGColor);
    CGContextFillRect(context, rect);
    
    CGRect clearRect;
    CGFloat paddingX;
    
    CGFloat tipLabelPadding;
    
    self.scanningImageView.hidden = YES;
    self.myQRCodeButton.hidden = YES;
    switch (self.scanningStyle) {
        case kKenScanningStyleQRCode: {
            tipLabelPadding = ScanningOffetY;
            self.QRCodeTipLabel.text = kXHQRCodeTipString;
            
            self.myQRCodeButton.hidden = NO;
            self.scanningImageView .hidden = NO;
            paddingX = kXHQRCodeRectPaddingX;
            clearRect = CGRectMake(paddingX, ScanningOffetY, CGRectGetWidth(rect) - paddingX * 2, CGRectGetWidth(rect) - paddingX * 2);
            break;
        }
        case kKenScanningStyleStreet:
        case kKenScanningStyleBook:
            tipLabelPadding = 20;
            if (self.scanningStyle == kKenScanningStyleStreet) {
                self.QRCodeTipLabel.text = kXHStreetTipString;
            } else {
                self.QRCodeTipLabel.text = kXHBookTipString;
            }
            
            paddingX = 20;
            clearRect = CGRectMake(paddingX, 20, CGRectGetWidth(rect) - paddingX * 2, CGRectGetWidth(rect) - paddingX * 2);
            break;
        case kKenScanningStyleWord:
            tipLabelPadding = 25;
            self.QRCodeTipLabel.text = kXHWordTipString;
            
            paddingX = 50;
            clearRect = CGRectMake(paddingX, 100, CGRectGetWidth(rect) - paddingX * 2, 50);
            break;
        default:
            break;
    }
    
    self.clearRect = clearRect;
    
    CGRect QRCodeTipLabelFrame = self.QRCodeTipLabel.frame;
    QRCodeTipLabelFrame.origin.y = CGRectGetMaxY(self.clearRect) + tipLabelPadding;
    self.QRCodeTipLabel.frame = QRCodeTipLabelFrame;
    
    CGContextClearRect(context, clearRect);
    CGContextSaveGState(context);
}

@end
