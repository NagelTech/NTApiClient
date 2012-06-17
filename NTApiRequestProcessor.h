//
//  NTApiRequestProcessor.h
//  Clucks
//
//  Created by Ethan Nagel on 6/13/12.
//  Copyright (c) 2012 BitDonkey, LLC. All rights reserved.
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
