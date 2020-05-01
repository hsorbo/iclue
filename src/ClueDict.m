//
//  clue.m
//  testtables
//
//  Created by Håvard Sørbø on 30.01.06.
//  Copyright 2006 Håvard Sørbø. All rights reserved.
//

#import "ClueDict.h"



@implementation ClueDict

- (ClueDict *) initWithDatabase: (NSString *)basename
{
    self = [super init];
	NSString *path =  [(NSString *)[[NSUserDefaults standardUserDefaults] objectForKey:@"DictLocation"] stringByExpandingTildeInPath];
	
	
	
	//Case-insensitive match of filenames
	NSFileManager *fileman = [NSFileManager defaultManager];
	for(NSString *file in [fileman enumeratorAtPath: path]){
		if ([[[file lastPathComponent] stringByDeletingPathExtension] isCaseInsensitiveLike: basename])
		{
			if([[file pathExtension] isCaseInsensitiveLike:@"idx"])
				clidx = fopen([[path stringByAppendingPathComponent: file] fileSystemRepresentation], "r");
			if([[file pathExtension] isCaseInsensitiveLike:@"dat"])
				cldata = fopen([[path stringByAppendingPathComponent: file] fileSystemRepresentation], "r");
			if([[file pathExtension] isCaseInsensitiveLike:@"iclue"])
				index = fopen([[path stringByAppendingPathComponent: file] fileSystemRepresentation], "r");
		}
	}
	
	//Error finding one of the files
    if (index == NULL || cldata == NULL || clidx == NULL) {
		NSLog(@"Error opening dictionary");
		return nil;
	}
	
    NSString * name = [[NSString alloc] initWithString: [[[basename lastPathComponent] uppercaseString] stringByDeletingPathExtension]];
    dictname = [[ClueDictName alloc] initWithName: name];
	return self;
}


- (int) getDictVersion
{
	return get_dict_version(clidx);
}

- (int) recordCount
{
    if (index != NULL){
        return count_records_idx(index) - 3;
    }
    else{
        return -1;
    }
}

- (int) findWordMatching: (NSString *) ss
{
	return _fe2(index, cldata, ss, 0, count_records_idx(index)); 
	//return find_entry(clidx, cldata, [ss cStringUsingEncoding:NSISOLatin1StringEncoding]);
}

- (bool) visible
{
	return [[NSUserDefaults standardUserDefaults] boolForKey: [dictname getShortName]];
}


int _fe2(FILE *indexfile, FILE *dictfile, NSString *keyword, int min, int max){
    //printf("min: %i \t max: %i\n", min, max);
    char wrd[255];
    int cur = min + ((max - min)/2);
    get_record(dictfile, get_offset(indexfile, cur) ,wrd, 1);
    NSComparisonResult res = [keyword localizedCaseInsensitiveCompare: [NSString stringWithCString: wrd encoding: NSISOLatin1StringEncoding]];
	if (res == NSOrderedSame || cur == max || cur == min) return cur; 
    if (res == NSOrderedAscending )
		max = cur;
	//else if (r > 0) max = cur;
    else min = cur; 
     
    return _fe2(indexfile, dictfile, keyword, min, max); 
}





- (NSString *) getWordAt: (int) pos
{
    char kw[128];
    get_keyw(cldata, get_offset(index, pos), &kw);
    return [NSString stringWithCString: kw encoding: NSISOLatin1StringEncoding  ];        
}




- (ClueDictName *) getDictName
{
	return dictname;
}

- (NSAttributedString *) colorize: (NSString *) str withColor: (NSColor *) color
{
    NSDictionary *col = [NSDictionary dictionaryWithObjectsAndKeys:
        color, NSForegroundColorAttributeName, nil];
    return  [[[NSAttributedString alloc] init] initWithString: str attributes: col];
}

- (NSAttributedString *) drawWordClass: (NSString *) str
{
    return [self colorize:
    [NSString stringWithFormat: @"%@. ", str] 
    withColor: [NSColor redColor]];
}


- (NSAttributedString *) drawLanguage: (NSString *) str
{
    return [self colorize:
    [NSString stringWithFormat: @"%@: ", str] 
    withColor: [NSColor orangeColor]];
}

- (NSAttributedString *) drawContext: (NSString *) str
{
    return [self colorize:
    [NSString stringWithFormat: @"(%@) ", str] 
    withColor: [NSColor orangeColor]];
}

