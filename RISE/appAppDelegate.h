//
//  appAppDelegate.h
//  RISE
//
//  Created by Mac User on 12/4/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>
@interface appAppDelegate : NSObject <NSApplicationDelegate>
{
 id backend;
 }

@property (assign) IBOutlet NSWindow *window;
@property (assign) IBOutlet WebView *webUI;

@end
