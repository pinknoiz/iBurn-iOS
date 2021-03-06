//
//  NSDateFormatter+iBurn.m
//  
//
//  Created by Christopher Ballinger on 7/31/14.
//
//

#import "NSDateFormatter+iBurn.h"

@implementation NSDateFormatter (iBurn)

+ (NSTimeZone*) brc_burningManTimeZone {
    return [NSTimeZone timeZoneWithName:@"PST"]; //use Gerlach time
}

+ (NSDateFormatter*) brc_playaEventsAPIDateFormatter
{
    static NSDateFormatter *brc_playaEventsAPIDateFormatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        brc_playaEventsAPIDateFormatter = [NSDateFormatter new];
        brc_playaEventsAPIDateFormatter.dateFormat = @"yyyy-MM-dd' 'HH:mm:ss";
        brc_playaEventsAPIDateFormatter.timeZone = [self brc_burningManTimeZone];
    });
    return brc_playaEventsAPIDateFormatter;
}

+ (NSDateFormatter*) brc_eventGroupDateFormatter
{
    static NSDateFormatter *brc_eventGroupDateFormatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        brc_eventGroupDateFormatter = [NSDateFormatter new];
        brc_eventGroupDateFormatter.dateFormat = @"yyyy-MM-dd";
        brc_eventGroupDateFormatter.timeZone = [self brc_burningManTimeZone];
    });
    return brc_eventGroupDateFormatter;
}

+ (NSDateFormatter*) brc_timeOnlyDateFormatter {
    static NSDateFormatter *brc_timeOnlyDateFormatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        brc_timeOnlyDateFormatter = [[NSDateFormatter alloc] init];
        brc_timeOnlyDateFormatter.dateFormat = @"h:mm a";
        brc_timeOnlyDateFormatter.timeZone = [self brc_burningManTimeZone];
    });
    return brc_timeOnlyDateFormatter;
}

+ (NSDateFormatter*) brc_dayOfWeekDateFormatter {
    static NSDateFormatter *brc_dayOfWeekDateFormatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        brc_dayOfWeekDateFormatter = [[NSDateFormatter alloc] init];
        brc_dayOfWeekDateFormatter.dateFormat = @"EEEE";
        brc_dayOfWeekDateFormatter.timeZone = [self brc_burningManTimeZone];
    });
    return brc_dayOfWeekDateFormatter;
}

+ (NSDateFormatter*) brc_shortDateFormatter {
    static NSDateFormatter *brc_shortDateFormatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        brc_shortDateFormatter = [[NSDateFormatter alloc] init];
        brc_shortDateFormatter.dateFormat = @"M/d";
        brc_shortDateFormatter.timeZone = [self brc_burningManTimeZone];
    });
    return brc_shortDateFormatter;
}

@end
