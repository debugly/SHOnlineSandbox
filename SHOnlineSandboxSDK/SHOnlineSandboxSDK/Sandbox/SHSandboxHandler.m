//
//  SHSandboxHandler.m
//  SHOnlineSandboxSDK
//
//  Created by 许乾隆 on 2017/10/22.
//  Copyright © 2017年 许乾隆. All rights reserved.
//

#import "SHSandboxHandler.h"
#import "SHHttpResponse.h"
#import "NSURLRequest+Query.h"

@implementation SHSandboxHandler

+ (void)registSandboxFileAPI
{
    [SHHttpResponse registAPI:@"/sandbox.do" handler:^BOOL(NSURLRequest *req, NSString *clientAddress, SHRequestCallback callback) {
        
        NSDictionary *ps = [req queries_sh];
        NSString *path = [ps objectForKey:@"p"];
        
        NSString *fullPath = [NSHomeDirectory() stringByAppendingPathComponent:path];
        
        BOOL isDirectory = NO;
        
        if ([[NSFileManager defaultManager]fileExistsAtPath:fullPath isDirectory:&isDirectory]) {
            if (isDirectory) {
                NSArray *contents = [[NSFileManager defaultManager]contentsOfDirectoryAtPath:fullPath error:nil];
                
                NSMutableArray * results = [NSMutableArray array];
                for (NSString * content in contents) {
                    NSString *cPath = [fullPath stringByAppendingPathComponent:content];
                    BOOL isD = NO;
                    [[NSFileManager defaultManager]fileExistsAtPath:fullPath isDirectory:&isD];
                    [results addObject:@{@"name":content,
                                         @"path":cPath,
                                         @"folder":@(isD)}];
                }
                
                NSData *data = [NSJSONSerialization dataWithJSONObject:results options:NSJSONWritingPrettyPrinted error:nil];
                
                callback(data,@"text/json");
                
            }else{
                NSData *data = [NSJSONSerialization dataWithJSONObject:@{@"err":@"not found"} options:NSJSONWritingPrettyPrinted error:nil];
                callback(data,@"text/json");
            }
        }else{
            NSData *data = [NSJSONSerialization dataWithJSONObject:@{@"err":@"not found"} options:NSJSONWritingPrettyPrinted error:nil];
            callback(data,@"text/json");
        }
        return YES;
    }];
}

@end
