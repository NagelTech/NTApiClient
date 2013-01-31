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

extern NSString *NTApiHeaderContentType;
extern NSString *NTApiHeaderAuthorization;

typedef NSString *NTApiThreadType;
extern NTApiThreadType NTApiThreadTypeMain;
extern NTApiThreadType NTApiThreadTypeBackground;
extern NTApiThreadType NTApiThreadTypeCurrent;

typedef NSString *NTApiLogType;
extern NTApiLogType NTApiLogTypeDebug;
extern NTApiLogType NTApiLogTypeInfo;
extern NTApiLogType NTApiLogTypeWarn;
extern NTApiLogType NTApiLogTypeError;

