//
//  NTApiRequest.m
//  Anchor
//
//  Created by Ethan Nagel on 5/22/13.
//  Copyright (c) 2013 Tomfoolery, Inc. All rights reserved.
//

#import "NTApiRequest.h"

#import "NTApiRequestProcessor.h"


@interface NTApiRequest ()
{
    NTApiRequestProcessor __weak *_requestProcessor;
}

@end


@implementation NTApiRequest


-(id)initWithRequestProcessor:(id)requestProcessor
{
    self = [super init];
    
    if ( self )
    {
        if ( ![requestProcessor isKindOfClass:[NTApiRequestProcessor class]] )
            @throw [NSException exceptionWithName:@"UnexpectedArgument" reason:@"NTApRequest expected a NTApiRequestProcessor instance and got something else." userInfo:nil];
        
        _requestProcessor = requestProcessor;
    }
    
    return self;
}


-(BOOL)isRunning
{
    NTApiRequestProcessor *requestProcessor = _requestProcessor;
    
    return (requestProcessor && requestProcessor.isRunning) ? YES : NO;
}


-(void)cancel
{
    NTApiRequestProcessor *requestProcessor = _requestProcessor;
    
    if ( requestProcessor )
        [requestProcessor cancel];
}


@end
