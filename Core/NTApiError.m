//
//  NTApiError.m
//
//  Copyright (c) 2011-2012 Ethan Nagel. All rights reserved.
//  See LICENSE for license details
//

#import "NTApiError.h"

// ARC is required

#if !__has_feature(objc_arc)
#   error ARC is required for NTApiClient
#endif


NSString *NTApiErrorCodeNSError = @"NTApiErrorCodeNSError";
NSString *NTApiErrorCodeInvalidJson = @"NTApiErrorCodeInvalidJson";
NSString *NTApiErrorCodeError = @"NTApiErrorCodeError";               // generic error
NSString *NTApiErrorCodeHttpError = @"NTApiErrorCodeHttpError";
NSString *NTApiErrorCodeNoInternet = @"NTApiErrorCodeNoInternet";
NSString *NTApiErrorCodeRequestCancelled = @"NTApiErrorCodeRequestCancelled";


@implementation NTApiError


@synthesize errorCode = mErrorCode;
@synthesize errorMessage = mErrorMessage;
@synthesize nsError = mNsError;
@synthesize httpErrorCode = mHttpErrorCode;


#pragma mark - errorCode management


static NSMutableSet *sAllErrorCodes = nil;


+(void)initErrorCodes
{
    [self addErrorCode:NTApiErrorCodeNSError];
    [self addErrorCode:NTApiErrorCodeInvalidJson];
    [self addErrorCode:NTApiErrorCodeError];
    [self addErrorCode:NTApiErrorCodeHttpError];
    [self addErrorCode:NTApiErrorCodeNoInternet];
    [self addErrorCode:NTApiErrorCodeRequestCancelled];
}


+(NSSet *)allErrorCodes
{
    if ( !sAllErrorCodes )
    {
        sAllErrorCodes = [NSMutableSet new];

        [self initErrorCodes];
        
    }
    
    return sAllErrorCodes;
}


+(void)addErrorCode:(NSString *)errorCode
{
    if ( !sAllErrorCodes )
        sAllErrorCodes = [NSMutableSet new];
    
    [sAllErrorCodes addObject:errorCode];
}


+(NSString *)mapErorCode:(NSString *)text
{
    if ( !text )
        return nil;
    
    NSString *value = [[self allErrorCodes] member:text];
    
    return (value) ? value : text;
}


#pragma mark - lifecycle


-(id)initWithCode:(NSString *)code message:(NSString *)message
{
    if ( (self=[super init]) )
    {
        self.errorCode = [NTApiError mapErorCode:code];
        self.errorMessage = message;
    }
    
    return self;
}


-(id)initWithNSError:(NSError *)nsError
{
    if ( (self=[super init]) )
    {
        self.errorCode = NTApiErrorCodeNSError;
        self.errorMessage = [nsError localizedDescription];
        self.nsError = nsError;
    }
    
    return self;
}


-(id)initWithHttpErrorCode:(int)httpErrorCode
{
    if ( (self=[super init]) )
    {
        self.errorCode = NTApiErrorCodeHttpError;
        self.httpErrorCode = httpErrorCode;
        self.errorMessage = [NSString stringWithFormat:@"Http Error Code %d", httpErrorCode];

    }
    
    return self;
}


+(NTApiError *)errorWithCode:(NSString *)code message:(NSString *)message
{
    return [[NTApiError alloc] initWithCode:code message:message];
}


+(NTApiError *)errorWithCode:(NSString *)code format:(NSString *)format, ...
{
    va_list args;
    va_start(args, format);
    
    NTApiError *apiError = [[NTApiError alloc] initWithCode:code 
                                                message:[[NSString alloc] initWithFormat:format arguments:args]];
    
    va_end(args);
    
    return apiError;
}


+(NTApiError *)errorWithNSError:(NSError *)nsError
{
    return [[NTApiError alloc] initWithNSError:nsError];
}


+(NTApiError *)errorWithHttpErrorCode:(int)httpErrorCode
{
    return [[NTApiError alloc] initWithHttpErrorCode:httpErrorCode];
}


-(NSString *)description
{
    return self.errorMessage;
}


@end
