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

typedef NSString *OpenWeatherSearchType;
extern OpenWeatherSearchType OpenWeatherSearchTypeAccurate;
extern OpenWeatherSearchType OpenWeatherSearchTypeLike;

extern NSString *OpenWeatherErrorCodeSuccess;
extern NSString *OpenWeatherErrorCodeError;
extern NSString *OpenWeatherErrorCodeNotFound;

@interface OpenWeatherApiClient : NTApiClient

@property (nonatomic) NSString *appid;
@property (nonatomic) OpenWeatherApiUnit unit;

+(instancetype)apiClient;

+(NSSet *)allUnits;


-(NTApiRequest *)beginFindCitiesWithName:(NSString *)cityName searchType:(OpenWeatherSearchType)searchType maxItems:(int)maxItems  responseHandler:(void (^)(NSArray *currentWeatherItems, NTApiError *error))responseHandler;

-(NTApiRequest *)beginGetCurrentWeatherWithCityCodes:(NSArray *)cityCodes responseHandler:(void (^)(NSArray *currentWeatherItems, NTApiError *error))responseHandler;

@end
