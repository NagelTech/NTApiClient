//
//  CurrentWeather.m
//  NTApiSample
//
//  Created by Ethan Nagel on 1/27/14.
//  Copyright (c) 2014 Nagel Technologies, Inc. All rights reserved.
//

#import "CurrentWeather.h"


@implementation CurrentWeather


-(instancetype)initWithJson:(NSDictionary *)json
{
    if ( (self = [super initWithJson:json]) )
    {
        _cityCode = [json stringForKey:@"id"];
        _cityName = [json stringForKey:@"name"];
        
        NSDictionary *sys = [json dictionaryForKey:@"sys"];
        
        _country = [sys stringForKey:@"country"];
        
        NSDictionary *weather = [[json arrayForKey:@"weather"] lastObject];
        
        _weatherDescription = [weather stringForKey:@"description"];
        _weatherIcon = [weather stringForKey:@"icon"];
        
        NSDictionary *main = [json dictionaryForKey:@"main"];
        
        _temp = [main floatForKey:@"temp"];
        
        if ( [OpenWeatherApiClient getDefault:@"unit"] == OpenWeatherApiUnitMetric )
            _temp -= 273.15;   // convert from kelvin to celsius if metric
    }
    
    return self;
}


@end
