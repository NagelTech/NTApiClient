//
//  NTApiArg.h
//
//  Copyright (c) 2011-2012 Ethan Nagel. All rights reserved.
//  See LICENSE for license details
//

#import <Foundation/Foundation.h>

#import "NTApiConst.h"

@class NTApiRequestBuilder;


@interface NTApiArg : NSObject

@property (strong, nonatomic)        NSString       *name;


-(BOOL)applyArgToBuilder:(NTApiRequestBuilder *)builder;
-(NSString *)description;


-(id)initWithName:(NSString *)name;

@end


@interface NTApiUrlArg : NTApiArg

@property (strong, nonatomic)        NSString       *value;

-(id)initWithName:(NSString *)name value:(NSString *)value;

+(NTApiUrlArg *)argWithName:(NSString *)name string:(NSString *)stringValue;
+(NTApiUrlArg *)argWithName:(NSString *)name intValue:(int)intValue;

-(BOOL)applyArgToBuilder:(NTApiRequestBuilder *)builder;
-(NSString *)description;

@end


@interface NTApiFormArg : NTApiArg

@property (strong, nonatomic)        NSString       *value;

-(id)initWithName:(NSString *)name value:(NSString *)value;

+(NTApiFormArg *)argWithName:(NSString *)name string:(NSString *)stringValue;
+(NTApiFormArg *)argWithName:(NSString *)name intValue:(int)intValue;

-(BOOL)applyArgToBuilder:(NTApiRequestBuilder *)builder;
-(NSString *)description;

@end


@interface NTApiMultipartArg : NTApiArg

@property (strong, nonatomic)        NSString       *value;
@property (strong, nonatomic)        NSData         *dataValue;
@property (strong, nonatomic)        NSString       *fileExtension;

-(id)initWithName:(NSString *)name value:(NSString *)value;
-(id)initWithName:(NSString *)name data:(NSData *)dataValue fileExtension:(NSString *)fileExtension;

+(NTApiMultipartArg *)argWithName:(NSString *)name string:(NSString *)stringValue;
+(NTApiMultipartArg *)argWithName:(NSString *)name intValue:(int)intValue;
+(NTApiMultipartArg *)argWithName:(NSString *)name data:(NSData *)dataValue fileExtension:(NSString *)fileExtension;

-(BOOL)applyArgToBuilder:(NTApiRequestBuilder *)builder;
-(NSString *)description;

@end


@interface NTApiRawDataArg : NTApiArg

@property (strong, nonatomic)        NSData         *rawData;
@property (strong, nonatomic)        NSString       *contentType;

-(id)initWithData:(NSData *)rawData contentType:(NSString *)contentType;

+(NTApiRawDataArg *)argWithData:(NSData *)rawData contentType:(NSString *)contentType;

-(BOOL)applyArgToBuilder:(NTApiRequestBuilder *)builder;
-(NSString *)description;

@end


@interface NTApiOptionArg : NTApiArg

@property (strong, nonatomic)        NSString       *value;

-(id)initWithName:(NSString *)name value:(NSString *)value;

+(NTApiOptionArg *)optionWithName:(NSString *)name value:(NSString *)value;
+(NTApiOptionArg *)optionWithName:(NSString *)name;

+(NTApiOptionArg *)optionRawData;
+(NTApiOptionArg *)optionRequestHandlerThread:(NTApiThreadType)threadType;
+(NTApiOptionArg *)optionUploadHandlerThread:(NTApiThreadType)threadType;
+(NTApiOptionArg *)optionDownloadHandlerThread:(NTApiThreadType)threadType;

-(BOOL)applyArgToBuilder:(NTApiRequestBuilder *)builder;
-(NSString *)description;

@end


@interface NTApiHeaderArg : NTApiArg

@property (strong, nonatomic)        NSString       *value;

-(id)initWithName:(NSString *)name value:(NSString *)value;

+(NTApiHeaderArg *)headerWithName:(NSString *)name value:(NSString *)value;

-(BOOL)applyArgToBuilder:(NTApiRequestBuilder *)builder;
-(NSString *)description;

@end


@interface NTApiBasicAuthArg : NTApiArg

@property (strong, nonatomic)        NSString       *password;

-(id)initWithUser:(NSString *)user password:(NSString *)password;

+(NTApiBasicAuthArg *)argWithUser:(NSString *)user password:(NSString *)password;

-(BOOL)applyArgToBuilder:(NTApiRequestBuilder *)builder;
-(NSString *)description;

@end


@interface NTApiBaseUrlArg : NTApiArg

+(NTApiBaseUrlArg *)argWithBaseUrl:(NSString *)baseUrl;

-(BOOL)applyArgToBuilder:(NTApiRequestBuilder *)builder;
-(NSString *)description;

@end


@interface NTApiHttpMethodArg : NTApiArg

+(NTApiBaseUrlArg *)argWithHttpMethod:(NSString *)httpMethod;

-(BOOL)applyArgToBuilder:(NTApiRequestBuilder *)builder;
-(NSString *)description;

@end


@interface NTApiTimeoutArg : NTApiArg

@property (assign, nonatomic)       int         timeout;

-(id)initWithTimeout:(int)timeout;

+(NTApiTimeoutArg *)argWithTimeout:(int)timeout;

-(BOOL)applyArgToBuilder:(NTApiRequestBuilder *)builder;
-(NSString *)description;

@end


@interface NTApiCachePolicyArg : NTApiArg

@property (assign, nonatomic)       NSURLRequestCachePolicy         cachePolicy;

-(id)initWithCachePolicy:(NSURLRequestCachePolicy)cachePolicy;

+(NTApiCachePolicyArg *)argWithCachePolicy:(NSURLRequestCachePolicy)cachePolicy;

-(BOOL)applyArgToBuilder:(NTApiRequestBuilder *)builder;
-(NSString *)description;

@end








