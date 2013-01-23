/*
* LPTimeIntervalYearView.j
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

@import <AppKit/CPControl.j>

@import "LPSlideView.j"
@import "_LPArrowButton.j"

var LPTimeIntervalYearView_yearCalendar_didMakeSelection_    = 1 << 1;

@implementation LPTimeIntervalYearView : CPControl
{
    CPDate                  _year                   @accessors(property=year);
    id                      _yearCalendarDelegate   @accessors(property=delegate);

    _LPContentMonthCalendar _currentYearCalendar;
    _LPContentMonthCalendar _previousYearCalendar;
    _LPContentMonthCalendar _nextYearCalendar;
    CPDate                  _currentDate;
    CPTextField             _yearLabel;
    CPView                  _headerMonthCalendar;
    LPSlideView             _slideView;
    _LPArrowButton          _nextButton;
    _LPArrowButton          _prevButton;
    unsigned                _implementedYearCalendarDelegateMethods;
}

/*! Theme attrbiutes
*/
+ (id)themeAttributes
{
    return [CPDictionary dictionaryWithObjects:[[CPNull null],[CPNull null], CGInsetMakeZero(), [CPNull null], [CPNull null], [CPNull null], [CPNull null], [CPNull null], [CPNull null], [CPNull null], [CPNull null], CGSizeMake(0,0), [CPNull null], [CPNull null], 40, [CPNull null], [CPNull null], [CPNull null], [CPNull null], [CPNull null], [CPNull null], 30, [CPNull null], [CPNull null], [CPNull null], [CPNull null]]
                                       forKeys:[@"background-color", @"bezel-color", @"bezel-inset", @"grid-color", @"grid-shadow-color",
                                                @"tile-size", @"tile-font", @"tile-text-color", @"tile-text-shadow-color", @"tile-text-shadow-offset", @"tile-bezel-color",
                                                @"header-button-offset", @"header-prev-button-image", @"header-next-button-image", @"header-height", @"header-background-color", @"header-font", @"header-text-color", @"header-text-shadow-color", @"header-text-shadow-offset", @"header-alignment",
                                                @"header-weekday-offset", @"header-weekday-label-font", @"header-weekday-label-color", @"header-weekday-label-shadow-color", @"header-weekday-label-shadow-offset"]];
}

/*! Init a new LPTimeIntervalYearView
*/
- (id)initWithFrame:(CGRect)aFrame
{
    if (self = [super initWithFrame:aFrame])
    {
        var bundle = [CPBundle bundleForClass:[self class]];

        _slideView = [[LPSlideView alloc] initWithFrame:CGRectMake(0, 40, CGRectGetWidth(aFrame), CGRectGetHeight(aFrame) - 40)];
        [_slideView setSlideDirection:LPSlideViewVerticalDirection];
        [_slideView setDelegate:self];
        [_slideView setAnimationCurve:CPAnimationEaseOut];
        [_slideView setAnimationDuration:0.2];
        [self addSubview:_slideView];

        _previousYearCalendar = [[_LPContentYearCalendar alloc] initWithFrame:CGRectMake(0, 40, CGRectGetWidth(aFrame), aFrame.size.height - 40) withYearCalendar:self];
        [_previousYearCalendar selectIndex:11];
        [_slideView addSubview:_previousYearCalendar];

        _nextYearCalendar = [[_LPContentYearCalendar alloc] initWithFrame:CGRectMake(0, 40, CGRectGetWidth(aFrame), aFrame.size.height - 40) withYearCalendar:self];
        [_slideView addSubview:_nextYearCalendar];

        _currentYearCalendar = _previousYearCalendar;

        _headerMonthCalendar = [[CPView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(aFrame), 40)];
        [self addSubview:_headerMonthCalendar];

        _yearLabel = [[CPTextField alloc] initWithFrame:CGRectMake(0, 8, aFrame.size.width, aFrame.size.height)];
        [_yearLabel setAutoresizingMask:CPViewWidthSizable | CPViewHeightSizable];
        [_yearLabel setAlignment:CPCenterTextAlignment];
        [_yearLabel setHitTests:NO];
        [_headerMonthCalendar addSubview:_yearLabel];

        _prevButton = [[_LPArrowButton alloc] initWithFrame:CGRectMake(6, 9, 16, 16)];
        [_prevButton setTarget:self];
        [_prevButton setBordered:NO];
        [_prevButton setAction:@selector(_didClickPreviousButton:)]
        [_headerMonthCalendar addSubview:_prevButton];

        _nextButton = [[_LPArrowButton alloc] initWithFrame:CGRectMake(CGRectGetMaxX([self bounds]) - 21, 9, 16, 16)];
        [_nextButton setTarget:self];
        [_nextButton setBordered:NO];
        [_nextButton setAction:@selector(_didClickNextButton:)]
        [_nextButton setAutoresizingMask:CPViewMinXMargin];
        [_headerMonthCalendar addSubview:_nextButton];

        _currentDate = [CPDate date];
        [self setYear:[CPDate date]];

    }
    return self;
}


