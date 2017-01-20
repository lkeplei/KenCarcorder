//
//  NSDate+KenDate.h
//  achr
//
//  Created by Ken.Liu on 16/5/19.
//  Copyright © 2016年 Hangzhou Ai Cai Network Technology Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (KenDate)

#pragma mark - 基础方法，获取年、月、日、时、分、秒
- (NSUInteger)year;
- (NSUInteger)month;
- (NSUInteger)day;
- (NSUInteger)hour;
- (NSUInteger)minute;
- (NSUInteger)second;

- (NSString *)yearStr;
- (NSString *)monthStr;
- (NSString *)dayStr;
- (NSString *)hourStr;
- (NSString *)minuteStr;
- (NSString *)secondStr;

+ (NSUInteger)year:(NSDate *)date;
+ (NSUInteger)month:(NSDate *)date;
+ (NSUInteger)day:(NSDate *)date;
+ (NSUInteger)hour:(NSDate *)date;
+ (NSUInteger)minute:(NSDate *)date;
+ (NSUInteger)second:(NSDate *)date;

#pragma mark - 比较、时间偏移
//是否为同一天，是返回YES，否则返回NO
- (BOOL)isSameDay:(NSDate *)anotherDate;

//返回numYears年后的日期
- (NSDate *)offsetYears:(NSInteger)numYears;
+ (NSDate *)offsetYears:(NSInteger)numYears fromDate:(NSDate *)fromDate;

//返回numMonths月后的日期
- (NSDate *)offsetMonths:(NSInteger)numMonths;
+ (NSDate *)offsetMonths:(NSInteger)numMonths fromDate:(NSDate *)fromDate;

//返回numDays天后的日期
- (NSDate *)offsetDays:(NSInteger)numDays;
+ (NSDate *)offsetDays:(NSInteger)numDays fromDate:(NSDate *)fromDate;

//返回numHours小时后的日期
- (NSDate *)offsetHours:(NSInteger)hours;
+ (NSDate *)offsetHours:(NSInteger)numHours fromDate:(NSDate *)fromDate;

#pragma mark - 扩展方法
//获取指定格式的日间字符串
- (NSString *)stringWithFormat:(NSString *)format;

//根据格式和字符串获取date
+ (NSDate *)dateFromString:(NSString *)string format:(NSString *)format;

//获取当前月的第一天
- (NSDate *)firstDayOfMonth;
+ (NSDate *)firstDayOfMonth:(NSDate *)date;

//获取当前月的最后一天
- (NSDate *)lastDayOfMonth;
+ (NSDate *)lastDayOfMonth:(NSDate *)date;

@end
