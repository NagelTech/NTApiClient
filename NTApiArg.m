//
//  NTApiArg.m
//
//  Copyright (c) 2011-2012 Ethan Nagel. All rights reserved.
//  See LICENSE for license details
//

#import "NTApiArg.h"
#import "NTApiRequestBuilder.h"


@implementation NTApiArg


@synthesize name = mName;

-initWithName:(NSString *)name
{
    if ( (self=[super init]) )
    {
        self.name = name;
    }
    
    return self;
}


-(BOOL)applyArgToBuilder:(NTApiRequestBuilder *)builder
{
    return YES;
}


-(NSString *)description
{
    return [NSString stringWithFormat:@"%@ %@", NSStringFromClass([self class]), self.name];
}

         
@end


@implementation NTApiUrlArg


@synthesize value = mValue;


-(id)initWithName:(NSString *)name value:(NSString *)value
{
    if ( (self=[super initWithName:name]) )
    {
        self.value = value;
    }
    
    return self;
}


+(NTApiUrlArg *)argWithName:(NSString *)name string:(NSString *)stringValue
{
    return [[NTApiUrlArg alloc] initWithName:name value:stringValue];
}


+(NTApiUrlArg *)argWithName:(NSString *)name intValue:(int)intValue
{
    return [[NTApiUrlArg alloc] initWithName:name value:[NSString stringWithFormat:@"%d", intValue]];
}


-(BOOL)applyArgToBuilder:(NTApiRequestBuilder *)builder
{
    return [builder addUrlValueWithName:self.name value:self.value];
}


-(NSString *)description
{
    return [NSString stringWithFormat:@"Url %@ = %@", self.name, self.value];
}

@end


@implementation NTApiFormArg


@synthesize value = mValue;


-(id)initWithName:(NSString *)name value:(NSString *)value
{
    if ( (self=[super initWithName:name]) )
    {
        self.value = value;
    }
    
    return self;
}


+(NTApiFormArg *)argWithName:(NSString *)name string:(NSString *)stringValue
{
    return [[NTApiFormArg alloc] initWithName:name value:stringValue];
}


+(NTApiFormArg *)argWithName:(NSString *)name intValue:(int)intValue
{
    return [[NTApiFormArg alloc] initWithName:name value:[NSString stringWithFormat:@"%d", intValue]];
}


-(BOOL)applyArgToBuilder:(NTApiRequestBuilder *)builder
{
    return [builder addUrlValueWithName:self.name value:self.value];
}


-(NSString *)description
{
    return [NSString stringWithFormat:@"Form %@ = %@", self.name, self.value];
}

@end


@implementation NTApiMultipartArg


@synthesize value = mValue;
@synthesize dataValue = mDataValue;
@synthesize fileExtension = mFileExtension;


-(id)initWithName:(NSString *)name value:(NSString *)value
{
    if ( (self=[super initWithName:name]) )
    {
        self.value = value;
        self.dataValue = nil;
        self.fileExtension = nil;
    }
    
    return self;
}


-(id)initWithName:(NSString *)name data:(NSData *)dataValue fileExtension:(NSString *)fileExtension;
{
    if ( (self=[super initWithName:name]) )
    {
        self.value = nil;
        self.dataValue = dataValue;
        self.fileExtension = fileExtension;
    }
    
    return self;
}


+(NTApiMultipartArg *)argWithName:(NSString *)name string:(NSString *)stringValue
{
    return [[NTApiMultipartArg alloc] initWithName:name value:stringValue];
}


+(NTApiMultipartArg *)argWithName:(NSString *)name intValue:(int)intValue
{
    return [[NTApiMultipartArg alloc] initWithName:name value:[NSString stringWithFormat:@"%d", intValue]];
}


+(NTApiMultipartArg *)argWithName:(NSString *)name data:(NSData *)dataValue fileExtension:(NSString *)fileExtension
{
    return [[NTApiMultipartArg alloc] initWithName:name data:dataValue fileExtension:fileExtension];
}


-(BOOL)applyArgToBuilder:(NTApiRequestBuilder *)builder
{
    if ( self.value )
        return [builder addMultipartValueWithName:self.name value:self.value];
    else
        return [builder addMultipartDataWithName:self.name data:self.dataValue extension:self.fileExtension];
}


-(NSString *)description
{
    if ( self.value )
        return [NSString stringWithFormat:@"Multi %@ = %@", self.name, self.value];
    else 
        return [NSString stringWithFormat:@"Multi %@ = data[%d bytes] extension=%@", self.name, self.dataValue.length, self.fileExtension];
}

@end


@implementation NTApiRawDataArg


@synthesize rawData = mRawData;
@synthesize contentType = mContentType;


-(id)initWithData:(NSData *)rawData contentType:(NSString *)contentType
{
    if ( (self=[super initWithName:nil]) )
    {
        self.rawData = rawData;
        self.contentType = contentType;
    }
    
    return self;
}


+(NTApiRawDataArg *)argWithData:(NSData *)rawData contentType:(NSString *)contentType
{
    return [[NTApiRawDataArg alloc] initWithData:rawData contentType:contentType];
}


-(BOOL)applyArgToBuilder:(NTApiRequestBuilder *)builder
{
    return [builder addRawDataWithContentType:self.contentType data:self.rawData];
}


