//
//  APAppDelegate.h
//  GameAssetOrganizer
//
//  Created by BTerhechte on 25.08.12.
//  Copyright (c) 2012 BTerhechte. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "APContentModel.h"

@interface APAppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;
@property (strong) APContentModel *model;
@property (strong) NSString *currentPreferencesPath;

- (IBAction)saveFile:(id)sender;
- (IBAction)loadFile:(id)sender;
- (IBAction)exportFile:(id)sender;
- (IBAction)setPreferencesPath:(id)sender;
@end
