//
//  APCollectionViewItemSelectable.m
//  GameAssetOrganizer
//
//  Created by BTerhechte on 27.08.12.
//  Copyright (c) 2012 BTerhechte. All rights reserved.
//

#import "APCollectionViewItemSelectable.h"
#import "APCollectionViewItemSelectableView.h"

@interface APCollectionViewItemSelectable ()

@end

@implementation APCollectionViewItemSelectable

-(void)setSelected:(BOOL)flag {
	[super setSelected: flag];
	if ([self.view respondsToSelector:@selector(setSelected:)]) {
		[(APCollectionViewItemSelectableView*)[self view] setSelected: flag]; //FixMe: Use NSInvocation
		[(APCollectionViewItemSelectableView*)[self view] setNeedsDisplay:YES];
	}
}

- (void) setMultiSelected:(BOOL)flag { if ([self.view respondsToSelector:@selector(setSelected:)]) {
        [(APCollectionViewItemSelectableView*)[self view] setSelected: flag]; //FixMe: Use NSInvocation
        [(APCollectionViewItemSelectableView*)[self view] setNeedsDisplay:YES];
    }
}

@end
