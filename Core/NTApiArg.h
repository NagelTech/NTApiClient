//
//  NTApiArg.h
//
//  Copyright (c) 2011-2012 Ethan Nagel. All rights reserved.
//  See LICENSE for license details
//

#import <Foundation/Foundation.h>

#import "NTApiConst.h"

@class NTApiRequestBuilder;


/**
 * Base class for NT API arguments. Args capture the values used to consrtuct the URL Request
 * such as URL args or form args for a POST. They also control options or how the request is
 * processed such as the timeout or threading model.
 */
@interface NTApiArg : NSObject

/**
 * the name of this argument.
 */
@property (strong, nonatomic)        NSString       *name;

/**
 * Used internally to apply this argument to a Request Builder when creating a request.
 */
-(BOOL)applyArgToBuilder:(NTApiRequestBuilder *)builder;

/**
 * returns a printable representation of the argument. Useful when debugging.
 */
-(NSString *)description;


-(id)initWithName:(NSString *)name;

@end


/**
 * Represents an argument passed as part of the URL. If the value passed is nil, the arg is suppressed.
 */
@interface NTApiUrlArg : NTApiArg

/**
 * The value of the arg
 */
@property (strong, nonatomic)        NSString       *value;

/**
 * Creates a new instance of the URL arg. If value is nil the arg is suppressed.
 * @param name the URL arg name
 * @param value the value of the arg
 * @return a new NTApiUrlArg instance
 */
-(id)initWithName:(NSString *)name value:(NSString *)value;

/**
 * Creates a new instance of the URL arg. If value is nil the arg is suppressed.
 * @param name the URL arg name
 * @param stringValue the value of the arg
 * @return a new NTApiUrlArg instance
 */
+(NTApiUrlArg *)argWithName:(NSString *)name string:(NSString *)stringValue;

/**
 * Creates a new instance of the URL arg with the integer value. This arg cannot be suppressed.
 * @param name the URL arg name
 * @param intValue the value of the arg
 * @return a new NTApiUrlArg instance
 */
+(NTApiUrlArg *)argWithName:(NSString *)name intValue:(int)intValue;

-(BOOL)applyArgToBuilder:(NTApiRequestBuilder *)builder;
-(NSString *)description;

@end


/**
 * Represents an argument passed as part of the URL. If the value passed is nil, the arg is suppressed. By default, 
 * adding a non-nil form arg will cause the request to be a POST with the form values.
 */
@interface NTApiFormArg : NTApiArg

/**
 * The value of the arg
 */
@property (strong, nonatomic)        NSString       *value;

/**
 * Creates a new instance of the form arg. If value is nil the arg is suppressed.
 * @param name the form arg name
 * @param value the value of the arg
 * @return a new NTApiFormArg instance
 */
-(id)initWithName:(NSString *)name value:(NSString *)value;

/**
 * Creates a new instance of the form arg. If stringValue is nil the arg is suppressed.
 * @param name the form arg name
 * @param stringValue the value of the arg
 * @return a new NTApiFormArg instance
 */
+(NTApiFormArg *)argWithName:(NSString *)name string:(NSString *)stringValue;

/**
 * Creates a new instance of the form arg with the integer value. This arg cannot be suppressed.
 * @param name the form arg name
 * @param intValue the value of the arg
 * @return a new NTApiFormArg instance
 */
+(NTApiFormArg *)argWithName:(NSString *)name intValue:(int)intValue;

-(BOOL)applyArgToBuilder:(NTApiRequestBuilder *)builder;
-(NSString *)description;

@end


/**
 * Represents an argument passed multi-part encoded form data. If the value passed is nil, the arg is suppressed. By default,
 * adding a non-nil multipard arg will cause the request to be a POST with the form values.
 */
@interface NTApiMultipartArg : NTApiArg

/**
 * The multipart value if a string
 */
@property (strong, nonatomic)        NSString       *value;

/**
 * The multipart value if binary data
 */
@property (strong, nonatomic)        NSData         *dataValue;

/**
 * The file extension to send the server as a hint if binary data is being passed.
 */
@property (strong, nonatomic)        NSString       *fileExtension;

