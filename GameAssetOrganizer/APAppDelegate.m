//
//  APAppDelegate.m
//  GameAssetOrganizer
//
//  Created by BTerhechte on 25.08.12.
//  Copyright (c) 2012 BTerhechte. All rights reserved.
//

#import "APAppDelegate.h"

@implementation APAppDelegate

@synthesize currentPreferencesPath = _currentPreferencesPath;
@synthesize model;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
    model = [APContentModel sharedModel];
}

- (IBAction)setPreferencesPath:(id)sender {
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    [panel setCanChooseDirectories:YES];
    [panel setCanChooseFiles:NO];
    
    __weak APAppDelegate *weakAppDelegate = self;
    
    [panel beginWithCompletionHandler:^(NSInteger result) {
        
        // get a strong reference here
        __strong APAppDelegate *strongAppDelegate = weakAppDelegate;
        
        if (result==NSFileHandlingPanelOKButton) {
            strongAppDelegate.currentPreferencesPath = [panel.URL path];
        }
    }];
}

- (IBAction)loadFile:(id)sender {
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    [panel setCanChooseDirectories:NO];
    [panel setCanChooseFiles:YES];
    [panel setAllowedFileTypes:@[ @"assetdesc", ]];
    
    __weak APAppDelegate *weakAppDelegate = self;
    
    [panel beginWithCompletionHandler:^(NSInteger result) {
        
        // get a strong reference here
        __strong APAppDelegate *strongAppDelegate = weakAppDelegate;
        
        if (result==NSFileHandlingPanelOKButton) {
            // load the data
            NSData *loadedData = [NSData dataWithContentsOfFile:[panel.URL path]];
            
            if (!loadedData)return;
            
            [strongAppDelegate.model loadImportedData: loadedData];
        }
    }];
}

- (IBAction)saveFile:(id)sender {
    NSSavePanel *panel = [NSSavePanel savePanel];
    [panel setCanCreateDirectories:YES];
    [panel setExtensionHidden:NO];
    [panel setAllowedFileTypes:@[ @"assetdesc", ]];
    
    __weak APAppDelegate *weakAppDelegate = self;
    
    [panel beginWithCompletionHandler:^(NSInteger result) {
        
        // get a strong reference here
        __strong APAppDelegate *strongAppDelegate = weakAppDelegate;
        
        if (result==NSFileHandlingPanelOKButton) {
            // get the data
            NSData *exportedData = [strongAppDelegate.model exportData];
            
            if (!exportedData) {
                NSBeep();
                return;
            }
            
            [exportedData writeToURL:panel.URL atomically:YES];
        }
    }];
}

- (NSString*) currentPreferencesPath {
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"CurrentPreferencesPath"];
}

- (void) setCurrentPreferencesPath:(NSString *)currentPreferencesPath {
    [[NSUserDefaults standardUserDefaults] setObject:currentPreferencesPath forKey:@"CurrentPreferencesPath"];
}

@end
