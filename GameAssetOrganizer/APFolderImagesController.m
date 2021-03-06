//
//  APFolderImagesController.m
//  GameAssetOrganizer
//
//  Created by BTerhechte on 25.08.12.
//  Copyright (c) 2012 BTerhechte. All rights reserved.
//

#import "APFolderImagesController.h"

// adhere to IKImageBrowserItem
@interface APFolderImageObject : NSObject
@property (nonatomic, strong) NSString *path;
@end

@implementation APFolderImageObject
@synthesize path;
- (NSString *) imageRepresentationType {
    return IKImageBrowserPathRepresentationType;
}
- (id) imageRepresentation {
    return self.path;
}
- (NSString *) imageTitle {
    return [[path pathComponents] lastObject];
}
- (NSString *) imageUID {
    return path;
}
@end


@interface APFolderImagesController(Private)
- (void) AP_updateFolderListing;
@end

@implementation APFolderImagesController
@synthesize folderImageView;
@synthesize currentFolderSelector;
@synthesize folders;
@synthesize currentFolder = _currentFolder;
@synthesize currentFolderContent;
@synthesize searchPredicate = _searchPredicate;

- (void) awakeFromNib {
    self.folders = @[     @"big",
    @"frigginHuge",
    @"medium",
    @"special",
    @"small"
    ];
    
    self.currentFolder = [[NSUserDefaults standardUserDefaults] integerForKey:@"CurrentFolder"];
    
    [self AP_updateFolderListing];
}

- (void) setSearchPredicate:(NSPredicate *)searchPredicate {
    [self willChangeValueForKey:@"searchPredicate"];
    self->_searchPredicate = searchPredicate;
    [self AP_updateFolderListing];
    [self didChangeValueForKey:@"searchPredicate"];
}

- (void) setCurrentFolder:(NSInteger)currentFolder {
    [self willChangeValueForKey:@"currentFolder"];
    _currentFolder = currentFolder;
    [[NSUserDefaults standardUserDefaults] setInteger:currentFolder forKey:@"CurrentFolder"];
    [self didChangeValueForKey:@"currentFolder"];
    
    // update the listing
    [self AP_updateFolderListing];
}

#pragma mark IKImageViewDelegate

- (NSUInteger) numberOfItemsInImageBrowser:(IKImageBrowserView *) aBrowser {
    return [self.currentFolderContent count];
}

- (id) imageBrowser:(IKImageBrowserView *) aBrowser itemAtIndex:(NSUInteger)index {
    return [self.currentFolderContent objectAtIndex:index];
}


@end

@implementation APFolderImagesController(Private)
- (void) AP_updateFolderListing {
    // get the selected folder
    NSString *folder = self.folders[self.currentFolder];
    
    // and find all images in the path for this
    NSString *currentPath = [APStoreLocation location];
    
    if (!currentPath) {
        // error message
        NSRunAlertPanel(@"Please set the root folder in the preferences",
                        @"Please set the root folder in the preferences", @"ok", nil, nil);
        return;
    }
    
    // and build the path
    NSString *path = [currentPath stringByAppendingPathComponent:folder];
    
    NSFileManager *currentFileManger = [NSFileManager defaultManager];
    NSArray *files = [currentFileManger contentsOfDirectoryAtPath:path
                                                            error:nil];
    
    NSMutableArray *mutableImages = [NSMutableArray arrayWithCapacity:[files count]];
    // remove all retina entries, we don't need those.
    [files enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSString *objString = obj;
        if ([objString rangeOfString:@"-retina2x"].length==0) {
            APFolderImageObject *aFolderObject = [[APFolderImageObject alloc] init];
            aFolderObject.path = [path stringByAppendingPathComponent:objString];
            [mutableImages addObject: aFolderObject];
        }
    }];
    
    // if we have a search predicate, apply it
    if (self.searchPredicate) {
        [mutableImages filterUsingPredicate:self.searchPredicate];
    }
    
    // and assign it
    self.currentFolderContent = mutableImages;
    
    [self.folderImageView reloadData];
}
@end