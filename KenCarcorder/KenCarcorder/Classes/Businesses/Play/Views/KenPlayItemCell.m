//
//  KenPlayItemCell.m
//  KenCarcorder
//
//  Created by 邱根友 on 2017/6/24.
//  Copyright © 2017年 Ken.Liu. All rights reserved.
//

#import "KenPlayItemCell.h"
#import "KenPlayDiscussDM.h"

@interface KenPlayItemCell ()

@property (nonatomic, strong) UILabel *dateL;
@property (nonatomic, strong) UILabel *nameL;
@property (nonatomic, strong) UILabel *timeL;
@property (nonatomic, strong) UILabel *discussL;

@end

@implementation KenPlayItemCell

- (void)setDiscussItem:(KenPlayDiscussItemDM *)discussItem {
    _discussItem = discussItem;
    
    self.dateL.text = [[discussItem timeDate] stringWithFormat:@"MM月dd日"];
    self.nameL.text = discussItem.userName;
    self.timeL.text = [self timeString:[discussItem timeDate]];
    self.discussL.text = discussItem.content;
}

- (NSString *)timeString:(NSDate *)date {
    NSDateComponents *com = [self getSubFromTwoDate:date to:[NSDate date]];
    NSString *timeStr = @"";
    if (com.year > 0 || com.month > 0 || com.day > 0) {
        timeStr = @"更早";
    } else {
        if (com.hour > 0) {
            timeStr = [@"" stringByAppendingFormat:@"%d小时", (int)com.hour];
        } else if (com.minute > 0) {
            timeStr = [@"" stringByAppendingFormat:@"%d分", (int)com.minute];
        } else if (com.second > 0) {
            timeStr = [@"" stringByAppendingFormat:@"%d秒", (int)com.second];
        }
    }
    return timeStr;
}

- (NSDateComponents*)getSubFromTwoDate:(NSDate*)from to:(NSDate*)to{
    NSCalendar *cal = [NSCalendar currentCalendar];//定义一个NSCalendar对象
    unsigned int unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
    return [cal components:unitFlags fromDate:from toDate:to options:0];
}

#pragma mark - getter setter
- (UILabel *)dateL {
    if (_dateL == nil) {
        UIImageView *avatarV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"play_default_head"]];
        avatarV.origin = CGPointMake(20, 20);
        [self.contentView addSubview:avatarV];
        
        _dateL = [UILabel labelWithTxt:@"" frame:(CGRect){0, avatarV.maxY, avatarV.width + 40, 20} font:[UIFont appFontSize14] color:[UIColor appMainColor]];
        [self.contentView addSubview:_dateL];
    }
    return _dateL;
}

- (UILabel *)nameL {
    if (_nameL == nil) {
        UIImageView *avatarV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"play_user"]];
        avatarV.origin = CGPointMake(self.dateL.maxX, 20);
        [self.contentView addSubview:avatarV];
        
        _nameL = [UILabel labelWithTxt:@"" frame:(CGRect){avatarV.maxX + 10, avatarV.originY, 100, avatarV.height}
                                  font:[UIFont appFontSize15] color:[UIColor appGrayTextColor]];
        _nameL.textAlignment = NSTextAlignmentLeft;
        [self.contentView addSubview:_nameL];
    }
    return _nameL;
}

- (UILabel *)timeL {
    if (_timeL == nil) {
        UIImageView *avatarV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"play_clock"]];
        avatarV.origin = CGPointMake(self.width - 80, self.nameL.originY);
        [self.contentView addSubview:avatarV];
        
        _timeL = [UILabel labelWithTxt:@"" frame:(CGRect){avatarV.maxX + 10, avatarV.minY, 70, avatarV.height} font:[UIFont appFontSize14] color:[UIColor appGrayTextColor]];
        _timeL.textAlignment = NSTextAlignmentLeft;
        [self.contentView addSubview:_timeL];
    }
    return _timeL;
}

- (UILabel *)discussL {
    if (_discussL == nil) {
        _discussL = [UILabel labelWithTxt:@"" frame:(CGRect){self.dateL.maxX , self.nameL.maxY + 10, self.width - self.dateL.maxX - 10, 50}
                                     font:[UIFont appFontSize14] color:[UIColor appBlackTextColor]];
        _discussL.textAlignment = NSTextAlignmentLeft;
        _discussL.numberOfLines = 0;
        [self.contentView addSubview:_discussL];
        
        UIView *line = [[UIView alloc] initWithFrame:(CGRect){20, _discussL.maxY+ 10, self.width - 40, 1}];
        line.backgroundColor = [UIColor appSepLineColor];
        [self.contentView addSubview:line];
    }
    return _discussL;
}

@end
