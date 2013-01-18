/*
 * LPCrashReporter.j
 * LPKit
 *
 * Created by Ludwig Pettersson on February 19, 2010.
 *
 * The MIT License
 *
 * Copyright (c) 2010 Ludwig Pettersson
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

@import <Foundation/CPObject.j>
@import <AppKit/CPAlert.j>

@import "LPURLPostRequest.j"
@import "LPMultiLineTextField.j"

@import "Resources/stacktrace.js"

var sharedErrorLoggerInstance = nil;


/*! @ingroup LPKit

    This class let you handle easily the management of crash reports for your application.

    How to use it:
    You need to call first [LPCrashReporter sharedErrorLogger] to initialize the reporter.
    Note that any exception occuring in the method where you call this will *not* be caught.

    Then you can configure it:

        [[LPCrashReporter sharedErrorLogger] setVersion:@"1.0.1"];
        [[LPCrashReporter sharedErrorLogger] setReportURL:[CPURL URLWithString:@"http://myawseomapp/crashreport.php"]];

    Note: the reportURL can also be set by defining a key in your Info.plist called "LPCrashReporterLoggingURL";

    In case of uncaught exception the reporter will freeze your application, and display a dialog to let user a chance
    to describe what he did and gather some information.
    Then if user click "Report", the reporter will send to your crash report manager the following request

        ```
        POST <reportURL> HTTP/1.0
        <HTTP-HEADERs>

        name=<exception name>
        reason=<exception reason>
        userAgent=<navigator userAgent>
        description=<user description>
        stackTrace=<the stacktrace>
        version=<version>
        ```

    Then your server can return a string as HTTP response body. This body will be shown to the user.


    You can manage custom behavior in crash handling by setting a delegate

        [[LPCrashReporter sharedErrorLogger] setDelegate:myObject];

    And implementing

        - (void)crashReporter:(LPCrashReporter)aCrashReported didCatchException:(CPDictionary)someInfo

    The dictionary will contains keys CPException, userAgent, description, stackTrace and version


    You can temporarly deactivate the reporter in your code by doing:

        [[LPCrashReporter sharedErrorLogger] setShouldInterceptException:NO];

    And reactivate it by doing:

        [[LPCrashReporter sharedErrorLogger] setShouldInterceptException:YES];
*/
@implementation LPCrashReporter : CPObject
{
    CPException _exception                  @accessors(property=exception);

    BOOL        shouldInterceptException    @accessors;
    CPString    alertInformative            @accessors;
    CPString    alertMessage                @accessors;
    CPString    version                     @accessors;
    CPURL       reportURL                   @accessors;
    id          delegate                    @accessors;

    id          stackTrace;
}

+ (id)sharedErrorLogger
{
    if (!sharedErrorLoggerInstance)
        sharedErrorLoggerInstance = [[LPCrashReporter alloc] init];

    return sharedErrorLoggerInstance;
}

- (id)init
{
    if (self = [super init])
    {
        alertMessage = [CPString stringWithFormat:@"The application %@ crashed unexpectedly.",
                                                  [[CPBundle mainBundle] objectForInfoDictionaryKey:@"CPBundleName"]];
        alertInformative = @"Click Reload to load the application again or click Report to send a report to the developer.";

        shouldInterceptException = YES;
        install_msgSend_catcher();
    }
    return self;
}

- (void)didCatchException:(CPException)anException stackTrace:(id)aStackTrace
{
    if ([self shouldInterceptException])
    {
        if (_exception)
            return;

        _exception = anException;
        stackTrace = aStackTrace;

        var overlayWindow = [[LPCrashReporterOverlayWindow alloc] initWithContentRect:CGRectMakeZero() styleMask:CPBorderlessBridgeWindowMask];
        [overlayWindow setLevel:CPNormalWindowLevel];
        [overlayWindow makeKeyAndOrderFront:nil];

        var alert = [[CPAlert alloc] init];
        [alert setDelegate:self];
        [alert setAlertStyle:CPCriticalAlertStyle];
        [alert addButtonWithTitle:@"Reload"];
        [alert addButtonWithTitle:@"Report..."];
        [alert setMessageText:alertMessage];
        [alert setInformativeText:alertInformative];
        [alert runModal];
    }
    else
    {
        [anException raise];
    }
}

/*
    CPAlert delegate methods:
*/

- (void)alertDidEnd:(CPAlert)anAlert returnCode:(id)returnCode
{
    switch (returnCode)
    {
        case 0: // Reload application
                location.reload();
                break;

        case 1: // Send report
                var reportWindow = [[LPCrashReporterReportWindow alloc] initWithContentRect:CGRectMake(0,0,560,409) styleMask:CPTitledWindowMask | CPResizableWindowMask stackTrace:stackTrace];
                [reportWindow setDelegate:delegate];
                [CPApp runModalForWindow:reportWindow];
                break;
    }
}