/**
 * Creates a new instance of the multipart arg. If value is nil the arg is suppressed.
 * @param name the form arg name
 * @param vaklue the value of the arg
 * @return a new NTApiMultipartArg instance
 */
-(id)initWithName:(NSString *)name value:(NSString *)value;

/**
 * Creates a new instance of the multipart arg. If dataValue is nil the arg is suppressed.
 * @param name the form arg name
 * @param dataValue the value of the arg
 * @param fileExtension a file extesion "hint" for the server.
 * @return a new NTApiMultipartArg instance
 */
-(id)initWithName:(NSString *)name data:(NSData *)dataValue fileExtension:(NSString *)fileExtension;

/**
 * Creates a new instance of the multipart arg. If value is nil the arg is suppressed.
 * @param name the form arg name
 * @param stringValue the value of the arg
 * @return a new NTApiMultipartArg instance
 */
+(NTApiMultipartArg *)argWithName:(NSString *)name string:(NSString *)stringValue;

/**
 * Creates a new instance of the multipart arg with an integer value. This arg cannot be suppressed.
 * @param name the form arg name
 * @param intValue the value of the arg
 * @return a new NTApiMultipartArg instance
 */
+(NTApiMultipartArg *)argWithName:(NSString *)name intValue:(int)intValue;

/**
 * Creates a new instance of the multipart arg. If dataValue is nil the arg is suppressed.
 * @param name the form arg name
 * @param dataValue the value of the arg
 * @param fileExtension a file extesion "hint" for the server.
 * @return a new NTApiMultipartArg instance
 */
+(NTApiMultipartArg *)argWithName:(NSString *)name data:(NSData *)dataValue fileExtension:(NSString *)fileExtension;


-(BOOL)applyArgToBuilder:(NTApiRequestBuilder *)builder;
-(NSString *)description;

@end


/**
 * Sends the passed NSData as the body of the request with no further processing.
 */
@interface NTApiRawDataArg : NTApiArg

/**
 * The data to be passed as the request body.
 */
@property (strong, nonatomic)        NSData         *rawData;

/**
 * The content type for the response data.
 */
@property (strong, nonatomic)        NSString       *contentType;

/**
 * Creates a new instance with the passed data and content type.
 * @param rawData the NSData
 * @patam contentType the content type to return. 
 * @return a new instance of NTApiRawDataArg
 */
-(id)initWithData:(NSData *)rawData contentType:(NSString *)contentType;

/**
 * Creates a new instance with the passed data and content type.
 * @param rawData the NSData
 * @patam contentType the content type to return.
 * @return a new instance of NTApiRawDataArg
 */
+(NTApiRawDataArg *)argWithData:(NSData *)rawData contentType:(NSString *)contentType;

-(BOOL)applyArgToBuilder:(NTApiRequestBuilder *)builder;
-(NSString *)description;

@end


/**
 * Allows setting several options that control how the request and response is processed, including:
 * Ignoring HTTP Error codes, disabling JSON parsing and setting the thread type (Main, background or current) for the response/upload/download handlers.
 */
@interface NTApiOptionArg : NTApiArg

/**
 * The value for the option, if applicable
 */
@property (strong, nonatomic)        NSString       *value;

-(id)initWithName:(NSString *)name value:(NSString *)value;

+(NTApiOptionArg *)optionWithName:(NSString *)name value:(NSString *)value;
+(NTApiOptionArg *)optionWithName:(NSString *)name;

/**
 * This option disables JSON parsing for this request. Use this if you are receiving data other than JSON
 * (such as an image) and you need to process it manually.
 */
+(NTApiOptionArg *)optionRawData;

/**
 * This option causes the response processing to ignore HTTP error codes
 * when parsing errors. HTTP Errors themseles will not cause an NTApiError
 * to be created. The actual HTTP Error can still be inspected through 
 */
+(NTApiOptionArg *)optionIgnoreHTTPErrorCodes;

/**
 * Set the thread that will run the responseHandler (note the funciton is misnamed).
 * This may be set to the main thread, a background thread or the current thread using NTApiThreadType*
 * values. The default is the main thread.
 */
