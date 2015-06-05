//
//  CCAppCacheTest.m
//  AppDiskCache
//
//  Created by lanjing on 15/6/4.
//  Copyright (c) 2015年 WaterWood. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "HLTestModelPerson.h"
#import "CCAppCache.h"

@interface CCAppCacheTest : XCTestCase
{
    CCAppCache *_appCache;
    HLTestModelPerson *_person;
}

@end

@implementation CCAppCacheTest

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    _appCache = [CCAppCache new];
    _person = [HLTestModelPerson new];
    _person.name = @"qiao";
    _person.age = 31;
    
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
    [_appCache clearAllCache];
    _appCache = nil;
    _person = nil;
}

//- (void)testExample {
//    // This is an example of a functional test case.
//    XCTAssert(YES, @"Pass");
//}
//
//- (void)testPerformanceExample {
//    // This is an example of a performance test case.
//    [self measureBlock:^{
//        // Put the code you want to measure the time of here.
//    }];
//}


-(void)testSaveObjectForKey
{
    [_appCache saveObject:_person forKey:@"person"];
    
    NSString *key = @"person";
    XCTestExpectation *expection = [self expectationWithDescription: key];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [expection fulfill];
    });
    
    [self waitForExpectationsWithTimeout:3 handler:^(NSError *error) {
        HLTestModelPerson *person1 = [_appCache objectForKey:key];
        XCTAssertEqualObjects(person1, _person);
    }];
}

-(void)testSaveObjectForKeyInOneHierarchicalKey
{
    _appCache.hierarchicalKeys = @[@"11111"];
    [self testSaveObjectForKey];
}

-(void)testSaveObjectForKeyInTwoHierarchicalKeys
{
    _appCache.hierarchicalKeys = @[@"11111", @"22222"];
    [self testSaveObjectForKey];
}


-(void)testSaveSingletonObject
{
    [_appCache saveSingletonObject:_person];
    
    NSString *key = @"person";
    XCTestExpectation *expection = [self expectationWithDescription: key];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [expection fulfill];
    });
    
    [self waitForExpectationsWithTimeout:3 handler:^(NSError *error) {
        HLTestModelPerson *person1 = [_appCache singletonObjectWithClass:[_person class]];
        XCTAssertEqualObjects(person1, _person);
    }];
}

-(void)testDirectoryPathFromHierarchicalKeys
{
    _appCache.hierarchicalKeys = @[@"key1", @"2222"];
    NSString *directoryPath = [_appCache directoryPathFromSelfHierarchicalKeys];
    XCTAssertEqualObjects(directoryPath, @"key1/2222");
    
}

-(void)testClearCacheAtHierarchicalKeys
{
    _appCache.hierarchicalKeys = @[@"11111", @"22222"];
    [self testSaveObjectForKey];
    [_appCache clearCacheAtHierarchicalKeys:@[@"11111", @"22222"]];
    
    NSString *key = @"person";
    XCTestExpectation *expection = [self expectationWithDescription: key];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [expection fulfill];
    });
    
    [self waitForExpectationsWithTimeout:3 handler:^(NSError *error) {
        HLTestModelPerson *person = [_appCache objectForKey:key];
        XCTAssertNil(person);
    }];
}



@end
