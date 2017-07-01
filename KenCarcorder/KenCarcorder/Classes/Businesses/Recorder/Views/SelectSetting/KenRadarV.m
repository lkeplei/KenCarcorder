//
//  KenRadarV.m
//  KenCarcorder
//
//  Created by hzyouda on 2017/3/4.
//  Copyright © 2017年 Ken.Liu. All rights reserved.
//

#import "KenRadarV.h"

@implementation KenRadarV

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(self.bounds.size.width / 2, self.bounds.size.height / 2) radius:30 startAngle:0 endAngle:2 * M_PI clockwise:YES];
    path.lineWidth = 1.0;
    [[UIColor colorWithRed:28 / 255.0 green:49 / 255.0 blue:71 / 255.0 alpha:1.0] setFill];
    [[UIColor colorWithRed:28 / 255.0 green:49 / 255.0 blue:90 / 255.0 alpha:1.0] setStroke];
    [path stroke];
    [path fill];
}

- (void)animationWithDuraton:(NSTimeInterval)duration {
    [UIView animateWithDuration:duration animations:^{
        self.transform = CGAffineTransformScale(self.transform, 3.0, 3.0);
        self.alpha = 0.0;
    } completion:^(BOOL finished) {
        if (self.superview) {
            [self removeFromSuperview];
        }
    }];
}

@end
