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
        _cityCode = [json objectForKey:@"id"];
        _cityName = [json objectForKey:@"name"];
        
        NSDictionary *weather = [[json objectForKey:@"weather"] lastObject];
        
        _weatherDescription = [weather objectForKey:@"description"];
        _weatherIcon = [weather objectForKey:@"icon"];
        
        NSDictionary *main = [json objectForKey:@"main"];
        
        _temp = [[main objectForKey:@"temp"] floatValue];
        
        if ( [OpenWeatherApiClient getDefault:@"unit"] == OpenWeatherApiUnitMetric )
            _temp -= 273.15;   // convert from kelvin to celsius if metric
    }
    
    return self;
}


@end
