//
//  CurrentWeather.h
//  NTApiSample
//
//  Created by Ethan Nagel on 1/27/14.
//  Copyright (c) 2014 Nagel Technologies, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ModelObject.h"


@interface CurrentWeather : ModelObject

@property (nonatomic) NSString *cityCode;
@property (nonatomic) NSString *cityName;
@property (nonatomic) NSString *country;
@property (nonatomic) NSString *weatherDescription;
@property (nonatomic) NSString *weatherIcon;
@property (nonatomic) float temp;

@end
