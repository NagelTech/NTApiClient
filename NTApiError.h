//
//  NTApiError.h
//
//  Copyright (c) 2011-2012 Ethan Nagel. All rights reserved.
//  See LICENSE for license details
//

#import <Foundation/Foundation.h>

/**
 * Indicates that the NTApiError is wrapping an NSError. The original error is
 * available in NTApiError.nsError.
 */
extern NSString *NTApiErrorCodeNSError;

/**
 * The API was unable to successfully parse the JSON response
 */
extern NSString *NTApiErrorCodeInvalidJson;

/**
 * A generic error has occured.
 */
extern NSString *NTApiErrorCodeError;

/**
 * An HTTP error has occured. Returned for HTTP result codes >= 500. The HTTP error code
 * is in NTApiError.httpErrorCode
 */
extern NSString *NTApiErrorCodeHttpError;

/**
 * There ia no route to the API server.
 */
extern NSString *NTApiErrorCodeNoInternet;

/**
 * The request has been cancelled.
 */
extern NSString *NTApiErrorCodeRequestCancelled;


/**
 * Represents an error returned from the API. This can be a built-in error or an error parsed from the
 * API response.
 */
@interface NTApiError : NSObject


/**
 * The error code of the errror. For built-in error codes (NTApiErrorCode*) or any error code registered
 * with +addErrorCode:, this value can be compared using == instead of string compares.
 */
@property (strong, atomic)  NSString    *errorCode;

/**
 * The error message associatedwith this error.
 */
@property (strong, atomic)  NSString    *errorMessage;

/**
 * The NSError when the errorCode == NTApiErrorCodeNTError
 */
@property (strong, atomic)  NSError     *nsError;

/**
 * The HTTP Response code when errorCode == NTApiErrorHttpError
 */
@property (assign, atomic)  int          httpErrorCode;

/**
 * Returns the set of all error codes registered with addErrorCode
 */
+(NSSet *)allErrorCodes;

/**
 * Adds an error code to the list of errors automatically mapped. Any erro codes mapped here may be compared as constants
 * using == instead of string compares.
 * @param errorCode the error code to add to the mapping table (allErrorCodes)
 */
+(void)addErrorCode:(NSString *)errorCode;

/**
 * Translates the given string into the mapped error code in +allErrorCodes if present, otherwise the original string is returned.
 */
+(NSString *)mapErorCode:(NSString *)text;

/**
 * Returns a new instance with the indicated code and message.
 * @param code the error code, If the value has been passed to addErrorCode it will be mapped to that value.
 * @param message the error message.
 * @return the new instance of NTApiError
 */
-(id)initWithCode:(NSString *)code message:(NSString *)message;

/**
 * Returns a new instance with the passed NSError. The errorCode will bt NTApiErrorCodeNSError
 * @param nsError the NSError
 * @return the new instance of NTApiError
 */
-(id)initWithNSError:(NSError *)nsError;

/**
 * Returns a new instance with the passed HTTP error code. The errorCode will bt NTApiErrorCodeHttpError
 * @param httpErrorCode the HTTP response code
 * @return the new instance of NTApiError
 */
-(id)initWithHttpErrorCode:(int)httpErrorCode;

/**
 * Returns a new instance with the indicated code and message.
 * @param code the error code, If the value has been passed to addErrorCode it will be mapped to that value.
 * @param message the error message.
 * @return the new instance of NTApiError
 */
+(NTApiError *)errorWithCode:(NSString *)code message:(NSString *)message;

/**
 * Returns a new instance with the indicated code and message.
 * @param code the error code, If the value has been passed to addErrorCode it will be mapped to that value.
 * @param format the error message as a NSString stringWithFormat string
 * @return the new instance of NTApiError
 */
+(NTApiError *)errorWithCode:(NSString *)code format:(NSString *)format, ...;

/**
 * Returns a new instance with the passed NSError. The errorCode will bt NTApiErrorCodeNSError
 * @param nsError the NSError
 * @return the new instance of NTApiError
 */
+(NTApiError *)errorWithNSError:(NSError *)nsError;

/**
 * Returns a new instance with the passed HTTP error code. The errorCode will bt NTApiErrorCodeHttpError
 * @param httpErrorCode the HTTP response code
 * @return the new instance of NTApiError
 */
+(NTApiError *)errorWithHttpErrorCode:(int)httpErrorCode;

/**
 * returns the errorMessage
 */
-(NSString *)description;

@end

