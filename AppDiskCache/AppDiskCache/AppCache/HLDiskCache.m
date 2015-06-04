//
//  HLDiskCache.m
//  Cupertino
//
//  Created by lanjing on 15/5/28.
//  Copyright (c) 2015年 福建讯盟软件有限公司. All rights reserved.
//

#import "HLDiskCache.h"

@interface HLDiskCache ()

@property (nonatomic) dispatch_queue_t ioQueue;
@property (nonatomic) NSFileManager *fileManager;

@end


@implementation HLDiskCache
{
    NSString *_diskCachePath;
}

-(instancetype)init
{
    return [self initWithNameSpace:@"default"];
}

-(instancetype)initWithNameSpace:(NSString *)namespace
{
    if(self = [super init])
    {
        NSString *fullNamespace = [@"com.ww.HLDiskCache." stringByAppendingString:namespace];
        // Init the disk cache
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        _diskCachePath = [paths[0] stringByAppendingPathComponent:fullNamespace];
        
        if(![[NSFileManager defaultManager] fileExistsAtPath:_diskCachePath])
        {
            [[NSFileManager defaultManager] createDirectoryAtPath:_diskCachePath withIntermediateDirectories:YES attributes:nil error:nil];
        }
        
    }
    return self;
}

-(void)saveObject:(id<NSCoding>) object toFile:(NSString *)fileName;
{
    [self saveObject:object toFile:fileName atDirectory:nil];
}

-(void)saveObject:(id<NSCoding>) object toFile:(NSString *)fileName atDirectory:(NSString *)directory
{
    NSParameterAssert([[(NSObject *)object class] conformsToProtocol:@protocol(NSCoding)]);
    if([[(NSObject *)object class] conformsToProtocol:@protocol(NSCoding)] == NO)
    {
        return;
    }
    NSString *directoryPath = [_diskCachePath stringByAppendingPathComponent:directory];
    if(![self.fileManager fileExistsAtPath:directoryPath])
    {
        [self.fileManager createDirectoryAtPath:directoryPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    dispatch_async(self.ioQueue, ^{
        NSString *filePath = [directoryPath stringByAppendingPathComponent:fileName];
        [NSKeyedArchiver archiveRootObject:object toFile:filePath];
    });
   
//    dispatch_sync(self.ioQueue, ^{
//        NSString *filePath = [directoryPath stringByAppendingPathComponent:fileName];
//        [NSKeyedArchiver archiveRootObject:object toFile:filePath];
//    });

}

-(id)objectWithFileName:(NSString *)fileName
{
    return [self objectWithFileName:fileName atDirectory:nil];
}

-(id)objectWithFileName:(NSString *)fileName atDirectory:(NSString *)directory
{
    if([fileName length] == 0) return nil;
    NSString *directoryPath = [_diskCachePath stringByAppendingPathComponent:directory];
    NSString *filePath = [directoryPath stringByAppendingPathComponent:fileName];
    if(![self.fileManager fileExistsAtPath:filePath])
    {
        return nil;
    }
    
    __block id result = nil;
    dispatch_sync(self.ioQueue, ^{
        result = [NSKeyedUnarchiver unarchiveObjectWithFile:filePath];
        
    });
   return result;
}

-(void)clearAllCache
{
    [self clearCacheAtDirectory:nil];
}

-(void)clearCacheAtDirectory:(NSString *)directory
{
    NSString *path = [self filePathWithFileName:nil atDirectory:directory];
    
    dispatch_async(self.ioQueue, ^{
        if([self.fileManager fileExistsAtPath:path isDirectory:nil])
        {
            [self.fileManager removeItemAtPath:path error:nil];
        }

    });
    
}

-(NSString *)cacheDirectory
{
    return _diskCachePath;
}

-(NSString *)filePathWithFileName:(NSString *)fileName
{
    return [self filePathWithFileName:fileName atDirectory:nil];
}

-(NSString *)filePathWithFileName:(NSString *)fileName atDirectory:(NSString *)directory
{
    NSString *filePath = _diskCachePath;
    if([directory length])
    {
        filePath = [_diskCachePath stringByAppendingPathComponent:directory];
    }
    
    if([fileName length])
    {
        filePath = [filePath stringByAppendingPathComponent:fileName];
    }
    return filePath;
}
#pragma mark properties

-(dispatch_queue_t)ioQueue
{
    if(!_ioQueue)
    {
        _ioQueue = dispatch_queue_create("com.ww.HLDiskCache", DISPATCH_QUEUE_SERIAL);
    }
    return _ioQueue;
}

-(NSFileManager *)fileManager
{
    if(!_fileManager)
    {
        _fileManager = [NSFileManager new];
    }
    return _fileManager;
}
@end












