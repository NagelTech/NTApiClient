//
//  OpenWeatherApiClient.h
//  NTApiSample
//
//  Created by Ethan Nagel on 1/27/14.
//  Copyright (c) 2014 Nagel Technologies, Inc. All rights reserved.
//


#import "NTApiClient.h"

@class CurrentWeather;

typedef NSString *OpenWeatherApiUnit;
extern OpenWeatherApiUnit OpenWeatherApiUnitImperial;
extern OpenWeatherApiUnit OpenWeatherApiUnitMetric;


@interface OpenWeatherApiClient : NTApiClient

@property (nonatomic) NSString *appid;
@property (nonatomic) OpenWeatherApiUnit unit;

+(instancetype)apiClient;

+(NSSet *)allUnits;

-(NTApiRequest *)beginGetCurrentWeatherWithCityCodes:(NSArray *)cityCodes responseHandler:(void (^)(NSArray *currentWeatherItems, NTApiError *error))responseHandler;

@end
