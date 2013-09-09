//
//  NTApiRequestProcesor.m
//
//  Copyright (c) 2011-2012 Ethan Nagel. All rights reserved.
//  See LICENSE for license details
//

#import "NTApiRequestProcessor.h"
#import "NTApiResponse.h"
#import "NTApiError.h"


// ARC is required

#if !__has_feature(objc_arc)
#   error ARC is required for NTApiClient
#endif


@interface NTApiRequestProcessor () <NSURLConnectionDelegate>
{
    NSURLConnection *_connection;
    int _expectedContentLength;
    BOOL _shouldCacheResponse;
    BOOL _isRunning;
}


@property (readonly,nonatomic) NSMutableData *data;


@end


@implementation NTApiRequestProcessor


-(NSMutableData *)data
{
    return (NSMutableData *)_response.data;
}



-(id)initWithURLRequest:(NSURLRequest *)request
{
    if ( (self=[super init]) )
    {
        _request = request;
        _response = [[NTApiResponse alloc] init];
        _response.request = request;
    }
    
    return self;
}


-(void)start
{
//    LLog(@"Starting request: %@", mRequest.URL);
    
    _response.startTime = [NSDate date];
    
    _connection = [[NSURLConnection alloc] initWithRequest:_request delegate:self startImmediately:NO];

    [_connection start];
}


-(BOOL)isRunning
{
    return (_connection && !_response.endTime) ? YES : NO;
}


-(void)cancel
{
    // todo: make sure we are running, etc.
    
    [_connection cancel];
}


#pragma mark NSURLConnectionDelegate methods


-(void)connection:(NSURLConnection *)connection didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite
{
    // todo: I'm not sure this ever gets called or is really valid...
    
    //    LDebug(@"didSendBodyData %d/%d bytes", totalBytesWritten, totalBytesExpectedToWrite);
    
    if ( _uploadProgressHandler )
        _uploadProgressHandler(totalBytesWritten, totalBytesExpectedToWrite);
}


- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
//    LDebug(@"didReceiveResponse");
    _expectedContentLength = (response.expectedContentLength == NSURLResponseUnknownLength) ? 0 : response.expectedContentLength;
    _response.data = [NSMutableData dataWithCapacity:_expectedContentLength];

    
    if ( [response isKindOfClass:[NSHTTPURLResponse class]] )
    {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        
        _response.httpStatusCode = httpResponse.statusCode;
        _response.headers = httpResponse.allHeaderFields;
    }
    
    if ( _downloadProgressHandler ) // 0% downloaded
        _downloadProgressHandler(0, _expectedContentLength);
}


- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
//    LError(@"connectionDidFailWithError: %@", error);
    
    _response.endTime = [NSDate date];

    _response.error = [NTApiError errorWithNSError:error];
    
    if ( error.code == -1009 || error.code == -1004 )    // Yep, magic number.  I bet there's a constant somewhere
        _response.error.errorCode = NTApiErrorCodeNoInternet;
    
    if ( _responseHandler )
        _responseHandler(_response);
}


- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    //    LLog(@"connectionDidFinishLoading");
    
    _response.endTime = [NSDate date];
    
    // If we have a download progress handler and we didn't end up with the size we thought we would have, go ahead and 
    // do a final update...
    
    if ( _downloadProgressHandler && self.data.length != _expectedContentLength )
    {
        _downloadProgressHandler(self.data.length, self.data.length);
    }
    
    _response.error = nil;
    
    if ( _responseHandler )
        _responseHandler(_response);
}


- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [self.data appendData:data];
    
//    LDebug(@"didReceiveData: (received %d) %d/%d bytes", data.length, mData.length, mExpectedContentLength);

    if ( _downloadProgressHandler )
        _downloadProgressHandler(self.data.length, _expectedContentLength);
}



- (NSCachedURLResponse *)connection:(NSURLConnection *)connection
                  willCacheResponse:(NSCachedURLResponse *)cachedResponse
{
    return _shouldCacheResponse ? cachedResponse : nil;
}



@end
