//
//  timesuckAppDelegate.h
//  timesuck
//
//  Created by Kyle Conroy on 8/28/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "FMDatabase.h"

@interface timesuckAppDelegate : NSObject <NSApplicationDelegate> {
@private
    FMDatabase *db;
    NSWindow *window;
    NSDate *lastWake;
    NSDateFormatter *dateFormatter;
    NSMutableDictionary *applications;
    NSPersistentStoreCoordinator *__persistentStoreCoordinator;
    NSManagedObjectModel *__managedObjectModel;
    NSManagedObjectContext *__managedObjectContext;
}

@property (assign) IBOutlet NSWindow *window;

@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;

- (IBAction)saveAction:sender;
- (FMDatabase*)initDatabase;

@end