#pragma mark -
#pragma mark Delegate accessors

/*! Set the delegate
    You can implement the method:
    - yearCalendar:didMakeSelection:
    @param aDelegate a delegate
*/
- (void)setDelegate:(id)aDelegate
{
    _yearCalendarDelegate = aDelegate;
    _implementedYearCalendarDelegateMethods = 0;

    // Look if the delegate implements or not the delegate methods
    if ([_yearCalendarDelegate respondsToSelector:@selector(yearCalendar:didMakeSelection:)])
        _implementedYearCalendarDelegateMethods |= LPTimeIntervalYearView_yearCalendar_didMakeSelection_;

}


#pragma mark -
#pragma mark Year accessors

/*! Set the year
    @Param aDate the year
*/
- (void)setYear:(CPDate)aDate
{
    if ([_year isEqualToDate:aDate])
        return;

    _year = [aDate copy];

    [_yearLabel setStringValue:[CPString stringWithFormat:@"%i - %i ", _year.getUTCFullYear() - 11 , _year.getUTCFullYear()]];
}

#pragma mark -
#pragma mark Action for buttons

/*! Occurs when clicking on the button next
*/
- (void)_didClickNextButton:(id)sender
{
    var newDate =  new Date(_year.getUTCFullYear() + 11,_currentDate.getMonth(),_currentDate.getDate());
    [self _slideToNextViewWithDate:newDate];
}

/*! Occurs when clicking on the previous next
*/
- (void)_didClickPreviousButton:(id)sender
{
    var newDate =  new Date(_year.getUTCFullYear() - 11,_currentDate.getMonth(),_currentDate.getDate());
    [self _slideToNextViewWithDate:newDate];
}

/*! Slide to the next view with a new date
    @param aDate a new date
*/
- (void)_slideToNextViewWithDate:(CPDate)aDate
{
    if (_currentYearCalendar == _nextYearCalendar)
        _currentYearCalendar = _previousYearCalendar;
    else
        _currentYearCalendar = _nextYearCalendar;

    [_currentYearCalendar setDate:aDate];
    [_currentYearCalendar selectIndex:nil];

    [_currentYearCalendar highlightIndex:_currentDate.getUTCFullYear() - aDate.getUTCFullYear() + 11];

    [self setYear:aDate];

    [_slideView slideToView:_currentYearCalendar direction:LPSlideViewNegativeDirection];
}


#pragma mark -
#pragma mark Subview layout

/*! Layout the subvies
*/
- (void)layoutSubviews
{
    var themeState = [self themeState];

    [_currentYearCalendar setBackgroundColor:[self valueForThemeAttribute:@"background-color" inState:themeState]];

    [_yearLabel setFont:[self valueForThemeAttribute:@"header-font" inState:themeState]];
    [_yearLabel setTextColor:[self valueForThemeAttribute:@"header-text-color" inState:themeState]];
    [_yearLabel setTextShadowColor:[self valueForThemeAttribute:@"header-text-shadow-color" inState:themeState]];
    [_yearLabel setTextShadowOffset:[self valueForThemeAttribute:@"header-text-shadow-offset" inState:themeState]];

    [_nextButton setValue:[self valueForThemeAttribute:@"header-next-button-image" inState:themeState] forThemeAttribute:@"bezel-color" ];
    [_prevButton setValue:[self valueForThemeAttribute:@"header-prev-button-image" inState:themeState] forThemeAttribute:@"bezel-color" ];
}

