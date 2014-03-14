//
//  NTApiConst.h
//
//  Copyright (c) 2011-2012 Ethan Nagel. All rights reserved.
//  See LICENSE for license details
//

#import <Foundation/Foundation.h>


extern NSString *NTApiOptionRawData;
extern NSString *NTApiOptionIgnoreHTTPErrorCodes;
extern NSString *NTApiOptionResponseHandlerThreadType;
extern NSString *NTApiOptionUploadHandlerThreadType;
extern NSString *NTApiOptionDownloadHandlerThreadType;
extern NSString *NTApiOptionAllowInvalidSSLCert;

extern NSString *NTApiHeaderContentType;
extern NSString *NTApiHeaderAuthorization;

typedef NSString *NTApiThreadType;
extern NTApiThreadType NTApiThreadTypeMain;
extern NTApiThreadType NTApiThreadTypeBackground;
extern NTApiThreadType NTApiThreadTypeCurrent;

typedef enum 
{
    NTApiLogTypeDebug = 1<<0,
    NTApiLogTypeInfo = 1<<1,
    NTApiLogTypeWarn = 1<<2,
    NTApiLogTypeError = 1<<3,
 
    NTApiLogTypeNone = 0,
    NTApiLogTypeAll = 0x0F,
} NTApiLogType;

