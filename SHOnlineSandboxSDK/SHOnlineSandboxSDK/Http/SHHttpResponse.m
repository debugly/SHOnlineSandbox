//
//  SHHttpResponse.m
//  SHOnlineSandboxSDK
//
//  Created by 许乾隆 on 2017/10/11.
//  Copyright © 2017年 许乾隆. All rights reserved.
//

#import "SHHttpResponse.h"

@implementation SHHttpResponse

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

#if DEBUG
    {
        NSString *text = [NSString stringWithFormat:@"<H1>404</H1><H3>您想要的内容跑去火星旅游了！</H3><pre>请联系许乾隆，该请求未能处理!\n[url:%@]\n[headers:%@]\n%@</pre>",req.URL.absoluteString,req.allHTTPHeaderFields,[[NSDate date]description]];
        
        NSData *data = [text dataUsingEncoding:NSUTF8StringEncoding];
        
        callback(data,@"text/html");
        
        return YES;
    }
#endif
    
    return NO;
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
        callback(data,mime);
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
