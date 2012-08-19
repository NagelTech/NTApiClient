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
#import "NTApiRequestBuilder.h"



@protocol NTApiClientDefaultProvider;
@class NTApiRequestProcessor;


@interface NTApiClient : NSObject

@property (strong, atomic)  NSString                *baseUrl;


+(void)setDefault:(NSString *)key value:(id)value;
+(id)getDefault:(NSString *)key;


+(void)networkRequestStarted:(NSURLRequest *)request options:(NSDictionary *)options;               // overridable
+(void)networkRequestCompleted:(NSURLRequest *)request options:(NSDictionary *)options processor:(NTApiRequestProcessor *)processor;


-(id)init;

-(void)writeLogWithType:(NTApiLogType)logType andFormat:(NSString *)format, ...;
                                            

-(void)beginRequest:(NSString *)command 
               args:(NSArray *)args 
    responseHandler:(void (^)(NSDictionary *response, NTApiError *error))responseHandler 
uploadProgressHandler:(void (^)(int bytesSent, int totalBytes))uploadProgressHandler
downloadProgressHandler:(void (^)(int bytesReceived, int totalBytes))downloadProgressHandler;

-(void)beginRequest:(NSString *)command 
               args:(NSArray *)args 
    responseHandler:(void (^)(NSDictionary *response, NTApiError *error))responseHandler;


@end


@protocol NTApiClientDefaultProvider <NSObject>

-(id)getApiClientDefault:(NSString *)key;

@end

