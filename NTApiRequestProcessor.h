//
//  NTApiRequestProcessor.h
//
//  Copyright (c) 2011-2012 Ethan Nagel. All rights reserved.
//  See LICENSE for license details
//

#import <Foundation/Foundation.h>


@interface NTApiRequestProcessor : NSObject


@property (copy, nonatomic, readwrite)     void (^responseHandler)(NSData *, NSURLResponse *,  NSError *);
@property (copy, nonatomic, readwrite)     void (^uploadProgressHandler)(int bytesSent, int totalBytes);
@property (copy, nonatomic, readwrite)     void (^downloadProgressHandler)(int bytesReceived, int totalBytes);


-(id)initWithURLRequest:(NSURLRequest *)request;

-(void)start;
-(void)cancel;


@end
