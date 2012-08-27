//
//  APContentModel.m
//  GameAssetOrganizer
//
//  Created by BTerhechte on 25.08.12.
//  Copyright (c) 2012 BTerhechte. All rights reserved.
//

#import "APContentModel.h"

@implementation APContentObject
@synthesize pack, assetPack, filename, folder;
+ (APContentObject*) objectWithPack:(NSInteger)pack assetPack:(NSInteger)assetPack filename:(NSString*)filename folder:(NSURL*)folder {
    APContentObject *op = [[APContentObject alloc] init];
    op.pack = pack;
    op.assetPack = assetPack;
    op.filename = filename;
    op.folder = folder;
    return op;
}
- (id) initWithCoder: (NSCoder *)coder {
    if (self = [super init]) {
        self.pack = [coder decodeIntegerForKey:@"pack"];
        self.assetPack = [coder decodeIntegerForKey:@"assetPack"];
        self.filename = [coder decodeObjectForKey:@"filename"];
        self.folder = [coder decodeObjectForKey:@"folder"];
    }
    return self;
}
- (void) openItem {
    NSWorkspace *ws = [NSWorkspace sharedWorkspace];
    [ws selectFile: [self.folder path] inFileViewerRootedAtPath:nil];
}
- (NSString*) path {
    return [self.folder path];
}
- (void) encodeWithCoder: (NSCoder *)coder {
    [coder encodeInteger:self.pack forKey:@"pack"];
    [coder encodeInteger:self.assetPack forKey:@"assetPack"];
    [coder encodeObject:self.filename forKey:@"filename"];
    [coder encodeObject:self.folder forKey:@"folder"];
}

@end

@implementation APContentModel
@synthesize gameAssetConfig, currentAssetPack, currentPack;

+ (APContentModel*) sharedModel {
    static APContentModel* staticSharedModel;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        staticSharedModel = [[APContentModel alloc] init];
        
        // after starupt, nothing is selectrd
        staticSharedModel.currentAssetPack = -1;
        staticSharedModel.currentPack = -1;
    });
    return staticSharedModel;
}

- (id) init {
    self = [super init];
    if (self) {
        self.gameAssetConfig = [NSMutableDictionary dictionaryWithCapacity:100];
        
        // this structure defines how many packs we have, how many sub packs they have
        _structure = @{
            @"Pack1" : @[ @"AssetPack1", @"AssetPack2" ],
            @"Pack2" : @[ @"AssetPack1", @"AssetPack2" ],
            @"Pack3" : @[ @"AssetPack1", @"AssetPack2" ],
            @"Pack4" : @[ @"AssetPack1", @"AssetPack2" ]
        };
        
        // and now we create the pack structure from this structure
        for(NSString *key in _structure) {
            NSMutableDictionary *pack = [NSMutableDictionary dictionaryWithCapacity:10];
            
            for (NSString *assetPack in [_structure objectForKey:key]) {
                // create a mutable array for every entry
                [pack setObject:[NSMutableArray array]
                         forKey:assetPack];
            }
            [self.gameAssetConfig setObject:pack
                                     forKey:key];
        }
    }
    return self;
}

- (NSData*) exportData {
    NSDictionary *exportedDataDictionary = @{ @"header" : _structure,
    @"data": self.gameAssetConfig};
    
    return [NSKeyedArchiver archivedDataWithRootObject:exportedDataDictionary];
}

- (void) loadImportedData:(NSData*) importedData {
    NSDictionary *importedDictionary =
    [NSKeyedUnarchiver unarchiveObjectWithData:importedData];
    _structure = [importedDictionary objectForKey:@"header"];
    self.gameAssetConfig = [importedDictionary objectForKey:@"data"];
    
    self.currentAssetPack = -1;
    self.currentPack = -1;
}

- (NSString*) titleOfPack:(NSInteger)pack {
    return [[_structure allKeys] objectAtIndex:pack];
}
- (NSString*) titleOfAssetPack:(NSInteger)assetPack inPack:(NSInteger)pack {
    return [[_structure objectForKey:[[_structure allKeys] objectAtIndex:pack]] objectAtIndex: assetPack];
}

- (NSInteger) numberOfPacks {
    return [_structure count];
}

- (NSInteger) numberOfAssetPacksInPack:(NSInteger)pack {
    return [[_structure objectForKey:[[_structure allKeys] objectAtIndex:pack]] count];
}

- (NSArray*) assetsForPack:(NSInteger)pack assetPack:(NSInteger)assetPack {
    NSDictionary *packDict = [self.gameAssetConfig objectForKey:[[self.gameAssetConfig allKeys] objectAtIndex:pack]];
    return [[packDict objectForKey:[[packDict allKeys] objectAtIndex:assetPack]] copy]; // copy to make it immutable
}

- (void) setAssets:(NSArray*)assets forPack:(NSInteger)pack  assetPack:(NSInteger)assetPack {
    NSMutableArray *mutableCopy = [assets mutableCopy];
    
    // make sure we have only ap objects
    __block bool unsafe = NO;
    [mutableCopy enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if (![obj isKindOfClass:[APContentObject class]]) {
            unsafe = YES;
            *stop = YES;
        }
    }];
    
    if (unsafe) {
        NSLog(@"%s %s: Asset Array contained non APContentObjects", __FILE__, (char*)_cmd);
        return;
    }
    
    NSMutableDictionary *packDict = [self.gameAssetConfig objectForKey:
                                     [[self.gameAssetConfig allKeys] objectAtIndex:pack]];
    [packDict setObject:assets
                 forKey:[[packDict allKeys] objectAtIndex:assetPack]];
    
    // and save it again
    [self.gameAssetConfig setObject:packDict
                             forKey:[[self.gameAssetConfig allKeys] objectAtIndex:pack]];
}

- (void) addObject:(APContentObject*)object toPack:(NSInteger)pack assetPack:(NSInteger)assetPack {
    NSMutableDictionary *packDict = [self.gameAssetConfig objectForKey:
                                     [[self.gameAssetConfig allKeys] objectAtIndex:pack]];
    
    NSMutableArray *packAssetArray = [packDict objectForKey:[[packDict allKeys] objectAtIndex:assetPack]];
    
    // make sure to not add touble
    __block bool contains = NO;
    [packAssetArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        APContentObject *contentObject = obj;
        if ([[contentObject.folder path] isEqualToString:[object.folder path]]) {
            contains = YES;
            *stop = YES;
        }
    }];
    
    // object is alrady in there
    if (contains) {
        return;
    }
    
    [packAssetArray addObject:object];
    
    [self.gameAssetConfig setObject:packDict
                             forKey:[[self.gameAssetConfig allKeys] objectAtIndex:pack]];
}

- (void) removeObject:(APContentObject*)object fromPack:(NSInteger)pack assetPack:(NSInteger)assetPack {
    NSMutableDictionary *packDict = [self.gameAssetConfig objectForKey:
                                     [[self.gameAssetConfig allKeys] objectAtIndex:pack]];
    
    __block NSMutableArray *packAssetArray = [packDict objectForKey:[[packDict allKeys] objectAtIndex:assetPack]];
    
    // we can't just remove, since the object id may be different
    [[packAssetArray copy] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        APContentObject *contentObject = obj;
        if ([[contentObject.folder path] isEqualToString:[object.folder path]]) {
            [packAssetArray removeObject:obj];
            *stop = YES;
        }
    }];
    
    // and save it back
    [self.gameAssetConfig setObject:packDict
                             forKey:[[self.gameAssetConfig allKeys] objectAtIndex:pack]];
}

@end
