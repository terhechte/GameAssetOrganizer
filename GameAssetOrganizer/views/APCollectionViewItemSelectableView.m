//
//  APCollectionViewItemSelectableView.m
//  GameAssetOrganizer
//
//  Created by BTerhechte on 27.08.12.
//  Copyright (c) 2012 BTerhechte. All rights reserved.
//

#import "APCollectionViewItemSelectableView.h"

@implementation APCollectionViewItemSelectableView
@synthesize selected;

- (void)drawRect:(NSRect)dirtyRect {
    // if we're selected, draw a selection
    if (self.selected) {
        NSBezierPath *selectionBezierPath = [NSBezierPath bezierPathWithRoundedRect:self.bounds
                                                                            xRadius:8 yRadius:8];
        
        NSGradient *selectionGradient = [[NSGradient alloc] initWithStartingColor:[NSColor selectedMenuItemColor]
                                                                      endingColor:[NSColor alternateSelectedControlColor]];
        
        [selectionGradient drawInBezierPath:selectionBezierPath angle:90.0];
    }
}

@end
