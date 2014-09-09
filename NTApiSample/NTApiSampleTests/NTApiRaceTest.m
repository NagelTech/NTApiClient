//
//  NTApiRaceTest.m
//  NTApiSample
//
//  Created by Jason Barbour LeBrun on 9/8/14.
//  Copyright (c) 2014 Nagel Technologies, Inc. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "ApiClientTypeA.h"
#import "ApiClientTypeB.h"

@interface NTApiRaceTests : XCTestCase

@end

@implementation NTApiRaceTests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

/// This test really verifies the race condition in default initialization!
/// To prove it... go into NTApiClient.m in the sefDefault method.
/// Comment out the ```dispatch_sync(sDefaultInitQueue, ^{``` and closing ```});```
/// This test will most likely fail. You may need to run tests a few times.

- (void)testRaceCondition
{
    NSString* defaultKey = @"someDefault";
    NSString* defaultKey2 = @"someDefault2";
    NSString* defaultVal = @"someDefaultval";
    NSString* defaultVal2 = @"someDefaultVal2";

    XCTestExpectation* readDefaultExpection = [self expectationWithDescription:@"read the defaults"];

    dispatch_group_t dispatch_setter_group = dispatch_group_create();

    dispatch_group_async(dispatch_setter_group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        [ApiClientTypeA setDefault:defaultKey value:defaultVal];
    });

    dispatch_group_async(dispatch_setter_group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        [ApiClientTypeA setDefault:defaultKey2 value:defaultVal2];
    });

    dispatch_group_notify(dispatch_setter_group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        XCTAssertEqual([ApiClientTypeA getDefault:defaultKey], defaultVal);
        XCTAssertEqual([ApiClientTypeA getDefault:defaultKey2], defaultVal2);
        [readDefaultExpection fulfill];
    });

    [self waitForExpectationsWithTimeout:5 handler:^(NSError *error) {
        XCTAssertFalse(error);
    }];
    
}

@end
