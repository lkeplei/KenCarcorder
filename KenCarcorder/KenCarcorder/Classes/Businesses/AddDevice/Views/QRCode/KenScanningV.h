//
//  KenScanningV.h
//  KenCarcorder
//
//  Created by 邱根友 on 2017/5/13.
//  Copyright © 2017年 Ken.Liu. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, KenScanningStyle) {
    kKenScanningStyleQRCode = 0,
    kKenScanningStyleBook,
    kKenScanningStyleStreet,
    kKenScanningStyleWord,
};

@interface KenScanningV : UIView

@property (nonatomic, assign, readonly) KenScanningStyle scanningStyle;

- (void)transformScanningTypeWithStyle:(KenScanningStyle)style;
- (void)scanning;

@end
