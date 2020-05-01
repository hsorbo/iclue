//
//  ImportOperation.m
//  iClue
//
//  Created by Håvard Sørbø on 11.03.08.
//  Copyright 2008 Håvard Sørbø. All rights reserved.
//

#import "ImportOperation.h"



@implementation ImportOperation


- (id)initWithIDXFile: (NSString *) filename selector:(SEL) selector sender: (id) sender

{	
	if (![super init]) return nil;
	index_file = [[NSString alloc] initWithString: filename];
	_selector = selector;
	_sender = sender;
	
	return self;
}

- (BOOL)isConcurrent { 
	return NO; 
} 

- (void)main {
	NSString *path = [(NSString *)[[NSUserDefaults standardUserDefaults] objectForKey:@"DictLocation"] stringByExpandingTildeInPath];
	BOOL isDir;
	
	NSString *dat_file = [NSString stringWithFormat:@"%@.DAT", [index_file stringByDeletingPathExtension]];
	NSString *index_file_dst = [path stringByAppendingPathComponent: [index_file lastPathComponent]];
	NSString *dat_file_dst = [path stringByAppendingPathComponent: [dat_file lastPathComponent]];
	
	
	NSFileManager *filemanager = [[NSFileManager alloc] init];
	
	//Create dir if needed
	if (!([filemanager fileExistsAtPath: path isDirectory: &isDir] && isDir))
		[filemanager createDirectoryAtPath: path attributes: nil];
			
	//Copy
	if (![filemanager fileExistsAtPath: index_file_dst isDirectory: nil] && ![filemanager fileExistsAtPath: dat_file_dst isDirectory: nil])
	{
		[filemanager copyPath: index_file toPath: index_file_dst  handler: nil];
		[filemanager copyPath: dat_file toPath: dat_file_dst  handler: nil];
		[self indexFile: dat_file_dst];
	}
	
	[filemanager release];
	[[[NSApplication sharedApplication] delegate] performSelectorOnMainThread: _selector withObject: nil waitUntilDone: YES];
	//[_sender performSelector:_selector];
}


- (void) indexFile: (NSString *)filepath 
{
    FILE *raw, *indx;
    raw = fopen([filepath fileSystemRepresentation],  "r");
    indx = fopen([[[filepath stringByDeletingPathExtension] stringByAppendingPathExtension:@"iclue"] fileSystemRepresentation], "w");
//	indx = fopen([[NSString stringWithFormat:@"%@.iclue", filepath] fileSystemRepresentation], "w");
    
    if (raw != NULL && index != NULL){
        create_indexfile(raw,indx);
        fclose(raw);
        fclose(indx);
    }
}

@end
