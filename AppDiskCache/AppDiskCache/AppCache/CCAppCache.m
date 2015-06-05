//
//  CCAppCache.m
//  Cupertino
//
//  Created by lanjing on 15/5/28.
//  Copyright (c) 2015年 WaterWood. All rights reserved.
//

#import "CCAppCache.h"
#import <objc/runtime.h>
#import "HLDiskCache.h"

@interface CCAppCache ()

@property (nonatomic, strong, readonly) HLDiskCache *diskCache;

@end


@implementation CCAppCache
@synthesize diskCache = _diskCache;

-(HLDiskCache *)diskCache
{
    if(!_diskCache)
    {
        _diskCache = [HLDiskCache new];
    }
    return _diskCache;
}


//存储单例对象，使用对象的类型作为key
-(void)saveSingletonObject:(id<NSCoding>)object
{
    [self saveObject:object forKey:[self classNameWithClass:[(NSObject *)object class]]];
}
-(id)singletonObjectWithClass:(Class) class;
{
    return [self objectForKey:[self classNameWithClass:class]];
}

-(void)removeSingletonObjectInCacheWithClass:(Class) class
{
    NSString *path = [self filePathWithHierarchicalKeysForKey:[self classNameWithClass:class]];
    [self removeObjectInCacheForKey:path];
}


-(void)saveObject:(id<NSCoding>)object forKey:(NSString *)key
{
    if(object == nil || [key length] == 0) return;
    
    [self.diskCache saveObject:object toFile:key atDirectory:[self directoryPathFromSelfHierarchicalKeys]];
}

-(id)objectForKey:(NSString *)key
{
    return [self.diskCache objectWithFileName:key atDirectory:[self directoryPathFromSelfHierarchicalKeys]];
}

-(void)removeObjectInCacheForKey:(NSString *)key
{
    [self.diskCache clearCacheAtPath:[self filePathWithHierarchicalKeysForKey:key]];
}


-(void)clearCacheAtHierarchicalKeys:(NSArray *)keys
{
    if([keys count] == 0) return;
    
    __block NSString *directoryPath = [self directoryPathWithHierarchicalKeys:keys];
    [self.diskCache clearCacheAtPath:directoryPath];
    
}


-(void)clearAllCacheOfHierarchicalKeys
{
    NSString *directoryPath = self.hierarchicalKeys.firstObject;
    [self.diskCache clearCacheAtPath:directoryPath];
}

-(void)clearAllCache
{
    [self.diskCache clearCacheAtPath:nil];
}

-(NSString *)directoryPathFromSelfHierarchicalKeys
{
    return [self directoryPathWithHierarchicalKeys:self.hierarchicalKeys];
}

-(NSString *)directoryPathWithHierarchicalKeys:(NSArray *)hierarchicalKeys
{
    __block NSString *directoryPath = nil;
    [hierarchicalKeys enumerateObjectsUsingBlock:^(NSString *key, NSUInteger idx, BOOL *stop) {
        if([key isKindOfClass:[NSString class]] && [key length])
        {
            if(idx == 0)
            {
                directoryPath = key;
            }
            else
            {
                directoryPath = [directoryPath stringByAppendingPathComponent:key];
            }
        }
    }];
    
    return directoryPath;
    
}


 -(NSString *)filePathWithHierarchicalKeysForKey:(NSString *)key
 {
     NSString *directoryPath = [self directoryPathFromSelfHierarchicalKeys];
     NSString *filePath = [directoryPath length] ? [directoryPath stringByAppendingPathComponent:key] : key;
     return filePath;
 }
     

-(NSString*) classNameWithClass:(Class) class
{
    const char *className = class_getName(class);
    NSString *classNameString = [NSString stringWithCString:className encoding:NSUTF8StringEncoding];
    return classNameString;
}
@end
