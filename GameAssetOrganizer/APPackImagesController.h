//
//  APPackImagesController.h
//  GameAssetOrganizer
//
//  Created by BTerhechte on 25.08.12.
//  Copyright (c) 2012 BTerhechte. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "APContentModel.h"

@interface APPackImagesController : NSObject
@property (strong) APContentModel* model;
@property (weak) IBOutlet NSCollectionView *collectionView;
@property (strong) NSIndexSet *currentPackIndexes;
@property (strong) NSArray *currentPackContent;
@property (strong) NSString *currentFilesMaxRect;

- (IBAction)removeAllItems:(id)sender;
- (IBAction)removeSelectedItems:(id)sender;

@end
