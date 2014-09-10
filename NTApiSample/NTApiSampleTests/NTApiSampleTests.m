//
//  NTApiSampleTests.m
//  NTApiSampleTests
//
//  Created by Ethan Nagel on 1/27/14.
//  Copyright (c) 2014 Nagel Technologies, Inc. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "ApiClientTypeA.h"
#import "ApiClientTypeB.h"

@interface NTApiSampleTests : XCTestCase

@end

@implementation NTApiSampleTests

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


- (void)testSimpleDefault
{
    NSString* defaultKey = @"someDefault";
    NSString* defaultVal = @"DefaultVal";

    [ApiClientTypeA setDefault:defaultKey value:defaultVal];
    XCTAssertEqual([ApiClientTypeA getDefault:defaultKey], defaultVal);

}

- (void)testMultiImplDefault
{
    NSString* defaultKey = @"someDefault";
    NSString* defaultValA = @"typeADefault";
    NSString* defaultValB = @"typeBDefault";

    [ApiClientTypeA setDefault:defaultKey value:defaultValA];
    XCTAssertEqual([ApiClientTypeA getDefault:defaultKey], defaultValA);

    [ApiClientTypeB setDefault:defaultKey value:defaultValB];

    XCTAssertEqual([ApiClientTypeA getDefault:defaultKey], defaultValA);

    XCTAssertEqual([ApiClientTypeB getDefault:defaultKey], defaultValB);

}

- (void)testInternallyUsedDefaults
{
    NSString* defaultKey = @"baseUrl";
    NSString* defaultValA = @"url1.example.com";
    NSString* defaultValB = @"url2.example.com";

    [ApiClientTypeA setDefault:defaultKey value:defaultValA];
    [ApiClientTypeB setDefault:defaultKey value:defaultValB];

    ApiClientTypeA* clientA = [[ApiClientTypeA alloc] init];
    ApiClientTypeB* clientB = [[ApiClientTypeB alloc] init];

    XCTAssertEqual(clientA.baseUrl, defaultValA);
    XCTAssertEqual(clientB.baseUrl, defaultValB);
}


@end
