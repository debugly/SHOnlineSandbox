//
//  SHHttpRoute.m
//  SHOnlineSandboxSDK
//
//  Created by 许乾隆 on 2017/10/11.
//  Copyright © 2017年 许乾隆. All rights reserved.
//

#import "SHHttpRoute.h"

@implementation SHHttpRoute

static NSMutableDictionary *API_Map_s;
static NSMutableDictionary *RES_Map_s;

+ (void)load
{
    API_Map_s = [NSMutableDictionary dictionary];
    RES_Map_s = [NSMutableDictionary dictionary];
}

+ (BOOL)handleRequest:(NSURLRequest *)req clientAddress:(NSString *)clientAddress callback:(SHRequestCallback)callback
{
    NSString *path = req.URL.path;
    SHRequestHandler handler = API_Map_s[path];
    
    if (!handler) {
        handler = RES_Map_s[path];
    }
    
    if (handler) {
        return handler(req,clientAddress,callback);
    }
    
    if ([self handleAsResource:req callback:callback]) {
        return YES;
    }
    
    ///路由这一层默认返回一个 404 页面！这里不处理的话，server里会返回 404 使用默认的页面；
    NSURLRequest *newReq = [NSURLRequest requestWithURL:[NSURL URLWithString:@"/404.html"]];
    return [self handleAsResource:newReq callback:callback];
}

static inline NSString * OnlineBundleSource_Path (NSString *filename)
{
    NSBundle *libBundle = [NSBundle bundleWithPath:[[[NSBundle mainBundle]resourcePath]stringByAppendingPathComponent:@"SHOnlineSandbox.bundle"]];
    if (libBundle && filename) {
        NSString *s = [[libBundle resourcePath]stringByAppendingPathComponent:filename];
        return s;
    }
    return nil;
}

static inline NSString * MimeForPath(NSString *filepath){
    NSArray *imags = @[@"png",@"jpg",@"jpeg",@"gif",@"webp"];
    
    if ([imags containsObject:[filepath pathExtension]]) {
        return [NSString stringWithFormat:@"image/%@",[filepath pathExtension]];
    }
    
    NSArray *textArr = @[@"html",@"txt",@"json",@"css",@"js"];
    
    if ([textArr containsObject:[filepath pathExtension]]) {
        return [NSString stringWithFormat:@"text/%@",[filepath pathExtension]];
    }
    
    return @"text/html";
}

+ (BOOL)handleAsResource:(NSURLRequest *)req callback:(SHRequestCallback)callback
{
    NSString *path = OnlineBundleSource_Path(req.URL.path);
    NSData *data = [NSData dataWithContentsOfFile:path options:NSDataReadingMappedIfSafe error:NULL];
    if (data) {
        NSString *mime = MimeForPath(path);
        
        SHHttpResponse *resp = [SHHttpResponse make:^(SHHttpResponse *maker) {
            [maker setStatusCode:200];
            [maker setMimeType:mime];
            [maker setData:data];
        }];
        
        callback(resp);
        return YES;
    }
    return NO;
}

+ (void)registAPI:(NSString *)api handler:(SHRequestHandler)handler
{
    if (api.length > 0 && handler) {
        [API_Map_s setObject:[handler copy] forKey:api];
    }
}

+ (void)registResource:(NSString *)res handler:(SHRequestHandler)handler
{
    if (res.length > 0 && handler) {
        [RES_Map_s setObject:[handler copy] forKey:res];
    }
}

@end
