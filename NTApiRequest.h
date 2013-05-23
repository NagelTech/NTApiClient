//
//  NTApiRequest.h
//  Anchor
//
//  Created by Ethan Nagel on 5/22/13.
//  Copyright (c) 2013 Tomfoolery, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NTApiRequest : NSObject

-(id)initWithRequestProcessor:(id)requestProcessor;

@property (readonly,nonatomic) BOOL isRunning;

-(void)cancel;

@end
