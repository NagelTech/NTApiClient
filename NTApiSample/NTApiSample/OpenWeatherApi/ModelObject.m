//
//  ModelObject.m
//  NTApiSample
//
//  Created by Ethan Nagel on 1/27/14.
//  Copyright (c) 2014 Nagel Technologies, Inc. All rights reserved.
//

#import "ModelObject.h"


@implementation ModelObject


-(instancetype)initWithJson:(NSDictionary *)json
{
    return self;    // we don't really do anything at this level
}


+(NSArray *)itemArrayWithJsonArray:(NSArray *)jsonArray
{
    NSMutableArray *items = [NSMutableArray arrayWithCapacity:jsonArray.count];
    
    for(NSDictionary *json in jsonArray)
    {
        ModelObject *item = [[self alloc] initWithJson:json];
        
        if ( item )
            [items addObject:item];
    }
    
    return [items copy];
}


@end
