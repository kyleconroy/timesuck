//
//  TimesuckLogFormatter.m
//  timesuck
//
//  Created by Kyle Conroy on 8/31/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "TimesuckLogFormatter.h"

@implementation TimesuckLogFormatter

- (NSString *)formatLogMessage:(DDLogMessage *)logMessage
{    
    return logMessage->logMsg;
}

- (void)dealloc
{
    [super dealloc];
}

@end
