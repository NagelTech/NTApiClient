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


@interface NTApiClient : NSObject


@property (strong, atomic)  NSString                *baseUrl;
@property (assign, atomic)  NTApiLogType             logFlags;


+(void)setDefault:(NSString *)key value:(id)value;
+(id)getDefault:(NSString *)key;


+(void)networkRequestStarted:(NSURLRequest *)request options:(NSDictionary *)options;               // overridable
+(void)networkRequestCompleted:(NSURLRequest *)request options:(NSDictionary *)options response:(NTApiResponse *)response;

+(id)parseJsonData:(NSData *)data error:(NSError **)error;              // overridable

-(id)init;

-(void)writeLogWithType:(NTApiLogType)logType andFormat:(NSString *)format, ...;
                                            

-(NTApiRequest *)beginRequest:(NSString *)command
               args:(NSArray *)args 
    responseHandler:(void (^)(NTApiResponse *response))responseHandler
uploadProgressHandler:(void (^)(int bytesSent, int totalBytes))uploadProgressHandler
downloadProgressHandler:(void (^)(int bytesReceived, int totalBytes))downloadProgressHandler;

-(NTApiRequest *)beginRequest:(NSString *)command
               args:(NSArray *)args 
    responseHandler:(void (^)(NTApiResponse *response))responseHandler;


@end


@protocol NTApiClientDefaultProvider <NSObject>

-(id)getApiClientDefault:(NSString *)key;

@end

