//
//  NTApiClient.m
//
//  Copyright (c) 2011-2012 Ethan Nagel. All rights reserved.
//  See LICENSE for license details
//

#import "NTApiClient.h"
#import "NTApiRequestBuilder.h"
#import "NTApiRequestProcessor.h"


// ARC is required

#if !__has_feature(objc_arc)
#   error ARC is required for NTApiClient
#endif


#pragma mark Log Configuration

// logging system selection
//#define NTAPI_LOG_NONE
//#define NTAPI_LOG_INTERNAL
//#define NTAPI_LOG_NTLOG

// Log enable/disable
//#define NTAPI_LOG_DISABLE_DEBUG            // Logs POST data and headers
//#define NTAPI_LOG_DISABLE_INFO             // Logs Request URL & parsed response (truncated)
//#define NTAPI_LOG_DISABLE_WARN             // not currently used
//#define NTAPI_LOG_DISABLE_ERROR            // Logs API errors

#if !defined(NTAPI_LOG_NONE) && !defined(NTAPI_LOG_INTERNAL) && !defined(NTAPI_LOG_NTLOG)
#   warning No Log option is defined (NTAPI_LOG_NONE, NTAPI_LOG_INTERNAL or NTAPI_LOG_NTLOG) so default of NTAPI_LOG_INTERNAL will be used
#   define NTAPI_LOG_INTERNAL
#endif


#if defined(NTAPI_LOG_NONE)
#   define LogDebug(format, ...)   
#   define LogInfo(format, ...)    
#   define LogWarn(format, ...)    
#   define LogError(format, ...)   

#elif defined(NTAPI_LOG_INTERNAL)
#   define LogDebug(format, ...)   [self writeLogWithType:NTApiLogTypeDebug andFormat:format, ##__VA_ARGS__]
#   define LogInfo(format, ...)    [self writeLogWithType:NTApiLogTypeInfo andFormat:format, ##__VA_ARGS__]
#   define LogWarn(format, ...)    [self writeLogWithType:NTApiLogTypeWarn andFormat:format, ##__VA_ARGS__]
#   define LogError(format, ...)   [self writeLogWithType:NTApiLogTypeError andFormat:format, ##__VA_ARGS__]

#elif defined(NTAPI_LOG_NTLOG)
#   import "NTLog.h"
#   define LogDebug(format, ...)   NTLogDebug(format, ##__VA_ARGS__)
#   define LogInfo(format, ...)    NTLog(format, ##__VA_ARGS__)
#   define LogWarn(format, ...)    NTLogWarn(format, ##__VA_ARGS__)
#   define LogError(format, ...)   NTLogError(format, ##__VA_ARGS__)

#endif


#ifdef NTAPI_LOG_DISABLE_DEBUG
#   undef LogDebug
#   define LogDebug(format, ...)   
#endif

#ifdef NTAPI_LOG_DISABLE_INFO
#   undef LogInfo
#   define LogInfo(format, ...)   
#endif

#ifdef NTAPI_LOG_DISABLE_WARN
#   undef LogWarn
#   define LogWarn(format, ...)   
#endif

#ifdef NTAPI_LOG_DISABLE_ERROR
#   undef LogError
#   define LogError(format, ...)   
#endif


#pragma mark JSON library configuration

// JSON Deserializer selection:
//#define NTAPI_JSON_CUSTOM     // You may override +parseJsonData:error: to use any parser you like
//#define NTAPI_JSON_NSJSON     // Use built-in NSJSONSerialization class (iOS 5.0+ only) -- DEFAULT!
//#define NTAPI_JSON_SBJSON     // Use SBJSON library, you must include it yourself.

#if !defined(NTAPI_JSON_CUSTOM) && !defined(NTAPI_JSON_NSJSON) && !defined(NTAPI_JSON_SBJSON)
#   warning No JSON library is defined (NTAPI_JSON_CUSTOM, NTAPI_JSON_NSJSON or NTAPI_JSON_SBJSON) so default of NTAPI_JSON_NSJSON will be used
#   define NTAPI_JSON_NSJSON
#endif


#ifdef NTAPI_JSON_SBJSON
#   import "SBJson.h"
#endif


@interface NTApiClient ()
{
}


+(NSThread *)requestThread;

+(void)requestThreadMain;

@end


@implementation NTApiClient


static NSMutableDictionary  *sDefaults = nil;

