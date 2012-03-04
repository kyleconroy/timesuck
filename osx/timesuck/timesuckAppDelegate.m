//
//  timesuckAppDelegate.m
//  timesuck
//
//  Created by Kyle Conroy on 8/28/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "timesuckAppDelegate.h"
#import "HTTPServer.h"
#import "MyHTTPConnection.h"
#import "DDLog.h"
#import "DDTTYLogger.h"

@implementation timesuckAppDelegate

@synthesize window;
@synthesize webView;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    [[NSUserDefaults standardUserDefaults] setBool:TRUE forKey:@"WebKitDeveloperExtras"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    // Set last wake to now
    lastWake = [[NSDate alloc] init];
    selectedDate = [[NSDate alloc] init];
    
    intervalFormatter = [[NSDateFormatter alloc] init];
    [intervalFormatter setDateFormat:@"MMMM y"];
    state = @"Month";
    [heading setStringValue:[intervalFormatter stringFromDate:selectedDate]];
    
    db = [self initDatabase];
    
    if (!db) {
        return;
    }
    
    // Not sure if this is needed
    [db retain];
    
    // Start the HTTP server
    // Configure our logging framework.
    [DDLog addLogger:[DDTTYLogger sharedInstance]];
    
    // Initalize our http server
    httpServer = [[HTTPServer alloc] init];
    
    // Tell the server to broadcast its presence via Bonjour.
    [httpServer setType:@"_http._tcp."];
    
    // Normally there's no need to run our server on any specific port.
    [httpServer setPort:9045];
    
    // We're going to extend the base HTTPConnection class with our MyHTTPConnection class.
    // This allows us to do all kinds of customizations.
    [httpServer setConnectionClass:[MyHTTPConnection class]];
    
    NSError *error = nil;
    if(![httpServer start:&error])
    {
        //DDLogError(@"Error starting HTTP Server: %@", error);
    }
    
    // Date Formatter
    dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setLocale:[NSLocale currentLocale]];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    //Initalize dictionary
    applications = [[NSMutableDictionary alloc] init];
    
    NSNotificationCenter *notCenter;
    
    notCenter = [[NSWorkspace sharedWorkspace] notificationCenter];
    
    [notCenter addObserver:self selector:@selector(systemDidSleep:)
               name:NSWorkspaceWillPowerOffNotification object:nil];
    [notCenter addObserver:self selector:@selector(systemDidSleep:) 
               name:NSWorkspaceScreensDidSleepNotification object:nil];
    [notCenter addObserver:self selector:@selector(systemDidWake:) 
               name:NSWorkspaceScreensDidWakeNotification object:nil];
    [notCenter addObserver:self selector:@selector(applicationDidActivate:)
               name:NSWorkspaceDidActivateApplicationNotification object:nil];
    [notCenter addObserver:self selector:@selector(applicationDidDeactivate:)
                      name:NSWorkspaceDidDeactivateApplicationNotification object:nil];
    
    //Setup the webview?    
    NSString* filePath = [[NSBundle mainBundle] pathForResource:@"graph" 
                                                         ofType:@"html"];
    NSURL* fileURL = [NSURL fileURLWithPath:filePath];
    NSURLRequest* request = [NSURLRequest requestWithURL:fileURL];
    [[webView mainFrame] loadRequest:request];
}

- (NSDate *)parseDate:(NSString *)dateStr
{
    return [NSDate dateWithTimeIntervalSince1970:[dateStr doubleValue]];
}

- (FMDatabase*)initDatabase
{
    /* Get Database Path */
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    NSString *executableName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleExecutable"];
    NSString *resolvedPath = [paths objectAtIndex:0];
    resolvedPath = [resolvedPath stringByAppendingPathComponent:executableName];
    resolvedPath = [resolvedPath stringByAppendingPathComponent:@"database.db"];
    
    /* Create Database */
    FMDatabase *database = [FMDatabase databaseWithPath:resolvedPath];
    if (![database open]) {
        [database release];
        return nil;
    }
    
    /* Create Table */
    [database executeUpdate:@"CREATE TABLE IF NOT EXISTS logs (type TEXT, name TEXT, start REAL, end REAL, duration REAL)"];
    
    return database;
}

