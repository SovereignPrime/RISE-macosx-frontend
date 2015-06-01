//
//  appAppDelegate.h
//  RISE
//
//  Created by Mac User on 12/4/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>
#import <WebKit/WebUIDelegate.h>
#import <WebKit/WebPolicyDelegate.h>

@interface appAppDelegate : NSObject <NSApplicationDelegate>
{
    id backend;
    NSString * backendPath;
    id win;
 }

@property (assign) IBOutlet NSWindow *window;
@property (assign) IBOutlet WebView *webUI;

@end
