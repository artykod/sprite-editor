//
//  sourceImageView.m
//  spriteEditor
//
//  Created by afiki on 07.07.13.
//  Copyright (c) 2013 afiki. All rights reserved.
//

#import	<OpenGL/gl.h>
#import	<OpenGL/glu.h>
#import "ImageViewer.h"
#import "MainWindow.h"
#import "Console.h"

@implementation ImageViewer

float scaleCorrectionX = 1.f, scaleCorrectionY = 1.f;
NSPoint mouseOld;
NSPoint translate;
float scale = 1.f;

GLuint texture = 0;
float textureWidth = 0;
float textureHeight = 0;

float mainSpriteScaleX = 1.f;
float mainSpriteScaleY = 1.f;

double red = 0;
double green = 0;
double blue = 0;

static ImageViewer *instanceImageViewer;
+ (ImageViewer *)instance {
	return instanceImageViewer;
}

static NSString *lastImageFileName = nil;
+ (void)setLastImageFileName:(NSString *)fileName {
	lastImageFileName = fileName;
}

// PARAMETERS ========================================================================

- (void) resetTransform {
	scale = 1.f;
	translate.x = 0.f;
	translate.y = 0.f;
	
	[self updateFrame];
}

- (void) setScale:(float)value {
	scale = MAX(0.01f, value);
	[self setNeedsDisplay: YES];
}



// LOADING IMAGE ========================================================================