-(NSString *)description
{
    return [NSString stringWithFormat:@"Raw data[%d bytes] Content-Type=%@", self.rawData.length, self.contentType];
}

@end


@implementation NTApiOptionArg


@synthesize value = mValue;


-(id)initWithName:(NSString *)name value:(NSString *)value
{
    if ( (self=[super initWithName:name]) )
    {
        self.value = value;
    }
    
    return self;
}


+(NTApiOptionArg *)optionWithName:(NSString *)name value:(NSString *)value
{
    return [[NTApiOptionArg alloc] initWithName:name value:value];
}


+(NTApiOptionArg *)optionWithName:(NSString *)name
{
    return [[NTApiOptionArg alloc] initWithName:name value:nil];
}


-(BOOL)applyArgToBuilder:(NTApiRequestBuilder *)builder
{
    return [builder addOptionWithName:self.name value:self.value];
}


-(NSString *)description
{
    return [NSString stringWithFormat:@"Option %@ = %@", self.name, self.value];
}

@end


@implementation NTApiHeaderArg


@synthesize value = mValue;


-(id)initWithName:(NSString *)name value:(NSString *)value
{
    if ( (self=[super initWithName:name]) )
    {
        self.value = value;
    }
    
    return self;
}


+(NTApiHeaderArg *)headerWithName:(NSString *)name value:(NSString *)value
{
    return [[NTApiHeaderArg alloc] initWithName:name value:value];
}


-(BOOL)applyArgToBuilder:(NTApiRequestBuilder *)builder
{
    return [builder addOptionWithName:self.name value:self.value];
}


-(NSString *)description
{
    return [NSString stringWithFormat:@"Header %@ = %@", self.name, self.value];
}

@end


@implementation NTApiBasicAuthArg


@synthesize password = mPassword;



-(id)initWithUser:(NSString *)user password:(NSString *)password
{
    if ( (self=[super initWithName:user]) )
    {
        self.password = password;
    }
    
    return self;
}


+(NTApiBasicAuthArg *)argWithUser:(NSString *)user password:(NSString *)password
{
    return [[NTApiBasicAuthArg alloc] initWithUser:user password:password];
}


-(BOOL)applyArgToBuilder:(NTApiRequestBuilder *)builder
{
    // build the appropriate header...
    
    NSString *authString = [NSString stringWithFormat:@"%@:%@", 
                            (self.name) ? self.name : @"", 
                            (self.password) ? self.password : @""];
    
    NSString *base64Auth = [NTApiRequestBuilder base64Encode:[authString dataUsingEncoding:NSUTF8StringEncoding]];
    
    [builder addHeaderWithName:NTApiHeaderAuthorization value:[NSString stringWithFormat:@"Basic %@", base64Auth]];
    
    return YES;
}


-(NSString *)description
{
    return [NSString stringWithFormat:@"BasicAuth %@ %@", self.name, self.password];
}

@end


@implementation NTApiBaseUrlArg


+(NTApiBaseUrlArg *)argWithBaseUrl:(NSString *)baseUrl
{
    return [[NTApiBaseUrlArg alloc] initWithName:baseUrl];
}


-(BOOL)applyArgToBuilder:(NTApiRequestBuilder *)builder
{
    builder.baseUrl = self.name;
    
    return YES;
}


-(NSString *)description
{
    return [NSString stringWithFormat:@"BaseUrl %@", self.name];
}


@end


@implementation NTApiHttpMethodArg


+(NTApiHttpMethodArg *)argWithHttpMethod:(NSString *)httpMethod
{
    return [[NTApiHttpMethodArg alloc] initWithName:httpMethod];
}


-(BOOL)applyArgToBuilder:(NTApiRequestBuilder *)builder
{
    builder.httpMethod = self.name;
    
    return YES;
}


-(NSString *)description
{
    return [NSString stringWithFormat:@"Method %@", self.name];
}


@end


@implementation NTApiTimeoutArg


@synthesize timeout = mTimeout;


-(id)initWithTimeout:(int)timeout
{
    if ( (self=[super initWithName:nil]) )
    {
        self.timeout = timeout;
    }
    
    return self;
}


+(NTApiTimeoutArg *)argWithTimeout:(int)timeout
{
    return [[NTApiTimeoutArg alloc] initWithTimeout:timeout];
}

-(BOOL)applyArgToBuilder:(NTApiRequestBuilder *)builder
{
    builder.timeout = self.timeout;
    
    return YES;
}


-(NSString *)description
{
    return [NSString stringWithFormat:@"Timeout %d sec", self.timeout];
}


@end

@implementation NTApiCachePolicyArg


@synthesize cachePolicy = mCachePolicy;


-(id)initWithCachePolicy:(NSURLRequestCachePolicy)cachePolicy
{
    if ( (self=[super initWithName:nil]) )
    {
        self.cachePolicy = cachePolicy;
    }
    
    return self;
}


+(NTApiCachePolicyArg *)argWithCachePolicy:(NSURLRequestCachePolicy)cachePolicy
{
    return [[NTApiCachePolicyArg alloc] initWithCachePolicy:cachePolicy];
}


-(BOOL)applyArgToBuilder:(NTApiRequestBuilder *)builder
{
    builder.cachePolicy = self.cachePolicy;
    
    return YES;
}


-(NSString *)description
{
    return [NSString stringWithFormat:@"Cache Policy %d", self.cachePolicy];
}


@end



