/*
* LPTimeIntervalView.j
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

@import "LPTimeIntervalHourView.j"
@import "LPTimeIntervalYearView.j"
@import "LPTimeIntervalDayView.j"
@import "LPTimeIntervalMonthView.j"
@import "LPTimeIntervalYearView.j"

var LPTimeIntervalView_timeIntervalView_didSelectStartDate_endDate_intervalType_    = 1 << 1;

LPIntervalTypeDay     = 1;
LPIntervalTypeMonth   = 2;
LPIntervalTypeYear    = 3;
LPIntervalTypeHour    = 4;

@implementation LPTimeIntervalView : CPView
{
    CPColor                 _borderColor                                 @accessors(property=borderColor);
    CPDate                  _endDate                                     @accessors(getter=endDate);
    CPDate                  _startDate                                   @accessors(getter=startDate);
    id                      _timeIntervalViewDelegate                    @accessors(property=delegate);
    int                     _intervalType                                @accessors(property=intervalType);

    LPTimeIntervalHourView      _calendarHourView;
    LPTimeIntervalDayView       _calendarView;
    LPTimeIntervalMonthView     _monthCalendarView;
    LPTimeIntervalYearView      _yearCalendarView;
    unsigned                _implementedTimeIntervalViewDelegateMethods;
}


#pragma mark -
#pragma mark Init methods

/*! Init a LPTimeIntervalView
    @param aRect a rect
*/
- (id)initWithFrame:(CGRect)aRect
{
    if (self = [super initWithFrame:aRect])
    {
        var date = [CPDate date];

        _borderColor = [CPColor clearColor];

        _calendarHourView = [[LPTimeIntervalHourView alloc] initWithFrame:CGRectMake(aRect.size.width / 2 - 190 / 2, 0, 189, 205)];
        [_calendarHourView setDelegate:self];
        [_calendarHourView setHidden:NO];
        [self addSubview:_calendarHourView];

        _calendarView = [[LPTimeIntervalDayView alloc] initWithFrame:CGRectMake(aRect.size.width / 2 - 190 / 2, 0, 189, 166)];
        [_calendarView selectDate:date];
        [_calendarView setDelegate:self];
        [_calendarView setAllowsMultipleSelection:NO];
        [_calendarView setHidden:YES];
        [self addSubview:_calendarView];

        _monthCalendarView = [[LPTimeIntervalMonthView alloc] initWithFrame:CGRectMake(aRect.size.width / 2 - 190 / 2, 0, 189, 168)];
        [_monthCalendarView setDelegate:self];
        [_monthCalendarView setHidden:YES];
        [_monthCalendarView setYear:date];
        [self addSubview:_monthCalendarView];

        _yearCalendarView = [[LPTimeIntervalYearView alloc] initWithFrame:CGRectMake(aRect.size.width / 2 - 190 / 2, 0, 189, 168)];
        [_yearCalendarView setDelegate:self];
        [_yearCalendarView setHidden:YES];
        [_yearCalendarView setYear:date];
        [self addSubview:_yearCalendarView];

        _intervalType = LPIntervalTypeDay;

        _startDate = [self _intervalForFirstDay:date];
        _endDate = [self _intervalForEndDay:date];
    }

    return self;
}


/*! Return a LPTimeIntervalView with the days interval
*/
+ (id)timeIntervalViewHours
{
    var timeIntervalView = [[LPTimeIntervalView alloc] initWithFrame:CGRectMake(0,0,200,210)];

    [timeIntervalView setIntervalType:LPIntervalTypeHour];

    return timeIntervalView;
}

/*! Return a LPTimeIntervalView with the days interval
*/
+ (id)timeIntervalViewDays
{
    var timeIntervalView = [[LPTimeIntervalView alloc] initWithFrame:CGRectMake(0,0,200,210)];

    [timeIntervalView setIntervalType:LPIntervalTypeDay];

    return timeIntervalView;
}

/*! Return a LPTimeIntervalView with the years interval
*/
+ (id)timeIntervalViewYears
{
    var timeIntervalView = [[LPTimeIntervalView alloc] initWithFrame:CGRectMake(0,0,200,210)];

    [timeIntervalView setIntervalType:LPIntervalTypeYear];

    return timeIntervalView;
}

/*! Return a LPTimeIntervalView with the months interval
*/
+ (id)timeIntervalViewMonths
{
    var timeIntervalView = [[LPTimeIntervalView alloc] initWithFrame:CGRectMake(0,0,200,210)];

    [timeIntervalView setIntervalType:LPIntervalTypeMonth];

    return timeIntervalView;
}


#pragma mark -
#pragma mark Set the delegate

/*! Set the delegate
    You can implement the methods :
    - timeIntervalView:didSelectFirstDay:end:
    @param aDelegate the delegate
*/
- (void)setDelegate:(id)aDelegate
{
    _timeIntervalViewDelegate = aDelegate;

    _implementedTimeIntervalViewDelegateMethods = 0;

    // Look if the delegate implements or not the delegate methods
    if ([_timeIntervalViewDelegate respondsToSelector:@selector(timeIntervalView:didSelectStartDate:endDate:intervalType:)])
        _implementedTimeIntervalViewDelegateMethods |= LPTimeIntervalView_timeIntervalView_didSelectStartDate_endDate_intervalType_;
}

