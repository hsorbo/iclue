//
//  ClueDictName.h
//  iClue
//
//  Created by Håvard Sørbø on 15.06.06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface ClueDictName : NSObject {
    NSString *name;
}


- (NSString *) getFromLang;
- (NSString *) getToLang;

- (NSString *) getFullName;
- (NSString *) getShortName;

- (NSString *) shortToLongName: (NSString*)twoChar;
- (NSString *) getExtraName;

@end
