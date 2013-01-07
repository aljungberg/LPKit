/*
*   Filename:         CPDate+FirstLastDate.j
*   Created:          Mon Nov 19 10:51:55 PST 2012
*   Author:           Alexandre Wilhelm <alexandre.wilhelm@alcatel-lucent.com>
*   Description:      CNA Dashboard
*   Project:          Cloud Network Automation - Nuage - Data Center Service Delivery - IPD
*
* Copyright (c) 2011-2012 Alcatel, Alcatel-Lucent, Inc. All Rights Reserved.
*
* This source code contains confidential information which is proprietary to Alcatel.
* No part of its contents may be used, copied, disclosed or conveyed to any party
* in any manner whatsoever without prior written permission from Alcatel.
*
* Alcatel-Lucent is a trademark of Alcatel-Lucent, Inc.
*
*/

@import <Foundation/CPDate.j>

@implementation CPDate (FirstLastDate)

/*! Return the last time of a day
    @param aDate a day
    @return a new date
*/
+ (CPDate)lastDateOfADay:(CPDate)aDate
{
    var stringDate = [aDate description],
        dayBefore = aDate.getDay(),
        newDate = [[CPDate alloc] initWithString:stringDate.substr(0, 10) + ' 00:00:00 ' + stringDate.substr(20) + "+0000"];

    // For some timezones and dates, midnight does not exist. E.g. CLT 2010-10-10 00:00 is actually 2010-10-09 23:00
    // due to the summer time change (DST). Normally, regardless of the time zone, the shift is 1 hour but there
    // have been 2 hour shifts too. So inch forward 1 hour at a time until we arrive at the original date. It
    // won't be midnight but it'll be as close as we can get.
    while (newDate.getDay() != dayBefore)
        newDate.setTime(newDate.getTime() + 60 * 60 * 1000);

    newDate.setTime(newDate.getTime() + 24 * 60 * 60 * 1000 - 1000);

    return newDate;
}

/*! Return the first time of a day
    @param aDate a day
    @return a new date
*/
+ (CPDate)firstDateOfMonth:(CPDate)aDate
{
    return new Date(aDate.getUTCFullYear(),aDate.getMonth(),1);
}

/*! Return the first date of an year
    @param aDate the targeted year
    @return a new date
*/
+ (CPDate)firstDateOfYear:(CPDate)aDate
{
    return new Date(aDate.getUTCFullYear(),0,1);;
}

/*! Return the last date of a pmonth
    @param aDate the targeted month
    @return a new month
*/
+ (CPDate)lastDateOfAMonth:(CPDate)aDate
{
    var date = new Date(aDate.getUTCFullYear(),aDate.getMonth(),31),
        monthBefore = aDate.getMonth();

    while (date.getMonth() != monthBefore)
        date.setTime(date.getTime() - 60 * 60 * 1000);

    date.setHours(23);
    date.setMinutes(59);
    date.setSeconds(59);

    return date;
}

/*! Return the last date of an year
    @param aDate the targeted year
    @return a new date
*/
+ (CPDate)lastDateOfAnYear:(CPDate)aDate
{
    var date = new Date(aDate.getUTCFullYear(),aDate.getMonth(),31),
        yearBefore = aDate.getUTCFullYear();

    while (date.getUTCFullYear() != yearBefore)
        date.setTime(date.getTime() - 60 * 60 * 1000);

    date.setHours(23);
    date.setMinutes(59);
    date.setSeconds(59);

    return date;
}

/*! Return the number of day in a month
*/
+ (int)numberOfDaysInMonthForDate:(CPDate)aDate
{
    return new Date(aDate.getUTCFullYear(),aDate.getMonth() + 1,0).getDate();
}

/*! Return a bool to know if the day number is the last day of the month
    @param aDayNumber the day number
    @param aDate the month
    @return a boolean
*/
+ (BOOL)isLastDay:(int)aDayNumber ofMonthForDate:(CPDate)aDate
{
    switch ([CPDate numberOfDaysInMonthForDate:aDate])
    {
        case 28:
            return aDayNumber == 28;

        case 29:
            return aDayNumber == 29;

        case 30:
            return aDayNumber == 30;

        case 31:
            return aDayNumber == 31;

        default:
    }

    return NO;
}

@end
