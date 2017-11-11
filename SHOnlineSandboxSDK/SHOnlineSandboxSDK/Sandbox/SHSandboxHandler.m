//
//  SHSandboxHandler.m
//  SHOnlineSandboxSDK
//
//  Created by 许乾隆 on 2017/10/22.
//  Copyright © 2017年 许乾隆. All rights reserved.
//

#import "SHSandboxHandler.h"
#import "SHHttpRoute.h"
#import "NSURLRequest+Query.h"
#import <UIKit/UIKit.h>

@implementation SHSandboxHandler

+ (void)registSandboxFileAPI
{
    [SHHttpRoute registAPI:@"/download.do" handler:^BOOL(NSURLRequest *req, NSString *clientAddress, SHRequestCallback callback) {
        NSDictionary *ps = [req queries_sh];
        NSString *path = [ps objectForKey:@"path"];
        NSString *fullPath = [NSHomeDirectory() stringByAppendingPathComponent:path];
        BOOL isDirectory = NO;
        
        if ([[NSFileManager defaultManager]fileExistsAtPath:fullPath isDirectory:&isDirectory]) {
            if (isDirectory) {
                
            }else{
                NSFileHandle *fHandle = [NSFileHandle fileHandleForReadingAtPath:fullPath];
                NSData *payload = [fHandle readDataToEndOfFile];
                
                SHHttpResponse *resp = [SHHttpResponse make:^(SHHttpResponse *maker) {
                    [maker setStatusCode:200];
                    [maker setMimeType:@"application/octet-stream"];
                    [maker setData:payload];
                }];
                
                callback(resp);
            }
        }else{
            NSData *payload = [NSJSONSerialization dataWithJSONObject:@{@"err":@"not found"} options:NSJSONWritingPrettyPrinted error:nil];
            
            SHHttpResponse *resp = [SHHttpResponse make:^(SHHttpResponse *maker) {
                [maker setStatusCode:200];
                [maker setMimeType:@"text/json"];
                [maker setData:payload];
            }];
            
            callback(resp);
        }
        return YES;
    }];
    
    [SHHttpRoute registAPI:@"/sandbox.json" handler:^BOOL(NSURLRequest *req, NSString *clientAddress, SHRequestCallback callback) {
        
        NSDictionary *ps = [req queries_sh];
        NSString *path = [ps objectForKey:@"path"];
        
        if (!path || path.length == 0) {
            
            NSDictionary *result = @{@"name":[[UIDevice currentDevice]name],
                                     @"path":@"/",
                                     @"isf":@(YES)};
            NSData *payload = [NSJSONSerialization dataWithJSONObject:result options:NSJSONWritingPrettyPrinted error:nil];
            
            SHHttpResponse *resp = [SHHttpResponse make:^(SHHttpResponse *maker) {
                [maker setStatusCode:200];
                [maker setMimeType:@"text/json"];
                [maker setData:payload];
            }];
            
            callback(resp);
        }else{
            NSString *fullPath = [NSHomeDirectory() stringByAppendingPathComponent:path];
            
            BOOL isDirectory = NO;
            
            if ([[NSFileManager defaultManager]fileExistsAtPath:fullPath isDirectory:&isDirectory]) {
                if (isDirectory) {
                    NSArray *contents = [[NSFileManager defaultManager]contentsOfDirectoryAtPath:fullPath error:nil];
                    
                    if ([contents count] > 0) {
                        NSMutableArray * results = [NSMutableArray array];
                        for (NSString * content in contents) {
                            NSString *cPath = [fullPath stringByAppendingPathComponent:content];
                            BOOL isD = NO;
                            [[NSFileManager defaultManager]fileExistsAtPath:cPath isDirectory:&isD];
                            cPath = [cPath stringByReplacingOccurrencesOfString:NSHomeDirectory() withString:@""];
                            [results addObject:@{@"name":content,
                                                 @"path":cPath,
                                                 @"isf":@(isD)}];
                        }
                        
                        NSData *payload = [NSJSONSerialization dataWithJSONObject:results options:NSJSONWritingPrettyPrinted error:nil];
                        
                        SHHttpResponse *resp = [SHHttpResponse make:^(SHHttpResponse *maker) {
                            [maker setStatusCode:200];
                            [maker setMimeType:@"text/json"];
                            [maker setData:payload];
                        }];
                        
                        callback(resp);
                        
                    }else{
                        NSDictionary *result = @{@"name":@"文件夹空空的",
                                                 @"empty":@(YES),
                                                 @"isf":@(NO)};
                        NSData *payload = [NSJSONSerialization dataWithJSONObject:@[result] options:NSJSONWritingPrettyPrinted error:nil];
                        
                        SHHttpResponse *resp = [SHHttpResponse make:^(SHHttpResponse *maker) {
                            [maker setStatusCode:200];
                            [maker setMimeType:@"text/json"];
                            [maker setData:payload];
                        }];
                        
                        callback(resp);
                    }
                }else{
                    NSData *payload = [NSJSONSerialization dataWithJSONObject:@{@"err":@"not found"} options:NSJSONWritingPrettyPrinted error:nil];
                    SHHttpResponse *resp = [SHHttpResponse make:^(SHHttpResponse *maker) {
                        [maker setStatusCode:200];
                        [maker setMimeType:@"text/json"];
                        [maker setData:payload];
                    }];
                    
                    callback(resp);
                }
            }else{
                NSData *payload = [NSJSONSerialization dataWithJSONObject:@{@"err":@"not found"} options:NSJSONWritingPrettyPrinted error:nil];
                
                SHHttpResponse *resp = [SHHttpResponse make:^(SHHttpResponse *maker) {
                    [maker setStatusCode:200];
                    [maker setMimeType:@"text/json"];
                    [maker setData:payload];
                }];
                
                callback(resp);
            }
        }
        return YES;
    }];
}

@end
