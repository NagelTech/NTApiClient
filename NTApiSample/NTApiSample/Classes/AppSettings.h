//
//  AppSettings.h
//  NTApiSample
//
//  Created by Ethan Nagel on 2/2/14.
//  Copyright (c) 2014 Nagel Technologies, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface AppSettings : NSObject

+(instancetype)defaultSettings;

@property (nonatomic) NSArray *cityCodes;

@end
