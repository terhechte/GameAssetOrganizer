//
//  APContentModel.h
//  GameAssetOrganizer
//
//  Created by BTerhechte on 25.08.12.
//  Copyright (c) 2012 BTerhechte. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface APStoreLocation : NSObject {
	NSString *_location;
}
+ (APStoreLocation*) sharedLocation;
+ (NSString*) location;
- (NSString*) location;
- (void) setLocation:(NSString*)location;
@end

@interface APContentObject : NSObject
@property (nonatomic, assign) NSInteger pack, assetPack;
@property (nonatomic, strong) NSString *filename;
@property (nonatomic, strong) NSURL *folder;
+ (APContentObject*) objectWithPack:(NSInteger)pack assetPack:(NSInteger)assetPack filename:(NSString*)filename folder:(NSURL*)folder;
- (NSDictionary*) dictionary;
- (NSString*) relativeFolder;
@end

@interface APContentModel : NSObject {
    NSDictionary *_structure; // the internal structure
}
// really simple container for our config
@property (nonatomic, strong) NSMutableDictionary *gameAssetConfig;

// setting the current selected pack / asset
@property (nonatomic, assign) NSInteger currentPack;
@property (nonatomic, assign) NSInteger currentAssetPack;

- (void) loadImportedData:(NSData*) importedData;
- (NSData*) exportData;
- (NSDictionary*) exportDictionary;
    
+ (APContentModel*) sharedModel;
- (NSInteger) numberOfPacks;
- (NSInteger) numberOfAssetPacksInPack:(NSInteger)pack;
- (NSString*) titleOfPack:(NSInteger)pack;
- (NSString*) titleOfAssetPack:(NSInteger)assetPack inPack:(NSInteger)pack;
- (NSArray*) assetsForPack:(NSInteger)pack assetPack:(NSInteger)assetPack;
- (void) setAssets:(NSArray*)assets forPack:(NSInteger)pack  assetPack:(NSInteger)assetPack;
- (void) addObject:(APContentObject*)object toPack:(NSInteger)pack assetPack:(NSInteger)assetPack;
- (void) removeObject:(APContentObject*)object fromPack:(NSInteger)pack assetPack:(NSInteger)assetPack;
@end
