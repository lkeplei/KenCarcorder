//
//  KenSegmentV.h
//  KenCarcorder
//
//  Created by 邱根友 on 2017/5/6.
//  Copyright © 2017年 Ken.Liu. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, KenSegmentItemStatus) {
    kKenSegmentItemNormal = 0,
    kKenSegmentItemSelected = 1,
};

@interface KenSegmentV : UIView

@property (nonatomic, copy) void (^segmentSelectChanged)(NSInteger index);

- (instancetype)initWithItem:(NSArray *)array frame:(CGRect)frame;

@end


#pragma mark - item
@interface KenSegmentItemV : UIView

@property (nonatomic, assign) KenSegmentItemStatus status;

- (instancetype)initWithTitle:(NSString *)title frame:(CGRect)frame;

@end
