//
//  NTApiClient.m
//
//  Copyright (c) 2011-2012 Ethan Nagel. All rights reserved.
//  See LICENSE for license details
//

#import "NTApiClient.h"

#import "Logger.h"
#import "SBJson.h"

#import "NSUrlConnection+NTCompletionHandler.h"
#import "NetworkActivityManager.h"


NSString *NTApiOptionRawData = @"NTApiOptionRawData";

NSString *NTApiHeaderContentType = @"Content-Type";
NSString *NTApiHeaderAuthorization = @"Authorization";

NTApiLogType NTApiLogTypeDebug = @"Debug";
NTApiLogType NTApiLogTypeInfo = @"Info";
NTApiLogType NTApiLogTypeWarn = @"Warn";
NTApiLogType NTApiLogTypeError = @"Error";



#pragma mark Log Configuration

// logging system selection
//#define NTAPI_LOG_NONE
//#define NTAPI_LOG_INTERNAL
//#define NTAPI_LOG_LLOG

// Log enable/disable
//#define NTAPI_LOG_DISABLE_DEBUG            // Logs POST data and headers
//#define NTAPI_LOG_DISABLE_INFO             // Logs Request URL & parsed response (truncated)
//#define NTAPI_LOG_DISABLE_WARN             // not currently used
//#define NTAPI_LOG_DISABLE_ERROR            // Logs API errors

#if !defined(NTAPI_LOG_NONE) && !defined(NTAPI_LOG_INTERNAL) && !defined(NTAPI_LOG_LLOG)
#   warning No Log option is defined (NTAPI_LOG_NONE, NTAPI_LOG_INTERNAL or NTAPI_LOG_LLOG) so default of NTAPI_LOG_INTERNAL will be used
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

#elif defined(NTAPI_LOG_LLOG)
#   import "Logger.h"
#   define LogDebug(format, ...)   LDebug(format, ##__VA_ARGS__)
#   define LogInfo(format, ...)    LLog(format, ##__VA_ARGS__)
#   define LogWarn(format, ...)    LWarn(format, ##__VA_ARGS__)
#   define LogError(format, ...)   LError(format, ##__VA_ARGS__)

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


@implementation NTApiClient


static NSMutableDictionary *sDefaults = nil;
static Reachability *sReachability = nil;


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
                    
    [sDefaults setObject:value forKey:key];
}


+(id)getDefault:(NSString *)key
{
    if (!sDefaults )
        return nil;
    
    id value = [sDefaults objectForKey:key];
    
    if ( value && [value conformsToProtocol:@protocol(NTApiClientDefaultProvider)] )
        value = [value getApiClientDefault:key];
    
    return value;
}


+(Reachability *)reachability
{
    if ( !sReachability )
    {
        sReachability = [Reachability reachabilityForInternetConnection]; 
    }
    
    return sReachability;
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
    
    // now add request-specific args...
    
    if ( inputArgs )
        [allArgs addObjectsFromArray:inputArgs];
    
    return allArgs;
}


-(void)beginRequest:(NSString *)command 
               args:(NSArray *)args 
    responseHandler:(void (^)(NSDictionary *response, NTApiError *error))responseHandler
uploadProgressHandler:(void (^)(int bytesSent, int totalBytes))uploadProgressHandler
downloadProgressHandler:(void (^)(int bytesReceived, int totalBytes))downloadProgressHandler;
{
    // Process our arguments and create a request...
    
    NSArray *allArgs = [self createArgsForCommand:command withArgs:args];
    
    NTApiRequestBuilder *builder = [[NTApiRequestBuilder alloc] initWithArgs:allArgs];
    
    NSMutableURLRequest *request = [builder createRequest];
    
    if ( !request )
    {
        LogError(@"%@ = ERROR: %@", command, builder.error);
        responseHandler(nil, builder.error);
        return ;
    }
    
    NSDictionary *options = builder.options;
    
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
    
    [NetworkActivityManager beginActivity];
    
    // For now, this must be on the main thread...
    
    dispatch_async(dispatch_get_main_queue(), 
    ^{
        [NSURLConnection sendAsynchronousRequest:request shouldCacheResponse:NO withCompletionHandler:^(NSData *data, NSURLResponse *response, NSError *error) 
         {
             [NetworkActivityManager endActivity];
             
             if ( error != nil )
             {
                 LogError(@"%@ = ERROR: %@", command, error);
                 responseHandler(nil, [NTApiError errorWithNSError:error]);
                 return ;
             }
             
             NSDictionary *json = nil;
             
             if ( [options objectForKey:NTApiOptionRawData] )
             {
                 json = [NSDictionary dictionaryWithObject:data forKey:@"rawData"];
                 LogInfo(@"%@ = rawData[%d bytes]", command, data.length);
             }
             
             else // parse as JSON
             {
                 SBJsonParser *parser = [[SBJsonParser alloc] init];
                 
                 json = [parser objectWithString:[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]];
                 
                 // Attempt to recover from errors/warnings outputted by PHP...
                 
                 if ( !json )
                 {
                     NSString *text = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                     
                     // if it looks like a PHP error message...
                     
                     if ( [text hasPrefix:@"<br/>"] )
                     {
                         // Try to find the start of the JSON data...
                         
                         NSRange range = [text rangeOfString:@"{"];
                         
                         if ( range.location != NSNotFound )
                         {
                             NSString *phpMessages = [text substringToIndex:range.location];
                             text = [text substringFromIndex:range.location];
                             
                             LogError(@"Found PHP Messages: %@", phpMessages);
                             
                             json = [parser objectWithString:text];
                             
                             if ( json )
                             {
                                 NSMutableDictionary *temp = [NSMutableDictionary dictionaryWithDictionary:json];
                                 
                                 [temp setObject:phpMessages forKey:@"php_messages"];
                                 
                                 json = temp;
                             }
                         }
                     }
                 }
                 
                 if ( !json )
                 {
                     //LogError(@"%@ = ERROR: Unable to parse JSON Response: %@", command, parser.error);
                     LogError(@"%@ = ERROR: Unable to parse JSON Response", command);
                     LogError(@"> > > > > > > > > > > > > > > > > > > > >");
                     LogError(@"%.*s", [data length], [data bytes]);
                     LogError(@"> > > > > > > > > > > > > > > > > > > > >");
                     
                     responseHandler(nil, [NTApiError errorWithCode:NTApiErrorCodeInvalidJson message:@"Unable to Parse JSON response"]);
                     return ;
                 }
                 
                 LogInfo(@"%@ = %@", command, json);
             }
             
             responseHandler(json, nil);
         }
         uploadProgressHandler:uploadProgressHandler
         downloadProgressHandler:downloadProgressHandler];    
       
    });
}


-(void)beginRequest:(NSString *)command 
               args:(NSArray *)args 
    responseHandler:(void (^)(NSDictionary *, NTApiError *))responseHandler
{
    [self beginRequest:command args:args responseHandler:responseHandler uploadProgressHandler:nil downloadProgressHandler:nil];
}


@end
