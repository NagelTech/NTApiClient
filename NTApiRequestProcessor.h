//
//  NTApiRequestProcessor.h
//
//  Copyright (c) 2011-2012 Ethan Nagel. All rights reserved.
//  See LICENSE for license details
//

#import <Foundation/Foundation.h>


@interface NTApiRequestProcessor : NSObject


@property (copy, nonatomic, readwrite)     void (^responseHandler)(NTApiRequestProcessor *processor);
@property (copy, nonatomic, readwrite)     void (^uploadProgressHandler)(int bytesSent, int totalBytes);
@property (copy, nonatomic, readwrite)     void (^downloadProgressHandler)(int bytesReceived, int totalBytes);

@property (readonly, nonatomic)           NSURLRequest   *request;
@property (readonly, nonatomic)           NSURLResponse  *response;
@property (readonly, nonatomic)           NSData         *data;
@property (readonly, nonatomic)           NSError        *error;
@property (readonly, nonatomic)           NSDate         *startTime;
@property (readonly, nonatomic)           NSDate         *endTime;
@property (readonly, nonatomic)           int             httpStatusCode;


-(id)initWithURLRequest:(NSURLRequest *)request;

-(void)start;
-(void)cancel;


@end
