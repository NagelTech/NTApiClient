//
//  OpenWeatherApiClient.m
//  NTApiSample
//
//  Created by Ethan Nagel on 1/27/14.
//  Copyright (c) 2014 Nagel Technologies, Inc. All rights reserved.
//

#import "OpenWeatherApiClient.h"


OpenWeatherApiUnit OpenWeatherApiUnitImperial = @"imperial";
OpenWeatherApiUnit OpenWeatherApiUnitMetric = @"metric";


@implementation OpenWeatherApiClient


+(instancetype)apiClient
{
    return [[OpenWeatherApiClient alloc] init];
}


+(NSSet *)allUnits
{
    static NSSet *allUnits = nil;
    
    if ( !allUnits )
        allUnits = [NSSet setWithArray:@[OpenWeatherApiUnitMetric, OpenWeatherApiUnitImperial]];
    
    return allUnits;
}


-(id)init
{
    self = [super init];
    
    if ( self )
    {
        self.unit = [self.class getDefault:@"unit"];
        self.appid = [self.class getDefault:@"appid"];
    }
    
    return self;
}


-(NTApiRequest *)beginDirectRequest:(NSString *)command args:(NSArray *)args responseHandler:(void (^)(NSDictionary *data, NTApiError *error))responseHandler
{
    // This method should do whatever is common to ALL requests - generally extracting error messages, etc.
    
    // We always want to get JSON responses, so we will add that argument here. Also, if an appid is provided we will include it
    
    args = [args arrayByAddingObjectsFromArray:
            @[
                [NTApiUrlArg argWithName:@"mode" string:@"json"],
                [NTApiHeaderArg headerWithName:@"x-api-key" value:self.appid],  // pass as a http header to show how ;)
            ]];
    
    NTApiRequest *request = [self beginRequest:command args:args responseHandler:^(NTApiResponse *response)
    {
        NTApiError *error = response.error;
        
        // If there wasn't a system error, see if we can find an error from the API and instantiate it...
        
        if ( !error )
        {
            // Note: as far as I know, the OpenWearher API doesn't return this, it's more of an example...
            NSDictionary *errorJson = [response.json valueForKey:@"error"];

            if ( errorJson )
                error = [NTApiError errorWithCode:[errorJson valueForKey:@"code"] message:[errorJson valueForKey:@"message"]];
        }
        
        responseHandler(response.json, error);
    }];
    
    return request;
}


-(NTApiRequest *)beginStdRequest:(NSString *)command args:(NSArray *)args responseHandler:(void (^)(NSDictionary *data, NTApiError *error))responseHandler
{
    // This method should hanbdle items that are generally common to requests. It may add standard parameters such
    // as a session token or even make multiple API calls to do something like re-authenticate transparently. It should
    // make one or more calls to beginDirectRequest.

    args = [args arrayByAddingObjectsFromArray:
            @[
                [NTApiUrlArg argWithName:@"units" string:self.unit],
              ]
            ];
    
    return [self beginDirectRequest:command args:args responseHandler:responseHandler];
}


-(NTApiRequest *)beginGetCurrentWeatherWithCityCodes:(NSArray *)cityCodes responseHandler:(void (^)(NSArray *currentWeatherItems, NTApiError *error))responseHandler
{
    NSString *codesCSV = [cityCodes componentsJoinedByString:@","];
    
    return [self beginStdRequest:@"group"
                            args:@[
                                   [NTApiUrlArg argWithName:@"id" string:codesCSV],
                                   ]
                 responseHandler:^(NSDictionary *data, NTApiError *error)
    {
        NSArray *currentWeatherItems = nil;
        
        if ( data )
        {
            NSArray *jsonItems = [data objectForKey:@"list"];
            
            currentWeatherItems = [CurrentWeather itemArrayWithJsonArray:jsonItems];
        }
        

        responseHandler(currentWeatherItems, error);
    }];
}


@end


