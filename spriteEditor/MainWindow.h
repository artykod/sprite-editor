//
//  MainWindow.h
//  spriteEditor
//
//  Created by afiki on 07.07.13.
//  Copyright (c) 2013 afiki. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ImageViewer.h"
#import "ScaleSlider.h"
#import "Console.h"
#import "GroupCell.h"

@interface MainWindow : NSWindow <NSTableViewDelegate, NSTableViewDataSource>

@property (nonatomic, retain) IBOutlet ImageViewer *imageViewer;
@property (nonatomic, retain) IBOutlet ScaleSlider *scaleSlider;
@property (nonatomic, retain) IBOutlet NSTextFieldCell *fileNameLabel;
@property (nonatomic, retain) IBOutlet NSWindow *console;

+ (MainWindow *)instance;

- (void)reopenWindow;

- (void)setImageScale:(float)value;

- (IBAction)onUpdateImageButtonClick:(id)sender;
- (IBAction)onOpenImageButtonClick:(id)sender;
- (IBAction)onResetImageButtonClick:(id)sender;
- (IBAction)onConsoleButtonClick:(id)sender;

@end