- (void)logForType:(NSString *)type name:(NSString *)name start:(NSDate *)start end:(NSDate *)end
{    
    [db executeUpdate:@"INSERT INTO logs VALUES (?,?,?,?,?)", 
                      type,
                      name,
                      [NSNumber numberWithDouble:[start timeIntervalSince1970]],
                      [NSNumber numberWithDouble:[end timeIntervalSince1970]],
                      [NSNumber numberWithDouble:[end timeIntervalSinceDate:start]]];
}

- (NSString*)graphJson
{
    // TODO make this query configurable
    NSString *query = @"SELECT strftime('%s', date(start, 'unixepoch', 'localtime')), sum(duration) "
                      "FROM logs WHERE start > strftime('%s', '2012-02-01') "
                      "AND type != 'system' AND name != 'Google Chrome' "
                      "GROUP BY date(start, 'unixepoch', 'localtime')";
    
    FMResultSet *s = [db executeQuery:query];
    NSMutableDictionary *payload = [[NSMutableDictionary alloc] init];
    NSMutableArray *data = [[NSMutableArray alloc] init];
    
    while ([s next]) {
        NSMutableArray *point = [[NSMutableArray alloc] init];
        [point addObject:[NSNumber numberWithDouble:[s doubleForColumnIndex:0] * 1000]];
        [point addObject:[NSNumber numberWithDouble:[s doubleForColumnIndex:1] / 3600]];
        [data addObject:point];
    }
    
    [payload setObject:data forKey:@"data"];
    
    NSError *error; 
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:payload 
                                                       options:0
                                                         error:&error];
    if (! jsonData) {
        NSLog(@"Got an error: %@", error);
        return nil;
    } else {
        return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
}

- (void)applicationDidActivate:(NSNotification *)notification
{
    NSRunningApplication *app = [[notification userInfo] objectForKey:@"NSWorkspaceApplicationKey"];
    
    if ([[app localizedName] isEqualToString:@"loginwindow"])
        return;
    
    [applications setObject:[NSDate date] forKey:[app localizedName]];
}

- (void)deactivateApplication:(NSString *)localizedName
{
    NSDate *started = [applications objectForKey:localizedName];
    
    if (started == nil)
        return;
    
    NSDate *now = [NSDate date];
    
    [self logForType:@"application" name:localizedName start:started end:now];
    
    // Unset the value
    [applications removeObjectForKey:localizedName];    
}

-(IBAction)showWindow:(id)sender
{
    [window makeKeyAndOrderFront:nil];  
}

-(IBAction)changeInterval:(id)sender
{
    state = [sender labelForSegment:[sender selectedSegment]];
    [state retain];
    
    if ([state isEqualToString:@"Year"]) {
        [intervalFormatter setDateFormat:@"y"];
    } else if ([state isEqualToString:@"Month"]) {
        [intervalFormatter setDateFormat:@"MMMM y"];
    } else if ([state isEqualToString:@"Day"]) {
        [intervalFormatter setDateFormat:@"EEEE MMMM dd, y"];
    }
    
    [heading setStringValue:[intervalFormatter stringFromDate:selectedDate]];
}

-(IBAction)changeDate:(id)sender
{
    NSString *action = [sender labelForSegment:[sender selectedSegment]];
    NSDate *newDate;
    
    if ([action isEqualToString:@"Today"]) {
        newDate = [[NSDate alloc] init];
    } else if ([action isEqualToString:@"◀"]) {
        newDate = [self previousDate];
    } else if ([action isEqualToString:@"▶"]) {
        newDate = [self nextDate];
    }
    
    [newDate retain];
    [selectedDate release];
    selectedDate = newDate;
    
    [heading setStringValue:[intervalFormatter stringFromDate:selectedDate]];
}

