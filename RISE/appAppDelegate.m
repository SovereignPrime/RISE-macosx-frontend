//
//  appAppDelegate.m
//  RISE
//
//  Created by Mac User on 12/4/13.
//  Copyright (c) 2013 Sovereign Prime. All rights reserved.
//

#import "appAppDelegate.h"
#import <Foundation/Foundation.h>
#import <Foundation/NSProcessInfo.h>

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
    NSFileManager *conf = [NSFileManager defaultManager];
    NSString *binPath = [backendPath stringByAppendingPathComponent: @"erts-5.10.3/bin/erl"];
    [conf removeItemAtPath:@"/tmp/rise.port" error:nil];
    NSString *vsn = [NSString stringWithContentsOfFile: [backendPath stringByAppendingPathComponent: @"releases/start_erl.data"] encoding: NSASCIIStringEncoding error:nil];
    
    vsn = [[[vsn componentsSeparatedByString: @" "] lastObject] stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSArray *args = [NSArray arrayWithObjects: @"-pa",  @"./site/ebin", 
                                              @"-pa", @"./site/include",
                                              @"-embded", @"-sname", @"rise",
                                              @"-boot", [@"." stringByAppendingFormat: @"%@%@%@", @"/releases/", vsn, @"/rise"],
                                              @"-config", @"./etc/app.config",
                                              @"-config", @"./etc/bitmessage.config",
                                              @"-config",  @"./etc/cowboy.config",
                                              @"-config", @"./etc/eminer.config",
                                              @"-config", @"./etc/etorrent.config",
                                              @"-config", @"./etc/sync.config",
                                              @"-args_file",  @"./etc/vm.args",
                     nil
                                              ];
    backend = [NSTask new];
    NSMutableDictionary *env = [NSMutableDictionary dictionaryWithDictionary: [[NSProcessInfo processInfo] environment]];
    
    [env setObject: backendPath forKey: @"ROOTDIR"]; 
    [env setObject: [backendPath stringByAppendingPathComponent:@"/site/static"] forKey: @"DOC_ROOT"]; 
    [backend setEnvironment: env];
    [backend setCurrentDirectoryPath:backendPath];
    [backend setArguments: args];
    [backend setLaunchPath: binPath ];
    [backend launch];
    // [backend waitUntilExit];
    while (![conf fileExistsAtPath: @"/tmp/rise.port"]);
    NSString *port = [NSString stringWithContentsOfFile: @"/tmp/rise.port" encoding: NSASCIIStringEncoding error: nil];
    NSString *url = [@"http://localhost:" stringByAppendingString: port];
    id responce = [NSURLRequest requestWithURL:[NSURL URLWithString: url]];
    [[self.webUI mainFrame] loadRequest:responce];
}
- (NSApplicationTerminateReply) applicationShouldTerminate:(NSApplication *)sender
{
    [backend terminate];
    [backend waitUntilExit];
    //NSString * bin = [backendPath stringByAppendingPathComponent: @"bin/rise"]; 
    // backend = [NSTask launchedTaskWithLaunchPath:bin arguments:[NSArray arrayWithObject:@"stop"]];
    //return NSTerminateNow;
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
-(void)download:(NSURLDownload *)download decideDestinationWithSuggestedFilename:(NSString *)filename
{
    NSSavePanel *savePanel = [NSSavePanel savePanel];
    [savePanel setNameFieldStringValue:filename];
    if ([savePanel runModal] == NSOKButton ) 
    {
        NSString *path = [[savePanel URL] path];
        [download setDestination: path allowOverwrite:YES];
    }
}
- (void)webView:(WebView *)webView 
   decidePolicyForMIMEType:(NSString *)type 
                   request:(NSURLRequest *)request 
                     frame:(WebFrame *)frame 
          decisionListener:(id < WebPolicyDecisionListener >)listener
{
    NSLog(type);
    if([type isEqualToString:@"octet/binary"])
    {
        [listener download];
    }
}



@end

