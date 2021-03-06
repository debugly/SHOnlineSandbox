//
//  SHHttpService.m
//  SHOnlineSandboxSDK
//
//  Created by 许乾隆 on 2017/10/12.
//  Copyright © 2017年 许乾隆. All rights reserved.
//

#import "SHHttpService.h"
#import "SHHttpServer.h"
#import "SHHttpRoute.h"
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
            return [SHHttpRoute handleRequest:req clientAddress:clientAddress callback:callback];
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
    [SHHttpRoute registAPI:@"/" handler:^BOOL(NSURLRequest *req, NSString *clientAddress, SHRequestCallback callback) {
//        NSString *text = @"<H1>Welcome to use Sohu Onlie Sandbox SDK.<H1>";
        
        SHHttpResponse *resp = [SHHttpResponse make:^(SHHttpResponse *maker) {
            [maker setStatusCode:301];
            [maker setMimeType:@"text/html"];
            [maker setHeader:@{@"Location":@"/index.html"}];
        }];
        
        callback(resp);
        return YES;
    }];
    
    [SHHttpRoute registAPI:@"/root.json" handler:^BOOL(NSURLRequest *req, NSString *clientAddress, SHRequestCallback callback) {
        
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
        
        SHHttpResponse *resp = [SHHttpResponse make:^(SHHttpResponse *maker) {
            [maker setStatusCode:200];
            [maker setMimeType:@"text/json"];
            [maker setData:[payload dataUsingEncoding:NSUTF8StringEncoding]];
        }];
        
        callback(resp);
        return YES;
    }];
    
    
    [SHHttpRoute registAPI:@"/uname.json" handler:^BOOL(NSURLRequest *req, NSString *clientAddress, SHRequestCallback callback) {
        NSString *payload = [[UIDevice currentDevice]name];
        
        SHHttpResponse *resp = [SHHttpResponse make:^(SHHttpResponse *maker) {
            [maker setStatusCode:200];
            [maker setMimeType:@"text/plain"];
            [maker setData:[payload dataUsingEncoding:NSUTF8StringEncoding]];
        }];
        
        callback(resp);
        return YES;
    }];
    
    [SHHttpRoute registAPI:@"/appinfo.json" handler:^BOOL(NSURLRequest *req, NSString *clientAddress, SHRequestCallback callback) {
        
        NSString *name = [[UIDevice currentDevice]name];
        NSString *sysName = [[UIDevice currentDevice]systemName];
        NSString *localizedModel = [[UIDevice currentDevice]localizedModel];
        NSString *systemVersion = [[UIDevice currentDevice]systemVersion];
        [[UIDevice currentDevice]setBatteryMonitoringEnabled:YES];
        UIDeviceBatteryState batteryState = [[UIDevice currentDevice]batteryState];
        float batteryLevel = [[UIDevice currentDevice]batteryLevel];
        NSString *idfv = [[[UIDevice currentDevice]identifierForVendor]UUIDString];
        
        NSString *sys = [NSString stringWithFormat:@"%@(%@)",sysName,systemVersion];
        NSString *battery = @"";
        
        if (UIDeviceBatteryStateUnknown == batteryState) {
            battery = @"未知状态";
        }else if (UIDeviceBatteryStateCharging == batteryState) {
            battery = [NSString stringWithFormat:@"充电中(%d%%)",(int)(100 * batteryLevel)];
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
        
        NSData *payload = [NSJSONSerialization dataWithJSONObject:info options:NSJSONWritingPrettyPrinted error:nil];
        
        SHHttpResponse *resp = [SHHttpResponse make:^(SHHttpResponse *maker) {
            [maker setStatusCode:200];
            [maker setMimeType:@"text/json"];
            [maker setData:payload];
        }];
        
        callback(resp);
        return YES;
    }];
    
    ///处理请求沙盒目录、文件的请求
    [SHSandboxHandler registSandboxFileAPI];
}

@end
