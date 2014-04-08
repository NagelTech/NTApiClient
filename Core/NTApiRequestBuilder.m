//
//  NTApiRequestBuilder.m
//
//  Copyright (c) 2011-2012 Ethan Nagel. All rights reserved.
//  See LICENSE for license details
//

#import "NTApiRequestBuilder.h"

#import "NTApiError.h"
#import "NTApiArg.h"

// ARC is required

#if !__has_feature(objc_arc)
#   error ARC is required for NTApiClient
#endif


@interface NTApiRequestBuilder () // private

@property (strong,nonatomic)    NSArray             *args;
@property (strong, nonatomic)   NTApiError          *error;
@property (strong,nonatomic)    NSString            *multipartBoundry;
@property (nonatomic)           NSString            *defaultHttpMethod;


-(BOOL)initializeMultipart;

@end


@implementation NSMutableData (NTApiClientHelper)


-(void)appendFormat:(NSString *)format, ...
{
    // A little helper to append formatted text to NSMutableData...
    
    va_list args;
    va_start(args, format);
    
    NSString *string = [[NSString alloc] initWithFormat:format arguments:args];
    
    NSData *data=[string dataUsingEncoding:NSUTF8StringEncoding];
    
    [self appendData:data];
}


@end


@implementation NTApiRequestBuilder


@synthesize args = mArgs;
@synthesize error = mError;
@synthesize multipartBoundry = mMulipartBoundry;

@synthesize baseUrl = mBaseUrl;
@synthesize headers = mHeaders;
@synthesize options = mOptions;
@synthesize httpMethod = mHttpMethod;
@synthesize timeout = mTimeout;
@synthesize cachePolicy = mCachePolicy;
@synthesize urlString = mUrlString;
@synthesize formString = mFormString;
@synthesize multipartData = mMulipartData;
@synthesize rawData = mRawData;
@synthesize defaultHttpMethod = mDefaltHttpMethod;


+(NSString *)urlEncode:(NSString *)string
{
    // based on: http://madebymany.com/blog/url-encoding-an-nsstring-on-ios
    
    return (__bridge_transfer NSString *)CFURLCreateStringByAddingPercentEscapes(NULL,
                                                                                 (__bridge CFStringRef)string,
                                                                                 NULL,
                                                                                 (CFStringRef)@"!*'\"();:@&=+$,/?%#[]% ",
                                                                                 CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding));
}


static char NTBase64EncodingTable[64] = {
    'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P',
    'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z', 'a', 'b', 'c', 'd', 'e', 'f',
    'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v',
    'w', 'x', 'y', 'z', '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '+', '/'
};




+(NSString *)base64Encode:(NSData *)data
{
    // from http://stackoverflow.com/questions/392464/any-base64-library-on-iphone-sdk
    
    unsigned long ixtext, lentext;
    long ctremaining;
    unsigned char input[3], output[4];
    short i, charsonline = 0, ctcopy;
    const unsigned char *raw;
    NSMutableString *result;
    
    lentext = [data length];
    if (lentext < 1)
        return @"";
    result = [NSMutableString stringWithCapacity: lentext];
    raw = [data bytes];
    ixtext = 0;
    
    while (true) {
        ctremaining = lentext - ixtext;
        if (ctremaining <= 0)
            break;
        for (i = 0; i < 3; i++) {
            unsigned long ix = ixtext + i;
            if (ix < lentext)
                input[i] = raw[ix];
            else
                input[i] = 0;
        }
        output[0] = (input[0] & 0xFC) >> 2;
        output[1] = ((input[0] & 0x03) << 4) | ((input[1] & 0xF0) >> 4);
        output[2] = ((input[1] & 0x0F) << 2) | ((input[2] & 0xC0) >> 6);
        output[3] = input[2] & 0x3F;
        ctcopy = 4;
        switch (ctremaining) {
            case 1:
                ctcopy = 2;
                break;
            case 2:
                ctcopy = 3;
                break;
        }
        
        for (i = 0; i < ctcopy; i++)
            [result appendString: [NSString stringWithFormat: @"%c", NTBase64EncodingTable[output[i]]]];
        
        for (i = ctcopy; i < 4; i++)
            [result appendString: @"="];
        
        ixtext += 3;
        charsonline += 4;
        
        if ((data.length > 0) && (charsonline >= data.length))
            charsonline = 0;
    }
    return result;
    
}


-(id)initWithArgs:(NSArray *)args
{
    if ( (self=[super init]) )
    {
        self.args = args;
        
    }
    
    return self;
}


-(NSString *)multipartBoundry
{
    if ( !mMulipartBoundry )
        mMulipartBoundry = [NSString stringWithFormat:@">>>>%f<<<<", [NSDate timeIntervalSinceReferenceDate]];
    
    return mMulipartBoundry;
}


-(BOOL)addUrlValueWithName:(NSString *)name value:(NSString *)value
{
    if ( !value )
        return YES; // ignore nil values
    
    if ( self.urlString.length > 0 )
        [self.urlString appendString:@"&"];
    
    [self.urlString appendFormat:@"%@=%@", name, [NTApiRequestBuilder urlEncode:value]];
    
    return YES;
}


-(BOOL)addHeaderWithName:(NSString *)name value:(NSString *)value
{
    if ( !value )
        return YES; // ignore nil values
    
    [self.headers setObject:value forKey:name];
    
    return YES;
}


