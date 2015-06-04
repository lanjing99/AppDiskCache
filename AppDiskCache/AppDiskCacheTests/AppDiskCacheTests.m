//
//  AppDiskCacheTests.m
//  AppDiskCacheTests
//
//  Created by lanjing on 15/6/3.
//  Copyright (c) 2015年 WaterWood. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "HLDiskCache.h"
#import "HLTestModelPerson.h"


//问题：文件写入到磁盘是异步写，写操作完成之后马上读会有问题！
//添加一个基于内存的缓存？
//暂时没有必要，因为目前使用的场景，读在启动的时候读，写是网络请求完成后写


@interface AppDiskCacheTests : XCTestCase

@end

@implementation AppDiskCacheTests
{
    HLDiskCache *_diskCache;
}

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    _diskCache = [[HLDiskCache alloc] initWithNameSpace:@"test"];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
    [_diskCache clearAllCache];
    _diskCache = nil;
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

- (void)testInitWithNameSpace
{
    NSString *cacheDirectory = [_diskCache cacheDirectory];
    BOOL isDirectory = NO;
    XCTAssert([[NSFileManager defaultManager] fileExistsAtPath:cacheDirectory isDirectory:&isDirectory]);
    XCTAssertTrue(isDirectory);
}

- (void)testSaveGetObject
{
    NSString *fileName = @"person.archieve";
    
    HLTestModelPerson *person = [self createAndSaveObjectAtDirectory:nil withFileName:fileName];
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"person"];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [expectation fulfill];
        
    });
    
    [self waitForExpectationsWithTimeout:3 handler:^(NSError *error) {
        HLTestModelPerson *person1 = [self objectAtDirectory:nil withFileName:fileName];
        XCTAssertEqualObjects(person, person1);

    }];
}


- (void)testSaveGetObjectAtDirectory
{
    NSString *directory = @"qiao";
    NSString *fileName = @"person.archieve";
    
    HLTestModelPerson *person = [self createAndSaveObjectAtDirectory:directory withFileName:fileName];
    
//    XCTestExpectation *expectation = [self expectationWithDescription:@"person"];
//    [expectation fulfill];
//    [self waitForExpectationsWithTimeout:2 handler:^(NSError *error) {
//        
//    
//        HLTestModelPerson *person1 = [self objectAtDirectory:directory withFileName:fileName];
//        XCTAssertEqualObjects(person, person1);
//        
//    }];
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"person"];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [expectation fulfill];
        
    });
    
    [self waitForExpectationsWithTimeout:3 handler:^(NSError *error) {
        HLTestModelPerson *person1 = [self objectAtDirectory:directory withFileName:fileName];
        XCTAssertEqualObjects(person, person1);
        
    }];

}

-(HLTestModelPerson *)createAndSaveObjectAtDirectory:(NSString *)directory withFileName:(NSString *)fileName
{
    HLTestModelPerson *person = [HLTestModelPerson new];
    person.name = @"qiao";
    person.age = 31;
    [_diskCache saveObject:person toFile:fileName atDirectory:directory];
    return person;
}

-(id)objectAtDirectory:(NSString *)directory withFileName:(NSString *)fileName
{
    BOOL isDirectory = NO;
    NSString *filePath = [_diskCache filePathWithFileName:fileName atDirectory:directory];
    XCTAssert([[NSFileManager defaultManager] fileExistsAtPath:filePath isDirectory:&isDirectory]);
    XCTAssertFalse(isDirectory);
    
    HLTestModelPerson *person1 = [_diskCache objectWithFileName:@"person.archieve" atDirectory:directory];
    return person1;
}

-(void)testClearDirectory
{
    NSString *directory = @"qiao";
    NSString *fileName = @"person.archieve";
    
    [self createAndSaveObjectAtDirectory:directory withFileName:fileName];
    NSString *path = [_diskCache filePathWithFileName:fileName atDirectory:directory];
   
    //同时设置两个expectation会失败？
//    XCTestExpectation *expectation = [self expectationWithDescription:@"person"];
//    [expectation fulfill];
//    [self waitForExpectationsWithTimeout:2 handler:^(NSError *error) {
//         XCTAssert([[NSFileManager defaultManager] fileExistsAtPath:path]);
//    }];
    
    [_diskCache clearCacheAtDirectory:directory];
    
    XCTestExpectation *expectation1 = [self expectationWithDescription:@"person"];
    [expectation1 fulfill];
    [self waitForExpectationsWithTimeout:2 handler:^(NSError *error) {
        XCTAssertFalse([[NSFileManager defaultManager] fileExistsAtPath:path]);
    }];

    
    
}

-(void)testClearAllCache
{
    NSString *directory = nil;
    NSString *fileName = @"person.archieve";
    
    [self createAndSaveObjectAtDirectory:directory withFileName:fileName];
    NSString *path = [_diskCache filePathWithFileName:fileName atDirectory:directory];
//    XCTAssert([[NSFileManager defaultManager] fileExistsAtPath:path]);
    [_diskCache clearCacheAtDirectory:directory];
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"person"];
    [expectation fulfill];
    [self waitForExpectationsWithTimeout:2 handler:^(NSError *error) {
        XCTAssertFalse([[NSFileManager defaultManager] fileExistsAtPath:path]);
    }];
}

@end
