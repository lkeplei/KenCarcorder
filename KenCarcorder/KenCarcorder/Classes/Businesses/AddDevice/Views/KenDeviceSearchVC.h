//
//  KenDeviceSearchVC.h
//  KenCarcorder
//
//  Created by 邱根友 on 2017/5/13.
//  Copyright © 2017年 Ken.Liu. All rights reserved.
//

#import "KenBaseVC.h"

@interface KenDeviceSearchVC : KenBaseVC<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, copy) void (^deviceSelcetBlock)(KenDeviceDM *device);

@end