-(BOOL)addFormValueWithName:(NSString *)name value:(NSString *)value
{
    if ( !value )
        return YES; // ignore nil values
    
    if ( self.multipartData || self.rawData )
    {
        self.error = [NTApiError errorWithCode:NTApiErrorCodeError message:@"RequestBuilder: form data may not be combined with multipart or raw data"];
        
        return NO;
    }
    
    if ( !self.formString ) // initialize if this is the first form value
    {
        self.defaultHttpMethod = @"POST";
        self.formString = [NSMutableString new];
        [self addHeaderWithName:NTApiHeaderContentType value:@"application/x-www-form-urlencoded"];
    }
    else
        [self.formString appendString:@"&"];
    
    [self.formString appendFormat:@"%@=%@", name, [NTApiRequestBuilder urlEncode:value]];
    
    return YES;
}


-(BOOL)initializeMultipart
{
    if ( self.formString || self.rawData )
    {
        self.error = [NTApiError errorWithCode:NTApiErrorCodeError message:@"RequestBuilder: multipart data may not be combined with form or raw data"];
        
        return NO;
    }
    
    if ( !self.multipartData ) // initialize if this is the first multipart value.
    {
        self.defaultHttpMethod = @"POST";
        [self addHeaderWithName:NTApiHeaderContentType value:[NSString stringWithFormat:@"multipart/form-data; boundary=%@", self.multipartBoundry]];
        
        self.multipartData = [NSMutableData new];
        
        [self.multipartData appendFormat:@"--%@\r\n", self.multipartBoundry];
    }
    
    return YES;
}


-(BOOL)addMultipartValueWithName:(NSString *)name value:(NSString *)value
{
    if ( !value )
        return YES; // ignore nil values
    
    if ( ![self initializeMultipart] )
        return NO;
    
    [self.multipartData appendFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n", name];
    
    [self.multipartData appendFormat:@"\r\n"];
    [self.multipartData appendFormat:@"%@", value];
    [self.multipartData appendFormat:@"\r\n"];
    
    [self.multipartData appendFormat:@"--%@\r\n", self.multipartBoundry];
    
    return YES;
}



-(BOOL)addMultipartDataWithName:(NSString *)name data:(NSData *)data extension:(NSString *)extension
{
    if ( !data )
        return YES; // ignore nil values
    
    if ( ![self initializeMultipart] )
        return NO;
    
    [self.multipartData appendFormat:@"Content-Disposition: form-data; name=\"%@\"; attachment; filename=\"%@.%@\"\r\n", name, name, (extension) ? extension : @"bin"];
    
    [self.multipartData appendFormat:@"\r\n"];
    [self.multipartData appendData:data];
    [self.multipartData appendFormat:@"\r\n"];
    
    [self.multipartData appendFormat:@"--%@\r\n", self.multipartBoundry];
    
    return YES;
}


-(BOOL)addRawDataWithContentType:(NSString *)contentType data:(NSData *)data
{
    if ( !data )
        return YES; // ignore nil values
    
    if ( self.multipartData || self.formString )
    {
        self.error = [NTApiError errorWithCode:NTApiErrorCodeError message:@"RequestBuilder: raw data may not be combined with multipart or form data"];
        
        return NO;
    }
    
    if ( self.rawData )
    {
        self.error = [NTApiError errorWithCode:NTApiErrorCodeError message:@"RequestBuilder: raw data may only be defined once"];
        
        return NO;
    }
    
    self.defaultHttpMethod = @"POST";
    [self addHeaderWithName:NTApiHeaderContentType value:contentType];
    self.rawData = data;
    
    return YES;
}



-(BOOL)addOptionWithName:(NSString *)name value:(NSString *)value
{
    // note: nil values are not ignored here!
    
    [self.options setObject:(value) ? value : [NSNull null] forKey:name];
    
    return YES;
}


-(NSMutableURLRequest *)createRequest
{
    // first, initialize our state...
    
    self.error = nil; // set if we return nil
    self.multipartBoundry = nil; // will be created the first time it is accessed.
    
    self.baseUrl = nil;
    self.headers = [NSMutableDictionary new];
    self.options = [NSMutableDictionary new];
    self.httpMethod = nil;   // default - autodetect
    self.defaultHttpMethod = @"GET";
    self.timeout = 60;          // default to 60 seconds
    self.cachePolicy = NSURLRequestUseProtocolCachePolicy;  // default
    
    self.urlString = [NSMutableString new];
    
    self.formString = nil;
    self.multipartData = nil;
    self.rawData = nil;
    
    // Loop through each argument, applying it to ourselves...
    
    for(NTApiArg *arg in self.args)
    {
        if ( ![arg applyArgToBuilder:self] )
            return nil; // failed
    }
    
    // do some sanity checking...
    
    if ( !self.baseUrl )
    {
        self.error = [NTApiError errorWithCode:NTApiErrorCodeError message:@"RequestBuilder: baseUrl not set"];
        return nil;
    }
    
    // Now that we have applied all our arguments successfully, we can build the request...
    
    NSString *url = (self.urlString && self.urlString.length) ? [NSString stringWithFormat:@"%@?%@", self.baseUrl, self.urlString] : self.baseUrl;
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    
    // create our data...
    
    if ( self.multipartData != nil )  // multipart data...
        [request setHTTPBody:self.multipartData];
    
    else if ( self.formString != nil ) // url encoded form data...
        [request setHTTPBody:[self.formString dataUsingEncoding:NSUTF8StringEncoding]];
    
    else if ( self.rawData != nil )
        [request setHTTPBody:self.rawData];
    else
        [request setHTTPBody:[@"" dataUsingEncoding:NSUTF8StringEncoding]]; // It's an empty request, but we can't leave it null
    
    // Set our method...
    
    request.HTTPMethod = (self.httpMethod) ? self.httpMethod : self.defaultHttpMethod;
    
    // Set timeout...
    
    request.timeoutInterval = (NSTimeInterval)self.timeout;
    
    // Set cachePolicy...
    
    request.cachePolicy = self.cachePolicy;
    
    // Set headers...
    
    [request setAllHTTPHeaderFields:self.headers];
    
    return request;
}


@end
