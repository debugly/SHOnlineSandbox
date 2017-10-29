//
//  SHHttpResponseWriter.h
//  SHOnlineSandboxSDK
//
//  Created by 许乾隆 on 2017/10/11.
//  Copyright © 2017年 许乾隆. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SHHttpResponseWriter : NSObject

+ (BOOL)writeData:(NSData *)data toSocket:(int)socket;

+ (BOOL)writeText:(NSString *)text toSocket:(int)socket;

+ (BOOL)writeJson:(id)json toSocket:(int)socket;

@end
