//
//  DictHandler.h
//  testtables
//
//  Created by Håvard Sørbø on 02.02.06.
//  Copyright 2006 Håvard Sørbø. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ClueDict.h"


@interface DictHandler : NSObject {
    NSMutableArray *dlist;
    IBOutlet NSTableView *table;

}
-(DictHandler *) init;
-(void) listFiles;
-(NSMutableArray *) getDictList;
-(ClueDict *) getDictAt: (int) pos;
-(void) reset;

//Tableview
-(int) numberOfRowsInTableView: (NSTabView*)table;


@end