@end

@implementation LPTimeIntervalYearView (LPTimeIntervalYearViewDelegate)

/*! Delegate of the widget
    @param anIndex, the index selected
*/
- (void)_didMakeSelection:(int)anIndex
{
    if ([self isHidden] || _year == nil || anIndex == nil)
        return;

    var date = new Date(_year.getUTCFullYear() - 11 + anIndex + 1,0,0);

    _currentDate = date;

    if (_implementedYearCalendarDelegateMethods & LPTimeIntervalYearView_yearCalendar_didMakeSelection_)
        [_yearCalendarDelegate yearCalendar:self didMakeSelection:date];
}

@end


@implementation _LPContentYearCalendar : CPView
{
    CPDate             _date            @accessors(property=date);

    CPArray            _tiles;
    LPTimeIntervalYearView _yearCalendar;
}

/*! Init a new _LPContentMonthCalendar
    @param aFrame
    @param aMonthCalendar a monthcalendar
*/
- (id)initWithFrame:(CGRect)aFrame withYearCalendar:(LPMonthCalendar)anYearCalendar
{
    if (self = [super initWithFrame:aFrame])
    {
        _yearCalendar = anYearCalendar
        _tiles = [CPArray array];

        // Create tiles
        for (var i = 0; i < 12; i++)
        {
            var tile = [[_LPContentYearView alloc] initWithFrame:CGRectMakeZero() withYearCalendar:_yearCalendar];
            [self addSubview:tile];
            [_tiles addObject:tile];
        }

        [self tile];
    }

    return self;
}

- (void)setDate:(CPDate)aDate
{
    _date = aDate;

    for (var i = 0; i < [_tiles count]; i++)
    {
        var tile = [_tiles objectAtIndex:i],
            year = [CPString stringWithFormat:@"%i", _date.getUTCFullYear() - 11 + i];

        [tile setTitle:year];
    }
}

#pragma mark -
#pragma mark Tile functions

/*! Return the size of a cell
*/
- (int)tileSize
{
    var bounds = [self bounds];

    return CGSizeMake(CGRectGetWidth(bounds) / 3, (CGRectGetHeight(bounds) / 4));
}

/*! Init all the cell
*/
- (void)tile
{
    var tiles = [self subviews],
        tileSize = [self tileSize],
        tileIndex = 0;

    if ([tiles count] > 0)
    {
        for (var i = 0; i < 4; i++)
        {
            for (var j = 0; j < 3; j++)
            {

                // CGRectInset() mucks up the frame for some reason.
                var tileFrame = CGRectMake((j * tileSize.width), i * tileSize.height, tileSize.width, tileSize.height);

                [tiles[tileIndex] setFrame:tileFrame];

                var year = [CPString stringWithFormat:@"%i", [CPDate date].getUTCFullYear() - 11 + (j +i*3)];

                [tiles[tileIndex] setTitle:year];
                tileIndex += 1;
            }
        }
    }
}


#pragma mark -
#pragma mark Mouse events

/*! Return the index of the cell clicked
    @param aPoint the point clicked
*/
- (int)indexOfTileAtPoint:(CGPoint)aPoint
{
    var tileSize = [self tileSize];

    // Get the week row
    var rowIndex = FLOOR(aPoint.y / tileSize.height),
        columnIndex = FLOOR(aPoint.x / tileSize.width);

    // Limit the column index, there are only 7
    if (columnIndex > 2)
        columnIndex = 2;
    else if (columnIndex < 0)
        columnIndex = 0;

    // Limit the row index, there are only 6
    if (rowIndex > 3)
        rowIndex = 3;
    else if (rowIndex < 0)
        rowIndex = 0;

    var tileIndex = (rowIndex * 3) + columnIndex;

    // There are only 12 tiles
    if (tileIndex > 11)
        return 11;

    return tileIndex;
}

