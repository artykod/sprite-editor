//
//  Console.m
//  spriteEditor
//
//  Created by afiki on 08.07.13.
//  Copyright (c) 2013 afiki. All rights reserved.
//

#import "Console.h"

@implementation Console

@synthesize consoleText;

static Console *instanceConsole;
+ (Console *)instance {
	return  instanceConsole;
}

+ (void)log:(NSString *)message {
	if (instanceConsole) {
		NSString *messageWithNewLine = [message stringByAppendingString:@"\n"];
		
		BOOL scroll = (NSMaxY(instanceConsole.consoleText.visibleRect) == NSMaxY(instanceConsole.consoleText.bounds));
		
		[instanceConsole.consoleText.textStorage appendAttributedString:[[NSAttributedString alloc]initWithString:messageWithNewLine]];
		[instanceConsole.consoleText.textStorage setForegroundColor:[NSColor grayColor]];
		
		if (scroll) {
			[instanceConsole.consoleText scrollRangeToVisible: NSMakeRange(instanceConsole.consoleText.string.length, 0)];
		}
	}
}

+ (void)logWarning:(NSString *)message {
	if (instanceConsole) {
		NSString *messageWithNewLine = [message stringByAppendingString:@"\n"];
		
		BOOL scroll = (NSMaxY(instanceConsole.consoleText.visibleRect) == NSMaxY(instanceConsole.consoleText.bounds));
		
		[instanceConsole.consoleText.textStorage appendAttributedString:[[NSAttributedString alloc]initWithString:messageWithNewLine]];
		[instanceConsole.consoleText.textStorage setForegroundColor:[NSColor grayColor]];
		
		if (scroll) {
			[instanceConsole.consoleText scrollRangeToVisible: NSMakeRange(instanceConsole.consoleText.string.length, 0)];
		}
	}
}

+ (void)logError:(NSString *)message {
	if (instanceConsole) {
		NSString *messageWithNewLine = [message stringByAppendingString:@"\n"];
		
		BOOL scroll = (NSMaxY(instanceConsole.consoleText.visibleRect) == NSMaxY(instanceConsole.consoleText.bounds));
	
		[instanceConsole.consoleText.textStorage appendAttributedString:[[NSAttributedString alloc]initWithString:messageWithNewLine]];
		[instanceConsole.consoleText.textStorage setForegroundColor:[NSColor grayColor]];
		
		if (scroll) {
			[instanceConsole.consoleText scrollRangeToVisible: NSMakeRange(instanceConsole.consoleText.string.length, 0)];
		}
	}
}

- (void) awakeFromNib {
	instanceConsole = self;
	
	[self setReleasedWhenClosed:FALSE];
	[self setFloatingPanel:YES];
	
	[self close];
	
	[Console log:@"Sprite editor started."];
}

@end
