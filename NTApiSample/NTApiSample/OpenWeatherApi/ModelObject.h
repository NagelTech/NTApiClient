//
//  ModelObject.h
//  NTApiSample
//
//  Created by Ethan Nagel on 1/27/14.
//  Copyright (c) 2014 Nagel Technologies, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ModelObject : NSObject

+(NSArray *)itemArrayWithJsonArray:(NSArray *)jsonArray;

-(instancetype)initWithJson:(NSDictionary *)json;

@end
