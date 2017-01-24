//
//  NSDate+WT.m
//  WiseTime
//
//  Created by Michael Shrader on 6/19/14.
//  Copyright (c) 2014 Crank211. All rights reserved.
//

#import "NSDate+WT.h"

#define DATE_COMPONENTS (NSCalendarUnitYear| NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitWeekOfYear |  NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond | NSCalendarUnitWeekday | NSCalendarUnitWeekdayOrdinal)
#define CURRENT_CALENDAR [NSCalendar currentCalendar]

const int kSecondsInMinute = 60;
const int kMinutesInHour = 60;
const int kHoursInDay = 24;
const int kDaysInWeek = 7;
const int kDaysInMonthAvg = 30;
const int kDaysInYear = 365;

@implementation NSDate (WT)

- (BOOL)willUseAgo
{
    NSDate * now = [NSDate date];
    NSTimeInterval ti = [now timeIntervalSinceDate:self];

    return (ti < kSecondsInMinute * kMinutesInHour * kHoursInDay);
}

- (NSString *)agoOrDate
{
    NSDate * now = [NSDate date];
    NSTimeInterval ti = [now timeIntervalSinceDate:self];

    if (ti < kSecondsInMinute * kMinutesInHour * kHoursInDay) {
        return [self ago];
    }
    else {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"dd MMM"];
        return [formatter stringFromDate:self];
    }
}
- (NSString *)timeString
{
    NSDateFormatter *timeFormatter = [[NSDateFormatter alloc] init];
    [timeFormatter setDateFormat:@"h:mma"];

    return [[timeFormatter stringFromDate:self] lowercaseString];
}

- (NSString *)timeWithWeekday
{
    NSDateFormatter *dayFormatter = [[NSDateFormatter alloc] init];
    [dayFormatter setDateFormat:@"EEE"];

    return [NSString stringWithFormat:@"%@\n%@",
                                      [self timeString], [dayFormatter stringFromDate:self]];
}

- (NSString *)timeStringWithDate
{
    NSDateFormatter *dayFormatter = [[NSDateFormatter alloc] init];
    [dayFormatter setDateFormat:@"MMM d"];

    return [NSString stringWithFormat:@"%@ on %@",
                                      [self timeString], [dayFormatter stringFromDate:self]];
}

- (NSString *)yearString
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];

    [formatter setDateFormat:@"Y"];
    return [formatter stringFromDate:self];
}

- (NSString *)dateString
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];

    [formatter setDateFormat:@"M/d/Y"];
    return [formatter stringFromDate:self];
}

- (NSString *)dateStringForWeek
{
    NSDate *sunday = [self dateBySubtractingDays:self.weekday - 1];
    NSDate *saturday = [self getLastDayInWeek];

    return [NSString stringWithFormat:@"%@ - %@", [sunday dateString], [saturday dateString]];
}

- (NSString *)longDateStringForMonth
{
    NSDate *firstDayInMonth = [self getFirstDayInMonth];
    NSDate *lastDayInMonth = [self getLastDayInMonth];

    return [NSString stringWithFormat:@"%@ - %@", [firstDayInMonth dateString], [lastDayInMonth dateString]];
}

// Months
#define JANUARY @"January"
#define FEBRUARY @"February"
#define MARCH @"March"
#define APRIL @"April"
#define MAY @"May"
#define JUNE @"June"
#define JULY @"July"
#define AUGUST @"August"
#define SEPTEMBER @"September"
#define OCTOBER @"October"
#define NOVEMBER @"November"
#define DECEMBER @"December"

- (NSString *)dateStringForMonth
{
    NSString *month;

    switch (self.month)
    {
        case 1:
            month = JANUARY;
            break;
        case 2:
            month = FEBRUARY;
            break;
        case 3:
            month = MARCH;
            break;
        case 4:
            month = APRIL;
            break;
        case 5:
            month = MAY;
            break;
        case 6:
            month = JUNE;
            break;
        case 7:
            month = JULY;
            break;
        case 8:
            month = AUGUST;
            break;
        case 9:
            month = SEPTEMBER;
            break;
        case 10:
            month = OCTOBER;
            break;
        case 11:
            month = NOVEMBER;
            break;
        case 12:
            month = DECEMBER;
            break;
    }


    return [NSString stringWithFormat:@"%@ %@", month, self.yearString];
}

