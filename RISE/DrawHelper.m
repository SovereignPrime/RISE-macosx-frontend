//
//  DrawHelper.m
//  RISE
//
//  Created by T0ha on 24.07.14.
//
//

#import "DrawHelper.h"

@implementation DrawHelper
- (void)drawRect:(NSRect)rect
{
    // Call original drawing method
    [self drawRectOriginal:rect];
    [self _setTextShadow:NO];
    
    NSRect titleRect;
    
    NSRect brect = [self bounds];
    
    // creating round-rected bounding path
    float radius = [self roundedCornerRadius];
    NSBezierPath *path = [NSBezierPath alloc];
    NSPoint topMid = NSMakePoint(NSMidX(brect), NSMaxY(brect));
    NSPoint topLeft = NSMakePoint(NSMinX(brect), NSMaxY(brect));
    NSPoint topRight = NSMakePoint(NSMaxX(brect), NSMaxY(brect));
    NSPoint bottomRight = NSMakePoint(NSMaxX(brect), NSMinY(brect));
    
    [path moveToPoint: topMid];
    [path appendBezierPathWithArcFromPoint: topRight
                                   toPoint: bottomRight
                                    radius: radius];
    [path appendBezierPathWithArcFromPoint: bottomRight
                                   toPoint: brect.origin
                                    radius: radius];
    [path appendBezierPathWithArcFromPoint: brect.origin
                                   toPoint: topLeft
                                    radius: radius];
    [path appendBezierPathWithArcFromPoint: topLeft
                                   toPoint: topRight
                                    radius: radius];
    [path closePath];
    
    [path addClip];
    
    // rect for title
    titleRect = NSMakeRect(0, 0, brect.size.width, brect.size.height);
    
    // get current context
    CGContextRef context = (CGContextRef)[[NSGraphicsContext currentContext] graphicsPort];
    // multiply mode - for colorizing original border
    CGContextSetBlendMode(context, kCGBlendModeMultiply);
    
    // draw background
    if (!gFrameColor)
        // default bg color
        gFrameColor = [NSColor colorWithCalibratedRed: (126 / 255.0) green: (161 / 255.0) blue: (177 / 255.0) alpha: 1.0];
    
    [gFrameColor set];
    
    [[NSBezierPath bezierPathWithRect:rect] fill];
    
    // copy mode - for title
    CGContextSetBlendMode(context, kCGBlendModeCopy);
    
    // draw title text
    [self _drawTitleStringIn: titleRect withColor: nil];
}

- (void)_drawTitleStringIn: (NSRect) rect withColor: (NSColor *) color
{
    if (!gTitleColor)
        // default text color
        gTitleColor = [NSColor colorWithCalibratedRed: 1.0 green: 1.0 blue: 1.0 alpha: 1.0];
    [self _drawTitleStringOriginalIn: rect withColor: gTitleColor];
}

@end
