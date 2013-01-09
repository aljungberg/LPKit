/*
* CPDate+FirstLastDate.j
* LPKit
*
* Created by Alexandre Wilhelm <alexandre.wilhelm@alcatel-lucent.com> on November 7, 2009.
*
* The MIT License
*
* Copyright (c) 2009 Ludwig Pettersson
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in
* all copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
* THE SOFTWARE.
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
    return new Date(aDate.getUTCFullYear(), aDate.getMonth(), 1);
}

/*! Return the first date of an year
    @param aDate the targeted year
    @return a new date
*/
+ (CPDate)firstDateOfYear:(CPDate)aDate
{
    return new Date(aDate.getUTCFullYear(), 0, 1);
}

/*! Return the last date of a pmonth
    @param aDate the targeted month
    @return a new month
*/
+ (CPDate)lastDateOfAMonth:(CPDate)aDate
{
    var date = new Date(aDate.getUTCFullYear(), aDate.getMonth(), 31),
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
    var date = new Date(aDate.getUTCFullYear(), aDate.getMonth(), 31),
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
    return new Date(aDate.getUTCFullYear(), aDate.getMonth() + 1, 0).getDate();
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
