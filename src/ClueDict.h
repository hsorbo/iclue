//
//  clue.h
//  testtables
//
//  Created by Håvard Sørbø on 30.01.06.
//  Copyright 2006 Håvard Sørbø. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <entries.h>
#import <idx.h>
#import "ClueDictName.h"

@interface ClueDict : NSObject {
    FILE *index, *cldata, *clidx;
    NSString *word;
    NSString *definition;
	ClueDictName *dictname;
}

- (ClueDict *) initWithDatabase: (NSString *)basename;
- (int) recordCount;
- (int) findWordMatching: (NSString *) ss;

//- (NSString *) datfilename;


- (NSString *) getWordAt: (int) pos;
- (id) getDefAt: (int) pos;
- (ClueDictName *) getDictName;
- (int) getDictVersion;
- (bool) visible;

@end
 