/*! Set the type of the interval
    @param anIntervalType
*/
- (void)setIntervalType:(int)anIntervalType
{
    _intervalType = anIntervalType;

    switch (_intervalType)
    {
        case LPIntervalTypeDay:
            [_calendarHourView setHidden:YES];
            [_calendarView setHidden:NO];
            [_monthCalendarView setHidden:YES];
            [_yearCalendarView setHidden:YES];
            break;

        case LPIntervalTypeMonth:
            [_calendarHourView setHidden:YES];
            [_calendarView setHidden:YES];
            [_monthCalendarView setHidden:NO];
            [_yearCalendarView setHidden:YES];
            break;

        case LPIntervalTypeYear:
            [_calendarHourView setHidden:YES];
            [_calendarView setHidden:YES];
            [_monthCalendarView setHidden:YES];
            [_yearCalendarView setHidden:NO];
            break;

        case LPIntervalTypeHour:
            [_calendarHourView setHidden:NO];
            [_calendarView setHidden:YES];
            [_monthCalendarView setHidden:YES];
            [_yearCalendarView setHidden:YES];
            break;

        default:
            [_calendarHourView setHidden:NO];
            [_calendarView setHidden:YES];
            [_monthCalendarView setHidden:YES];
            [_yearCalendarView setHidden:YES];
    }

    _endDate = [self _intervalForEndDay:_endDate];
    _startDate = [self _intervalForFirstDay:_startDate];
}


#pragma mark -
#pragma mark Date methods

/*! Return the firstDay relative to the choosen interval
    @param aDate
    @return a date
*/
- (CPDate)_intervalForFirstDay:(CPDate)aDate
{
    switch (_intervalType)
    {
        case LPIntervalTypeDay :
            return [CPDate firstHourOfDay:aDate];
            break;

        case LPIntervalTypeMonth :
            return [CPDate firstDateOfMonth:aDate];
            break;

        case LPIntervalTypeYear:
            return [CPDate firstDateOfYear:aDate];
            break;
    }

    return aDate;
}

/*! Return the endDay relative to the choosen interval
    @param aDate
    @return a date
*/
- (void)_intervalForEndDay:(CPDate)aDate
{
    switch (_intervalType)
    {
        case LPIntervalTypeDay :
            return [CPDate lastDateOfADay:aDate];
            break;

        case LPIntervalTypeMonth :
            return [CPDate lastDateOfAMonth:aDate];
            break;

        case LPIntervalTypeYear:
            return [CPDate lastDateOfAnYear:aDate];
            break;
    }

    return aDate;
}

#pragma mark -
#pragma mark Draw rect

/*! Draw the rect
    @param aRect the rect
*/
- (void)drawRect:(CGRect)aRect
{
    var context = [[CPGraphicsContext currentContext] graphicsPort];

    CGContextBeginPath(context);
    CGContextSetStrokeColor(context,_borderColor);
    CGContextSetLineWidth(context, 1);
    CGContextMoveToPoint(context, 0, 0);
    CGContextAddLineToPoint(context, aRect.size.width , 0);
    CGContextAddLineToPoint(context, aRect.size.width, aRect.size.height );
    CGContextAddLineToPoint(context, 0, aRect.size.height);
    CGContextAddLineToPoint(context, 0, 0);
    CGContextStrokePath(context);
    CGContextClosePath(context);
}

@end



@implementation LPTimeIntervalView (LPTimeIntervalViewCalendarDelegate)


/*! Delegate of the hourCalendarView
    @param aCalendarView the calendarView
    @param aFirstDate the firstDate
    @param anEndDate the endDate
*/
- (void)hourCalendarView:(LPTimeIntervalHourView)aCalendarView didMakeSelection:(CPDate)aFirstDate enDate:(CPDate)anEndDate
{
    [self _didSelectStartDate:aFirstDate endDate:anEndDate];
}

/*! Delegate of the calendarView
    @param aCalendarView the calendarView
    @param aFirstDate the firstDate
*/
- (void)calendarView:(LPTimeIntervalDayView)aCalendarView didMakeSelection:(CPDate)aDate
{
    [self _didSelectStartDate:[self _intervalForFirstDay:aDate] endDate:[self _intervalForEndDay:aDate]];
}

/*! Delegate of monthCalendar
    @param aMonthCalendarView the monthCalendar
    @param aDate the date
*/
- (void)monthCalendarView:(LPTimeIntervalMonthView)aMonthCalendarView didMakeSelection:(CPDate)aDate
{
     [self _didMakeSelectionInterval:aDate];
     //[_calendarView selectDate:aDate];
}

/*! Delegate of yearCalendar
    @param anYearCalendarView the yearCalendar
    @param aDate the date
*/
- (void)yearCalendar:(LPTimeIntervalYearView)anYearCalendarView didMakeSelection:(CPDate)aDate
{
     [self _didMakeSelectionInterval:aDate];
}

/*! Did make a selection will call timeIntervalView:didSelectFirstDay:end:
*/
- (void)_didMakeSelectionInterval:(CPDate)aDate
{
    [self _didSelectStartDate:[self _intervalForFirstDay:aDate] endDate:[self _intervalForEndDay:aDate]];
}

/*! _didSelectStartDate:(CPDate)aDate endDate:(CPDate)anEndDate
    @param aDate startDate
    @param endDate endDate
*/
- (void)_didSelectStartDate:(CPDate)aStartDate endDate:(CPDate)anEndDate
{
    _endDate = anEndDate;
    _startDate = aStartDate;

    if (!(_implementedTimeIntervalViewDelegateMethods & LPTimeIntervalView_timeIntervalView_didSelectStartDate_endDate_intervalType_))
        return;

    [_timeIntervalViewDelegate timeIntervalView:self didSelectStartDate:_startDate endDate:_endDate intervalType:_intervalType];
}

@end
