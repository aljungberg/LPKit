/*
 * LPTimeIntervalDayView.j
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


@import "LPCalendarView.j"


@implementation LPTimeIntervalDayView : LPCalendarView
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

/*! Init an new themed instance of LPTimeIntervalDayView
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
