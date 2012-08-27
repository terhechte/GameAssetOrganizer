//
//  APFolderImagesController.h
//  GameAssetOrganizer
//
//  Created by BTerhechte on 25.08.12.
//  Copyright (c) 2012 BTerhechte. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Quartz/Quartz.h>

@interface APFolderImagesController : NSObject
@property (weak) IBOutlet IKImageBrowserView *folderImageView;
@property (weak) IBOutlet NSPopUpButton *currentFolderSelector;
@property (nonatomic, strong) NSArray *folders;
@property (nonatomic, assign) NSInteger currentFolder;
@property (nonatomic, strong) NSArray* currentFolderContent;
@property (nonatomic, strong) NSPredicate *searchPredicate;

@end
