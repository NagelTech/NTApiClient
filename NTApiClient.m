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


#pragma mark Log Configuration

// Log enable/disable
#define LOG_ENABLE
//#define LOG_ENABLE_DEBUG            // Logs POST data and headers
#define LOG_ENABLE_INFO             // Logs Request URL & parsed response (truncated)
#define LOG_ENABLE_WARN             // not currently used
#define LOG_ENABLE_ERROR            // Logs API errors

// logging system selection
#define LOG_LLOG
//#define LOG_NSLOG


#if !defined(LOG_ENABLE)
#   define LogDebug(format, ...)   
#   define LogInfo(format, ...)    
#   define LogWarn(format, ...)    
#   define LogError(format, ...)   

#elif defined(LOG_NSLOG)
#   define LogDebug(format, ...)   NSLog(@"Debug: " format, ##__VA_ARGS__)
#   define LogInfo(format, ...)    NSLog(format, ##__VA_ARGS__)
#   define LogWarn(format, ...)    NSLog(@"Warning: " format, ##__VA_ARGS__)
#   define LogError(format, ...)   NSLog(@"Error: " format, ##__VA_ARGS__)

#elif defined(LOG_LLOG)
#   import "Logger.h"
#   define LogDebug(format, ...)   LDebug(format, ##__VA_ARGS__)
#   define LogInfo(format, ...)    LLog(format, ##__VA_ARGS__)
#   define LogWarn(format, ...)    LWarn(format, ##__VA_ARGS__)
#   define LogError(format, ...)   LError(format, ##__VA_ARGS__)

#endif


#ifndef LOG_ENABLE_DEBUG
#   undef LogDebug
#   define LogDebug(format, ...)   
#endif

#ifndef LOG_ENABLE_INFO
#   undef LogInfo
#   define LogInfo(format, ...)   
#endif

#ifndef LOG_ENABLE_WARN
#   undef LogWarn
#   define LogWarn(format, ...)   
#endif

#ifndef LOG_ENABLE_ERROR
#   undef LogError
#   define LogError(format, ...)   
#endif


@implementation NTApiClient


static NSMutableDictionary *sDefaults = nil;
static Reachability *sReachability = nil;


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
