//
//  AppSettings.m
//  NTApiSample
//
//  Created by Ethan Nagel on 2/2/14.
//  Copyright (c) 2014 Nagel Technologies, Inc. All rights reserved.
//

#import "AppSettings.h"


#define DEFAULT_CITY_CODES @"5391959,5128581,2643743,1816670,2147714"        // SF,New York,London,Beijing,Sydney


@interface AppSettings ()
{
    NSArray *_cityCodes;
}

@end


@implementation AppSettings


+(instancetype)defaultSettings
{
    static AppSettings *defaultSettings = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        defaultSettings = [[AppSettings alloc] init];
    });
    
    return defaultSettings;
}


#pragma mark - cityCodes


-(NSArray *)cityCodes
{
    if ( !_cityCodes )
    {
        NSString *csv = [NSUserDefaults.standardUserDefaults valueForKey:@"cityCodes"];
        
        if ( !csv )
        {
            csv = DEFAULT_CITY_CODES;
        }
        
        _cityCodes = [csv componentsSeparatedByString:@","];
    }
    
    return _cityCodes;
}


-(void)setCityCodes:(NSArray *)cityCodes
{
    if ( _cityCodes == cityCodes || [_cityCodes isEqualToArray:cityCodes] )
        return ;
    
    NSString *csv = [cityCodes componentsJoinedByString:@","];
    
    [NSUserDefaults.standardUserDefaults setValue:csv forKey:@"cityCodes"];
    [NSUserDefaults.standardUserDefaults synchronize];
    
    _cityCodes = cityCodes;
}


@end
