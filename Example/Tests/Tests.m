//
//  DRNetworkUpdatingPlistTests.m
//  DRNetworkUpdatingPlistTests
//
//  Created by Daniel Broad on 02/05/2016.
//  Copyright (c) 2016 Daniel Broad. All rights reserved.
//

#import "DRNetworkUpdatingPlist.h"

@import XCTest;

@interface Tests : XCTestCase

@end

@implementation Tests

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

- (void)test
{
    DRNetworkUpdatingPlist *myPlist = [[DRNetworkUpdatingPlist alloc] initWithRootURL:[NSURL URLWithString:@""] name:@"test.plist"];
    
    XCTAssertEqual([myPlist integerForKey:@"test"], 123456,@"Integer retrieval test");
}

@end