static NSThread             *sRequestThread = nil;
static NSRunLoop            *sRequestRunLoop = nil;
static NSPort               *sRequestRunLoopPort = nil;
static NSOperationQueue     *sResponseQueue = nil;


-(void)writeLogWithType:(NTApiLogType)logType andFormat:(NSString *)format, ...
{
    // override this to provide your own logging...
    
    va_list args;
    va_start(args, format);
    
    NSString *message = [[NSString alloc] initWithFormat:format arguments:args];
    
    va_end(args);
    
    if ( logType != NTApiLogTypeInfo )
        NSLog(@"(API) %@: %@", logType, message);
    else 
        NSLog(@"(API) %@", message);
}


+(void)setDefault:(NSString *)key value:(id)value
{
    if ( !sDefaults )
        sDefaults = [NSMutableDictionary new];

    [sDefaults setObject:(value) ? value : [NSNull null] forKey:key];
}


+(id)getDefault:(NSString *)key
{
    if (!sDefaults )
        return nil;
    
    id value = [sDefaults objectForKey:key];
    
    if ( value && [value conformsToProtocol:@protocol(NTApiClientDefaultProvider)] )
        value = [value getApiClientDefault:key];
    
    if ( value == [NSNull null] )
        value = nil;
    
    return value;
}


+(NSThread *)requestThread
{
    @synchronized(self)
    {
        if ( !sRequestThread )
        {
            sRequestThread = [[NSThread alloc] initWithTarget:self selector:@selector(requestThreadMain) object:nil];
            
            sRequestThread.name = @"NTApiRequestThread";
            
            [sRequestThread start];
        }
        
        return sRequestThread;
    }
}


+(NSOperationQueue *)responseQueue
{
    @synchronized(self)
    {
        if ( !sResponseQueue )
        {
            sResponseQueue = [[NSOperationQueue alloc] init];
        }
        
        return sResponseQueue;
    }
}

                              
+(void)requestThreadMain
{
    // First, we need to prepare our run loop...
    
    sRequestRunLoop = [NSRunLoop currentRunLoop];
    
    sRequestRunLoopPort = [NSPort port];
    [sRequestRunLoop addPort:sRequestRunLoopPort forMode:NSDefaultRunLoopMode];
    
    [sRequestRunLoop run];
    
    // This will continue running until mPort is removed from the Run Loop.
    
    @synchronized(self)
    {
        // We are now done with these, so we can clean up.
        
        sRequestRunLoopPort = nil;
        sRequestRunLoop = nil;
        sRequestThread = nil;   // will cause 
    }
}
    

+(void)networkRequestStarted:(NSURLRequest *)request options:(NSDictionary *)options
{
    // override to do global things like start/stop network activity
}


+(void)networkRequestCompleted:(NSURLRequest *)request options:(NSDictionary *)options response:(NTApiResponse *)response
{
    // override to do global things like start/stop network activity
}


+(id)parseJsonData:(NSData *)data error:(NSError *__autoreleasing *)error
{
    
#if defined(NTAPI_JSON_CUSTOM)
    
    @throw [NSException exceptionWithName:@"MustOverride" reason:@"parseJsonData must be overridden" userInfo:nil];
    
#elif defined(NTAPI_JSON_NSJSON)        // iOS 5+
    
    return [NSJSONSerialization JSONObjectWithData:data options:0 error:error];
    
#elif defined(NTAPI_JSON_SBJSON)
    
    SBJsonParser *parser = [[SBJsonParser alloc] init];
    
    return [parser objectWithData:data error:&error];
    
#else
    
#   error NTAPI_JSON_??? not defined
    
#endif
    
}



@synthesize baseUrl = mBaseUrl;


-(id)init
{
    if ( (self=[super init]) )
    {
        self.baseUrl = [NTApiClient getDefault:@"baseUrl"];
    }
    
    return self;
}


-(NSArray *)createArgsForCommand:(NSString *)command withArgs:(NSArray *)inputArgs
{
    NSMutableArray *allArgs = [NSMutableArray new];
    
    // Add our args first (may be overridden by later items)...
    
    [allArgs addObject:[NTApiBaseUrlArg argWithBaseUrl:[NSString stringWithFormat:@"%@/%@", self.baseUrl, command]]];
    
    // Main Thread is the default for handlers...
    
    [allArgs addObject:[NTApiOptionArg optionRequestHandlerThread:NTApiThreadTypeMain]];
    [allArgs addObject:[NTApiOptionArg optionUploadHandlerThread:NTApiThreadTypeMain]];
    [allArgs addObject:[NTApiOptionArg optionDownloadHandlerThread:NTApiThreadTypeMain]];
    
    // now add request-specific args...
    
    if ( inputArgs )
        [allArgs addObjectsFromArray:inputArgs];
    
    return allArgs;
}


