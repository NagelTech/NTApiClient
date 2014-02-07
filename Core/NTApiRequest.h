//
//  NTApiRequest.h
//  Anchor
//
//  Created by Ethan Nagel on 5/22/13.
//  Copyright (c) 2013 Tomfoolery, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>


/**
 * Represents an NTAPI Request. this is returned from NTApiClient beginRequest flavors and is useful for
 * cancelling pending requests.
 */

@interface NTApiRequest : NSObject

-(id)initWithRequestProcessor:(id)requestProcessor;

/**
 * returns YES while a request is still running (not completed.)
 */
@property (readonly,nonatomic) BOOL isRunning;

/** 
 * Call this method to cancel a reunning request. The responseHandler will be called with the response.error set to 
 * NTApiErrorRequestCancelled.
 */
-(void)cancel;

@end
