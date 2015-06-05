//
//  CCAppCache.h
//  Cupertino
//
//  Created by lanjing on 15/5/28.
//  Copyright (c) 2015年 WaterWood. All rights reserved.
//

#import <Foundation/Foundation.h>

//注意用户未登录的情况

//userID->CityCode->ClassName
//默认的用户ID 00000000000

@interface CCAppCache : NSObject

@property (nonatomic, copy) NSArray *hierarchicalKeys;        //层次keys，用去区分路径。例如不同用户在不同城市下的相同缓存。

//存储单例对象，使用对象的类型作为key
-(void)saveSingletonObject:(id<NSCoding>)object;
-(id)singletonObjectWithClass:(Class) class;
-(void)removeSingletonObjectInCacheWithClass:(Class) class;

-(void)saveObject:(id<NSCoding>)object forKey:(NSString *)key;
-(id)objectForKey:(NSString *)key;
-(void)removeObjectInCacheForKey:(NSString *)key;

-(void)clearCacheAtHierarchicalKeys:(NSArray *)keys;
-(void)clearAllCacheOfHierarchicalKeys;
-(void)clearAllCache;

-(NSString *)directoryPathFromSelfHierarchicalKeys;

@end
