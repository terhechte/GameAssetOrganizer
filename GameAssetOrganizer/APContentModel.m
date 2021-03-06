//
//  APContentModel.m
//  GameAssetOrganizer
//
//  Created by BTerhechte on 25.08.12.
//  Copyright (c) 2012 BTerhechte. All rights reserved.
//

#import "APContentModel.h"

@implementation APStoreLocation
+ (APStoreLocation*) sharedLocation {
	static APStoreLocation* location;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		location = [[APStoreLocation alloc] init];
	});
	return location;
}
// shorthand
+ (NSString*) location {
	APStoreLocation *location = [APStoreLocation sharedLocation];
	return [location location];
}
- (NSString*) location {
	// if it is not set, use the default
	if (!self->_location) {
		return [[NSUserDefaults standardUserDefaults] objectForKey:@"CurrentPreferencesPath"];
	}
	return self->_location;
}
- (void) setLocation:(NSString *)location {
	self->_location = location;
}
@end

@interface NSDictionary(Sort)
- (NSArray*) allSortedKeys;
@end
@implementation NSDictionary(Sort)
- (NSArray*) allSortedKeys {
    NSArray *keys = [self allKeys];
    return [keys sortedArrayUsingSelector:@selector(compare:)];
}
@end

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
		self.folder = [NSURL URLWithString:[coder decodeObjectForKey:@"folder"]];
    }
    return self;
}
- (void) openItem {
#ifndef CONSOLE
    NSWorkspace *ws = [NSWorkspace sharedWorkspace];
    [ws selectFile: [self.folder path] inFileViewerRootedAtPath:nil];
#endif
}
- (NSString*) path {
    return [self.folder path];
}
- (NSString*) folder {
	//add relative information
	// add our home directory, and create an nsurl again
	NSString *savedCompleteFolder = [[APStoreLocation location]
									 stringByAppendingString:[self->folder path]];
	
	return [NSURL URLWithString:savedCompleteFolder];
}
- (void) setFolder:(NSURL *)f {
	// remove the current preferences, and save then
	NSString *path = [f absoluteString];
	
	NSString *currentPath = [APStoreLocation location];
	
	[self willChangeValueForKey:@"folder"];
	self->folder = [NSURL URLWithString:[path stringByReplacingOccurrencesOfString:currentPath withString:@""]];
	[self didChangeValueForKey:@"folder"];
							 
}
- (void) encodeWithCoder: (NSCoder *)coder {
    [coder encodeInteger:self.pack forKey:@"pack"];
    [coder encodeInteger:self.assetPack forKey:@"assetPack"];
    [coder encodeObject:self.filename forKey:@"filename"];
	// for the folder, we have to make sure that we strip
	// the current user home direcctory away
	// otherwise, loading this file on a different system, will make it not load properly
    [coder encodeObject:[self relativeFolder] forKey:@"folder"];
}

- (NSString*) relativeFolder {
	NSString *homeDirectory = [APStoreLocation location];
	NSString *folderString = [self.folder absoluteString];
	NSString *strippedFolder = [folderString stringByReplacingOccurrencesOfString:homeDirectory withString:@""];
	return strippedFolder;
}

- (NSDictionary*) dictionary { // return a dictionary which is suitable for json serialization
    return @{ @"pack" : @(self.pack),
    @"assetPack": @(self.assetPack),
    @"filename": self.filename,
    @"folder": [self relativeFolder]}; //jsonserialization doesn't support url's
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
        // we load it from the structure.json file
        NSData *fileData = [NSData dataWithContentsOfFile:
                            [[NSBundle mainBundle] pathForResource:@"structure" ofType:@"json"]];
        
        NSAssert(fileData!=nil, @"structure.json seems empty");
        
        NSError *error = nil;
        
        _structure = [NSJSONSerialization JSONObjectWithData:fileData
                                                     options:0
                                                       error:&error];
        
        NSAssert(error==nil, [error localizedDescription]);
        
        NSAssert([_structure isKindOfClass:[NSDictionary class]],
                 @"structure.json has to return a dictionary");
        
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
    NSDictionary *exportedDataDictionary = @{
    @"header" : _structure,
    @"data": self.gameAssetConfig,
    @"folder": [APStoreLocation location]
    };
    
    
    return [NSKeyedArchiver archivedDataWithRootObject:exportedDataDictionary];
}