@end


@implementation LPCrashReporterOverlayWindow : CPWindow

- (void)initWithContentRect:(CGRect)aContentRect styleMask:(id)aStyleMask
{
    if (self = [super initWithContentRect:aContentRect styleMask:aStyleMask])
    {
        [[self contentView] setBackgroundColor:[CPColor colorWithWhite:0 alpha:0.4]];
    }
    return self;
}

@end


@implementation LPCrashReporterReportWindow : CPWindow
{
    CPButton                cancelButton;
    CPButton                sendButton;
    CPString                reportURL;
    CPTextField             descriptionLabel;
    CPTextField             informationLabel;
    CPTextField             sendingLabel;
    CPURL                   loggingURL;
    id                      stackTrace;
    LPMultiLineTextField    descriptionTextField;
    LPMultiLineTextField    informationTextField;
}

- (void)initWithContentRect:(CGRect)aContentRect styleMask:(id)aStyleMask stackTrace:(id)aStackTrace
{
    if (self = [super initWithContentRect:aContentRect styleMask:aStyleMask])
    {
        var contentView = [self contentView],
            applicationName = [[CPBundle mainBundle] objectForInfoDictionaryKey:@"CPBundleName"];

        [self setMinSize:aContentRect.size];
        [self setTitle:[CPString stringWithFormat:@"Problem Report for %@", applicationName]];

        informationLabel = [CPTextField labelWithTitle:@"Problem and system information:"];
        [informationLabel setFrameOrigin:CGPointMake(12,12)];
        [contentView addSubview:informationLabel];

        stackTrace = aStackTrace;
        var informationTextValue = [CPString stringWithFormat:@"User-Agent: %@\n\nException: %@\n\nVersion: %@\n\nStack Trace: \n %@",
                                                              navigator.userAgent,
                                                              [[LPCrashReporter sharedErrorLogger] exception],
                                                              [[LPCrashReporter sharedErrorLogger] version],
                                                              stackTrace];

        informationTextField = [LPMultiLineTextField textFieldWithStringValue:informationTextValue placeholder:@"" width:0];
        [informationTextField setEditable:NO];
        [informationTextField setFrame:CGRectMake(12, 31, CGRectGetWidth(aContentRect) - 24, 200)];
        [informationTextField setAutoresizingMask:CPViewWidthSizable | CPViewHeightSizable];
        [informationTextField setFont:[CPFont fontWithName:@"Courier New" size:11.0]];
        [contentView addSubview:informationTextField];

        descriptionLabel = [CPTextField labelWithTitle:@"Please describe what you were doing when the problem happened:"];
        [descriptionLabel setFrameOrigin:CGPointMake(12,241)];
        [descriptionLabel setAutoresizingMask:CPViewMinYMargin];
        [contentView addSubview:descriptionLabel];

        descriptionTextField = [LPMultiLineTextField textFieldWithStringValue:@"" placeholder:@"" width:0];
        [descriptionTextField setFrame:CGRectMake(CGRectGetMinX([informationTextField frame]), CGRectGetMaxY([descriptionLabel frame]) + 1, CGRectGetWidth([informationTextField frame]), 100)];
        [descriptionTextField setAutoresizingMask:CPViewWidthSizable | CPViewMinYMargin];
        [contentView addSubview:descriptionTextField];

        sendButton = [CPButton buttonWithTitle:[CPString stringWithFormat:@"Send to %@", applicationName]];
        [sendButton setFrameOrigin:CGPointMake(CGRectGetWidth(aContentRect) - CGRectGetWidth([sendButton frame]) - 15, 370)];
        [sendButton setAutoresizingMask:CPViewMinXMargin | CPViewMinYMargin];
        [sendButton setTarget:self];
        [sendButton setAction:@selector(didClickSendButton:)];
        [contentView addSubview:sendButton];
        [self setDefaultButton:sendButton];

        cancelButton = [CPButton buttonWithTitle:@"Cancel"];
        [cancelButton setFrameOrigin:CGPointMake(CGRectGetMinX([sendButton frame]) - CGRectGetWidth([cancelButton frame]) - 12, CGRectGetMinY([sendButton frame]))];
        [cancelButton setAutoresizingMask:CPViewMinXMargin | CPViewMinYMargin];
        [cancelButton setTarget:self];
        [cancelButton setAction:@selector(didClickCancelButton:)];
        [contentView addSubview:cancelButton];

        sendingLabel = [CPTextField labelWithTitle:@"Sending Report..."];
        [sendingLabel setFont:[CPFont boldSystemFontOfSize:11]];
        [sendingLabel sizeToFit];
        [sendingLabel setFrameOrigin:CGPointMake(12, CGRectGetMaxY(aContentRect) - 35)];
        [sendingLabel setHidden:YES];
        [contentView addSubview:sendingLabel];

        var userReportURL = [[LPCrashReporter sharedErrorLogger] reportURL],
            bundleReportURL = [CPURL URLWithString:[[CPBundle mainBundle] objectForInfoDictionaryKey:@"LPCrashReporterLoggingURL"]];

        reportURL = userReportURL || bundleReportURL;
    }

    return self;
}

