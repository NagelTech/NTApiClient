//
//  NTApiError.h
//
//  Copyright (c) 2011-2012 Ethan Nagel. All rights reserved.
//  See LICENSE for license details
//

#import <Foundation/Foundation.h>


// Negative NTApiErrorCodes are reserved as follows...


extern const int NTApiErrorCodeNSError;
extern const int NTApiErrorCodeInvalidJson;
extern const int NTApiErrorCodeError;               // generic error

@interface NTApiError : NSObject

@property (assign, atomic)  int          errorCode;
@property (strong, atomic)  NSString    *errorMessage;
@property (strong, atomic)  NSError     *nsError;


-(id)initWithCode:(int)code message:(NSString *)message;
-(id)initWithNSError:(NSError *)nsError;

+(NTApiError *)errorWithCode:(int)code message:(NSString *)message;
+(NTApiError *)errorWithCode:(int)code format:(NSString *)format, ...;
+(NTApiError *)errorWithNSError:(NSError *)nsError;

-(NSString *)description;

@end

