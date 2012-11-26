//
//  NTApiResponse.h
//  TakeANumber-iOS
//
//  Created by Ethan Nagel on 11/25/12.
//  Copyright (c) 2012 Tomfoolery, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>


@class NTApiError;


@interface NTApiResponse : NSObject

@property (readwrite, nonatomic)            NSData          *data;
@property (readwrite, nonatomic)            NSDictionary    *json;
@property (readwrite, nonatomic)            NTApiError      *error;
@property (readwrite, nonatomic)            NSDate          *startTime;
@property (readwrite, nonatomic)            NSDate          *endTime;
@property (readwrite, nonatomic)            int              httpStatusCode;
@property (readwrite, nonatomic)            NSDictionary    *headers;
@property (readwrite, nonatomic)            NSString        *prefixText;

@property (readonly,nonatomic)              int              elapsedMS;

+(NTApiResponse *)responseWithError:(NTApiError *)error;

@end
