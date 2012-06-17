//
//  NTApiConst.h
//
//  Created by Ethan Nagel on 6/16/12.
//  Copyright (c) 2012 BitDonkey, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>


extern NSString *NTApiOptionRawData;
extern NSString *NTApiOptionResponseHandlerThreadType;
extern NSString *NTApiOptionUploadHandlerThreadType;
extern NSString *NTApiOptionDownloadHandlerThreadType;

extern NSString *NTApiHeaderContentType;
extern NSString *NTApiHeaderAuthorization;

typedef NSString *NTApiThreadType;
extern NTApiThreadType NTApiThreadTypeMain;
extern NTApiThreadType NTApiThreadTypeBackground;

typedef NSString *NTApiLogType;
extern NTApiLogType NTApiLogTypeDebug;
extern NTApiLogType NTApiLogTypeInfo;
extern NTApiLogType NTApiLogTypeWarn;
extern NTApiLogType NTApiLogTypeError;

