//
//  main.m
//  processGameassets
//
//  Created by BTerhechte on 27.08.12.
//  Copyright (c) 2012 BTerhechte. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "APContentModel.h"

void syntax();
void syntax() {
    printf("\nSyntax: processGameassets assetfile.assetdesc path_to_processed_renders\n\n");
}

int main(int argc, const char * argv[])
{

    @autoreleasepool {
        
        if (argc==2) {
            syntax();
            return -1;
        }
        
        // get the input filename
        NSString *inFile = [NSString stringWithCString:argv[1] encoding:NSASCIIStringEncoding];
        if (!inFile) {
            syntax();
            return -1;
        }
		
		NSString *processedRenderlocation =[NSString stringWithCString:argv[2] encoding:NSASCIIStringEncoding];
		if (!processedRenderlocation) {
			syntax();
			return -1;
		}
        
        // now load the file, and spit out the data as json :)
        NSData *fileData = [NSData dataWithContentsOfFile:inFile];
        
        if (fileData==nil && [fileData length]==0) {
            syntax();
            return -1;
        }
		
		// set the folder
		APStoreLocation *location = [APStoreLocation sharedLocation];
		[location setLocation:processedRenderlocation];
        
        // initialize the data
        APContentModel *model = [[APContentModel alloc] init];
        
        [model loadImportedData:fileData];
        
        // and now get it as a dictionary representation
        NSDictionary *exportDictionary = [model exportDictionary];
        
        if (!exportDictionary) {
            syntax();
            return -1;
        }
        
        NSError *jsonConversionError = nil;
        
        NSData *jsonData =
        [NSJSONSerialization dataWithJSONObject:exportDictionary
                                        options:NSJSONWritingPrettyPrinted
                                          error:&jsonConversionError];
        
        if (jsonConversionError) {
            NSLog(@"Error: %@", jsonConversionError);
            return -1;
        }
        
        NSString *jsonString = [[NSString alloc] initWithData:jsonData
                                                     encoding:NSUTF8StringEncoding];
        
        // and print the json data.
        printf("\n%s\n", [jsonString UTF8String]);
        
    }
    return 0;
}

