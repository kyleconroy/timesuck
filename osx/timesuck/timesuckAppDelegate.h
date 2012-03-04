//
//  timesuckAppDelegate.h
//  timesuck
//
//  Created by Kyle Conroy on 8/28/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "WebKit/WebKit.h"
#import "FMDatabase.h"

@class HTTPServer;


@interface timesuckAppDelegate : NSObject <NSApplicationDelegate> {
@private
    NSDateFormatter *dateFormatter;
    NSDateFormatter *intervalFormatter;
    FMDatabase *db;
    NSString *state;
    IBOutlet id webView;
	IBOutlet NSWindow *window;
    IBOutlet NSTextField *heading;
    NSDate *lastWake;
    NSDate *selectedDate;
    NSMutableDictionary *applications;
    NSPersistentStoreCoordinator *__persistentStoreCoordinator;
    NSManagedObjectModel *__managedObjectModel;
    NSManagedObjectContext *__managedObjectContext;
    HTTPServer *httpServer;
}

@property (assign) IBOutlet NSWindow *window;
@property (assign) IBOutlet WebView *webView;

@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;

- (IBAction)showWindow:sender;
- (IBAction)saveAction:sender;
- (IBAction)chnageDate:sender;
- (IBAction)changeInterval:sender;
- (FMDatabase*)initDatabase;
- (void)logForType:(NSString*)type name:(NSString*)name start:(NSDate *)start end:(NSDate *)end;
- (NSDate *)parseDate:(NSString*)dateStr;
- (NSDate*)previousDate;
- (NSDate*)nextDate;
- (NSString*)graphJson;

@end
