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

/*! Themed the calendar
*/
- (void)themedCalendarView
{
    var bundle = [CPBundle bundleForClass:[self class]];

    [self setValue:[CPColor clearColor] forThemeAttribute:@"grid-color"];
    [self setValue:[CPColor clearColor] forThemeAttribute:@"grid-shadow-color"]

    // Header View
    [self setValue:40 forThemeAttribute:@"header-height" inState:CPThemeStateNormal];
    [self setValue:[CPFont boldSystemFontOfSize:11.0] forThemeAttribute:@"header-font" inState:CPThemeStateNormal];
    [self setValue:[CPColor colorWithHexString:@"333"] forThemeAttribute:@"header-text-color" inState:CPThemeStateNormal];
    [self setValue:[CPColor whiteColor] forThemeAttribute:@"header-text-shadow-color" inState:CPThemeStateNormal];
    [self setValue:CGSizeMake(1.0, 1.0) forThemeAttribute:@"header-text-shadow-offset" inState:CPThemeStateNormal];
    [self setValue:CPCenterTextAlignment forThemeAttribute:@"header-alignment" inState:CPThemeStateNormal];

    // Arrows
    [self setValue:CGSizeMake(10, 7) forThemeAttribute:@"header-button-offset" inState:CPThemeStateNormal];
    [self setValue:[CPColor colorWithPatternImage:[[CPImage alloc] initWithContentsOfFile:[bundle pathForResource:@"LPCalendar/previous.png"] size:CGSizeMake(16.0, 16.0)]] forThemeAttribute:@"header-prev-button-image" inState:CPThemeStateNormal];
    [self setValue:[CPColor colorWithPatternImage:[[CPImage alloc] initWithContentsOfFile:[bundle pathForResource:@"LPCalendar/next.png"] size:CGSizeMake(16.0, 16.0)]] forThemeAttribute:@"header-next-button-image" inState:CPThemeStateNormal];

    // Weekday labels
    [self setValue:25 forThemeAttribute:@"header-weekday-offset" inState:CPThemeStateNormal];
    [self setValue:[CPFont systemFontOfSize:9.0] forThemeAttribute:@"header-weekday-label-font" inState:CPThemeStateNormal];
    [self setValue:[CPColor colorWithWhite:0 alpha:0.57] forThemeAttribute:@"header-weekday-label-color" inState:CPThemeStateNormal];
    [self setValue:[CPColor colorWithWhite:1 alpha:0.8] forThemeAttribute:@"header-weekday-label-shadow-color" inState:CPThemeStateNormal];
    [self setValue:CGSizeMake(0.0, 1.0) forThemeAttribute:@"header-weekday-label-shadow-offset" inState:CPThemeStateNormal];

    // Day Tile View
    [self setValue:CGSizeMake(27, 21) forThemeAttribute:@"tile-size" inState:CPThemeStateNormal];
    [self setValue:[CPFont boldSystemFontOfSize:11.0] forThemeAttribute:@"tile-font" inState:CPThemeStateNormal];
    [self setValue:[CPColor colorWithHexString:@"333"] forThemeAttribute:@"tile-text-color" inState:CPThemeStateNormal];
    [self setValue:[CPColor colorWithWhite:1 alpha:0.8] forThemeAttribute:@"tile-text-shadow-color" inState:CPThemeStateNormal];
    [self setValue:CGSizeMake(1.0, 1.0) forThemeAttribute:@"tile-text-shadow-offset" inState:CPThemeStateNormal];

    // Highlighted
    [self setValue:[CPColor colorWithHexString:@"555"] forThemeAttribute:@"tile-text-color" inState:CPThemeStateHighlighted];

    // Selected
    [self setValue:[CPColor colorWithHexString:@"4A89E3"] forThemeAttribute:@"tile-text-color" inState:CPThemeStateSelected];
    [self setValue:[CPColor clearColor] forThemeAttribute:@"tile-text-shadow-color" inState:CPThemeStateSelected];

    // Disabled
    [self setValue:[CPColor colorWithWhite:0 alpha:0.3] forThemeAttribute:@"tile-text-color" inState:CPThemeStateDisabled];

    // Disabled & Selected (if that makes any sense.)
    [self setValue:[CPColor colorWithWhite:0 alpha:0.4] forThemeAttribute:@"tile-text-color" inState:CPThemeStateSelected | CPThemeStateDisabled];
    [self setValue:[CPColor clearColor] forThemeAttribute:@"tile-text-shadow-color" inState:CPThemeStateSelected | CPThemeStateDisabled];

}

/*! Init an new themed instance of LPDayCalendarView
*/
- (id)initWithFrame:(CGRect)aFrame
{
    if (self = [super initWithFrame:aFrame])
    {
        [self themedCalendarView];
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
