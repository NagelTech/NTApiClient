//
//  NTApiRequestBuilder.h
//
//  Copyright (c) 2011-2012 Ethan Nagel. All rights reserved.
//  See LICENSE for license details
//

#import <Foundation/Foundation.h>

#import "NTApiArg.h"
#import "NTApiError.h"


@interface NTApiRequestBuilder : NSObject


@property (strong,readonly, nonatomic)  NSArray     *args;

@property (strong, readonly, nonatomic) NTApiError  *error;
@property (strong, readonly, nonatomic) NSString    *multipartBoundry;

@property (strong, nonatomic)   NSString            *baseUrl;
@property (strong, nonatomic)   NSMutableDictionary *headers;
@property (strong, nonatomic)   NSMutableDictionary *options;
@property (strong, nonatomic)   NSString            *httpMethod;
@property (assign, nonatomic)   int                  timeout;   // in seconds
@property (assign, nonatomic)   NSURLRequestCachePolicy cachePolicy;
@property (strong, nonatomic)   NSMutableString     *urlString;
@property (strong, nonatomic)   NSMutableString     *formString;
@property (strong, nonatomic)   NSMutableData       *multipartData;
@property (strong, nonatomic)   NSData              *rawData;


+(NSString *)urlEncode:(NSString *)string;
+(NSString *)base64Encode:(NSData *)data;

-(id)initWithArgs:(NSArray *)args;

-(BOOL)addUrlValueWithName:(NSString *)name value:(NSString *)value;
-(BOOL)addHeaderWithName:(NSString *)name value:(NSString *)value;

-(BOOL)addFormValueWithName:(NSString *)name value:(NSString *)value;
-(BOOL)addMultipartValueWithName:(NSString *)name value:(NSString *)value;
-(BOOL)addMultipartDataWithName:(NSString *)name data:(NSData *)data extension:(NSString *)extension;
-(BOOL)addRawDataWithContentType:(NSString *)contentType data:(NSData *)data;

-(BOOL)addOptionWithName:(NSString *)name value:(NSString *)value;

-(NSMutableURLRequest *)createRequest;


@end
