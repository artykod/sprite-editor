//
//  Console.h
//  spriteEditor
//
//  Created by afiki on 08.07.13.
//  Copyright (c) 2013 afiki. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface Console : NSPanel

@property (nonatomic, retain) IBOutlet NSTextView *consoleText;

+ (void)log:(NSString *)message;

@end
