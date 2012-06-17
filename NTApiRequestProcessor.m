//
//  NTApiRequestProcesor.m
//  Clucks
//
//  Created by Ethan Nagel on 6/13/12.
//  Copyright (c) 2012 BitDonkey, LLC. All rights reserved.
//

#import "NTApiRequestProcessor.h"


@interface NTApiRequestProcessor () <NSURLConnectionDelegate>
{
    NSURLRequest *mRequest;
    NSURLResponse *mResponse;
    NSMutableData *mData;
    NSURLConnection *mConnection;
    int mExpectedContentLength;
    BOOL mShouldCacheResponse;
    
//    NSDate   *mStartTime;
//    NSDate   *mEndTime; 
}


@end


@implementation NTApiRequestProcessor


@synthesize responseHandler = mResponseHandler;
@synthesize uploadProgressHandler = mUploadProgressHandler;
@synthesize downloadProgressHandler = mDownloadProgressHandler;


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
    LLog(@"Starting request: %@", mRequest.URL);
    
    mConnection = [[NSURLConnection alloc] initWithRequest:mRequest delegate:self startImmediately:NO];

    [mConnection start];
}


-(void)cancel
{
    // todo: make sure we are running, etc.
    
    [mConnection cancel];
}


#pragma mark NSURLConnectionDelegate methods


- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    LDebug(@"didReceiveResponse");
    mResponse = response;
    mExpectedContentLength = (response.expectedContentLength == NSURLResponseUnknownLength) ? 0 : response.expectedContentLength;
    mData = [NSMutableData dataWithCapacity:mExpectedContentLength];
    
    if ( mDownloadProgressHandler ) // 0% downloaded
        mDownloadProgressHandler(0, mExpectedContentLength);
}


- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    LError(@"connectionDidFailWithError: %@", error);
    
    if ( mResponseHandler )
        mResponseHandler(nil, nil, error);
}


- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [mData appendData:data];
    
    LDebug(@"didReceiveData: (received %d) %d/%d bytes", data.length, mData.length, mExpectedContentLength);

    if ( mDownloadProgressHandler )
        mDownloadProgressHandler(mData.length, mExpectedContentLength);
}


- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    LLog(@"connectionDidFinishLoading");
    
    // If we have a download progress handler and we didn't end up with the size we thought we would have, go ahead and 
    // do a final update...
    
    if ( mDownloadProgressHandler && mData.length != mExpectedContentLength )
    {
        mDownloadProgressHandler(mData.length, mData.length);
    }
    
    if ( mResponseHandler )
        mResponseHandler(mData, mResponse, nil);
}


- (NSCachedURLResponse *)connection:(NSURLConnection *)connection
                  willCacheResponse:(NSCachedURLResponse *)cachedResponse
{
    return mShouldCacheResponse ? cachedResponse : nil;
}



-(void)connection:(NSURLConnection *)connection didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite
{
    LDebug(@"didSendBodyData %d/%d bytes", totalBytesWritten, totalBytesExpectedToWrite);
    
    if ( mUploadProgressHandler )
        mUploadProgressHandler(totalBytesWritten, totalBytesExpectedToWrite);
}


@end
