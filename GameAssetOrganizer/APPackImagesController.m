//
//  APPackImagesController.m
//  GameAssetOrganizer
//
//  Created by BTerhechte on 25.08.12.
//  Copyright (c) 2012 BTerhechte. All rights reserved.
//

#import "APPackImagesController.h"

#define CURRENT_PACK "currentPack"
#define CURRENT_ASSET_PACK "currentAssetPack"
#define GAME_DATA "gameData"

@interface APPackImagesController(Private)
- (void) AP_reloadData;
@end

@implementation APPackImagesController
@synthesize collectionView;
@synthesize currentPackContent;
@synthesize currentPackIndexes;
@synthesize currentFilesMaxRect;
@synthesize model;

- (void) awakeFromNib {
    self.model = [APContentModel sharedModel];
    [self.collectionView registerForDraggedTypes: [NSArray arrayWithObject:NSFilenamesPboardType]];
    
    // reload when pack or assetpack change
    [model addObserver:self
            forKeyPath:@"currentPack"
               options:0
               context:&CURRENT_PACK];
    [model addObserver:self
            forKeyPath:@"currentAssetPack"
               options:0
               context:&CURRENT_ASSET_PACK];
    
    // reload when the gamedata changes
    [model addObserver:self
            forKeyPath:@"gameDataConfig"
               options:0
               context:&GAME_DATA];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == &CURRENT_ASSET_PACK) {
        [self AP_reloadData];
    }
    else if (context == &CURRENT_PACK) {
        [self AP_reloadData];
    } else if (context == &GAME_DATA) {
        [self AP_reloadData];
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

#pragma mark UI Actions
- (IBAction)removeAllItems:(id)sender {
    if (self.model.currentPack==-1 || self.model.currentAssetPack==-1) {
        NSBeep();
        return;
    }
    
    for (APContentObject *object in self.currentPackContent) {
        [model removeObject:object fromPack:model.currentPack assetPack:model.currentAssetPack];
    }
    self.currentPackContent = [NSArray array];
}

#pragma mark CollectionViewDelegate
- (BOOL)collectionView:(NSCollectionView *)collectionView
            acceptDrop:(id < NSDraggingInfo >)draggingInfo
                 index:(NSInteger)index
         dropOperation:(NSCollectionViewDropOperation)dropOperation {
    
    NSPasteboard* pboard = [draggingInfo draggingPasteboard];
    NSArray *files = [pboard propertyListForType:NSFilenamesPboardType];
    
    // if we're in no gamepack, we can't add it
    if (model.currentAssetPack==-1) {
        NSBeep();
        return NO;
    }
    
    for(NSString *file in files) {
        APContentObject *obj =
        [APContentObject objectWithPack:model.currentPack
                              assetPack:model.currentAssetPack
                               filename:[file lastPathComponent]
                                 folder:[NSURL URLWithString:file]];
        [model addObject:obj toPack:model.currentPack assetPack:model.currentAssetPack];
    }
    
    // reload
    [self AP_reloadData];
    
    return YES;
}

- (NSDragOperation)collectionView:(NSCollectionView *)collectionView validateDrop:(id < NSDraggingInfo >)draggingInfo proposedIndex:(NSInteger *)proposedDropIndex dropOperation:(NSCollectionViewDropOperation *)proposedDropOperation {
    return NSDragOperationCopy;
}

@end

@implementation APPackImagesController(Private)
- (void) AP_reloadData {
    // if neither pack nor gamepack are selected, there's nothig to do
    if (model.currentPack == -1)return;
    // if we have only a pack selected, get all data from
    // the asset packs below
    NSMutableArray *objects = [NSMutableArray arrayWithCapacity:100];
    if (model.currentAssetPack==-1) {
        for(NSInteger i=0; i<[model numberOfAssetPacksInPack:model.currentPack]; i++) {
            [objects addObjectsFromArray:[model assetsForPack:model.currentPack
                                                    assetPack:i]];
        }
    } else {
        [objects addObjectsFromArray:[model assetsForPack:model.currentPack
                                                assetPack:model.currentAssetPack]];
    }
    
    self.currentPackContent = objects;
}
@end