/*! Mouse down event
    @param anEvent the event
*/
- (void)mouseDown:(CPEvent)anEvent
{
    var locationInView = [self convertPoint:[anEvent locationInWindow] fromView:nil],
        tileIndex = [self indexOfTileAtPoint:locationInView],
        tile = [[self subviews] objectAtIndex:tileIndex];

    [self selectIndex:tileIndex];
}


#pragma mark -
#pragma mark Select method

/*! Select an index
    @param anIndex an index
*/
- (void)selectIndex:(int)anIndex
{
    var tiles = [self subviews],
        tilesCount = [tiles count];

    for (var i = 0; i < tilesCount; i++)
    {
        var tile = tiles[i];

        if (anIndex == i)
        {
            [tile setSelected:YES];
        }
        else
        {
            [tile setSelected:NO];
            [tile setHighlighted:NO];
        }

    }

    [_yearCalendar _didMakeSelection:anIndex];
}

- (void)highlightIndex:(int)anIndex
{
    var tiles = [self subviews],
        tilesCount = [tiles count];

    for (var i = 0; i < tilesCount; i++)
    {
        var tile = tiles[i];

        if (anIndex == i)
            [tile setHighlighted:YES];
        else
            [tile setHighlighted:NO];
    }
}

@end


@implementation _LPContentYearView : CPControl
{
    BOOL isHighlighted @accessors(setter=setHighlighted:);
    BOOL isSelected @accessors(setter=setSelected:);

    CPTextField _textField;
    LPTimeIntervalYearView _yearCalendar;
}

/*! Init a new _LPContentMonthView
    @param aFrame a frame
    @param aMonthCalendar a monthCalendar
*/
- (id)initWithFrame:(CGRect)aFrame withYearCalendar:(LPMonthCalendar)anYearCalendar
{
    if (self = [super initWithFrame:aFrame])
    {
        [self setHitTests:NO];

        _textField = [[CPTextField alloc] initWithFrame:CGRectMakeZero()];
        [_textField setAutoresizingMask:CPViewMinXMargin | CPViewMaxXMargin | CPViewMinYMargin | CPViewMaxYMargin];

        [self addSubview:_textField];

        _yearCalendar = anYearCalendar;
    }
    return self;
}


#pragma mark -
#pragma mark Accessors

/*! Select or not a cell
    @param a boolean shouldBeSelected
*/
- (void)setSelected:(BOOL)shouldBeSelected
{
    if (isSelected === shouldBeSelected)
        return;

    isSelected = shouldBeSelected;

    if (shouldBeSelected)
        [self setThemeState:CPThemeStateSelected];
    else
        [self unsetThemeState:CPThemeStateSelected];
}

/*! Hilight or not a cell
    @param a bollean shouldBeHighlighted
*/
- (void)setHighlighted:(BOOL)shouldBeHighlighted
{
    if (isHighlighted === shouldBeHighlighted)
        return;

    isHighlighted = shouldBeHighlighted;

    if (shouldBeHighlighted)
        [self setThemeState:CPThemeStateHighlighted];
    else
        [self unsetThemeState:CPThemeStateHighlighted];
}

/*! Set the title of the cell
    @param aTitle the title
*/
- (void)setTitle:(CPString)aTitle
{
    // Update & Position the new label
    [_textField setStringValue:aTitle];
    [_textField sizeToFit];

    var bounds = [self bounds];
    [_textField setCenter:CGPointMake(CGRectGetMidX(bounds), CGRectGetMidY(bounds))];
}


#pragma mark -
#pragma mark layoutSubviews

/*! Layout the subviews
*/
- (void)layoutSubviews
{
    var themeState = [self themeState];

    [self setBackgroundColor:[_yearCalendar valueForThemeAttribute:@"tile-bezel-color" inState:themeState]]
    [_textField setFont:[_yearCalendar valueForThemeAttribute:@"tile-font" inState:themeState]];
    [_textField setTextColor:[_yearCalendar valueForThemeAttribute:@"tile-text-color" inState:themeState]];
    [_textField setTextShadowColor:[_yearCalendar valueForThemeAttribute:@"tile-text-shadow-color" inState:themeState]];
    [_textField setTextShadowOffset:[_yearCalendar valueForThemeAttribute:@"tile-text-shadow-offset" inState:themeState]];
}

@end
