#import "IClue.h"
#import "ImportOperation.h"



@implementation IClue

-(void) awakeFromNib
{
     NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
  
	[table setDelegate: self];
    columns = [table tableColumns];
    [table columnAutoresizingStyle];
	path = [self getDictonariesLocation];
   
   [self updateDictList];
   operationQueue = [[NSOperationQueue alloc] init];
     
   int selectedDict = [defaults integerForKey:@"SelectedDict"];
   
   if ( [[cluedicthandler getDictList] count] > selectedDict)
   {
      [dictselect selectItemAtIndex: selectedDict];
	  [self changeDict: self];
	}

}

- (NSOperationQueue *) getOperatorQueue
{
	return operationQueue;
}

- (NSString *)getDictonariesLocation
{
	NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
	NSString *dictloc = [defaults objectForKey:@"DictLocation"];
	if(dictloc == nil)
	{
		dictloc = [[NSString alloc] initWithString: @"~/Library/Application Support/iClue"];
		[[NSUserDefaults standardUserDefaults] setObject:dictloc forKey:@"DictLocation"];
	}
	
	return [dictloc stringByExpandingTildeInPath];
	
}


- (void)windowDidBecomeMain:(NSNotification *)aNotification
{
	
	
	
}

- (void)windowWillClose:(NSNotification *)aNotification
{
	[NSApp terminate: self];
}


- (void)checkTimeAlertDidEnd:(NSAlert *)alert returnCode:(int)returnCode contextInfo:(void *)contextInfo{
	if (returnCode == 1)
		exit(0);
	[window setIsVisible: false];
}


-(IBAction) changeDict: (id)sender
{
    cluedict = [cluedicthandler getDictAt: [dictselect indexOfSelectedItem] ];
    [table reloadData];
	NSArray *cols = [table tableColumns];
    
	//ClueDictName * dname = [cluedict getDictName];
	//NSLog(@"changeDict %@", [dname getFromLang]);
	[[[cols objectAtIndex: 0] headerCell] setStringValue: [[cluedict getDictName] getFromLang]]; 
    [[[cols objectAtIndex: 1] headerCell] setStringValue: [[cluedict getDictName] getToLang]]; 
    
	[self updateSearch: self];
}

-(IBAction) nextDict: (id)sender
{
	//[dictselect numberOfItems
	int current = [dictselect indexOfSelectedItem];
	if (current == [dictselect numberOfItems] -1)
		current = 0;
	else
		current++;
	[dictselect selectItemAtIndex: current];
	[self changeDict: self];
}


-(IBAction) import: (id)sender
{
	int result;
	NSArray *fileTypes = [NSArray arrayWithObject:@"idx"];
	NSOpenPanel *oPanel = [NSOpenPanel openPanel];
	[oPanel setAllowsMultipleSelection:YES];
	[oPanel setTitle: @"Open .idx files"];
	result = [oPanel runModalForDirectory:NSHomeDirectory()
									 file:nil types:fileTypes];
	if (result == NSOKButton) 
	{
		for (NSString *src in [oPanel filenames])
		{
			[[self getOperatorQueue] addOperation: [[ImportOperation alloc] initWithIDXFile:src selector:@selector(doneImporting) sender:nil]];
		}
	}
}


-(IBAction) cleanup: (id)sender
{

NSAlert *alert = [NSAlert alertWithMessageText:@"Are you sure you want to move to trash?" 
		defaultButton:@"No" alternateButton:@"Yes" 
		otherButton:nil informativeTextWithFormat: @"Are you sure you want to delete the folder:\n %@", [self getDictonariesLocation]];
		[alert beginSheetModalForWindow:window modalDelegate:self didEndSelector:@selector(doCleanup:returnCode:contextInfo:) contextInfo:nil];
		
		

}

- (void)doCleanup:(NSAlert *)alert returnCode:(int)returnCode contextInfo:(void *)contextInfo{
	if (returnCode == 0){
		NSString *trashDir = [NSHomeDirectory() stringByAppendingPathComponent:@".Trash"];
		NSString *p = [self getDictonariesLocation];
		int tag;
		[[NSWorkspace sharedWorkspace] performFileOperation:NSWorkspaceRecycleOperation source:[p stringByDeletingLastPathComponent] 
			destination:trashDir files:[NSArray arrayWithObject:[p lastPathComponent]] tag:&tag];
		[self updateDictList];
	}
}

-(void) doneImporting
{
	[self updateDictList];
	[dictselect selectItemAtIndex: 0];
	[self changeDict: self];

}


-(void) updateDictList
{

  if (cluedicthandler != nil)
 	[cluedicthandler reset];
    [dictselect removeAllItems];
    NSEnumerator *en = [[cluedicthandler getDictList] objectEnumerator];
    for(NSString *k in en){
		    [dictselect addItemWithTitle: k];
    }

}


-(void) applicationWillTerminate: (NSNotification *)notification
{
 	if (cluedicthandler != nil)
      [cluedicthandler release];
	
	//Save current dict-pos
 	[[NSUserDefaults standardUserDefaults] setInteger: [dictselect indexOfSelectedItem] forKey:@"SelectedDict"];
}


-(IBAction) updateSearch: (id)sender
{
	//if [sender is
	//int i = [cluedict findWordMatching: [sender stringValue]];
	int i = [cluedict findWordMatching: [searchfield stringValue]];
    [table scrollRowToVisible: i+10];
    [table selectRow: i+1 byExtendingSelection:FALSE];
}



//Dataview / Delegates...
-(int) numberOfRowsInTableView: (NSTabView*)table
{
    //Why is 63632 the largest number before it starts snipping!
    //return 63634;
    return [cluedict recordCount];
}



-(id) tableView: (NSTableView*)table objectValueForTableColumn: (NSTableColumn*)col row: (int)rowIndex
{
    if (col == [columns objectAtIndex: 0])
        return [cluedict getWordAt: rowIndex];
    if (col == [columns objectAtIndex: 1])
        return [cluedict getDefAt: rowIndex];
    return @"failes";
}

/*
- (float)tableView:(NSTableView *)tableView heightOfRow:(int)row
{
    //row += 12952;
    //124747, 12952
    //NSLog(@"row: %i", row);
    //NSMutableAttributedString *str = [cluedict getDefAt: row];
    //NSTableColumn *col = [[tableView tableColumns] objectAtIndex: 1];
    //NSCell *cell = [col dataCell];
    float width = 10;
    //float f = 30;
    return width;
}
*/


@end
