//
//  KenQRCodeVC.h
//  KenCarcorder
//
//  Created by 邱根友 on 2017/5/13.
//  Copyright © 2017年 Ken.Liu. All rights reserved.
//

#import "KenBaseVC.h"

@protocol QRReaderDelegate <NSObject>

- (void)qrReaderViewController:(UIViewController *)view didFinishPickingInformation:(NSString *)info;
- (void)qrReaderDismiss:(UIViewController *)view;

@end

@interface KenQRCodeVC : KenBaseVC

@property (nonatomic,weak) id<QRReaderDelegate> delegate;

@end
