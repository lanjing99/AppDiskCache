//
//  HLDiskCache.h
//  Cupertino
//
//  Created by lanjing on 15/5/28.
//  Copyright (c) 2015年 福建讯盟软件有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface HLDiskCache : NSObject

-(instancetype)initWithNameSpace:(NSString *)namespace;

-(void)saveObject:(id<NSCoding>) object toFile:(NSString *)fileName;
-(void)saveObject:(id<NSCoding>) object toFile:(NSString *)fileName atDirectory:(NSString *)directory;

-(id)objectWithFileName:(NSString *)fileName;
-(id)objectWithFileName:(NSString *)fileName atDirectory:(NSString *)directory;

-(void)clearCacheAtDirectory:(NSString *)directory;
-(void)clearAllCache;

-(NSString *)cacheDirectory;
-(NSString *)filePathWithFileName:(NSString *)fileName;
-(NSString *)filePathWithFileName:(NSString *)fileName atDirectory:(NSString *)directory;
@end
