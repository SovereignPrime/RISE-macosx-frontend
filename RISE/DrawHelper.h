//
//  DrawHelper.h
//  RISE
//
//  Created by T0ha on 24.07.14.
//
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

// global frame color
static NSColor * gFrameColor = nil;
// global title color
static NSColor * gTitleColor = nil;

@interface DrawHelper : NSObject
{
}

// to prevent errors
- (float)roundedCornerRadius;
- (void)drawRectOriginal:(NSRect)rect;
- (void) _drawTitleStringOriginalIn: (NSRect) rect withColor: (NSColor *) color;
- (NSWindow*)window;
- (id)_displayName;
- (NSRect)bounds;
- (void)_setTextShadow:(BOOL)on;

- (void)drawRect:(NSRect)rect;
- (void) _drawTitleStringIn: (NSRect) rect withColor: (NSColor *) color;
@end