- (NSDictionary*) exportDictionary {
    // return the data structure that can be used
    // from within a script. means we replace
    // apcontent objects with apdictionraies.
    NSMutableDictionary *returnPack = [NSMutableDictionary dictionaryWithCapacity:
                                       [_structure count]];
    
    for(NSString *key in _structure) {
        NSMutableDictionary *pack = [NSMutableDictionary dictionaryWithCapacity:10];
        
        NSInteger packIndex = [[self.gameAssetConfig allSortedKeys] indexOfObject:key];
        
        for (NSString *assetPack in [_structure objectForKey:key]) {
            
            NSInteger assetPackIndex = [[_structure objectForKey:key] indexOfObject:assetPack];
            
            // get the objects and transform them
            NSArray *objectDictionaries = [[self assetsForPack:packIndex assetPack:assetPackIndex]
                                           valueForKey:@"dictionary"];
            
            [pack setObject:objectDictionaries
                     forKey:assetPack];
        }
        [returnPack setObject:pack forKey:key];
    }
    return returnPack;
}

- (void) loadImportedData:(NSData*) importedData {
    NSDictionary *importedDictionary =
    [NSKeyedUnarchiver unarchiveObjectWithData:importedData];
    _structure = [importedDictionary objectForKey:@"header"];
    self.gameAssetConfig = [importedDictionary objectForKey:@"data"];
	
	// this makes things not work correct on other machines.
//    [[NSUserDefaults standardUserDefaults] setObject:[importedDictionary objectForKey:@"folder"]
//                                              forKey:@"CurrentPreferencesPath"];
    
    
    self.currentAssetPack = -1;
    self.currentPack = -1;
}

- (NSString*) titleOfPack:(NSInteger)pack {
    return [[_structure allSortedKeys] objectAtIndex:pack];
}
- (NSString*) titleOfAssetPack:(NSInteger)assetPack inPack:(NSInteger)pack {
    return [[_structure objectForKey:[[_structure allSortedKeys] objectAtIndex:pack]] objectAtIndex: assetPack];
}

- (NSInteger) numberOfPacks {
    return [_structure count];
}

- (NSInteger) numberOfAssetPacksInPack:(NSInteger)pack {
    return [[_structure objectForKey:[[_structure allSortedKeys] objectAtIndex:pack]] count];
}

- (NSArray*) assetsForPack:(NSInteger)pack assetPack:(NSInteger)assetPack {
    NSDictionary *packDict = [self.gameAssetConfig objectForKey:[[self.gameAssetConfig allSortedKeys] objectAtIndex:pack]];
    return [[packDict objectForKey:[[packDict allSortedKeys] objectAtIndex:assetPack]] copy]; // copy to make it immutable
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
                                     [[self.gameAssetConfig allSortedKeys] objectAtIndex:pack]];
    [packDict setObject:assets
                 forKey:[[packDict allSortedKeys] objectAtIndex:assetPack]];
    
    // and save it again
    [self.gameAssetConfig setObject:packDict
                             forKey:[[self.gameAssetConfig allSortedKeys] objectAtIndex:pack]];
}

- (void) addObject:(APContentObject*)object toPack:(NSInteger)pack assetPack:(NSInteger)assetPack {
    NSMutableDictionary *packDict = [self.gameAssetConfig objectForKey:
                                     [[self.gameAssetConfig allSortedKeys] objectAtIndex:pack]];
    
    NSMutableArray *packAssetArray = [packDict objectForKey:[[packDict allSortedKeys] objectAtIndex:assetPack]];
    
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
                             forKey:[[self.gameAssetConfig allSortedKeys] objectAtIndex:pack]];
}

- (void) removeObject:(APContentObject*)object fromPack:(NSInteger)pack assetPack:(NSInteger)assetPack {
    NSMutableDictionary *packDict = [self.gameAssetConfig objectForKey:
                                     [[self.gameAssetConfig allSortedKeys] objectAtIndex:pack]];
    
    __block NSMutableArray *packAssetArray = [packDict objectForKey:[[packDict allSortedKeys] objectAtIndex:assetPack]];
    
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
                             forKey:[[self.gameAssetConfig allSortedKeys] objectAtIndex:pack]];
}

@end
