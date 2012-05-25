//
//  NSURLConnection+NTCompletionHandler.h
//
// Origainally Created by Michael on July 20, 2011.
// Enhanced by Ethan Nagel - Added ARC support and downloadProgressHandler
//

#import <Foundation/Foundation.h>


@interface NSURLConnection (NTCompletionHandler)


//
// Performs an asynchronous load of the specified URL, and invokes the given
// block upon completion or error.
//
// Returns true if the connection was created successfully.
//
+ (BOOL)sendAsynchronousRequest:(NSURLRequest *)request
            shouldCacheResponse:(BOOL)shouldCache
          withCompletionHandler:(void (^)(NSData *receivedData,
                                          NSURLResponse *receivedResponse,
                                          NSError *error))completionHandler
          uploadProgressHandler:(void (^)(int bytesSent, int totalBytes))uploadProgressHandler
downloadProgressHandler:(void (^)(int bytesReceived, int totalBytes))downloadProgressHandler;

+ (BOOL)sendAsynchronousRequest:(NSURLRequest *)request
            shouldCacheResponse:(BOOL)shouldCache
          withCompletionHandler:(void (^)(NSData *receivedData,
                                          NSURLResponse *receivedResponse,
                                          NSError *error))completionHandler;

@end
