//
//  appAppDelegate.m
//  RISE
//
//  Created by Mac User on 12/4/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import "appAppDelegate.h"
#import <Foundation/Foundation.h>

@implementation appAppDelegate

@synthesize window = _window;

@synthesize webUI = _webUI;

- (void)dealloc
{
    [super dealloc];
}
	
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    id backend = [NSTask launchedTaskWithLaunchPath:@"/opt/rise/bin/nitrogen" arguments:[NSArray arrayWithObject:@"start"]];
    [backend waitUntilExit];
    id responce = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://localhost:8000"]];
    while ([NSURLConnection connectionWithRequest:responce delegate:nil] == nil);
    //[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://localhost:8000"]];
    [[self.webUI mainFrame] loadRequest:responce];
}

@end
