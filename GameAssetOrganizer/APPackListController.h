//
//  APPackListController.h
//  GameAssetOrganizer
//
//  Created by BTerhechte on 25.08.12.
//  Copyright (c) 2012 BTerhechte. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface APPackListController : NSObject <NSOutlineViewDataSource, NSOutlineViewDelegate> {
    APContentModel *model;
}

@property (assign) NSInteger selectedIndex;

@property (weak) IBOutlet NSOutlineView *outlineView;
@property (weak) IBOutlet NSCollectionView *collectionView;

@end
