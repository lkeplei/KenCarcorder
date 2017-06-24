//
//  KenPlayCell.h
//  KenCarcorder
//
//  Created by 邱根友 on 2017/6/17.
//  Copyright © 2017年 Ken.Liu. All rights reserved.
//

#import <UIKit/UIKit.h>

@class KenPlayDeviceItemDM;

@interface KenPlayCell : UICollectionViewCell

- (void)updateWithDevice:(KenPlayDeviceItemDM *)device;

@end
