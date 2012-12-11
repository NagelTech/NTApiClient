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

@property (readwrite, nonatomic, retain)            NSData          *data;
@property (readwrite, nonatomic, retain)            NSDictionary    *json;
@property (readwrite, nonatomic, retain)            NTApiError      *error;
@property (readwrite, nonatomic, retain)            NSDate          *startTime;
@property (readwrite, nonatomic, retain)            NSDate          *endTime;
@property (readwrite, nonatomic, assign)            int              httpStatusCode;
@property (readwrite, nonatomic, retain)            NSDictionary    *headers;
@property (readwrite, nonatomic, retain)            NSString        *prefixText;

@property (readonly,nonatomic, assign)              int              elapsedMS;

+(NTApiResponse *)responseWithError:(NTApiError *)error;

@end
