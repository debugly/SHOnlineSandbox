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
#import <UIKit/UIDevice.h>

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

- (NSString *)serverIP
{
    return [self.server serverIP];
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
    
    
    [SHHttpResponse registAPI:@"/uname.json" handler:^BOOL(NSURLRequest *req, NSString *clientAddress, SHRequestCallback callback) {
        NSString *name = [[UIDevice currentDevice]name];
        NSData *data = [name dataUsingEncoding:NSUTF8StringEncoding];
        callback(data,@"text/plain");
        return YES;
    }];
    
    [SHHttpResponse registAPI:@"/appinfo.json" handler:^BOOL(NSURLRequest *req, NSString *clientAddress, SHRequestCallback callback) {
        
        NSString *name = [[UIDevice currentDevice]name];
        NSString *sysName = [[UIDevice currentDevice]systemName];
        NSString *localizedModel = [[UIDevice currentDevice]localizedModel];
        NSString *systemVersion = [[UIDevice currentDevice]systemVersion];
        UIDeviceBatteryState batteryState = [[UIDevice currentDevice]batteryState];
        float batteryLevel = [[UIDevice currentDevice]batteryLevel];
        NSString *idfv = [[[UIDevice currentDevice]identifierForVendor]UUIDString];
        
        NSString *sys = [NSString stringWithFormat:@"%@(%@)",sysName,systemVersion];
        NSString *battery = @"";
        if (UIDeviceBatteryStateCharging == batteryState) {
            battery = [NSString stringWithFormat:@"充电中(%g)",batteryLevel];
        }else if (UIDeviceBatteryStateFull == batteryState){
            battery = [NSString stringWithFormat:@"已充满"];
        }else{
            battery = [NSString stringWithFormat:@"剩余电量(%g)",batteryLevel];
        }
        
        NSArray *info = @[@{@"名称" : name},
                          @{@"系统" : sys},
                          @{@"电池" : battery},
                          @{@"IDFV" : idfv},
                          @{@"模式" : localizedModel}];
        
        NSData *data = [NSJSONSerialization dataWithJSONObject:info options:NSJSONWritingPrettyPrinted error:nil];
        callback(data,@"text/json");
        return YES;
    }];
    
    ///处理请求沙盒目录、文件的请求
    [SHSandboxHandler registSandboxFileAPI];
}

@end
