//
//  NSDate+KenDate.m
//  achr
//
//  Created by Ken.Liu on 16/5/19.
//  Copyright © 2016年 Hangzhou Ai Cai Network Technology Co., Ltd. All rights reserved.
//

#import "NSDate+KenDate.h"

typedef NS_ENUM(NSUInteger, KenCalendarUnit)
{
    KenCalendarUnitEra                = NSCalendarUnitEra,
    KenCalendarUnitYear               = NSCalendarUnitYear,
    KenCalendarUnitMonth              = NSCalendarUnitMonth,
    KenCalendarUnitDay                = NSCalendarUnitDay,
    KenCalendarUnitHour               = NSCalendarUnitHour,
    KenCalendarUnitMinute             = NSCalendarUnitMinute,
    KenCalendarUnitSecond             = NSCalendarUnitSecond,
};

@implementation NSDate (KenDate)

#pragma mark - 基础方法，获取年、月、日、时、分、秒
- (NSUInteger)year {
    return [NSDate year:self];
}

- (NSUInteger)month {
    return [NSDate month:self];
}

- (NSUInteger)day {
    return [NSDate day:self];
}

- (NSUInteger)hour {
    return [NSDate hour:self];
}

- (NSUInteger)minute {
    return [NSDate minute:self];
}

- (NSUInteger)second {
    return [NSDate second:self];
}

- (NSString *)yearStr {
    return [NSString stringWithFormat:@"%zd", [self year]];
}

- (NSString *)monthStr {
    return [NSString stringWithFormat:@"%02zd", [self month]];
}

- (NSString *)dayStr {
    return [NSString stringWithFormat:@"%02zd", [self day]];
}

- (NSString *)hourStr {
    return [NSString stringWithFormat:@"%02zd", [self hour]];
}

- (NSString *)minuteStr {
    return [NSString stringWithFormat:@"%02zd", [self minute]];
}

- (NSString *)secondStr {
    return [NSString stringWithFormat:@"%02zd", [self second]];
}

+ (NSUInteger)year:(NSDate *)date {
    if (date == nil) return -1;
    return [[self getDateComponentsWithType:KenCalendarUnitYear date:date] year];
}

+ (NSUInteger)month:(NSDate *)date {
    if (date == nil) return -1;
    return [[self getDateComponentsWithType:KenCalendarUnitMonth date:date] month];
}

+ (NSUInteger)day:(NSDate *)date {
    if (date == nil) return -1;
    return [[self getDateComponentsWithType:KenCalendarUnitDay date:date] day];
}

+ (NSUInteger)hour:(NSDate *)date {
    if (date == nil) return -1;
    return [[self getDateComponentsWithType:KenCalendarUnitHour date:date] hour];
}

+ (NSUInteger)minute:(NSDate *)date {
    if (date == nil) return -1;
    return [[self getDateComponentsWithType:KenCalendarUnitMinute date:date] minute];
}

+ (NSUInteger)second:(NSDate *)date {
    if (date == nil) return -1;
    return [[self getDateComponentsWithType:KenCalendarUnitSecond date:date] second];
}

+ (NSDateComponents *)getDateComponentsWithType:(KenCalendarUnit)type date:(NSDate *)date {
    if (date == nil) return nil;
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_8_0
    NSDateComponents *components = [calendar components:(NSCalendarUnit)type fromDate:date];
#else
    NSCalendarUnit calendarType = NSEraCalendarUnit;
    switch (type) {
        case KenCalendarUnitEra: {
            calendarType = NSEraCalendarUnit;
        }
            break;
        case KenCalendarUnitYear: {
            calendarType = NSYearCalendarUnit;
        }
            break;
        case KenCalendarUnitMonth: {
            calendarType = NSMonthCalendarUnit;
        }
            break;
        case KenCalendarUnitDay: {
            calendarType = NSDayCalendarUnit;
        }
            break;
        case KenCalendarUnitHour: {
            calendarType = NSHourCalendarUnit;
        }
            break;
        case KenCalendarUnitMinute: {
            calendarType = NSMinuteCalendarUnit;
        }
            break;
        case KenCalendarUnitSecond: {
            calendarType = NSSecondCalendarUnit;
        }
            break;
    }
    NSDateComponents *components = [calendar components:calendarType fromDate:date];
#endif
    
    return components;
}