- (NSDate *)getFirstDayInWeek
{
    return [self dateBySubtractingDays:self.weekday - 1];
}

- (NSDate *)getLastDayInWeek
{
    return [[self getFirstDayInWeek] dateByAddingDays:6];
}

- (NSDate *)getFirstDayInMonth
{
    return [self dateBySubtractingDays:self.day - 1];
}

- (NSDate *)getLastDayInMonth
{
    return [[self getFirstDayInMonth] dateByAddingDays:[self daysInMonth].length - 1];
}

- (NSRange)daysInMonth
{
    NSCalendar *c = [NSCalendar currentCalendar];
    NSRange days = [c rangeOfUnit:NSDayCalendarUnit
                           inUnit:NSMonthCalendarUnit
                          forDate:self];
    return days;
}

- (NSString *)ago
{
    NSDate *now = [NSDate date];
    if ([now isBeforeDate:self]) {

        // timestamp returned from server sometimes 2 seconds in future so fix it here - hacktastic
        return [NSString stringWithFormat: @"2 secs ago\nToday"];
    }
    NSTimeInterval ti = [now timeIntervalSinceDate:self];
    NSTimeInterval tiSinceMidnight = [self timeIntervalSinceMidnightToday];
//    NSTimeInterval difference = ti - fabs(tiSinceMidnight);
    // any time today
    if(tiSinceMidnight > 0){ // happened today
        if (ti < kSecondsInMinute) {
            NSInteger secondsAgo = ti;
            if (secondsAgo > 1) {
                return [NSString stringWithFormat:NSLocalizedString(@"%d secs ago\nToday", "seconds ago"), (int)ti];
            }
            else {
                return NSLocalizedString(@"1 sec ago\nToday", "second ago");
            }
        }
        else if (ti < kSecondsInMinute * kMinutesInHour) {
            NSInteger minutesAgo = ti / kSecondsInMinute;
            if (minutesAgo > 1) {
                return [NSString stringWithFormat:NSLocalizedString(@"%d mins ago\nToday", "minutes ago"), minutesAgo];
            }
            else {
                return NSLocalizedString(@"1 min ago\nToday", "min ago");
            }
        }
        else if (ti < kSecondsInMinute * kMinutesInHour * kHoursInDay) {
            NSInteger hourSeconds = kSecondsInMinute * kMinutesInHour;
            NSInteger hoursAgo = ti / hourSeconds;
            if (hoursAgo > 1) {
                return [NSString stringWithFormat:NSLocalizedString(@"%d hours ago\nToday", "hours ago"), (int)(ti / hourSeconds)];
            }
            else {
                return NSLocalizedString(@"1 hour ago\nToday", "hour ago");
            }
        }
    }
            // 00:00 - 23:59 yesterday
    else if(abs(tiSinceMidnight) < kSecondsInMinute * kMinutesInHour * kHoursInDay){
        return [NSString stringWithFormat:NSLocalizedString(@"%@\nYesterday", "time yesterday"), [self timeString]];
    }
            // until 1 week ago
    else if (ti < kSecondsInMinute * kMinutesInHour * kHoursInDay * kDaysInWeek - 1) {
//        BOOL weekday = ti >= kSecondsInMinute * kMinutesInHour * kHoursInDay * 2;
        return [self timeWithWeekday];
    }
            // 1 week ago or more until 1 year
    else if (ti < kSecondsInMinute * kMinutesInHour * kHoursInDay * kDaysInYear) {
        NSInteger weekSeconds =  kSecondsInMinute * kMinutesInHour * kHoursInDay * kDaysInWeek;
        NSInteger weeksAgo = ti / weekSeconds;
        if (weeksAgo > 1) {
            return [NSString stringWithFormat:NSLocalizedString(@"%d weeks ago", "weeks ago"), (int)weeksAgo];
        }
        else {
            return NSLocalizedString(@"1 week ago", "week ago");
        }
    }
            // 1 year ago or more
    else {
        NSInteger yearSeconds = kSecondsInMinute * kMinutesInHour * kHoursInDay * kDaysInYear;
        NSInteger yearsAgo = ti / yearSeconds;
        if (yearsAgo > 1) {
            return [NSString stringWithFormat:NSLocalizedString(@"%d years ago", "years ago"), (int)yearsAgo];
        }
        else {
            return NSLocalizedString(@"1 year ago", "year ago");
        }
    }
    return nil;
}

