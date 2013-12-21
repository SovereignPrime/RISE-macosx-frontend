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
    backendPath = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"/Contents/Backend"];
    [backendPath retain];
    NSFileManager * conf = [NSFileManager defaultManager];
    NSError * err = nil;
    NSEnumerator * confUrls = [[conf URLsForDirectory: NSLibraryDirectory inDomains:NSUserDomainMask] objectEnumerator];    
    id obj;
    while (obj = [confUrls nextObject]) {
        NSString * path = [[NSURL URLWithString:@"rise" relativeToURL: obj] path];
        NSLog(path);
        //[conf createDirectoryAtPath: path withIntermediateDirectories:YES attributes:nil error:nil];
        NSString * from = [backendPath stringByAppendingPathComponent: @"etc"];
        NSLog(from);
        [conf copyItemAtPath: from toPath:path error: &err];
        NSLog([err localizedDescription]);
    }
    NSString * binPath = [backendPath stringByAppendingPathComponent: @"bin/nitrogen"];
    NSLog(binPath);
    backend = [NSTask launchedTaskWithLaunchPath: binPath arguments:[NSArray arrayWithObject:@"start"]];
    [backend waitUntilExit];
    
    while ([NSData dataWithContentsOfURL:[NSURL URLWithString:@"http://localhost:8000"]] == nil);
    id responce = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://localhost:8000"]];
    [[self.webUI mainFrame] loadRequest:responce];
}
- (NSApplicationTerminateReply) applicationShouldTerminate:(NSApplication *)sender
{
    
    NSString * bin = [backendPath stringByAppendingPathComponent: @"bin/nitrogen"]; 
     backend = [NSTask launchedTaskWithLaunchPath:bin arguments:[NSArray arrayWithObject:@"stop"]];
    //[backend waitUntilExit];
    return NSTerminateNow;
}
- (void)webView:(WebView *)sender runOpenPanelForFileButtonWithResultListener:(id < WebOpenPanelResultListener >)resultListener
{       
    // Create the File Open Dialog class.
    NSOpenPanel* openDlg = [NSOpenPanel openPanel];
    
    // Enable the selection of files in the dialog.
    [openDlg setCanChooseFiles:YES];
    
    // Enable the selection of directories in the dialog.
    [openDlg setCanChooseDirectories:NO];
    
    if ( [openDlg runModal] == NSOKButton )
    {
        NSArray* URLs = [openDlg URLs];
        NSMutableArray *files = [[NSMutableArray alloc]init];
        for (int i = 0; i <[URLs count]; i++) {
            NSString *filename = [[URLs objectAtIndex:i]relativePath];
            [files addObject:filename];
        }
        
        for(int i = 0; i < [files count]; i++ )
        {
            NSString* fileName = [files objectAtIndex:i];
            [resultListener chooseFilename:fileName]; 
        }
        [files release];
    }
    
}


@end
