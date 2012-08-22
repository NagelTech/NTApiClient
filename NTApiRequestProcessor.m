//
//  NTApiRequestProcesor.m
//
//  Copyright (c) 2011-2012 Ethan Nagel. All rights reserved.
//  See LICENSE for license details
//

#import "NTApiRequestProcessor.h"


// ARC is required

#if !__has_feature(objc_arc)
#   error ARC is required for NTApiClient
#endif



@interface NTApiRequestProcessor () <NSURLConnectionDelegate>
{
    NSURLRequest *mRequest;
    NSURLResponse *mResponse;
    NSMutableData *mData;
    NSURLConnection *mConnection;
    NSError *mError;
    int mExpectedContentLength;
    BOOL mShouldCacheResponse;
    
    NSDate   *mStartTime;           // when we start sending the request
    NSDate   *mEndTime;             // when we have got the entire response
}


@end


@implementation NTApiRequestProcessor


@synthesize responseHandler = mResponseHandler;
@synthesize uploadProgressHandler = mUploadProgressHandler;
@synthesize downloadProgressHandler = mDownloadProgressHandler;

@synthesize request = mRequest;
@synthesize response = mResponse;
@synthesize data = mData;
@synthesize error = mError;
@synthesize startTime = mStartTime;
@synthesize endTime = mEndTime;
@synthesize httpStatusCode = mHttpStatusCode;


-(id)initWithURLRequest:(NSURLRequest *)request
{
    if ( (self=[super init]) )
    {
        mRequest = request;
    }
    
    return self;
}


-(void)start
{
//    LLog(@"Starting request: %@", mRequest.URL);
    
    mStartTime = [NSDate date];
    
    mConnection = [[NSURLConnection alloc] initWithRequest:mRequest delegate:self startImmediately:NO];

    [mConnection start];
}


-(void)cancel
{
    // todo: make sure we are running, etc.
    
    [mConnection cancel];
}


#pragma mark NSURLConnectionDelegate methods


-(void)connection:(NSURLConnection *)connection didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite
{
    // todo: I'm not sure this ever gets called or is really valid...
    
    //    LDebug(@"didSendBodyData %d/%d bytes", totalBytesWritten, totalBytesExpectedToWrite);
    
    if ( mUploadProgressHandler )
        mUploadProgressHandler(totalBytesWritten, totalBytesExpectedToWrite);
}


- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
//    LDebug(@"didReceiveResponse");
    mResponse = response;
    mExpectedContentLength = (response.expectedContentLength == NSURLResponseUnknownLength) ? 0 : response.expectedContentLength;
    mData = [NSMutableData dataWithCapacity:mExpectedContentLength];
    
    if ( [response isKindOfClass:[NSHTTPURLResponse class]] )
    {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        
        mHttpStatusCode = httpResponse.statusCode;
    }
    
    if ( mDownloadProgressHandler ) // 0% downloaded
        mDownloadProgressHandler(0, mExpectedContentLength);
}


- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
//    LError(@"connectionDidFailWithError: %@", error);
    
    mEndTime = [NSDate date];
    mError = error;
    
    if ( mResponseHandler )
        mResponseHandler(self);
}


- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    //    LLog(@"connectionDidFinishLoading");
    
    mEndTime = [NSDate date];
    
    // If we have a download progress handler and we didn't end up with the size we thought we would have, go ahead and 
    // do a final update...
    
    if ( mDownloadProgressHandler && mData.length != mExpectedContentLength )
    {
        mDownloadProgressHandler(mData.length, mData.length);
    }
    
    mError = nil;
    
    if ( mResponseHandler )
        mResponseHandler(self);
}


- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [mData appendData:data];
    
//    LDebug(@"didReceiveData: (received %d) %d/%d bytes", data.length, mData.length, mExpectedContentLength);

    if ( mDownloadProgressHandler )
        mDownloadProgressHandler(mData.length, mExpectedContentLength);
}



- (NSCachedURLResponse *)connection:(NSURLConnection *)connection
                  willCacheResponse:(NSCachedURLResponse *)cachedResponse
{
    return mShouldCacheResponse ? cachedResponse : nil;
}



@end
