//
//  MainWindows.m
//  spriteEditor
//
//  Created by afiki on 07.07.13.
//  Copyright (c) 2013 afiki. All rights reserved.
//

#import "MainWindow.h"

@implementation MainWindow

@synthesize imageViewer, scaleSlider, fileNameLabel, console;

static MainWindow *instanceMainWindow;
+ (MainWindow *)instance {
	return instanceMainWindow;
}

- (void) awakeFromNib {
	instanceMainWindow = self;
	
	[self setReleasedWhenClosed:NO];
	[self setHidesOnDeactivate:NO];
	[NSApp activateIgnoringOtherApps:YES];
}

- (void)setImageScale:(float)value {
	[imageViewer setScale:value];
	[scaleSlider setFloatValue:([scaleSlider maxValue] - [scaleSlider minValue]) * (value / ([scaleSlider maxValue] / 100.f))];
	[scaleSlider setNeedsDisplay];
}

- (IBAction)onUpdateImageButtonClick:(id)sender {
	[imageViewer reloadImage];
}

- (IBAction)onResetImageButtonClick:(id)sender {
	[imageViewer resetTransform];
}

- (IBAction)onOpenImageButtonClick:(id)sender {
	NSOpenPanel* openDlg = [NSOpenPanel openPanel];
	
	[openDlg setCanChooseFiles:YES];
	[openDlg setCanChooseDirectories:YES];
	
	if ([openDlg runModal] == NSOKButton) {
		NSArray* files = [openDlg URLs];
		
		if (files.count > 0) {
			NSString *fileName = [[files objectAtIndex:0] path];
			
			[imageViewer loadImageFromResource:fileName];
			[fileNameLabel setStringValue:fileName];
		}
		
		[imageViewer resetTransform];
		[imageViewer updateFrame];
	}
}

- (IBAction)onConsoleButtonClick:(id)sender {
	if ([console isVisible]) {
		[console close];
	} else {
		[console makeKeyAndOrderFront:console];
	}
}

BOOL consoleOpened = NO;

- (void)reopenWindow {
	if (consoleOpened) {
		[console makeKeyAndOrderFront:console];
	}
	
	[self makeKeyAndOrderFront:self];
}

- (BOOL)windowShouldClose:(id)sender {
	consoleOpened = [console isVisible];
	[console close];
	return YES;
}

// TABLE VIEW DELEGATE

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
	return 3;
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
	GroupCell *cell = [tableView makeViewWithIdentifier:[GROUP_CELL_ID copy] owner:self];
	
	return cell;
}

@end
