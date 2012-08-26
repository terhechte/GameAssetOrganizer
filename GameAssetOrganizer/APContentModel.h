//
//  APContentModel.h
//  GameAssetOrganizer
//
//  Created by BTerhechte on 25.08.12.
//  Copyright (c) 2012 BTerhechte. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface APContentObject : NSObject
@property (nonatomic, assign) NSInteger pack, assetPack;
@property (nonatomic, strong) NSString *filename;
@property (nonatomic, strong) NSURL *folder;
@end

@interface APContentModel : NSObject {
    NSDictionary *_structure; // the internal structure
}
// really simple container for our config
@property (nonatomic, strong) NSMutableDictionary *gameAssetConfig;
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
