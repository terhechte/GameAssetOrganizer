//
//  APGradientView.h
//  GameAssetOrganizer
//
//  Created by BTerhechte on 28.08.12.
//  Copyright (c) 2012 BTerhechte. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface APGradientView : NSView
@property (nonatomic, strong) NSString *firstColor;
@property (nonatomic, strong) NSString *secondColor;
@property (nonatomic, assign) NSInteger angle;
@end