-(BOOL)isMultitaskingSupported
{
    UIDevice *device = [UIDevice currentDevice];
    
    return ( [device respondsToSelector:@selector(isMultitaskingSupported)] && device.multitaskingSupported );
}


-(NTApiRequest *)beginRequest:(NSString *)command
               args:(NSArray *)args 
    responseHandler:(void (^)(NTApiResponse *response))responseHandler
uploadProgressHandler:(void (^)(int bytesSent, int totalBytes))uploadProgressHandler
downloadProgressHandler:(void (^)(int bytesReceived, int totalBytes))downloadProgressHandler;
{
    // Note: This code is a little "blocks crazy", might be worth refactoring into a couple methods in the 
    // RequestProcessor...
    
    // Process our arguments and create a request...
    
    NSArray *allArgs = [self createArgsForCommand:command withArgs:args];
    
    NTApiRequestBuilder *builder = [[NTApiRequestBuilder alloc] initWithArgs:allArgs];
    
    NSMutableURLRequest *request = [builder createRequest];
    
    NSDictionary *options = builder.options;
    
    // BG Tasks support...
    
    if ( [self isMultitaskingSupported] )
    {
        BOOL responseOnMainThread = [options objectForKey:NTApiOptionResponseHandlerThreadType] == NTApiThreadTypeMain;
        
        UIBackgroundTaskIdentifier taskId = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:
        ^{
            // Handle notification if we are running in the background and being killed...
            
            NTApiError *error = [NTApiError errorWithCode:NTApiErrorCodeError message:@"Background task timed out"];
            
            LogError(@"Background task timed out!");
            
            if ( responseOnMainThread )
            {
                dispatch_async(dispatch_get_main_queue(), ^
                { 
                    responseHandler([NTApiResponse responseWithError:error]);
                });
               
            }
            
            else
                responseHandler([NTApiResponse responseWithError:error]);
        }];
        
//        LogDebug(@"Starting background task: %d", taskId);
        
        // Wrap our response so the background task is stopped...
        
        void (^temp)(NTApiResponse *response) = ^(NTApiResponse *response)
        {
            responseHandler(response);
//            LogDebug(@"Completing background task: %d", taskId);
            [[UIApplication sharedApplication] endBackgroundTask:taskId];
        };
       
        responseHandler = temp;
    }
        
    // Create wrappers for any blocks that need to run on the main thread...
    
    if ( [options objectForKey:NTApiOptionResponseHandlerThreadType] == NTApiThreadTypeMain )
    {
        void (^temp)(NTApiResponse *response) = ^(NTApiResponse *response)
        {
            dispatch_async(dispatch_get_main_queue(), ^
            { 
                responseHandler(response);
           });
        };
        
        responseHandler = temp;
    }
    
    if ( uploadProgressHandler && ([options objectForKey:NTApiOptionUploadHandlerThreadType] == NTApiThreadTypeMain) )
    {
        void (^temp)(int bytesSent, int totalBytes) = ^(int bytesSent, int totalBytes)
        {
            dispatch_async(dispatch_get_main_queue(), ^{ uploadProgressHandler(bytesSent, totalBytes); });
        };
        
        uploadProgressHandler = temp;
    }
    
    if ( downloadProgressHandler && ([options objectForKey:NTApiOptionDownloadHandlerThreadType] == NTApiThreadTypeMain) )
    {
        void (^temp)(int bytesReceived, int totalBytes) = ^(int bytesReceived, int totalBytes)
        {
            dispatch_async(dispatch_get_main_queue(), ^{ downloadProgressHandler(bytesReceived, totalBytes); });
        };
        
        downloadProgressHandler = temp;
    }
    
    // If the request builder failed, then we can error out...
    
    if ( !request )
    {
        LogError(@"%@ = ERROR: %@", command, builder.error);
        responseHandler([NTApiResponse responseWithError:builder.error]);

        return nil;
    }
    
    // output some useful debugging info..
    
    LogInfo(@"%@ %@", [request HTTPMethod], [request URL]);