+(NTApiOptionArg *)optionRequestHandlerThread:(NTApiThreadType)threadType;

/**
 * Set the thread that will run the uploadProgressHandler.
 * This may be set to the main thread or a background thread using NTApiThreadType*
 * values. The current thread is not supported with this handler. The default is the main thread.
 */
+(NTApiOptionArg *)optionUploadHandlerThread:(NTApiThreadType)threadType;

/**
 * Set the thread that will run the downloadProgressHandler.
 * This may be set to the main thread or a background thread using NTApiThreadType*
 * values. The current thread is not supported with this handler. The default is the main thread.
 */
+(NTApiOptionArg *)optionDownloadHandlerThread:(NTApiThreadType)threadType;

/**
 * Allows invaid SSL Certificates - use this if you have a self-signed SSL certificate.
 */
+(NTApiOptionArg *)optionAllowInvalidSSLCert:(BOOL)allowInvalidSSLCert;

-(BOOL)applyArgToBuilder:(NTApiRequestBuilder *)builder;
-(NSString *)description;

@end


/**
 * Adds an HTTP Header to the request.
 */
@interface NTApiHeaderArg : NTApiArg

/**
 * The HTTP header value
 */
@property (strong, nonatomic)        NSString       *value;

-(id)initWithName:(NSString *)name value:(NSString *)value;

+(NTApiHeaderArg *)headerWithName:(NSString *)name value:(NSString *)value;

-(BOOL)applyArgToBuilder:(NTApiRequestBuilder *)builder;
-(NSString *)description;

@end


/**
 * Adds a basic auth header to the request.
 */
@interface NTApiBasicAuthArg : NTApiArg

/**
 * the password
 */
@property (strong, nonatomic)        NSString       *password;

-(id)initWithUser:(NSString *)user password:(NSString *)password;

+(NTApiBasicAuthArg *)argWithUser:(NSString *)user password:(NSString *)password;

-(BOOL)applyArgToBuilder:(NTApiRequestBuilder *)builder;
-(NSString *)description;

@end


/**
 * Overrides the default "baseUrl" for this request only. Note in this context the baseUrl
 * is the url that will be sent to the host -- the entire part before the query string.
 * By default this value is the +baseUrl with the "command" argument appended to it.
 */
@interface NTApiBaseUrlArg : NTApiArg

+(NTApiBaseUrlArg *)argWithBaseUrl:(NSString *)baseUrl;

-(BOOL)applyArgToBuilder:(NTApiRequestBuilder *)builder;
-(NSString *)description;

@end


/**
 * Overrides the default request method (typically GET or POST.)
 * By default the method is a GET. It is qutomatically set to a POST
 * if arguments are set requiring s apost - such as a NTApiFormArg or NTApiMultipartArg
 */
@interface NTApiHttpMethodArg : NTApiArg

+(NTApiBaseUrlArg *)argWithHttpMethod:(NSString *)httpMethod;

-(BOOL)applyArgToBuilder:(NTApiRequestBuilder *)builder;
-(NSString *)description;

@end


/**
 * Override the default timeout for this request. Default is 60 seconds.
 */
@interface NTApiTimeoutArg : NTApiArg

@property (assign, nonatomic)       int         timeout;

-(id)initWithTimeout:(int)timeout;

+(NTApiTimeoutArg *)argWithTimeout:(int)timeout;

-(BOOL)applyArgToBuilder:(NTApiRequestBuilder *)builder;
-(NSString *)description;

@end


/**
 * Override the default cache policy for this request. Default is NSURLRequestUseProtocolCachePolicy.
 */
@interface NTApiCachePolicyArg : NTApiArg

@property (assign, nonatomic)       NSURLRequestCachePolicy         cachePolicy;

-(id)initWithCachePolicy:(NSURLRequestCachePolicy)cachePolicy;

+(NTApiCachePolicyArg *)argWithCachePolicy:(NSURLRequestCachePolicy)cachePolicy;

-(BOOL)applyArgToBuilder:(NTApiRequestBuilder *)builder;
-(NSString *)description;

@end








