NTApiClient
===========

A simple and flexible JSON-based API client for iOS.

NTApiClient is intended to used as a base class for your own JSON-based API. NTApiClient ultimately uses NSURLRequest to perform its processing. Request processing is handled on a background thread and your response handling may be either handled in a background thread,
the main thread or the thread that started the request (current thread).

NTArgs
------

At it's heart the system is controlled through an array of NTApiArgs - arguments ay be simple items like a URL argument or a form parameter. NTApiArgs may also be used to set headers or control the overall request such as the tomeout or the thread to handle the response in. Because this is an array that you can build and process it allows a lot of flexibility. You can think of the array of args as a very specific DSL. The following NTArgs are support:

 - Passing Data
   - `NTApiUrlArg` - A query string value
   - `NTApiFormArg` - A form value (POST semantics)
   - `NTApiMultipartArg` - A multipart attachment
   - `NTApiRawDataArg` - Send raw data with no additional processing
   - `NTApiBaseUrlArg` - Override the default baseUrl
 - Setting Headers
   - `NTApiHeaderArg` - A header value
   - `NTApiBasicAuthArg` - A Basic Auth header
 - Controlling the overall request
   - `NTApiOptionArg` - Set several overall options for the request including the threading model to use.
   - `NTApiTimeoutArg` - Override the default timeout
   - `NTApiHttpMethodArg` - Override the default HTTP method.
   - `NTApiCachePolicyArg` - Override the default cache policy.

Defaults
--------
Defaults allow you to set global values that may be overridden on a per request basis. This is a very convenient way to set values such as the baseUrl for your request. Additionally, defaults may be implemented using a protocol to allow "dynamic" default values such as a session id.

Threading
---------

Each request is processed using several threads:

 1. The request is created (parsing the NTApiArgs int an `NSURLRequest`) on the calling thread
 2. `NSURLRequest` delegate processing is handled on a single shared backgroud thread (the NTApiRequestThread). This processing is limited to capturing the downloading data, catching errors, etc. If upload or download progress handlers have been set, these will be called on the indicated thread - not the NTApiRequestThread.
 3. Once request processing is completed, response processing begins on a separate background thread. This is where JSON is parsed.
 4. finally, your responseHandler is called using the thread indicated (main, background or the thread that made the original request.)
 
An iOS background task is started for each request and lasts until your responseHandler returns, so your task should generally complete even if the app moves into background state.

Logging
-------

Good logging is really important for an API. By default NTApi will log messages to NSLog using an overridable method -(void)writeLogWithType:andFormat:. You may override this to log to your favorite logging subsystem. Additionally, if you are using CocoaPods and install NTLog the NTAPIClient will automatically use it. You can disable all logging via a macro as well. (see NTAPI_LOG_* macros.) You can easily add another logging system that will be used automatically, if you're interested see how NTLog is configured and send a pull request!

You can programmatically control what is logged with the logFlags property. This can be set on a per instance basis or set globally using the "logFlags" default.

Release History
---------------

 - 1.10 - 14-Mar-2014 Added support for self-signed SSL certificates with the arg `[NTApiOptionArg optionAllowInvalidSSLCert:YES]`.

 - 1.00 - 7-Feb-2014 Initial version submitted to cocoapods. Added documentation and a nice sample.
   
CocoaPods Installation
======================
Doesn't CocoaPods rock? There's nothing tricky about this podspec, just include it and you are good to go:

    pod 'NTApiClient'
    
If you are also using the 'NTLog' pod, some fancy acros will detect this and send log messages there for you. Neato.

Old School Installation
=======================
Simply add the files from the `Core` folder into your project and enjoy!

Usage
=====

Your API class
--------------

