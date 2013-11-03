//
//  sourceImageView.h
//  spriteEditor
//
//  Created by afiki on 07.07.13.
//  Copyright (c) 2013 afiki. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ImageViewer : NSOpenGLView <NSDraggingDestination>

+ (ImageViewer *)instance;
+ (void)setLastImageFileName:(NSString *)fileName;

- (void) drawRect: (NSRect) bounds;
- (void) setScale:(float)value;
- (void) updateFrame;
- (void) loadImageFromResource:(NSString *)fileName;
- (void) reloadImage;
- (void) resetTransform;

@end
