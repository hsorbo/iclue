//
//  DictHandler.m
//  testtables
//
//  Created by Håvard Sørbø on 02.02.06.
//  Copyright 2006 Håvard Sørbø. All rights reserved.
//

#import "DictHandler.h"
#import "ClueDict.h"

@implementation DictHandler

-(DictHandler *) init
{
    return [super init];
}


-(void) reset
{
	if (dlist != nil)
		[dlist release];
	dlist = [[NSMutableArray alloc] init];
	[self listFiles];
	[table reloadData];
}


-(void) listFiles
{
	NSString *importDir =  [(NSString *)[[NSUserDefaults standardUserDefaults] objectForKey:@"DictLocation"] stringByExpandingTildeInPath];
	NSFileManager *fileman = [NSFileManager defaultManager];
	
	for(NSString *file in [fileman enumeratorAtPath: importDir]){
	    if ([ [[file pathExtension] lowercaseString] isEqualToString: @"idx"])
		{
			NSString * basename =  [[file lastPathComponent] stringByDeletingPathExtension] ;
			{
				ClueDict * dict_ = [[ClueDict alloc] initWithDatabase: basename];
				if (dict_ != nil) 
					[dlist addObject: dict_ ];
			}
		}
    }
}

-(NSMutableArray *) getDictList
{
    NSMutableArray * a = [[NSMutableArray alloc] init];
    NSEnumerator *enumerator = [dlist objectEnumerator];
    ClueDict *d;
        while ((d = [enumerator nextObject])) {
            [a addObject: [[d getDictName] getFullName]];
        }
    return a;
    
}

-(ClueDict *) getDictAt: (int) pos
{
    return [dlist objectAtIndex: pos];
}

//TableViewBindings...
-(int) numberOfRowsInTableView: (NSTabView*)table
{
    return [dlist count];
}

-(id) tableView: (NSTableView*)table objectValueForTableColumn: (NSTableColumn*)col row: (int)rowIndex
{
	ClueDict * d = (ClueDict*)[dlist objectAtIndex:rowIndex];
	if ([[col identifier] isEqualToString:@"FromLanguage"])
			return  [[d getDictName] getFromLang];
	if ([[col identifier] isEqualToString:@"ToLanguage"])
		return  [[d getDictName] getToLang];
	if ([[col identifier] isEqualToString:@"Type"])
		return  [[d getDictName] getExtraName];
	if ([[col identifier] isEqualToString:@"Version"])
		return  [NSString stringWithFormat:@"%1.1f", [d getDictVersion] / 100.0];
	if ([[col identifier] isEqualToString:@"CheckBox"])
		{
		NSButtonCell *cell = (NSButtonCell *)[col dataCell];
		if (cell != NULL)
			[cell setNextState]; 
		}
		
	/*
	if (col == [columns objectAtIndex: 0])
			return  [[d getDictName] getFullName];
    if (col == [columns objectAtIndex: 1])
        return [cluedict getDefAt: rowIndex];
    */
	return @"failes";
}




- (void) dealloc {
    [dlist release];
    //NSLog(@"releasing dict-manager");
    [super dealloc];
}


@end