NTApiClient is designed to be subclassed to implement your own API. You can see the sample application for a decent example of how to do this. All the hard work for NTApiClient is done through the beginRequest: method - you will typically want to wrap this method with one that handles your shared API logic. Actually, I recomment using two methods as follows:

    -(NTApiRequest *)beginDirectRequest:(NSString *)command args:(NSArray *)args responseHandler:(void (^)(NSDictionary *data, NTApiError *error))responseHandler
    {
        // This method should do whatever is common to ALL requests - generally extracting error messages or adding args that are common to all requests. 
        
        NTApiRequest *request = [self beginRequest:command args:args responseHandler:^(NTApiResponse *response)
        {
            NTApiError *error = response.error;
            
            // If there wasn't a system error, see if we can find an error from the API and instantiate it...
            
            if ( !error )
            {
            	/// TODO: Extract any API error code that was returned
            }
            
            responseHandler(response.json, error);
        }];
        
        return request;
    }

    -(NTApiRequest *)beginStdRequest:(NSString *)command args:(NSArray *)args responseHandler:(void (^)(NSDictionary *data, NTApiError *error))responseHandler
    {
        // This method should handle items that are generally common to requests. It may add standard parameters such
        // as a session token or even make multiple API calls to do something like re-authenticate transparently. It should
        // make one or more calls to beginDirectRequest.

        return [self beginDirectRequest:command args:args responseHandler:responseHandler];
    }

Your API methods should generally call beginStdRequest to leverage your standard request processing. Here's an API method from the sample application to giv you an idea of how this might be implmented. Here we are parsing the response into our business objects and returning them.

    -(NTApiRequest *)beginFindCitiesWithName:(NSString *)cityName searchType:(OpenWeatherSearchType)searchType maxItems:(int)maxItems  responseHandler:(void (^)(NSArray *currentWeatherItems, NTApiError *error))responseHandler
    {
        return [self beginStdRequest:@"find"
                                args:@[
                                       [NTApiUrlArg argWithName:@"q" string:cityName],
                                       [NTApiUrlArg argWithName:@"type" string:searchType],
                                       [NTApiUrlArg argWithName:@"cnt" intValue:maxItems],
                                       ]
                     responseHandler:^(NSDictionary *data, NTApiError *error)
        {
            NSArray *currentWeatherItems = nil;
            
            if ( data )
            {
                NSArray *jsonItems = [data arrayForKey:@"list"];

                currentWeatherItems = [CurrentWeather itemArrayWithJsonArray:jsonItems];
            }
            
            responseHandler(currentWeatherItems, error);
        }];
    }

You can implement your own defaults by loading them in your init method. This allows your client code to override them as needed in a per API client instance basis. This example is also from the sample application.

    -(id)init
    {
        self = [super init];
        
        if ( self )
        {
            self.appid = [self.class getDefault:@"appid"];
        }
        
        return self;
    }

If you would like to have your API error codes converted into "NSString enum's" for you, you can register them with `NTApiError`. This will convert them to your constant values automatically so you can use == instead of `isEqualToString:`. The best place to do this is in your `+load' method as follows:

    +(void)load
    {
        [NTApiError addErrorCode:OpenWeatherErrorCodeNotFound];
    }

Initialization
--------------

You will typically want to configure your API server, etc as a defaults when your application starts up. This can be done in your AppDelegate's `didFinishLoadingWithOptions` as follows:

    [OpenWeatherApiClient setDefault:@"baseUrl" value:@"http://api.openweathermap.org/data/2.5"];
    [OpenWeatherApiClient setDefault:@"appid" value:OPENWEATHER_APPID];

Making API Calls
----------------

Using the API is pretty straight forward, here's an example. (Note this assumes a helper to create an instance - `+apiClient`)

    [[OpenWeatherApiClient apiClient] beginFindCitiesWithName:cityName
                                                   searchType:OpenWeatherSearchTypeLike
                                                     maxItems:20
                                              responseHandler:^(NSArray *currentWeatherItems, NTApiError *error)
    {
        if ( error ) // display API errors
        {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error getting weather"
                                                    message:error.errorMessage
                                                               delegate:nil
                                                      cancelButtonTitle:@"Ok"
                                                      otherButtonTitles:nil];
            
            [alertView show];
            
            return ;
        }
        
        self.currentWeatherItems = currentWeatherItems;
        [self.tableView reloadData];
    }];

