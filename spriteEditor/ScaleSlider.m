//
//  ScaleSlider.m
//  spriteEditor
//
//  Created by afiki on 08.07.13.
//  Copyright (c) 2013 afiki. All rights reserved.
//

#import "ScaleSlider.h"
#import "MainWindow.h"

@implementation ScaleSlider

- (IBAction)onChange:(id)sender {
	[[MainWindow instance] setImageScale:self.floatValue / 100.f];
}

@end
