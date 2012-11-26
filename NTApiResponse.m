//
//  NTApiResponse.m
//  TakeANumber-iOS
//
//  Created by Ethan Nagel on 11/25/12.
//  Copyright (c) 2012 Tomfoolery, Inc. All rights reserved.
//

#import "NTApiResponse.h"

@implementation NTApiResponse


-(int)elapsedMS
{
    return (self.startTime && self.endTime) ? (int)([self.endTime timeIntervalSinceDate:self.startTime] * 1000.0) : -1;
}


+(NTApiResponse *)responseWithError:(NTApiError *)error
{
    NTApiResponse *response = [[NTApiResponse alloc] init];
    
    response.error = error;
    
    return response;
}


@end