/*    
    for(NTApiArg *arg in allArgs)
        LogDebug(@"    %@", [arg description]);
*/    
    for(NSString *key in request.allHTTPHeaderFields)
        LogDebug(@"    Header %@ = %@" , key, [request.allHTTPHeaderFields objectForKey:key]);
    
    if ( [[request HTTPMethod] isEqualToString:@"POST"] )
    {
        LogDebug(@"< < < < < < < < < < < < < < < < < < < < <");
        LogDebug(@"%.*s", [[request HTTPBody] length], [[request HTTPBody] bytes]);
        LogDebug(@"< < < < < < < < < < < < < < < < < < < < <");
    }
    
    [[self class] networkRequestStarted:request options:options];
    
     NTApiRequestProcessor *requestProcessor = [[NTApiRequestProcessor alloc] initWithURLRequest:request];
    
    requestProcessor.responseHandler = ^(NTApiResponse *response)
    {
        [[self class] networkRequestCompleted:request options:options response:response];
        
        // Enqueue our response processing...
        
        [[NTApiClient responseQueue] addOperationWithBlock:^
        {
            if ( response.error )
            {
                LogError(@"%@ = (%dms) ERROR: %@", command, response.elapsedMS, response.error);

                responseHandler(response);

                return ;
            }
            
            if ( response.httpStatusCode < 299 )
            {
                if ( response.httpStatusCode != 200 )
                    LogWarn(@"Http Status Code: %d", response.httpStatusCode);
            }
            
            else if ( ![options objectForKey:NTApiOptionIgnoreHTTPErrorCodes]) // http error
            {
                LogError(@"Http Error Code: %d", response.httpStatusCode);
                response.error = [NTApiError errorWithHttpErrorCode:response.httpStatusCode];
            }
                        
            if ( [options objectForKey:NTApiOptionRawData] )
            {
                if ( response.error )
                    LogError(@"%@ = (%dms) ERROR %@, rawData[%d bytes]", command, response.elapsedMS, response.error, response.data.length);
                else
                    LogInfo(@"%@ = (%dms) rawData[%d bytes]", command, response.elapsedMS, response.data.length);
            }
            
            else // parse as JSON
            {
                NSError *error = nil;
                
                response.json = [self.class parseJsonData:response.data error:&error];
                
                // Attempt to recover from errors/warnings outputted by server...
                
                if ( !response.json )
                {
                  NSString *text = [[NSString alloc] initWithData:response.data encoding:NSUTF8StringEncoding];
                    
                    // Try to find the start of the JSON data...
                    
                    NSRange range = [text rangeOfString:@"{"];
                    
                    if ( range.location != NSNotFound )
                    {
                        NSString *prefixText = [text substringToIndex:range.location];
                        text = [text substringFromIndex:range.location];
                        
                        LogWarn(@"Prefix text found: %@", prefixText);
                        
                        response.prefixText = prefixText;
                        
                        error = nil;
                        response.json = [self.class parseJsonData:[text dataUsingEncoding:NSUTF8StringEncoding] error:&error];
                    }
                }
                
                if ( !response.json )
                {
                    if ( error )
                        LogError(@"JSON parser error - %@", error);
                    LogError(@"> > > > > > > > > > > > > > > > > > > > >");
                    LogError(@"%.*s", response.data.length, response.data.bytes);
                    LogError(@"> > > > > > > > > > > > > > > > > > > > >");
                    
                    response.error = [NTApiError errorWithCode:NTApiErrorCodeInvalidJson message:@"Unable to Parse JSON response"];
                }
                
                if ( response.error )
                    LogInfo(@"%@ = (%dms) ERROR %@, %@", command, response.elapsedMS, response.error, response.json);
                else
                    LogInfo(@"%@ = (%dms) %@", command, response.elapsedMS, response.json);
            }
            
            // execute the responsehandler on the appropriate thread...
            
            responseHandler(response);
        }];
        
    };
    
    requestProcessor.uploadProgressHandler = uploadProgressHandler;
    requestProcessor.downloadProgressHandler = downloadProgressHandler;
    
    // Dispatch the request to the request thread...
    
    [requestProcessor performSelector:@selector(start) onThread:[NTApiClient requestThread] withObject:nil waitUntilDone:NO];
    
    return [[NTApiRequest alloc] initWithRequestProcessor:requestProcessor];
}


-(NTApiRequest *)beginRequest:(NSString *)command
               args:(NSArray *)args 
    responseHandler:(void (^)(NTApiResponse *response))responseHandler
{
    return [self beginRequest:command args:args responseHandler:responseHandler uploadProgressHandler:nil downloadProgressHandler:nil];
}


@end
