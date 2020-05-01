//
//  ImportOperation.h
//  iClue
//
//  Created by Håvard Sørbø on 11.03.08.
//  Copyright 2008 Håvard Sørbø. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <entries.h>


@interface ImportOperation : NSOperation {

NSString * index_file;
SEL _selector;
id _sender;

}

- (id)initWithIDXFile: (NSString *) filename selector:(SEL) selector sender: (id) sender;
- (void) indexFile: (NSString *)filepath;
@end
