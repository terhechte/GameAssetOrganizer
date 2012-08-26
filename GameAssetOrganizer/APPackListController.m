//
//  APPackListController.m
//  GameAssetOrganizer
//
//  Created by BTerhechte on 25.08.12.
//  Copyright (c) 2012 BTerhechte. All rights reserved.
//

#import "APPackListController.h"

@implementation APPackListController
@synthesize selectedIndex = _selectedIndex;
@synthesize outlineView;
@synthesize collectionView;

- (void) awakeFromNib {
    model = [APContentModel sharedModel];
}

- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item {
    return 2;
    NSLog(@"%s", _cmd);
    NSInteger nr = 0;
    if (!item)nr =  [model numberOfPacks];

    if([[(NSDictionary*)item objectForKey:@"leaf"] boolValue])nr = 0;
    
    if (item) {
        nr = [model numberOfAssetPacksInPack:[(APContentObject*)item pack]];
    }
    
    NSLog(@"return nummer for %@ is %li", item, nr);
    return nr;
}

- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item {
    NSLog(@"%s", _cmd);
    if (!item) {
        return @{ @"title" : [model titleOfPack:index],
                  @"index": [NSNumber numberWithLong:index],
                  @"leaf": @NO};
    }
    
    return @{ @"title" : [model titleOfAssetPack:index inPack:[[(NSDictionary*)
                                                                item objectForKey:@"index"] intValue]],
              @"index": [NSNumber numberWithLong: index],
              @"leaf": @YES};
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item {
    NSLog(@"%s", _cmd);
    if ([[(NSDictionary*)item objectForKey:@"leaf"] boolValue])return NO;
    return YES;
}

- (id)outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item {
    NSLog(@"%s (item: %@)", _cmd, item);
    if (!item) return @"Root";
    return @"lala";
    if (![item isKindOfClass:[NSDictionary class]]) return nil;
    NSLog(@"data for: %@", item);
    return [(NSDictionary*)item objectForKey:@"title"];
}

@end
