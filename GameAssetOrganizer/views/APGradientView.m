//
//  APGradientView.m
//  GameAssetOrganizer
//
//  Created by BTerhechte on 28.08.12.
//  Copyright (c) 2012 BTerhechte. All rights reserved.
//

#import "APGradientView.h"

/*
 NSColor: Instantiate from Web-like Hex RRGGBB string
 Original Source: <http://cocoa.karelia.com/Foundation_Categories/NSColor__Instantiat.m>
 (See copyright notice at <http://cocoa.karelia.com>)
 */
@interface NSColor(Hex)
+ (NSColor *) colorFromHexRGB:(NSString *) inColorString;
@end

@implementation NSColor(Hex)
+ (NSColor *) colorFromHexRGB:(NSString *) inColorString
{
	NSColor *result = nil;
	unsigned int colorCode = 0;
	unsigned char redByte, greenByte, blueByte;
	
	if (nil != inColorString)
	{
		NSScanner *scanner = [NSScanner scannerWithString:inColorString];
		(void) [scanner scanHexInt:&colorCode];	// ignore error
	}
	redByte		= (unsigned char) (colorCode >> 16);
	greenByte	= (unsigned char) (colorCode >> 8);
	blueByte	= (unsigned char) (colorCode);	// masks off high bits
	result = [NSColor
			  colorWithCalibratedRed:		(float)redByte	/ 0xff
			  green:	(float)greenByte/ 0xff
			  blue:	(float)blueByte	/ 0xff
			  alpha:1.0];
	return result;
}
@end


@implementation APGradientView

@synthesize firstColor, secondColor, angle;

- (void) drawRect:(NSRect)dirtyRect {
    if (self.firstColor && self.secondColor) {
        // draw the gradient
        NSColor *firstColorValue = [NSColor colorFromHexRGB:self.firstColor];
        NSColor *secondColorValue = [NSColor colorFromHexRGB:self.secondColor];
        
        if (!firstColorValue || !secondColorValue)return;
        
        NSGradient *gradient = [[NSGradient alloc] initWithStartingColor:firstColorValue
                                                             endingColor:secondColorValue];
        [gradient drawInRect:self.bounds angle:angle];
    }
}

@end
