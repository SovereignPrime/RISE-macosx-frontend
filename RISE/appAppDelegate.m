//
//  appAppDelegate.m
//  RISE
//
//  Created by Mac User on 12/4/13.
//  Copyright (c) 2013 Sovereign Prime. All rights reserved.
//

#import "appAppDelegate.h"
#import "DrawHelper.h"
#import <Foundation/Foundation.h>
#import <Foundation/NSProcessInfo.h>
#import <objc/runtime.h>

@implementation appAppDelegate

@synthesize window = _window;

@synthesize webUI = _webUI;

- (void)dealloc
{
    [super dealloc];
}
	
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    id _class = [[[self.window contentView] superview] class];
    
    // Exchange drawRect:
    Method m0 = class_getInstanceMethod([DrawHelper class], @selector(drawRect:));
    class_addMethod(_class, @selector(drawRectOriginal:), method_getImplementation(m0), method_getTypeEncoding(m0));
    
    Method m1 = class_getInstanceMethod(_class, @selector(drawRect:));
    Method m2 = class_getInstanceMethod(_class, @selector(drawRectOriginal:));
    
    method_exchangeImplementations(m1, m2);
    
    // Exchange _drawTitleStringIn:withColor:
    Method m3 = class_getInstanceMethod([DrawHelper class], @selector(_drawTitleStringIn:withColor:));
    class_addMethod(_class, @selector(_drawTitleStringOriginalIn:withColor:), method_getImplementation(m3), method_getTypeEncoding(m3));
    
    Method m4 = class_getInstanceMethod(_class, @selector(_drawTitleStringIn:withColor:));
    Method m5 = class_getInstanceMethod(_class, @selector(_drawTitleStringOriginalIn:withColor:));
    
    method_exchangeImplementations(m4, m5);
    
    [self.window setTitlebarAppearsTransparent:YES];
    backendPath = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"/Contents/Backend"];
    [backendPath retain];
   /* NSString *url = [NSString stringWithFormat: @"http://localhost:%d", 8000];
    id responce = [NSURLRequest requestWithURL:[NSURL URLWithString: url]];
    [[self.webUI mainFrame] loadRequest:responce];*/
    [self startBackend];
}
- (NSApplicationTerminateReply) applicationShouldTerminate:(NSApplication *)sender
{
    [[NSNotificationCenter defaultCenter] removeObserver: self];
    [backend terminate];
    [backend waitUntilExit];
    return NSTerminateNow;
}

- (void)notificationListener:(NSNotification *)notification
{
    NSData *data = [[notification userInfo] objectForKey:NSFileHandleNotificationDataItem];
    if ([data length] > 0) {
        NSString *str = [NSString stringWithUTF8String: [data bytes]];
        NSScanner * scan = [NSScanner scannerWithString:str];
        [scan scanUpToString:@"0.0.0.0:" intoString: NULL];
        if (![scan isAtEnd]) {
            [scan setScanLocation:[scan scanLocation] + 8];
            int port;
            [scan scanInt:&port];
            NSString *url = [NSString stringWithFormat: @"http://localhost:%d", port];
            id responce = [NSURLRequest requestWithURL:[NSURL URLWithString: url]];
            [[self.webUI mainFrame] loadRequest:responce];
            win = [self.webUI windowScriptObject];
        } else {
            [[notification object] readInBackgroundAndNotify];
        }
            
    }
    
}

- (void)receiveWakeNote: (NSNotification *) note
{
    NSLog(@"Wake note: %@", [note name]);
    [self.webUI reload:self];
}

-(void)webView:(WebView *)webView willPerformDragDestinationAction:(WebDragDestinationAction)action forDraggingInfo:(id<NSDraggingInfo>)draggingInfo
{
    NSPasteboard *pbord = [draggingInfo draggingPasteboard];
    if ([[pbord types] containsObject:NSFilenamesPboardType]) {
    NSArray *files = [pbord propertyListForType:NSFilenamesPboardType];
    
    [win evaluateWebScript:[NSString stringWithFormat:@"upload('%@');", [files lastObject]]];
    }
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
            NSString *filename = [[URLs objectAtIndex:i] absoluteString];
            [files addObject:filename];
        }
        
        for(int i = 0; i < [files count]; i++ )
        {
            NSString* fileName = [files objectAtIndex:i];
            NSLog(@"%@\n", fileName);
            [win evaluateWebScript:[NSString stringWithFormat:@"upload('%@');", fileName]];
            [resultListener chooseFilename:@"fileName"];
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
        //[download setDestination: path allowOverwrite:YES];
        [win evaluateWebScript:[NSString stringWithFormat:@"download('%@');", path]];
    }
}
- (void)webView:(WebView *)webView 
   decidePolicyForMIMEType:(NSString *)type 
                   request:(NSURLRequest *)request 
                     frame:(WebFrame *)frame 
          decisionListener:(id < WebPolicyDecisionListener >)listener
{
    if([type isEqualToString:@"octet/binary"])
    {
        [listener download];
    }
}
- (void)startBackend
{
    NSFileManager *conf = [NSFileManager defaultManager];
    NSString *binPath = [backendPath stringByAppendingPathComponent:@"erts-7.1/bin/erl"];
    [conf removeItemAtPath:@"/tmp/rise.port" error:nil];
    NSString *vsn = [NSString stringWithContentsOfFile: [backendPath stringByAppendingPathComponent: @"releases/start_erl.data"] encoding: NSASCIIStringEncoding error:nil];
    
    vsn = [[[vsn componentsSeparatedByString: @" "] lastObject] stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSArray *args = [NSArray arrayWithObjects:  @"-args_file",  @"./etc/vm.args",
                        nil
                                              ];
    backend = [NSTask new];
    NSMutableDictionary *env = [NSMutableDictionary dictionaryWithDictionary: [[NSProcessInfo processInfo] environment]];
    
    [env setObject: backendPath forKey: @"ROOTDIR"]; 
    [env setObject: [backendPath stringByAppendingPathComponent:@"/site/static"] forKey: @"DOC_ROOT"]; 
    [backend setEnvironment: env];
    [backend setCurrentDirectoryPath:backendPath];
    [backend setArguments: args];
    NSPipe *mstdout = [NSPipe pipe];
    [backend setStandardOutput: mstdout];
    [backend setStandardError:[NSPipe pipe]];
    [backend setStandardInput:[NSPipe pipe]];
    [backend setLaunchPath: binPath ];
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(notificationListener:) 
                                                 name:NSFileHandleReadCompletionNotification 
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(backendTerminteNotification:) 
                                                 name:NSTaskDidTerminateNotification
                                               object:nil];
    
    [[[NSWorkspace sharedWorkspace] notificationCenter] addObserver: self
                                                           selector: @selector(receiveWakeNote:)
                                                               name: NSWorkspaceDidWakeNotification object: NULL];
    
    [backend launch];
    [[mstdout fileHandleForReading] readInBackgroundAndNotify];
}

- (void)backendTerminteNotification:(NSNotification *)notification
{
    [[NSNotificationCenter defaultCenter] removeObserver: self];
    int status = [backend terminationStatus];
    NSLog(@"Stopped accidentally status: %d\n", status);
    [self startBackend];
}
@end

