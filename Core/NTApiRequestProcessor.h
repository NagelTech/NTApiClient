//
//  NTApiRequestProcessor.h
//
//  Copyright (c) 2011-2012 Ethan Nagel. All rights reserved.
//  See LICENSE for license details
//

#import <Foundation/Foundation.h>

#import "NTApiRequest.h"


@class NTApiResponse;

/**
 * Internal helper class that actually performs the request using NSURLRequest.
 */
@interface NTApiRequestProcessor : NTApiRequest


@property (copy, nonatomic, readwrite)     void (^responseHandler)(NTApiResponse *response);
@property (copy, nonatomic, readwrite)     void (^uploadProgressHandler)(int bytesSent, int totalBytes);
@property (copy, nonatomic, readwrite)     void (^downloadProgressHandler)(int bytesReceived, int totalBytes);
@property (nonatomic)                      BOOL allowInvalidSSLCert;

@property (readonly, nonatomic)           NSURLRequest   *request;
@property (readonly, nonatomic)           NTApiResponse  *response;


-(id)initWithURLRequest:(NSURLRequest *)request;

-(BOOL)isRunning;

-(void)start;
-(void)cancel;


@end