#pragma mark - 比较、时间偏移
- (BOOL)isSameDay:(NSDate *)date {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components1 = [calendar components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay)
                                                fromDate:self];
    NSDateComponents *components2 = [calendar components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay)
                                                fromDate:date];
    return ([components1 year] == [components2 year] && [components1 month] == [components2 month] && [components1 day] == [components2 day]);
}

- (NSDate *)offsetYears:(NSInteger)numYears {
    return [NSDate offsetYears:numYears fromDate:self];
}

+ (NSDate *)offsetYears:(NSInteger)numYears fromDate:(NSDate *)fromDate {
    if (fromDate == nil) return nil;
    
    NSDateComponents *offsetComponents = [[NSDateComponents alloc] init];
    [offsetComponents setYear:numYears];
    
    return [[self getCalendar] dateByAddingComponents:offsetComponents toDate:fromDate options:0];
}

- (NSDate *)offsetMonths:(NSInteger)numMonths {
    return [NSDate offsetMonths:numMonths fromDate:self];
}

+ (NSDate *)offsetMonths:(NSInteger)numMonths fromDate:(NSDate *)fromDate {
    if (fromDate == nil) return nil;

    NSDateComponents *offsetComponents = [[NSDateComponents alloc] init];
    [offsetComponents setMonth:numMonths];
    
    return [[self getCalendar] dateByAddingComponents:offsetComponents toDate:fromDate options:0];
}

- (NSDate *)offsetDays:(NSInteger)numDays {
    return [NSDate offsetDays:numDays fromDate:self];
}

+ (NSDate *)offsetDays:(NSInteger)numDays fromDate:(NSDate *)fromDate {
    if (fromDate == nil) return nil;
    
    NSDateComponents *offsetComponents = [[NSDateComponents alloc] init];
    [offsetComponents setDay:numDays];
    
    return [[self getCalendar] dateByAddingComponents:offsetComponents toDate:fromDate options:0];
}

- (NSDate *)offsetHours:(NSInteger)hours {
    return [NSDate offsetHours:hours fromDate:self];
}

+ (NSDate *)offsetHours:(NSInteger)numHours fromDate:(NSDate *)fromDate {
    if (fromDate == nil) return nil;

    NSDateComponents *offsetComponents = [[NSDateComponents alloc] init];
    [offsetComponents setHour:numHours];
    
    return [[self getCalendar] dateByAddingComponents:offsetComponents toDate:fromDate options:0];
}

+ (NSCalendar *)getCalendar {
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_8_0
    // NSDayCalendarUnit
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
#else
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
#endif
    
    return calendar;
}

#pragma mark - 扩展方法
- (NSString *)stringWithFormat:(NSString *)format {
    NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
    [outputFormatter setDateFormat:format];
    return [outputFormatter stringFromDate:self];
}

+ (NSDate *)dateFromString:(NSString *)string format:(NSString *)format {
    NSDateFormatter *inputFormatter = [[NSDateFormatter alloc] init];
    [inputFormatter setLocale:[NSLocale localeWithLocaleIdentifier:@"zh_CN"]];
    [inputFormatter setDateFormat:format];
    
    NSDate *date = [inputFormatter dateFromString:string];
    
    return date;
}

- (NSDate *)firstDayOfMonth {
    return [NSDate firstDayOfMonth:self];
}

+ (NSDate *)firstDayOfMonth:(NSDate *)date {
    if (date == nil) return nil;
    
    return [date offsetDays:-[date day] + 1];
}

- (NSDate *)lastDayOfMonth {
    return [NSDate lastDayOfMonth:self];
}

+ (NSDate *)lastDayOfMonth:(NSDate *)date {
    if (date == nil) return nil;
    
    NSDate *lastDate = [self firstDayOfMonth:date];
    return [[lastDate offsetMonths:1] offsetDays:-1];
}
@end