- (NSDate*)previousDate
{   
    NSDateComponents *components = [[[NSDateComponents alloc] init] autorelease];
    
    if ([state isEqualToString:@"Year"]) {
        components.year = -1;
        return [[NSCalendar currentCalendar] dateByAddingComponents:components 
                                                             toDate:selectedDate
                                                            options:0];
    }
    
    if ([state isEqualToString:@"Month"]) {
        components.month = -1;
        return [[NSCalendar currentCalendar] dateByAddingComponents:components 
                                                             toDate:selectedDate
                                                            options:0];
    }
    
    components.day = -1;
    return [[NSCalendar currentCalendar] dateByAddingComponents:components 
                                                         toDate:selectedDate
                                                        options:0];
}

- (NSDate*)nextDate
{   
    NSDateComponents *components = [[[NSDateComponents alloc] init] autorelease];
    
    if ([state isEqualToString:@"Year"]) {
        components.year = 1;
        return [[NSCalendar currentCalendar] dateByAddingComponents:components 
                                             toDate:selectedDate
                                             options:0];
    }
    
    if ([state isEqualToString:@"Month"]) {
        components.month = 1;
        return [[NSCalendar currentCalendar] dateByAddingComponents:components 
                                             toDate:selectedDate
                                             options:0];
    }
    
    components.day = 1;
    return [[NSCalendar currentCalendar] dateByAddingComponents:components 
                                         toDate:selectedDate
                                         options:0];
}

- (void)applicationDidDeactivate:(NSNotification *)notification
{
    NSRunningApplication *app = [[notification userInfo] objectForKey:@"NSWorkspaceApplicationKey"];
    [self deactivateApplication:[app localizedName]];
}

- (void)systemDidSleep:(NSNotification *)notification
{
    if (lastWake == nil) {
        return;
    }
    
    NSDate *now = [NSDate date];
    [self logForType:@"system" name:@"OS X" start:lastWake end:now];
    [lastWake release];
}

/**
 * No need to log wake, that happens on shutdown
 */
- (void)systemDidWake:(NSNotification *)notification
{
    lastWake = [[NSDate alloc] init];
}

/**
    Returns the directory the application uses to store the Core Data store file. This code uses a directory named "timesuck" in the user's Library directory.
 */
- (NSURL *)applicationFilesDirectory {

    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *libraryURL = [[fileManager URLsForDirectory:NSLibraryDirectory inDomains:NSUserDomainMask] lastObject];
    return [libraryURL URLByAppendingPathComponent:@"timesuck"];
}

/**
    Creates if necessary and returns the managed object model for the application.
 */
- (NSManagedObjectModel *)managedObjectModel {
    if (__managedObjectModel) {
        return __managedObjectModel;
    }
	
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"timesuck" withExtension:@"momd"];
    __managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];    
    return __managedObjectModel;
}

/**
    Returns the persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it. (The directory for the store is created, if necessary.)
 */
- (NSPersistentStoreCoordinator *) persistentStoreCoordinator {
    if (__persistentStoreCoordinator) {
        return __persistentStoreCoordinator;
    }

    NSManagedObjectModel *mom = [self managedObjectModel];
    if (!mom) {
        NSLog(@"%@:%@ No model to generate a store from", [self class], NSStringFromSelector(_cmd));
        return nil;
    }

    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *applicationFilesDirectory = [self applicationFilesDirectory];
    NSError *error = nil;
    
    NSDictionary *properties = [applicationFilesDirectory resourceValuesForKeys:[NSArray arrayWithObject:NSURLIsDirectoryKey] error:&error];
        
    if (!properties) {
        BOOL ok = NO;
        if ([error code] == NSFileReadNoSuchFileError) {
            ok = [fileManager createDirectoryAtPath:[applicationFilesDirectory path] withIntermediateDirectories:YES attributes:nil error:&error];
        }
        if (!ok) {
            [[NSApplication sharedApplication] presentError:error];
            return nil;
        }
    }
    else {
        if ([[properties objectForKey:NSURLIsDirectoryKey] boolValue] != YES) {
            // Customize and localize this error.
            NSString *failureDescription = [NSString stringWithFormat:@"Expected a folder to store application data, found a file (%@).", [applicationFilesDirectory path]]; 
            
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            [dict setValue:failureDescription forKey:NSLocalizedDescriptionKey];
            error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:101 userInfo:dict];
            
            [[NSApplication sharedApplication] presentError:error];
            return nil;
        }
    }
    
    NSURL *url = [applicationFilesDirectory URLByAppendingPathComponent:@"timesuck.storedata"];
    __persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:mom];
    if (![__persistentStoreCoordinator addPersistentStoreWithType:NSXMLStoreType configuration:nil URL:url options:nil error:&error]) {
        [[NSApplication sharedApplication] presentError:error];
        [__persistentStoreCoordinator release], __persistentStoreCoordinator = nil;
        return nil;
    }

    return __persistentStoreCoordinator;
}

