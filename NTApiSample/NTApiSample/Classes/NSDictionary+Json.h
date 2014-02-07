//
//  NSDictionary+Json.h
//  NTApiSample
//
//  Created by Ethan Nagel on 2/3/14.
//  Copyright (c) 2014 Nagel Technologies, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (Json)

-(NSString *)stringForKey:(NSString *)key;
-(float)floatForKey:(NSString *)key;
-(NSDictionary *)dictionaryForKey:(NSString *)key;
-(NSArray *)arrayForKey:(NSString *)key;

@end
