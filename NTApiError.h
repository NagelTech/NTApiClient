//
//  NTApiError.h
//
//  Copyright (c) 2011-2012 Ethan Nagel. All rights reserved.
//  See LICENSE for license details
//

#import <Foundation/Foundation.h>


// Negative NTApiErrorCodes are reserved as follows...


extern NSString *NTApiErrorCodeNSError;
extern NSString *NTApiErrorCodeInvalidJson;
extern NSString *NTApiErrorCodeError;               // generic error
extern NSString *NTApiErrorCodeHttpError;
extern NSString *NTApiErrorCodeNoInternet;
extern NSString *NTApiErrorCodeRequestCancelled;

@interface NTApiError : NSObject

@property (strong, atomic)  NSString    *errorCode;
@property (strong, atomic)  NSString    *errorMessage;
@property (strong, atomic)  NSError     *nsError;
@property (assign, atomic)  int          httpErrorCode;

+(NSSet *)allErrorCodes;
+(void)addErrorCode:(NSString *)errorCode;
+(NSString *)mapErorCode:(NSString *)text;

-(id)initWithCode:(NSString *)code message:(NSString *)message;
-(id)initWithNSError:(NSError *)nsError;
-(id)initWithHttpErrorCode:(int)httpErrorCode;

+(NTApiError *)errorWithCode:(NSString *)code message:(NSString *)message;
+(NTApiError *)errorWithCode:(NSString *)code format:(NSString *)format, ...;
+(NTApiError *)errorWithNSError:(NSError *)nsError;
+(NTApiError *)errorWithHttpErrorCode:(int)httpErrorCode;

-(NSString *)description;

@end

