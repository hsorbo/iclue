/* IClue */

#import <Cocoa/Cocoa.h>
#import "ClueDict.h"
#import "DictHandler.h"
//#import "ClueFramework/entries.h"
//#import "ClueFramework/index.h"

@interface IClue : NSObject
{
    IBOutlet NSPopUpButton *dictselect;
    IBOutlet NSSearchField *searchfield;
    IBOutlet NSTableView *table;
    IBOutlet NSWindow *window;
    NSString *path;
    ClueDict *cluedict;
    IBOutlet DictHandler *cluedicthandler;
    NSArray *columns;
	NSMutableDictionary *toolbarItems; 
	NSOperationQueue * operationQueue;
}
- (IBAction)changeDict:(id)sender;
- (IBAction)import:(id)sender;
- (IBAction)updateSearch:(id)sender;
- (IBAction) nextDict: (id)sender;
- (IBAction) cleanup: (id)sender;
- (void) updateDictList;
- (void)checkTimeAlertDidEnd:(NSAlert *)alert returnCode:(int)returnCode contextInfo:(void *)contextInfo;
- (void) applicationWillTerminate: (NSNotification *)notification;
- (NSString *)getDictonariesLocation;
- (NSOperationQueue *) getOperatorQueue;
@end
