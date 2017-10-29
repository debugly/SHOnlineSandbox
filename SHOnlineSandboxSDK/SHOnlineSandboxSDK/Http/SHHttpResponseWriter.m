//
//  SHHttpResponseWriter.m
//  SHOnlineSandboxSDK
//
//  Created by 许乾隆 on 2017/10/11.
//  Copyright © 2017年 许乾隆. All rights reserved.
//

#import "SHHttpResponseWriter.h"

@implementation SHHttpResponseWriter

+ (BOOL)writeRawData:(const void *)data length:(NSUInteger)length toSocket:(int)socket
{
    ssize_t sent = 0;
    
    while (sent < length) {
        ssize_t s = write(socket, data + sent, length - sent);
        if (s > 0) {
            sent += s;
        }else{
            return NO;
        }
    }
    return YES;
}

+ (BOOL)writeData:(NSData *)data toSocket:(int)socket
{
    return [self writeRawData:[data bytes] length:[data length] toSocket:socket];
}

+ (BOOL)writeText:(NSString *)text toSocket:(int)socket
{
    NSData *data = [text dataUsingEncoding:NSUTF8StringEncoding];
    return [self writeData:data toSocket:socket];
}

+ (BOOL)writeJson:(id)json toSocket:(int)socket
{
    NSError *err = nil;
    NSData *data = [NSJSONSerialization dataWithJSONObject:json options:NSJSONWritingPrettyPrinted error:&err];
    if (data) {
        return [self writeData:data toSocket:socket];
    }else{
        return [self writeJson:[NSDictionary dictionaryWithObject:err.localizedDescription forKey:@"error"] toSocket:socket];
    }
}

@end