- (GLuint) loadTextureFromFile: (NSString *) fileName {
	NSBitmapImageRep *image = [NSBitmapImageRep imageRepWithContentsOfFile:fileName];
	
    if (image == nil) {
		NSBeep();
		
		NSAlert *alert = [[NSAlert alloc] init];
		[alert setMessageText:@"Unable to load texture."];
		[alert runModal];
		
		[Console log:[NSString stringWithFormat:@"Unable to load texture from file : %@", fileName]];
		
		NSLog(@"Unable to load texture from file : %@", fileName);
		
        return 0;
    }
	
    int    bitsPerPixel = (int)[image bitsPerPixel];
    GLenum format;
	
	[Console log:[NSString stringWithFormat:@"format = %ld", [image bitmapFormat]]];
	
    if (bitsPerPixel == 24) {
        format = GL_RGBA;
		[Console log:[NSString stringWithFormat:@"24 bits"]];
    } else {
		if (bitsPerPixel == 32) {
			format = GL_RGBA;
			[Console log:[NSString stringWithFormat:@"32 bits"]];
		} else {
			NSBeep();
			
			[Console log:[NSString stringWithFormat:@"unknown bits"]];
			
			NSAlert *alert = [[NSAlert alloc] init];
			[alert setMessageText:@"Bad pixel format. Cancel loading."];
			[alert runModal];
			
			[Console log:@"Bad pixel format. Cancel loading."];
			NSLog(@"Bad pixel format. Cancel loading.");
			
			return 0;
		}
	}
	
    int             width  = (int)[image pixelsWide];
    int             height = (int)[image pixelsHigh];
    unsigned char * imageData = [image bitmapData];
	
	[Console log:[NSString stringWithFormat:@"Loaded image [%d x %d]", width, height]];
	NSLog(@"Loaded image [%d x %d]", width, height);
	
	int size = width * height << 2;
    unsigned char *ptr = (unsigned char *)malloc(size);
	
    /*for (int row = height - 1; row >= 0; --row) {
        memcpy(ptr + (height - row - 1) * bytesPerRow, imageData + row * bytesPerRow, bytesPerRow);
	}*/
	
	int bytes = bitsPerPixel < 32 ? 3 : 4;
	double count = 0;
	
	for (int i = 0; i < width*height; ++i) {
		int destOffset = i << 2;
		int scrOffset = i*bytes;
		
		*(ptr + destOffset + 0) = *(imageData + scrOffset + 0);
		*(ptr + destOffset + 1) = *(imageData + scrOffset + 1);
		*(ptr + destOffset + 2) = *(imageData + scrOffset + 2);
		if (bytes > 3) {
			*(ptr + destOffset + 3) = *(imageData + scrOffset + 3);
		} else {
			*(ptr + destOffset + 3) = 255;
		}
		
		// TO AVARAGE COLOR
		
		double alpha = (double)*(ptr + destOffset + 3);
		
		red += (double)*(ptr + destOffset + 0) * alpha;
		green += (double)*(ptr + destOffset + 1) * alpha;
		blue += (double)*(ptr + destOffset + 2) * alpha;
		
		if (alpha > 5.0) {
			count += 1.0;
		}
	}
	
	// FIND AVARAGE COLOR
	
	count *= 255.0 * 255.0;
	
	if (count > 0.01) {
		red /= count;
		green /= count;
		blue /= count;
	}
	
	red = 1.f - red;
	green = 1.f - green;
	blue = 1.f - blue;
	
	//NSLog(@"r = %f, g = %f, b = %f", red, green, blue);
	
	
	// LOAD IMAGE TO OPENGL
	
    GLuint id;
	
    glGenTextures     (1, &id);
    glBindTexture     (GL_TEXTURE_2D, id);
    gluBuild2DMipmaps (GL_TEXTURE_2D, format, width, height, format, GL_UNSIGNED_BYTE, ptr);
    glTexParameteri   (GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri   (GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_LINEAR);
	
    free(ptr);
	
	textureWidth = width;
	textureHeight = height;
	
	float max = MAX(textureWidth, textureHeight);
	
	mainSpriteScaleX = width / max;
	mainSpriteScaleY = height / max;
	
    return id;
}

- (GLuint) loadTextureFromResource: (NSString *) name
{
    NSString * path = [[NSBundle mainBundle] pathForImageResource: name];
	
    if (path == nil) {
        return 0;
	}
	
    return [self loadTextureFromFile: path];
}

- (void) loadImageFromResource:(NSString *)fileName {
	texture = [self loadTextureFromFile:fileName];

	lastImageFileName = fileName;
}

- (void) reloadImage {
	if (lastImageFileName) {
		[self loadImageFromResource:lastImageFileName];
	}
}


// OPENGL RENDERING ========================================================================

- (void)prepareOpenGL {
	[super prepareOpenGL];
	
	[self reloadImage];
	
	if (texture == 0) {
		//texture = [self loadTextureFromResource:@"blank.png"];
		texture = [self loadTextureFromResource:@"icon.icns"];
	}
	
	glMatrixMode(GL_PROJECTION);
	glOrtho(-1, 1, -1, 1, 0, 100);
	
	glMatrixMode(GL_MODELVIEW);
	glLoadIdentity();
	
	glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
}

- (void)reshape {
	[super reshape];

	float min = MIN([self bounds].size.width, [self bounds].size.height);
	scaleCorrectionX = min / [self bounds].size.width;
	scaleCorrectionY = min / [self bounds].size.height;
	
	glViewport(0, 0, [self bounds].size.width, [self bounds].size.height);
}

- (void)drawRect:(NSRect)dirtyRect {
	
	// APPLY AVERAGE COLOR
	
	glClearColor(red, green, blue, 1.f);
    glClear(GL_COLOR_BUFFER_BIT);
	
	
	// TRANSFORM
	
	glLoadIdentity();
	glScalef(scale, scale, 1.f);
	glTranslatef(translate.x, translate.y, 0.f);
	glScalef(scaleCorrectionX * mainSpriteScaleX, scaleCorrectionY * mainSpriteScaleY, 1.f);
	
	
	// IMAGE
	
	glEnable(GL_BLEND);
	glEnable(GL_TEXTURE_2D);
    glBindTexture(GL_TEXTURE_2D, texture);
	
	glColor3f(1, 1, 1);
	
	glBegin(GL_QUADS);
	{
		glTexCoord2f(0, 0);
		glVertex2f(-1, 1);
		
		glTexCoord2f(1, 0);
		glVertex2f(1, 1);

		glTexCoord2f(1, 1);
		glVertex2f(1, -1);

		glTexCoord2f(0, 1);
		glVertex2f(-1, -1);
	}
	glEnd();
	
	glDisable(GL_TEXTURE_2D);
	glDisable(GL_BLEND);
	
	// IMAGE BORDER
	
	glColor3f(1, 0, 0);
	
	glLineWidth(3);
	glBegin(GL_LINES);
	{
		glVertex2f(-1, -1);
		glVertex2f( 1, -1);
		
		glVertex2f( 1, -1);
		glVertex2f( 1,  1);
		
		glVertex2f( 1,  1);
		glVertex2f(-1,  1);
		
		glVertex2f(-1,  1);
		glVertex2f(-1, -1);
		
	}
	glEnd();
	
	
	// FLUSH & SWAP
	
	glFlush();
	glSwapAPPLE();
}

- (void) updateFrame {
	[self setNeedsDisplay: YES];
}



// TRANSFORMATION ========================================================================

- (void) mouseDown: (NSEvent *) theEvent
{
    NSPoint pt = [theEvent locationInWindow];
	
    mouseOld = [self convertPoint: pt fromView: nil];
	
	[self setNeedsDisplay: YES];
}

- (void) mouseDragged: (NSEvent *) theEvent
{
    NSPoint pt = [theEvent locationInWindow];
	
    pt = [self convertPoint: pt fromView: nil];
	
	translate.x += (pt.x - mouseOld.x) / [self bounds].size.width / (scale * 0.5f);
	translate.y += (pt.y - mouseOld.y) / [self bounds].size.height / (scale * 0.5f);
	
    mouseOld = pt;
	
    [self setNeedsDisplay: YES];
}

- (void)mouseUp:(NSEvent *)theEvent {
	[self setNeedsDisplay: YES];
}

- (void)scrollWheel:(NSEvent *)theEvent {
	[self setScale:scale - theEvent.deltaY * 0.02f];
	[[MainWindow instance] setImageScale:scale];
}



// DRAG & DROP ========================================================================

- (BOOL)performDragOperation:(id <NSDraggingInfo>)sender {
    NSPasteboard *pboard = [sender draggingPasteboard];
	
    if ( [[pboard types] containsObject:NSURLPboardType] ) {
        NSURL *fileURL = [NSURL URLFromPasteboard:pboard];

		[self loadImageFromResource:[fileURL path]];
    }
    return YES;
}

- (BOOL)prepareForDragOperation:(id <NSDraggingInfo>)sender {
    return YES;
}

- (NSDragOperation)draggingEntered:(id <NSDraggingInfo>)sender {
    if ((NSDragOperationGeneric & [sender draggingSourceOperationMask]) == NSDragOperationGeneric) {
        return NSDragOperationGeneric;
    } else {
        return NSDragOperationNone;
    }
}

- (void)draggingExited:(id <NSDraggingInfo>)sender {
	//
}

- (NSDragOperation)draggingUpdated:(id <NSDraggingInfo>)sender {
    if ((NSDragOperationGeneric & [sender draggingSourceOperationMask])	== NSDragOperationGeneric) {
        return NSDragOperationGeneric;
    } else {
        return NSDragOperationNone;
    }
}

- (void)draggingEnded:(id <NSDraggingInfo>)sender {
	//
}

- (void)concludeDragOperation:(id <NSDraggingInfo>)sender {
    [self setNeedsDisplay:YES];
}

// WINDOW INIT ========================================================================

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
	
	[self registerForDraggedTypes:[NSArray arrayWithObjects:NSURLPboardType, NSFilenamesPboardType, nil]];
	
    return self;
}

- (void)dealloc {
    [self unregisterDraggedTypes];
}

@end