- (NSTimeInterval)timeIntervalSinceMidnightToday
{
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    [gregorian setTimeZone:[NSTimeZone localTimeZone]];

    //2. Get tomorrow's date
    NSDateComponents *offsetComponents = [gregorian components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit fromDate:[NSDate date]];
    [offsetComponents setHour:0];
    [offsetComponents setMinute:0];
    [offsetComponents setSecond:0];
    NSDate *midnight = [gregorian dateFromComponents:offsetComponents];
    NSTimeInterval diff = [self timeIntervalSinceDate:midnight];
//    EMLog(@"\nthis: %@\nmidn: %@\ndiff: %f", self, midnight, diff);
    return diff;
}

static NSArray *_names = nil;
- (NSString *)weekdayStringShort
{
    if(nil == _names){
        _names = [NSArray arrayWithObjects:@"Su", @"M", @"T", @"W", @"Th", @"F", @"S", nil];
    }
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
//    [gregorian setTimeZone:[NSTimeZone localTimeZone]];

    NSDateComponents *offsetComponents = [gregorian components:NSWeekdayCalendarUnit fromDate:self];
    NSInteger weekday = [offsetComponents weekday];
    return [_names objectAtIndex:weekday-1];
}

- (BOOL)isPast
{
    return [self compare:[NSDate date]] != NSOrderedDescending;
}

/*
 The receiver is later in time than anotherDate, NSOrderedDescending
 The receiver is earlier in time than anotherDate, NSOrderedAscending.
 */

- (BOOL)isBeforeDate:(NSDate *)date
{
    return [self compare:date] == NSOrderedAscending;
}
- (BOOL)isAfterDate:(NSDate *)date
{
    return [self compare:date] == NSOrderedDescending;
}


#pragma mark Relative Dates

+ (NSDate *) dateWithDaysFromNow: (NSInteger) days
{
    // Thanks, Jim Morrison
    return [[NSDate date] dateByAddingDays:days];
}

+ (NSDate *) dateWithDaysBeforeNow: (NSInteger) days
{
    // Thanks, Jim Morrison
    return [[NSDate date] dateBySubtractingDays:days];
}

+ (NSDate *) dateTomorrow
{
    return [NSDate dateWithDaysFromNow:1];
}

+ (NSDate *) dateYesterday
{
    return [NSDate dateWithDaysBeforeNow:1];
}

+ (NSDate *) dateWithHoursFromNow: (NSInteger) dHours
{
    NSTimeInterval aTimeInterval = [[NSDate date] timeIntervalSinceReferenceDate] + D_HOUR * dHours;
    NSDate *newDate = [NSDate dateWithTimeIntervalSinceReferenceDate:aTimeInterval];
    return newDate;
}

+ (NSDate *) dateWithHoursBeforeNow: (NSInteger) dHours
{
    NSTimeInterval aTimeInterval = [[NSDate date] timeIntervalSinceReferenceDate] - D_HOUR * dHours;
    NSDate *newDate = [NSDate dateWithTimeIntervalSinceReferenceDate:aTimeInterval];
    return newDate;
}

+ (NSDate *) dateWithMinutesFromNow: (NSInteger) dMinutes
{
    NSTimeInterval aTimeInterval = [[NSDate date] timeIntervalSinceReferenceDate] + D_MINUTE * dMinutes;
    NSDate *newDate = [NSDate dateWithTimeIntervalSinceReferenceDate:aTimeInterval];
    return newDate;
}