/**
    Returns the managed object context for the application (which is already
    bound to the persistent store coordinator for the application.) 
 */
- (NSManagedObjectContext *) managedObjectContext {
    if (__managedObjectContext) {
        return __managedObjectContext;
    }

    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setValue:@"Failed to initialize the store" forKey:NSLocalizedDescriptionKey];
        [dict setValue:@"There was an error building up the data file." forKey:NSLocalizedFailureReasonErrorKey];
        NSError *error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        [[NSApplication sharedApplication] presentError:error];
        return nil;
    }
    __managedObjectContext = [[NSManagedObjectContext alloc] init];
    [__managedObjectContext setPersistentStoreCoordinator:coordinator];

    return __managedObjectContext;
}

/**
    Returns the NSUndoManager for the application. In this case, the manager returned is that of the managed object context for the application.
 */
- (NSUndoManager *)windowWillReturnUndoManager:(NSWindow *)window {
    return [[self managedObjectContext] undoManager];
}

/**
    Performs the save action for the application, which is to send the save: message to the application's managed object context. Any encountered errors are presented to the user.
 */
- (IBAction) saveAction:(id)sender {
    NSError *error = nil;
    
    if (![[self managedObjectContext] commitEditing]) {
        NSLog(@"%@:%@ unable to commit editing before saving", [self class], NSStringFromSelector(_cmd));
    }

    if (![[self managedObjectContext] save:&error]) {
        [[NSApplication sharedApplication] presentError:error];
    }
}

- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender {
    
    // Write out current applications log
    for(id key in applications) {
        [self deactivateApplication:key];
    }
    
    // Write out system sleep
    [self systemDidSleep:nil];

    // Save changes in the application's managed object context before the application terminates.

    if (!__managedObjectContext) {
        return NSTerminateNow;
    }

    if (![[self managedObjectContext] commitEditing]) {
        NSLog(@"%@:%@ unable to commit editing to terminate", [self class], NSStringFromSelector(_cmd));
        return NSTerminateCancel;
    }

    if (![[self managedObjectContext] hasChanges]) {
        return NSTerminateNow;
    }

    NSError *error = nil;
    if (![[self managedObjectContext] save:&error]) {

        // Customize this code block to include application-specific recovery steps.              
        BOOL result = [sender presentError:error];
        if (result) {
            return NSTerminateCancel;
        }

        NSString *question = NSLocalizedString(@"Could not save changes while quitting. Quit anyway?", @"Quit without saves error question message");
        NSString *info = NSLocalizedString(@"Quitting now will lose any changes you have made since the last successful save", @"Quit without saves error question info");
        NSString *quitButton = NSLocalizedString(@"Quit anyway", @"Quit anyway button title");
        NSString *cancelButton = NSLocalizedString(@"Cancel", @"Cancel button title");
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:question];
        [alert setInformativeText:info];
        [alert addButtonWithTitle:quitButton];
        [alert addButtonWithTitle:cancelButton];

        NSInteger answer = [alert runModal];
        [alert release];
        alert = nil;
        
        if (answer == NSAlertAlternateReturn) {
            return NSTerminateCancel;
        }
    }

    return NSTerminateNow;
}

- (void)dealloc
{
    [__managedObjectContext release];
    [__persistentStoreCoordinator release];
    [__managedObjectModel release];
    [dateFormatter release];
    [intervalFormatter release];
    [lastWake release];
    [selectedDate release];
    [applications release];
    [db release];
    [super dealloc];
}

@end
