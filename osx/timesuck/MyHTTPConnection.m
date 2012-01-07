#import "MyHTTPConnection.h"
#import "HTTPMessage.h"
#import "HTTPDataResponse.h"
#import "DDNumber.h"
#import "HTTPLogging.h"
#import "timesuckAppDelegate.h"

// Log levels : off, error, warn, info, verbose
// Other flags: trace
static const int httpLogLevel = HTTP_LOG_LEVEL_WARN; // | HTTP_LOG_FLAG_TRACE;


/**
 * All we have to do is override appropriate methods in HTTPConnection.
**/

@implementation MyHTTPConnection

- (BOOL)supportsMethod:(NSString *)method atPath:(NSString *)path
{
	HTTPLogTrace();
	
	// Add support for POST
	
	if ([method isEqualToString:@"POST"])
	{
		if ([path isEqualToString:@"/log"])
		{
			// Let's be extra cautious, and make sure the upload isn't 5 gigs
			return true;
		}
	}
	
	return [super supportsMethod:method atPath:path];
}

- (BOOL)expectsRequestBodyFromMethod:(NSString *)method atPath:(NSString *)path
{
	HTTPLogTrace();
	
	// Inform HTTP server that we expect a body to accompany a POST request
	
	if([method isEqualToString:@"POST"])
		return YES;
	
	return [super expectsRequestBodyFromMethod:method atPath:path];
}

- (NSObject<HTTPResponse> *)httpResponseForMethod:(NSString *)method URI:(NSString *)path
{
	HTTPLogTrace();
	
	if ([method isEqualToString:@"POST"] && [path isEqualToString:@"/log"])
	{		
		NSString *postStr = nil;
		
		NSData *postData = [request body];
		if (postData)
		{
			postStr = [[[NSString alloc] initWithData:postData encoding:NSUTF8StringEncoding] autorelease];
		}
        
        NSMutableDictionary* data = [[NSMutableDictionary alloc] init];
        
        // Parse post body
        NSArray *lines = [postStr componentsSeparatedByString:@"&"];
        for(NSString *line in lines)
        {
            NSArray *lineElements = [line componentsSeparatedByString:@"="];
            NSString *value = [lineElements objectAtIndex:1];
            value = [value stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            [data setObject:value forKey:[lineElements objectAtIndex:0]];
        }
		
		HTTPLogVerbose(@"%@[%p]: postStr: %@", THIS_FILE, self, postStr);
		
		// Result will be of the form "answer=..."
				
		NSData *response = nil;
        
		if(![data objectForKey:@"domain"])
        {
			response = [@"{'error': true, 'message': 'No value provided for key domain'}" dataUsingEncoding:NSUTF8StringEncoding];
            return [[[HTTPDataResponse alloc] initWithData:response] autorelease];
		}
        
        if(![data objectForKey:@"start"])
        {
			response = [@"{'error': true, 'message': 'No value provided for key start'}" dataUsingEncoding:NSUTF8StringEncoding];
            return [[[HTTPDataResponse alloc] initWithData:response] autorelease];
		}
        
        if(![data objectForKey:@"end"])
        {
			response = [@"{'error': true, 'message': 'No value provided for key end'}" dataUsingEncoding:NSUTF8StringEncoding];
            return [[[HTTPDataResponse alloc] initWithData:response] autorelease];
		}
        
        timesuckAppDelegate *appDelegate = (timesuckAppDelegate *)[NSApp delegate];
                
        [appDelegate logForType:@"website" 
                          name:[data objectForKey:@"domain"]
                         start:[appDelegate parseDate:[data objectForKey:@"start"]]
                           end:[appDelegate parseDate:[data objectForKey:@"end"]]];
        
        response = [@"{'error': false, 'message': 'Success'}" dataUsingEncoding:NSUTF8StringEncoding];
        return [[[HTTPDataResponse alloc] initWithData:response] autorelease];
	}
	
	return [super httpResponseForMethod:method URI:path];
}

- (void)prepareForBodyWithSize:(UInt64)contentLength
{
	HTTPLogTrace();
	
	// If we supported large uploads,
	// we might use this method to create/open files, allocate memory, etc.
}

- (void)processBodyData:(NSData *)postDataChunk
{
	HTTPLogTrace();
	
	// Remember: In order to support LARGE POST uploads, the data is read in chunks.
	// This prevents a 50 MB upload from being stored in RAM.
	// The size of the chunks are limited by the POST_CHUNKSIZE definition.
	// Therefore, this method may be called multiple times for the same POST request.
	
	BOOL result = [request appendData:postDataChunk];
	if (!result)
	{
		HTTPLogError(@"%@[%p]: %@ - Couldn't append bytes!", THIS_FILE, self, THIS_METHOD);
	}
}

@end