+ (NSDate *) dateWithMinutesBeforeNow: (NSInteger) dMinutes
{
    NSTimeInterval aTimeInterval = [[NSDate date] timeIntervalSinceReferenceDate] - D_MINUTE * dMinutes;
    NSDate *newDate = [NSDate dateWithTimeIntervalSinceReferenceDate:aTimeInterval];
    return newDate;
}

#pragma mark Comparing Dates

- (BOOL) isEqualToDateIgnoringTime: (NSDate *) aDate
{
    NSDateComponents *components1 = [CURRENT_CALENDAR components:DATE_COMPONENTS fromDate:self];
    NSDateComponents *components2 = [CURRENT_CALENDAR components:DATE_COMPONENTS fromDate:aDate];
    return ((components1.year == components2.year) &&
            (components1.month == components2.month) &&
            (components1.day == components2.day));
}

- (BOOL) isToday
{
    return [self isEqualToDateIgnoringTime:[NSDate date]];
}

- (BOOL) isTomorrow
{
    return [self isEqualToDateIgnoringTime:[NSDate dateTomorrow]];
}

- (BOOL) isYesterday
{
    return [self isEqualToDateIgnoringTime:[NSDate dateYesterday]];
}

// This hard codes the assumption that a week is 7 days
- (BOOL) isSameWeekAsDate: (NSDate *) aDate
{
    NSDateComponents *components1 = [CURRENT_CALENDAR components:DATE_COMPONENTS fromDate:self];
    NSDateComponents *components2 = [CURRENT_CALENDAR components:DATE_COMPONENTS fromDate:aDate];

    // for the Sunday wierdness given to us by the design so that Sunday is the last day of the week rather than the first
    if (components1.weekday == 1 || components2.weekday == 1)
    {
        if (components1.weekday == 1)
        {
            if (components1.weekOfYear == components2.weekOfYear)
            {
                // same week, same day == match
                if (components2.weekday == 1)
                {
                    return YES;
                }
                // our Sunday is the last day of the week
                else
                {
                    return NO;
                }
            }
            // if not Sunday, previous week is our same week
            else if (components1.weekOfYear - components2.weekOfYear == 1 && components2.weekday != 1)
            {
                return YES;
            }
        }
        // self != Sunday but comparison date is
        else
        {
             if (components2.weekOfYear - components1.weekOfYear == 1)
             {
                 return YES;
             }
             else
             {
                 return NO;
             }
        }
    }

    // normal comparison since we're not dealing with a Sunday
    if(components1.weekOfYear == components2.weekOfYear)
    {
        return YES;
    }

    // Must be same week. 12/31 and 1/1 will both be week "1" if they are in the same week
    if (components1.weekOfYear != components2.weekOfYear) return NO;

    // Must have a time interval under 1 week. Thanks @aclark
    return (abs([self timeIntervalSinceDate:aDate]) < D_WEEK);
}

- (BOOL) isThisWeek
{
    return [self isSameWeekAsDate:[NSDate date]];
}

- (BOOL) isNextWeek
{
    NSTimeInterval aTimeInterval = [[NSDate date] timeIntervalSinceReferenceDate] + D_WEEK;
    NSDate *newDate = [NSDate dateWithTimeIntervalSinceReferenceDate:aTimeInterval];
    return [self isSameWeekAsDate:newDate];
}

- (BOOL) isLastWeek
{
    NSTimeInterval aTimeInterval = [[NSDate date] timeIntervalSinceReferenceDate] - D_WEEK;
    NSDate *newDate = [NSDate dateWithTimeIntervalSinceReferenceDate:aTimeInterval];
    return [self isSameWeekAsDate:newDate];
}

// Thanks, mspasov
- (BOOL) isSameMonthAsDate: (NSDate *) aDate
{
    NSDateComponents *components1 = [CURRENT_CALENDAR components:NSYearCalendarUnit | NSMonthCalendarUnit fromDate:self];
    NSDateComponents *components2 = [CURRENT_CALENDAR components:NSYearCalendarUnit | NSMonthCalendarUnit fromDate:aDate];
    return ((components1.month == components2.month) &&
            (components1.year == components2.year));
}

- (BOOL) isThisMonth
{
    return [self isSameMonthAsDate:[NSDate date]];
}