- (void)orderFront:(id)sender
{
    [super orderFront:sender];
    [self makeFirstResponder:descriptionTextField];
}

- (void)didClickSendButton:(id)sender
{
    [informationTextField setEnabled:NO];
    [descriptionTextField setEnabled:NO];
    [sendButton setEnabled:NO];
    [cancelButton setEnabled:NO];
    [informationLabel setAlphaValue:0.5];
    [descriptionLabel setAlphaValue:0.5];

    [sendingLabel setHidden:NO];

    var delegate = [[LPCrashReporter sharedErrorLogger] delegate],
        exception = [[LPCrashReporter sharedErrorLogger] exception];


    if (delegate && [delegate respondsToSelector:@selector(crashReporter:didCatchException:)])
    {
        var content = [CPDictionary dictionaryWithObjectsAndKeys:exception, @"exception",
                                                                 navigator.userAgent, @"userAgent",
                                                                 [descriptionTextField stringValue], @"description",
                                                                 stackTrace, @"stackTrace",
                                                                 [[LPCrashReporter sharedErrorLogger] version], @"version"];

        [delegate crashReporter:self didCatchException:content];
        location.reload();
    }
    else
    {
        var request = [LPURLPostRequest requestWithURL:reportURL],
            content = { 'name': [exception name],
                        'reason': [exception reason],
                        'userAgent': navigator.userAgent,
                        'description': [descriptionTextField stringValue],
                        'stackTrace': @"" + stackTrace + @"",
                        'version': [[LPCrashReporter sharedErrorLogger] version]};

        [request setContent:content];
        [CPURLConnection connectionWithRequest:request delegate:self];
    }
}

- (void)didClickCancelButton:(id)sender
{
    // Make the behaviour the same as if you click reload
    // on the initial alert.
    [[LPCrashReporter sharedErrorLogger] alertDidEnd:nil returnCode:0];
}

/*
    CPURLConnection delegate methods:
*/

- (void)connection:(CPURLConnection)aConnection didReceiveData:(id)aData
{
    [CPApp stopModal];
    [self orderOut:nil];

    var serverReply = aData,
        alert = [[CPAlert alloc] init];

    [alert setAlertStyle:CPInformationalAlertStyle];
    [alert addButtonWithTitle:@"Thanks!"];
    [alert addButtonWithTitle:@"Open Issue"];
    [alert._informativeLabel setSelectable:YES];


    if (serverReply)
    {
        [alert setMessageText:@"Thank you! Your report has been sent"];
        [alert setInformativeText:serverReply];
    }
    else
    {
        [alert setMessageText:@"Thanks!"];
        [alert setMessageText:@"Your report has been sent."];
    }

    [alert runModal];
}

- (void)alertDidEnd:(CPAlert)anAlert returnCode:(id)returnCode
{
    switch (returnCode)
    {
        case 0: // Reload application
                location.reload();
                break;

        case 1: // Send report
                window.open(reportURL);
                location.reload();
                break;
    }
}

@end

/*
    Let the monkey patching begin
*/

var original_objj_msgSend = objj_msgSend;

var catcher_objj_msgSend = function()
{
    try
    {
        // Don't catch on recursive objj_msgSend calls - if the exception
        // doesn't propagate to the top we can assume it was handled properly.
        // Also, wrapping every single objj_msgSend hits performance hard.
        objj_msgSend = original_objj_msgSend;
        return objj_msgSend.apply(this, arguments);
    }
    catch (anException)
    {
        CPLog.error(anException);
        [[LPCrashReporter sharedErrorLogger] didCatchException:anException stackTrace:printStackTrace({e: anException})];
        return nil;
    }
    finally
    {
        // Reinstall when we exit the top level objj_msgSend.
        objj_msgSend = catcher_objj_msgSend;
    }
};

/*
    Used by LPCrashReporter for the intial install.
*/
var install_msgSend_catcher = function()
{
    objj_msgSend = catcher_objj_msgSend;
};
