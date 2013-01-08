/*
*   Filename:         LPDayCalendarView.j
*   Created:          Tue Nov 20 14:09:04 PST 2012
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

@import "LPCalendarView.j"


@implementation LPDayCalendarView : LPCalendarView
{

}

/*! Theme attrbiutes
*/
+ (id)themeAttributes
{
    return [CPDictionary dictionaryWithObjects:[[CPNull null],[CPNull null], CGInsetMakeZero(), [CPNull null], [CPNull null], [CPNull null], [CPNull null], [CPNull null], [CPNull null], [CPNull null], [CPNull null], CGSizeMake(0,0), [CPNull null], [CPNull null], 40, [CPNull null], [CPNull null], [CPNull null], [CPNull null], [CPNull null], [CPNull null], 30, [CPNull null], [CPNull null], [CPNull null], [CPNull null]]
                                       forKeys:[@"background-color",@"bezel-color", @"bezel-inset", @"grid-color", @"grid-shadow-color",
                                                @"tile-size", @"tile-font", @"tile-text-color", @"tile-text-shadow-color", @"tile-text-shadow-offset", @"tile-bezel-color",
                                                @"header-button-offset", @"header-prev-button-image", @"header-next-button-image", @"header-height", @"header-background-color", @"header-font", @"header-text-color", @"header-text-shadow-color", @"header-text-shadow-offset", @"header-alignment",
                                                @"header-weekday-offset", @"header-weekday-label-font", @"header-weekday-label-color", @"header-weekday-label-shadow-color", @"header-weekday-label-shadow-offset"]];

}

/*! Init an new themed instance of LPDayCalendarView
*/
- (id)initWithFrame:(CGRect)aFrame
{
    if (self = [super initWithFrame:aFrame])
    {
        [self selectDate:[CPDate date]];
    }
    return self;
}

/*! Called when the user has clicked on a date
    @param selection the selection date
*/
- (void)didMakeSelection:(CPArray)aSelection
{
    // Make sure we have an end to the selection
    if ([aSelection count] <= 1)
        [aSelection addObject:nil];

    // Copy the selection
    fullSelection = [CPArray arrayWithArray:aSelection];

    // Call the delegate
    if (_delegate && [_delegate respondsToSelector:@selector(calendarView:didMakeSelection:)])
        [_delegate calendarView:self didMakeSelection:[fullSelection objectAtIndex:0]];
}

@end