- (BOOL) isSameYearAsDate: (NSDate *) aDate
{
    NSDateComponents *components1 = [CURRENT_CALENDAR components:NSYearCalendarUnit fromDate:self];
    NSDateComponents *components2 = [CURRENT_CALENDAR components:NSYearCalendarUnit fromDate:aDate];
    return (components1.year == components2.year);
}

- (BOOL) isThisYear
{
    // Thanks, baspellis
    return [self isSameYearAsDate:[NSDate date]];
}

- (BOOL) isNextYear
{
    NSDateComponents *components1 = [CURRENT_CALENDAR components:NSYearCalendarUnit fromDate:self];
    NSDateComponents *components2 = [CURRENT_CALENDAR components:NSYearCalendarUnit fromDate:[NSDate date]];

    return (components1.year == (components2.year + 1));
}

- (BOOL) isLastYear
{
    NSDateComponents *components1 = [CURRENT_CALENDAR components:NSYearCalendarUnit fromDate:self];
    NSDateComponents *components2 = [CURRENT_CALENDAR components:NSYearCalendarUnit fromDate:[NSDate date]];

    return (components1.year == (components2.year - 1));
}

- (BOOL) isEarlierThanDate: (NSDate *) aDate
{
    return ([self compare:aDate] == NSOrderedAscending);
}

- (BOOL) isLaterThanDate: (NSDate *) aDate
{
    return ([self compare:aDate] == NSOrderedDescending);
}

// Thanks, markrickert
- (BOOL) isInFuture
{
    return ([self isLaterThanDate:[NSDate date]]);
}

// Thanks, markrickert
- (BOOL) isInPast
{
    return ([self isEarlierThanDate:[NSDate date]]);
}


#pragma mark Roles
- (BOOL) isTypicallyWeekend
{
    NSDateComponents *components = [CURRENT_CALENDAR components:NSWeekdayCalendarUnit fromDate:self];
    if ((components.weekday == 1) ||
            (components.weekday == 7))
        return YES;
    return NO;
}

- (BOOL) isTypicallyWorkday
{
    return ![self isTypicallyWeekend];
}

#pragma mark Adjusting Dates

- (NSDate *) dateByAddingDays: (NSInteger) dDays
{
    NSTimeInterval aTimeInterval = [self timeIntervalSinceReferenceDate] + D_DAY * dDays;
    NSDate *newDate = [NSDate dateWithTimeIntervalSinceReferenceDate:aTimeInterval];
    return newDate;
}

- (NSDate *) dateBySubtractingDays: (NSInteger) dDays
{
    return [self dateByAddingDays: (dDays * -1)];
}

- (NSDate *) dateByAddingHours: (NSInteger) dHours
{
    NSTimeInterval aTimeInterval = [self timeIntervalSinceReferenceDate] + D_HOUR * dHours;
    NSDate *newDate = [NSDate dateWithTimeIntervalSinceReferenceDate:aTimeInterval];
    return newDate;
}

- (NSDate *) dateBySubtractingHours: (NSInteger) dHours
{
    return [self dateByAddingHours: (dHours * -1)];
}

- (NSDate *) dateByAddingMinutes: (NSInteger) dMinutes
{
    NSTimeInterval aTimeInterval = [self timeIntervalSinceReferenceDate] + D_MINUTE * dMinutes;
    NSDate *newDate = [NSDate dateWithTimeIntervalSinceReferenceDate:aTimeInterval];
    return newDate;
}

- (NSDate *) dateBySubtractingMinutes: (NSInteger) dMinutes
{
    return [self dateByAddingMinutes: (dMinutes * -1)];
}

- (NSDate *) dateAtStartOfDay
{
    NSDateComponents *components = [CURRENT_CALENDAR components:DATE_COMPONENTS fromDate:self];
    components.hour = 0;
    components.minute = 0;
    components.second = 0;
    return [CURRENT_CALENDAR dateFromComponents:components];
}

- (NSDate *) dateAtEndOfDay
{
    NSDateComponents *components = [CURRENT_CALENDAR components:DATE_COMPONENTS fromDate:self];
    components.hour = 23;
    components.minute = 59;
    components.second = 59;
    return [CURRENT_CALENDAR dateFromComponents:components];
}

