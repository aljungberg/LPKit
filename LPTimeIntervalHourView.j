/*
* LPTimeIntervalHourView.j
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

@import <AppKit/CPView.j>
@import <AppKit/CPStepper.j>

@class LPTimeIntervalDayView

@implementation LPTimeIntervalHourView : CPView
{
    id                      _delegate          @accessors(property=delegate);

    BOOL                    _stepperHours;
    CPStepper               _startStepper;
    CPStepper               _endStepper;
    CPTextField             _startTextField;
    CPTextField             _endTextField;
    LPTimeIntervalDayView   _calendarView;
}


/*! Theme attrbitues
*/
+ (id)themeAttributes
{
    return [CPDictionary dictionaryWithObjects:[[CPNull null],[CPNull null], [CPNull null], [CPNull null]]
                                       forKeys:[@"header-font", @"header-text-color", @"header-text-shadow-color", @"header-text-shadow-offset"]];


}

/*! Init a new LPTimeIntervalHourView
*/
- (id)initWithFrame:(CGRect)aRect
{
    if (self = [super initWithFrame:aRect])
    {
        var date = [CPDate date];

        _calendarView = [[LPTimeIntervalDayView alloc] initWithFrame:CGRectMake(aRect.size.width / 2 - 190 / 2, 0, 189, 166)];
        [_calendarView selectDate:date];
        [_calendarView setDelegate:self];
        [_calendarView setAllowsMultipleSelection:NO];
        [self addSubview:_calendarView];

        _startStepper = [CPStepper stepperWithInitialValue:0 minValue:0 maxValue:23];
        _endStepper = [CPStepper stepperWithInitialValue:24 minValue:1 maxValue:24];

        [_startStepper setTarget:self];
        [_startStepper setAction:@selector(clickOnStartStepper:)];
        [_startStepper setValueWraps:NO];

        _startTextField = [CPTextField labelWithTitle:@"Start : 0"];

        [_startTextField setFrameOrigin:CGPointMake(5,175 + [_startStepper frameSize].height / 2 - [_startTextField frameSize].height / 2)];
        [_startStepper setFrameOrigin:CGPointMake([_startTextField frameSize].width + 12,175)];

        [self addSubview:_startTextField];
        [self addSubview:_startStepper]

        [_endStepper setTarget:self];
        [_endStepper setAction:@selector(clickOnEndStepper:)];
        [_endStepper setValueWraps:NO];

        _endTextField = [CPTextField labelWithTitle:@"End : 24"];

        [_endStepper setFrameOrigin:CGPointMake(aRect.size.width - 5 - [_endStepper frameSize].width, 175)];
        [_endTextField setFrameOrigin:CGPointMake([_endStepper frameOrigin].x - [_endTextField frameSize].width, 175 + [_endStepper frameSize].height / 2 - [_endTextField frameSize].height / 2)];

        [self addSubview:_endTextField];
        [self addSubview:_endStepper]

    }
    return self;
}


#pragma mark -
#pragma mark Stepper action

/*! Occurs when clicking on the start stepper
*/
- (void)clickOnStartStepper:(id)sender
{
    if ([sender doubleValue] >= [_endStepper doubleValue])
        [_endStepper performClickUp:self];

    [_startTextField setStringValue:[CPString stringWithFormat:@"Start : %i" , [sender doubleValue]]];
    [_startTextField sizeToFit];
}

/*! Occurs when clicking on the end stepper
*/
- (void)clickOnEndStepper:(id)sender
{
    if ([sender doubleValue] <= [_startStepper doubleValue])
        [_startStepper performClickDown:self];

    [_endTextField setStringValue:[CPString stringWithFormat:@"End : %i" , [sender doubleValue]]];
    [_endTextField sizeToFit];
}

-(void)layoutSubviews
{
    var themeState = [self themeState];

    [_endTextField setFont:[self valueForThemeAttribute:@"header-font" inState:themeState]];
    [_endTextField setTextColor:[self valueForThemeAttribute:@"header-text-color" inState:themeState]];
    [_endTextField setTextShadowColor:[self valueForThemeAttribute:@"header-text-shadow-color" inState:themeState]];
    [_endTextField setTextShadowOffset:[self valueForThemeAttribute:@"header-text-shadow-offset" inState:themeState]];

    [_startTextField setFont:[self valueForThemeAttribute:@"header-font" inState:CPThemeStateNormal]];
    [_startTextField setTextColor:[self valueForThemeAttribute:@"header-text-color" inState:CPThemeStateNormal]];
    [_startTextField setTextShadowColor:[self valueForThemeAttribute:@"header-text-shadow-color" inState:CPThemeStateNormal]];
    [_startTextField setTextShadowOffset:[self valueForThemeAttribute:@"header-text-shadow-offset" inState:CPThemeStateNormal]];
}

@end

@implementation LPTimeIntervalHourView (LPTimeIntervalHourViewCalendarDelegate)

/*! Delegate of the calendar view
    @param aFirsDate
*/
- (void)calendarView:(LPTimeIntervalDayView)aCalendarView didMakeSelection:(CPDate)aFirstDate
{
    var dateStart = new Date(aFirstDate.getUTCFullYear(), aFirstDate.getMonth(), aFirstDate.getDate(),[_startStepper doubleValue] , 0, 0, 0),
        dateEnd = new Date(aFirstDate.getUTCFullYear(), aFirstDate.getMonth(), aFirstDate.getDate(), [_endStepper doubleValue] - 1, 59, 59, 99);

    // Call the delegate
    if (_delegate && [_delegate respondsToSelector:@selector(hourCalendarView:didMakeSelection:enDate:)])
        [_delegate hourCalendarView:self didMakeSelection:dateStart enDate:dateEnd];
}

@end
