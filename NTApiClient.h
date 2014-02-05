//
//  NTApiClient.h
//
//  Copyright (c) 2011-2012 Ethan Nagel. All rights reserved.
//  See LICENSE for license details
//

#import <Foundation/Foundation.h>

#import "NTApiConst.h"
#import "NTApiError.h"
#import "NTApiArg.h"
#import "NTApiRequest.h"
#import "NTApiResponse.h"


@protocol NTApiClientDefaultProvider;


/**
 * A base class designed to make implementing JSON-based API clients simple and painless.
 */
@interface NTApiClient : NSObject

/**
 * The default base url for this request. On initialization, this is set to the value of the "baseUrl" default value. You may update
 * this after creating an instance or override the value on a per-request basis using the NTApiBaseUrlArg argument
 */
@property (strong, atomic)  NSString                *baseUrl;

/** The logging flags in effect for this instance. On initialization ths value is either set to the "logFlags" default of available,
 * or NTApiLogAll if not found.
 */
@property (assign, atomic)  NTApiLogType             logFlags;


/**
 * Sets a global default value. Values may be either a constant such as an NSString or any class that
 * implements NTApiClientDefaultProvider.
 * @param key the name of the default value
 * @param value value for the default. If value implements NTApiDefaultClientProvider, it will query this
 * class each time +getDefault: is called. Passing nil will cause the default to be removed.
 */
+(void)setDefault:(NSString *)key value:(id)value;

/**
 * returns the current value for a default.
 * @param key the name of the default value
 */
+(id)getDefault:(NSString *)key;


/**
 * Called each time a network request is started. May be overridden to show network activity.
 * @param request the request being started.
 * @param options options parsed out of the request.
 */
+(void)networkRequestStarted:(NSURLRequest *)request options:(NSDictionary *)options;               // overridable

/**
 * Called each time a network request is competed, regardless of succes or failure. May be overridden to show network activity
 * or collect API statistics.
 * @param request the request being completed.
 * @param options options parsed out of the request.
 * @param response the response data. Inspect error to see if the request was sucesful.
 */
+(void)networkRequestCompleted:(NSURLRequest *)request options:(NSDictionary *)options response:(NTApiResponse *)response;

/**
 * Called to parse JSON data out of the request. By default it will use either NSJSONSerilization (default) or SBJSON based on the
 * NTAPI_JSON_??? macro that is defined. This function may be overriden to implement cutom JSON parsing. Define NTAPI_JSON_CUSTOM
 * to avoid any external dependencies when overriding this method.
 */
+(id)parseJsonData:(NSData *)data error:(NSError **)error;              // overridable

/**
 * creates a new instance of NTApiClient.
 */
-(id)init;

/** 
 * Called when a log entry should be written if using NTAPI_LOG_INTERNAL. By default, this method outputs to NSLog. Implement this
 * method to add your own custom logging solution. Note that logging may be disabled all together by defining NTAPI_LOG_NONE and
 * set to use NTLog if NTAPI_LOG_NTLOG. In either case this method is not called.
 * @discussion If you are using Cocoapods and include the NTLog Cocoapod, NTApiClient will detect this and automatically use it for logging.
 */
-(void)writeLogWithType:(NTApiLogType)logType andFormat:(NSString *)format, ...;
                                            

/**
 * begin the indicated request, calling a responseHandler when completed. Optionally, may call upload and download proggress
 * handlers.
 * @param command The "command" verb for this request. This is appended to the baseUrl to get the url for the request.
 * @param args An array of NTApiArg's to be parsed for this request. NTAPIArgs are used to add URL values, form parameters, 
 * and multi-part data. Additionally, NTApiArgs can set options such as the threading model to use for the response or the 
 * timeout of the request.
 * @param uploadProgressHandler optional block to be called as upload progress continues. Useful to display progress to the
 * user.
 * @param downloadProgressHandler optional block to be called as download progress continues. Useful to display progress to the
 * user.
 * @param responseHandler block to be called when the request is completed. This method is called on success or failure. Inspect
 * response.error to determine if an error occured. This method is always called if beginRequest returns non-nil.
 * By default, the responseHandler is called on the main thread, but this may be overridden by adding an arg of type
 * [NTApiOptionArg optionRequestHandlerThread:].
 * May not be nil.
 * @return an NTAPiRequest that may be used to cancel a pending request.
 */
-(NTApiRequest *)beginRequest:(NSString *)command
               args:(NSArray *)args 
    responseHandler:(void (^)(NTApiResponse *response))responseHandler
uploadProgressHandler:(void (^)(int bytesSent, int totalBytes))uploadProgressHandler
downloadProgressHandler:(void (^)(int bytesReceived, int totalBytes))downloadProgressHandler;

/**
 * begin the indicated request, calling a responseHandler when completed.
 * @discussion
 * @param command The "command" verb for this request. This is appended to the baseUrl to get the url for the request.
 * @param args An array of NTApiArg's to be parsed for this request. NTAPIArgs are used to add URL values, form parameters,
 * and multi-part data. Additionally, NTApiArgs can set options such as the threading model to use for the response or the
 * timeout of the request.
 * @param responseHandler block to be called when the request is completed. This method is called on success or failure. Inspect
 * response.error to determine if an error occured. This method is always called if beginRequest returns non-nil. May not be nil.
 * By default, the responseHandler is called on the main thread, but this may be overridden by adding an arg of type 
 * [NTApiOptionArg optionRequestHandlerThread:].
 * May not be nil.
 * @return an NTAPiRequest that may be used to cancel a pending request.
 */
-(NTApiRequest *)beginRequest:(NSString *)command
               args:(NSArray *)args 
    responseHandler:(void (^)(NTApiResponse *response))responseHandler;

@end


/**
 * Implement this protocol to return dynamic defaults to NTApiClients. Useful for things that change on a pre client basis
 * but are generally the same for a group of requests, such as a session ID. To use, create a class that implements this class,
 * returning values from getApiClientDefault. Then, register the class for any defaults you want returned using [NTApiClient setDefault:value:]
 */
@protocol NTApiClientDefaultProvider <NSObject>

/**
 * Returns a default value (if provided.)
 * @param key the default name.
 * @return the value of the default or nil if none.
 */
-(id)getApiClientDefault:(NSString *)key;

@end

