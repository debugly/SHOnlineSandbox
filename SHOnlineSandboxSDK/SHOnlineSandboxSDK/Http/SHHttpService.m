//
//  SHHttpService.m
//  SHOnlineSandboxSDK
//
//  Created by 许乾隆 on 2017/10/12.
//  Copyright © 2017年 许乾隆. All rights reserved.
//

#import "SHHttpService.h"
#import "SHHttpServer.h"
#import "SHHttpResponse.h"
#import "SHSandboxHandler.h"

@interface SHHttpService ()

@property (nonatomic, strong) SHHttpServer* server;

@end

@implementation SHHttpService

- (instancetype)initWithPort:(int)port
{
    self = [super init];
    if (self) {
        
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            
            [self prepareHandlers];
        });
        
        SHHttpServer *server = [SHHttpServer httpServer];
        [server startWithPort:port];
        [server resetRequestHandler:^BOOL(NSURLRequest *req, NSString *clientAddress, SHRequestCallback callback) {
            return [SHHttpResponse handleRequest:req clientAddress:clientAddress callback:callback];
        }];
        
        self.server = server;
    }
    return self;
}

+ (instancetype)startServerWithPort:(int)port
{
    return [[self alloc]initWithPort:port];
}

- (void)stop
{
    [self.server stop];
}

- (void)prepareHandlers
{
    [SHHttpResponse registAPI:@"/" handler:^BOOL(NSURLRequest *req, NSString *clientAddress, SHRequestCallback callback) {
        NSString *text = @"<H1>Welcome to use Sohu Onlie Sandbox SDK.<H1>";
        callback([text dataUsingEncoding:NSUTF8StringEncoding],@"text/html");
        return YES;
    }];
    
    [SHHttpResponse registAPI:@"/root.json" handler:^BOOL(NSURLRequest *req, NSString *clientAddress, SHRequestCallback callback) {
        
        NSString *urlCallback = nil;
        if ([req.URL.query rangeOfString:@"callback"].location != NSNotFound) {
            
            NSArray *items = [req.URL.query componentsSeparatedByString:@"&"];
            for (NSString *item in items) {
                NSArray *keyValue = [item componentsSeparatedByString:@"="];
                
                NSString *key = [keyValue firstObject];
                
                if ([key isEqualToString:@"callback"]) {
                    urlCallback = [keyValue lastObject];
                    break;
                }
            }
        }
        
        NSString *payload = @"['A','B','C','D']";
        
        if (urlCallback) {
            payload = [NSString stringWithFormat:@"%@(%@)",urlCallback,payload];
        }
        callback([payload dataUsingEncoding:NSUTF8StringEncoding],@"text/html");
        return YES;
    }];
    
    ///处理请求沙盒目录、文件的请求
    [SHSandboxHandler registSandboxFileAPI];
}

@end
