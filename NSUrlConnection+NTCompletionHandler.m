//
//  NSURLConnection+NTCompletionHandler.m
//
// Originally Created by Michael on July 20, 2011.
// Enhanced by Ethan Nagel - Added ARC support and downloadProgressHandler
//


#import "NSURLConnection+NTCompletionHandler.h"


@interface NTURLCompletionDelegate : NSObject<NSURLConnectionDataDelegate>
{
    void (^mCompletionHandler)(NSData *, NSURLResponse *,  NSError *);
    void (^mUploadProgressHandler)(int bytesSent, int totalBytes);
    void (^mDownloadProgressHandler)(int bytesReceived, int totalBytes);
    int mExpectedContentLength;
    BOOL mShouldCacheResponse;
}

@property (strong, atomic) NSMutableData *receivedData;
@property (strong, atomic) NSURLResponse *receivedResponse;


- (id)initWithCompletionHandler:(void (^)(NSData *data,
                                          NSURLResponse *response,
                                          NSError *error))completionHandler
            uploadProgressHandler:(void (^)(int bytesSent, int totalBytes))uploadProgressHandler
        downloadProgressHandler:(void (^)(int bytesReceived, int totalBytes))downloadProgressHandler
            shouldCacheResponse:(BOOL)shouldCache;

@end


@implementation NTURLCompletionDelegate

@synthesize receivedData = mReceivedData;
@synthesize receivedResponse = mReceivedResponse;


- (id)initWithCompletionHandler:(void (^)(NSData *data,
                                          NSURLResponse *response,
                                          NSError *error))completionHandler
            uploadProgressHandler:(void (^)(int bytesWritten, int totalBytes))uploadProgressHandler
        downloadProgressHandler:(void (^)(int bytesReceived, int totalBytes))downloadProgressHandler
            shouldCacheResponse:(BOOL)shouldCache
{
    if (self = [super init]) 
    {
        mCompletionHandler = (completionHandler) ? [completionHandler copy] : nil;
        mUploadProgressHandler = (uploadProgressHandler) ? [uploadProgressHandler copy] : nil;
        mDownloadProgressHandler = (downloadProgressHandler) ? [downloadProgressHandler copy] : nil;
        mShouldCacheResponse = shouldCache;
    }
    
    return self;
}


#pragma mark NSURLConnection delegate


- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    self.receivedResponse = response;
    mExpectedContentLength = (response.expectedContentLength == NSURLResponseUnknownLength) ? 0 : response.expectedContentLength;
    self.receivedData = [NSMutableData dataWithCapacity:mExpectedContentLength];

    if ( mDownloadProgressHandler ) // 0% downloaded
        mDownloadProgressHandler(self.receivedData.length, mExpectedContentLength);
}


- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    if ( mCompletionHandler )
        mCompletionHandler(nil, nil, error);

    mCompletionHandler = nil;
    mUploadProgressHandler = nil;
    mDownloadProgressHandler = nil;
    
    self.receivedData = nil;
    
    self.receivedResponse = nil;
}


- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [self.receivedData appendData:data];
    
    if ( mDownloadProgressHandler )
        mDownloadProgressHandler(self.receivedData.length, mExpectedContentLength);
}


- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    if ( mCompletionHandler )
        mCompletionHandler(self.receivedData, self.receivedResponse, nil);
    
    mCompletionHandler = nil;
    mUploadProgressHandler = nil;
    mDownloadProgressHandler = nil;
    
    self.receivedData = nil;
    self.receivedResponse = nil;
}


- (NSCachedURLResponse *)connection:(NSURLConnection *)connection
                  willCacheResponse:(NSCachedURLResponse *)cachedResponse
{
    return mShouldCacheResponse ? cachedResponse : nil;
}


-(void)connection:(NSURLConnection *)connection didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite
{
//    LDebug(@"%d/%d", totalBytesWritten, totalBytesExpectedToWrite);
    
    if ( mUploadProgressHandler )
        mUploadProgressHandler(totalBytesWritten, totalBytesExpectedToWrite);
}


@end



@implementation NSURLConnection (NTCompletionHandler)

+ (BOOL)sendAsynchronousRequest:(NSURLRequest *)request
            shouldCacheResponse:(BOOL)shouldCache
          withCompletionHandler:(void (^)(NSData *receivedData,
                                          NSURLResponse *receivedResponse,
                                          NSError *error))completionHandler
            uploadProgressHandler:(void (^)(int bytesSent, int totalBytes))uploadProgressHandler
          downloadProgressHandler:(void (^)(int bytesReceived, int totalBytes))downloadProgressHandler
{
    NTURLCompletionDelegate *delegate =
    [[NTURLCompletionDelegate alloc] initWithCompletionHandler:completionHandler
                                       uploadProgressHandler:uploadProgressHandler 
                                     downloadProgressHandler:downloadProgressHandler 
                                         shouldCacheResponse:shouldCache];
    
    NSURLConnection *connection =
    [NSURLConnection connectionWithRequest:request delegate:delegate];
    
    return connection != nil;
}


+(BOOL)sendAsynchronousRequest:(NSURLRequest *)request shouldCacheResponse:(BOOL)shouldCache withCompletionHandler:(void (^)(NSData *, NSURLResponse *, NSError *))completionHandler
{
    return [NSURLConnection sendAsynchronousRequest:request
                                shouldCacheResponse:shouldCache
                              withCompletionHandler:completionHandler
                                uploadProgressHandler:nil
                            downloadProgressHandler:nil];
}


@end