- (NSDateComponents *) componentsWithOffsetFromDate: (NSDate *) aDate
{
    NSDateComponents *dTime = [CURRENT_CALENDAR components:DATE_COMPONENTS fromDate:aDate toDate:self options:0];
    return dTime;
}

#pragma mark Retrieving Intervals

- (NSInteger) minutesAfterDate: (NSDate *) aDate
{
    NSTimeInterval ti = [self timeIntervalSinceDate:aDate];
    return (NSInteger) (ti / D_MINUTE);
}

- (NSInteger) minutesBeforeDate: (NSDate *) aDate
{
    NSTimeInterval ti = [aDate timeIntervalSinceDate:self];
    return (NSInteger) (ti / D_MINUTE);
}

- (NSInteger) hoursAfterDate: (NSDate *) aDate
{
    NSTimeInterval ti = [self timeIntervalSinceDate:aDate];
    return (NSInteger) (ti / D_HOUR);
}

- (NSInteger) hoursBeforeDate: (NSDate *) aDate
{
    NSTimeInterval ti = [aDate timeIntervalSinceDate:self];
    return (NSInteger) (ti / D_HOUR);
}

- (NSInteger) daysAfterDate: (NSDate *) aDate
{
    NSTimeInterval ti = [self timeIntervalSinceDate:aDate];
    return (NSInteger) (ti / D_DAY);
}

- (NSInteger) daysBeforeDate: (NSDate *) aDate
{
    NSTimeInterval ti = [aDate timeIntervalSinceDate:self];
    return (NSInteger) (ti / D_DAY);
}

// Thanks, dmitrydims
// I have not yet thoroughly tested this
- (NSInteger)distanceInDaysToDate:(NSDate *)anotherDate
{
    NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *components = [gregorianCalendar components:NSDayCalendarUnit fromDate:self toDate:anotherDate options:0];
    return components.day;
}

#pragma mark Decomposing Dates

- (NSInteger) nearestHour
{
    NSTimeInterval aTimeInterval = [[NSDate date] timeIntervalSinceReferenceDate] + D_MINUTE * 30;
    NSDate *newDate = [NSDate dateWithTimeIntervalSinceReferenceDate:aTimeInterval];
    NSDateComponents *components = [CURRENT_CALENDAR components:NSHourCalendarUnit fromDate:newDate];
    return components.hour;
}

- (NSInteger) hour
{
    NSDateComponents *components = [CURRENT_CALENDAR components:DATE_COMPONENTS fromDate:self];
    return components.hour;
}

- (NSInteger) minute
{
    NSDateComponents *components = [CURRENT_CALENDAR components:DATE_COMPONENTS fromDate:self];
    return components.minute;
}

- (NSInteger) seconds
{
    NSDateComponents *components = [CURRENT_CALENDAR components:DATE_COMPONENTS fromDate:self];
    return components.second;
}

- (NSInteger) day
{
    NSDateComponents *components = [CURRENT_CALENDAR components:DATE_COMPONENTS fromDate:self];
    return components.day;
}

- (NSInteger) month
{
    NSDateComponents *components = [CURRENT_CALENDAR components:DATE_COMPONENTS fromDate:self];
    return components.month;
}

- (NSInteger) week
{
    NSDateComponents *components = [CURRENT_CALENDAR components:DATE_COMPONENTS fromDate:self];
    return components.week;
}

- (NSInteger) weekday
{
    NSDateComponents *components = [CURRENT_CALENDAR components:DATE_COMPONENTS fromDate:self];
    return components.weekday;
}

- (NSInteger) nthWeekday // e.g. 2nd Tuesday of the month is 2
{
    NSDateComponents *components = [CURRENT_CALENDAR components:DATE_COMPONENTS fromDate:self];
    return components.weekdayOrdinal;
}

- (NSInteger) year
{
    NSDateComponents *components = [CURRENT_CALENDAR components:DATE_COMPONENTS fromDate:self];
    return components.year;
}

@end