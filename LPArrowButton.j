/*
*   Filename:         LPArrowButton.j
*   Created:          Wed Dec  5 14:54:22 PST 2012
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

@import <AppKit/CPButton.j>

@implementation LPArrowButton : CPButton
{
}

/*! Used for the animation of the button when clicking
*/
- (void)stopTracking:(CGPoint)lastPoint at:(CGPoint)aPoint mouseIsUp:(BOOL)mouseIsUp
{
    [self setFrameOrigin:CGPointMake([self frameOrigin].x, [self frameOrigin].y - 1)]
    [super stopTracking:lastPoint at:aPoint mouseIsUp:mouseIsUp];
}

/*! Used for the animation of the button when clicking
*/
- (void)mouseDown:(CPEvent)anEvent
{
    [super mouseDown:anEvent];
    [self setFrameOrigin:CGPointMake([self frameOrigin].x, [self frameOrigin].y + 1)];
}

@end