- (NSAttributedString *) drawUNK: (NSString *) str
{
    return [self colorize:
    [NSString stringWithFormat: @"[%@] ", str] 
    withColor: [NSColor blueColor]];
}


- (id) getDefAt: (int) pos
{
    //struct dbentry entry;
    //entry.class = NULL;
    //entry.lang = NULL;
    //entry.context = NULL;
    //entry.trans = NULL;
    
    long ling = get_offset(index, pos);
    //get_entry(cldata, ling ,&entry);
    
    struct db_defs defs;
    defs.class = NULL;
    defs.lang = NULL;
    defs.context = NULL;
    defs.trans = NULL;
    
    get_defs(cldata, ling, 0, &defs);
    
    NSMutableAttributedString *nsa = [[NSMutableAttributedString alloc] init];
       if (defs.class && strlen(defs.class) > 0){
            [nsa appendAttributedString: 
                [self drawWordClass: [NSString stringWithCString: defs.class encoding: NSISOLatin1StringEncoding]]
            ];
        }
    
        if (defs.context && strlen(defs.context) > 0){
            [nsa appendAttributedString: 
                [self drawContext: [NSString stringWithCString: defs.context encoding: NSISOLatin1StringEncoding]]
            ];
        }
       
        if (defs.trans && strlen(defs.trans) > 0){
            [nsa appendAttributedString: 
                [self drawUNK: [NSString stringWithCString: defs.trans encoding: NSISOLatin1StringEncoding]]
            ];
        }
        
        
        if (defs.lang && strlen(defs.lang) > 0){
            [nsa appendAttributedString: 
                [self drawLanguage: [NSString stringWithCString: defs.lang encoding: NSISOLatin1StringEncoding]]
            ];
        }
       
        //check to see if the two first characters is >>
        //like in UK-NO: abridgment 
        //Add definition
		if (strncmp(defs.def, ">>", 2) != 0){
			[nsa appendAttributedString: 
				[self colorize: [NSString stringWithCString: defs.def encoding: NSISOLatin1StringEncoding]
				withColor: [NSColor blackColor]]];
		}
		else{
		 //NSString *definition_ = [NSString stringWithCString: defs.def encoding: NSISOLatin1StringEncoding];
       /* 
        if ( [definition_ length] > 2 &&
        [[definition_ substringWithRange: NSMakeRange(0 , 2)] caseInsensitiveCompare: @">>"] == NSOrderedSame){ 
            NSMutableAttributedString *nsma = [[NSMutableAttributedString alloc] init]; 
            
            NSRange selectedRange = NSMakeRange(1,2);
            NSURL *linkURL = [NSURL URLWithString:@"http://www.apple.com/"] ;
            [nsma beginEditing];
            [nsma addAttribute:NSLinkAttributeName value:linkURL range:selectedRange];
            [nsma endEditing];
            //return @"UUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUU"; 
        }
        */
        
        //NSPopUpButtonCell * popup = [[[NSPopUpButtonCell alloc] init] autorelease];
        //[popup setBordered:NO];
        //[popup addItemWithTitle:@"1"];
        //NSButton * popup = [[NSButton alloc] init];
        //NSButtonCell * popup = [[NSButtonCell alloc] init];
        //[col setDataCell:popup];
        //[col sizeToFit];
        //return popup;
       //NSLog(@"%s", defs.def);
		//file://localhost/Users/hs/Projects/iClue/iClue.xcodeproj
       
		}
		 
	return nsa;
      //return [[NSCell alloc] initTextCell:NSTextAttachment];

  }

- (void) dealloc {
    //NSLog(@"DEALLOC DICT\n");
    fclose(index);
    fclose(cldata);
    [super dealloc];
}





- (void) indexAllFiles: (NSString *)importDir 
{
    FILE *raw, *indx;
    NSString *file;
    NSDirectoryEnumerator *dirEnum = [[NSFileManager defaultManager] enumeratorAtPath: importDir];
    while (file = [dirEnum nextObject]) {
        if ([[file pathExtension] isEqualToString: @"DAT"]){
            raw = fopen([[NSString stringWithFormat: @"%@/%@", importDir, file] cString], "r");
            indx= fopen([[NSString stringWithFormat: @"%@/%@.index", importDir, file] cString], "w");
            if (raw != NULL && index != NULL){
                create_indexfile(raw,indx);
                fclose(raw);
                fclose(indx);
            }
            
        }
    }
}


@end

