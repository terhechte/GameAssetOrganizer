//
//  APPackListController.m
//  GameAssetOrganizer
//
//  Created by BTerhechte on 25.08.12.
//  Copyright (c) 2012 BTerhechte. All rights reserved.
//

#import "APPackListController.h"

@interface APPackListObject : NSObject
@property (nonatomic, strong) NSString *title;
@property (nonatomic, assign) NSInteger index;
@property (nonatomic, assign) bool leaf;
+ (APPackListObject*) packListObjectWithTitle:(NSString*)title index:(NSInteger)index leaf:(bool)leaf;
@end

@implementation APPackListObject

@synthesize title = _title, index = _index, leaf = _leaf;

+ (APPackListObject*) packListObjectWithTitle:(NSString*)title index:(NSInteger)index leaf:(bool)leaf {
    APPackListObject *object = [[APPackListObject alloc] init];
    object.index = index;
    object.title = title;
    object.leaf = leaf;
    return object;
}

@end

@implementation APPackListController
@synthesize selectedIndex = _selectedIndex;
@synthesize outlineView;
@synthesize collectionView;

- (void) awakeFromNib {
    model = [APContentModel sharedModel];
    objects = [NSMutableArray arrayWithCapacity:10];
}

- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item {
    // we have an item, return the children
    APPackListObject *itemObj = item;
    if ([itemObj leaf]) {
        return 0;
    }
    
    // this is the root node
    if (!item) {
        // and remove hte old objects
        [objects removeAllObjects];
        return [model numberOfPacks];
    }
    
    // this is a asset node
    return [model numberOfAssetPacksInPack:itemObj.index];
}

- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item {
    if (!item) {
        // root node
        APPackListObject *po = [APPackListObject packListObjectWithTitle:[model titleOfPack:index]
                                                   index:index leaf:NO];
        // we save the objects so they don't get released
        [objects addObject:po];
        return po;
    }
    // normal node
    APPackListObject *packObject = item;
    APPackListObject *po = [APPackListObject packListObjectWithTitle:[model titleOfAssetPack:index inPack:packObject.index]
                                               index:index leaf:YES];
    // we save the objects so they don't get released
    [objects addObject:po];
    return po;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item {
    // root;
    if (!item)return YES;
    APPackListObject *itemObj = item;
    if (itemObj.leaf)return NO;
    return YES;
}

- (id)outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item {
    if (!item || ![item isKindOfClass:[APPackListObject class]]) return @"Root";
    return [(APPackListObject*)item title];
}

@end
