//
//  ClueDictName.m
//  iClue
//
//  Created by Håvard Sørbø on 15.06.06.
//  Copyright 2006 Håvard Sørbø. All rights reserved.
//

#import "ClueDictName.h"


@implementation ClueDictName

- (ClueDictName *) initWithName: (NSString *)dname
{
	if (self = [super init]){
			name = [[NSString alloc] initWithString: dname];
			//name = [[NSString alloc] stringWithString:dname]];
	} 
	return self;
}

- (NSString *) shortToLongName: (NSString*)twoChar
{
      NSDictionary *langs = [NSDictionary dictionaryWithObjectsAndKeys:
		@"Norsk", @"NO",
		@"Engelsk", @"UK",
		@"Tysk",@"DE",
		@"Spansk",@"ES",
		@"Svensk",@"SV",
		@"Fransk",@"FR",
		@"Medisinsk",@"ME",
		@"Maxi",@"MX",
		@"Teknisk", @"TE",
		@"Privat", @"PR",
		@"Bedrift", @"BE",
		@"Okonomisk", @"EC",
		nil];
	NSString * ret = [langs objectForKey: twoChar];
	if (ret == nil)
		ret = [NSString stringWithFormat: @"Unknown (%@)", twoChar];
	return ret;
}


- (NSString *) getFromLang
{
 	return [self shortToLongName: [name substringWithRange: NSMakeRange(2,2)]];
}

- (NSString *) getToLang
{
    return [self shortToLongName: [name substringWithRange: NSMakeRange(4,2)]];
}


- (NSString *) getExtraName
{
    if ([name length] >= 8){
        return [self shortToLongName: [name substringWithRange: NSMakeRange(6,2)]];
    }
    return NULL;
}


- (NSString *) getFullName
{
	NSString *ret =  [NSString stringWithFormat:@"%@ - %@", 
                    [self getFromLang],  
                    [self getToLang]
                    ];
    
    //NSString *nvar = [self shortToLongName: variant];
    NSString *nvar = [self getExtraName];
    if (nvar != NULL){
        ret = [NSString stringWithFormat: @"%@ (%@)", ret, nvar];
    }
    return ret;
}

- (NSString *) getShortName
{
    return name;
}

@end
