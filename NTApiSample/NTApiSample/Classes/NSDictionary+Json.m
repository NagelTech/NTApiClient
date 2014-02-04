//
//  NSDictionary+Json.m
//  NTApiSample
//
//  Created by Ethan Nagel on 2/3/14.
//  Copyright (c) 2014 Nagel Technologies, Inc. All rights reserved.
//

#import "NSDictionary+Json.h"


@implementation NSDictionary (Json)


-(NSString *)stringForKey:(NSString *)key
{
    id item = [self objectForKey:key];
    
    if ( !item || item == [NSNull null] )
        return nil;
    
    if ( [item isKindOfClass:[NSString class]] )
        return item;
    
    if ( [item respondsToSelector:@selector(stringValue)] )
        return [item stringValue];
    
    return nil; // can't convert.
}


-(float)floatForKey:(NSString *)key
{
    id item = [self objectForKey:key];
    
    if ( !item || item == [NSNull null] )
        return 0;
    
    if ( [item respondsToSelector:@selector(floatValue)] )
        return [item floatValue];
    
    return 0; // can't convert.
}


-(NSDictionary *)dictionaryForKey:(NSString *)key
{
    id item = [self objectForKey:key];
    
    if ( !item || item == [NSNull null] )
        return nil;
    
    if ( [item isKindOfClass:[NSDictionary class]] )
        return item;
 
    return nil;
}


-(NSArray *)arrayForKey:(NSString *)key
{
    id item = [self objectForKey:key];
    
    if ( !item || item == [NSNull null] )
        return nil;
    
    if ( [item isKindOfClass:[NSArray class]] )
        return item;
    
    return nil;
}


@end
