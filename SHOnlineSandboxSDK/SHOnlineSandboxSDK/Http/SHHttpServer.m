//
//  SHHttpServer.m
//  SHOnlineSandboxSDK
//
//  Created by 许乾隆 on 2017/9/26.
//  Copyright © 2017年 许乾隆. All rights reserved.
//

#import "SHHttpServer.h"
#import <sys/socket.h>
#import <netinet/in.h>
#import <arpa/inet.h>
#import <ifaddrs.h>

#import "SHHttpResponseWriter.h"

@interface SHHttpServer ()

@property (nonatomic, assign) int listenPort;
@property (nonatomic, assign) int listenSocket;
@property (nonatomic, assign) BOOL done;
@property (nonatomic, copy) SHRequestHandler requestHandler;
@property (nonatomic, copy) NSString *serverIP;

@end

@implementation SHHttpServer

+ (instancetype)httpServer
{
    return [[self alloc]init];
}

- (void)cleanSocket:(int)socket
{
    shutdown(socket, 2);
    close(socket);
}

- (void)stop
{
    self.done = YES;
    [self cleanSocket:self.listenSocket];
}

- (BOOL)startWithPort:(int)port
{
    int listenSocket = socket(AF_INET, SOCK_STREAM, 0);
    if (listenSocket == -1) {
        return NO;
    }
    
    int value = 1;
    if (setsockopt(listenSocket, SOL_SOCKET, SO_REUSEADDR, &value, sizeof(value)) == -1) {
        [self cleanSocket:listenSocket];
        return NO;
    }
    
    int no_sig_pipe = 1;
    
    if (setsockopt(listenSocket, SOL_SOCKET, SO_NOSIGPIPE, &no_sig_pipe, sizeof(no_sig_pipe)) == -1) {
        //?
    }
    
    struct ifaddrs* interfaces = NULL;
    int success = 0;
    /*
     
     4G-> WiFi 崩溃：
     malloc: *** error for object 0x128b32a08: incorrect checksum for freed object - object was probably modified after being freed.
     *** set a breakpoint in malloc_error_break to debug
     */
    // retrieve the current interfaces - returns 0 on success
    @try {
        success = getifaddrs(&interfaces);
    } @catch (NSException *exception) {
        //NSCog(@"get ip failed：%@",exception);
    }
    
    struct sockaddr_in serverAddr;
    memset(&serverAddr, 0, sizeof(serverAddr));
    serverAddr.sin_port = htons(port);
    
    if (success == 0)
    {
        // Loop through linked list of interfaces
        struct ifaddrs* temp_addr = interfaces;
        
        while (temp_addr != NULL)
        {
            sa_family_t family = temp_addr->ifa_addr->sa_family;
            NSString* ifa_name = [NSString stringWithUTF8String: temp_addr->ifa_name];
            
            if([@"en0" isEqualToString:ifa_name]){
                NSString *serverIP = nil;
                if (family == AF_INET)
                {
                    serverIP = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                } else if (family == AF_INET6) {
                    
                    struct in_addr sin_addr = ((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr;
                    if (sin_addr.s_addr != 0) {
                        char buffer[1024] = {0};
                        inet_ntop(AF_INET6, &sin_addr, buffer, sizeof(buffer));
                        serverIP = [NSString stringWithUTF8String:buffer];
                    }
                }
                
                if(serverIP && ![serverIP isEqualToString:@"0.0.0.0"]){
                    serverAddr.sin_family = family;
                    serverAddr.sin_addr.s_addr = ((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr.s_addr;
                    self.serverIP = serverIP;
                    
                    break;
                }
            }
            
            temp_addr = temp_addr->ifa_next;
        }
    }
    
    freeifaddrs(interfaces);

//    NSLog(@"server ip:%@",self.serverIP);
    
    if (bind(listenSocket, (const struct sockaddr *)&serverAddr, sizeof(serverAddr)) == -1) {
        [self cleanSocket:listenSocket];
        return NO;
    }
    
    if (listen(listenSocket, 20/* max connections */) == -1) {
        [self cleanSocket:listenSocket];
        return NO;
    }
    
    self.listenSocket = listenSocket;
    
    [self performSelectorInBackground:@selector(acceptClientConnectionsLoop) withObject:nil];
    return YES;
}

- (NSString *)sockaddrToNSString:(struct sockaddr *)addr
{
    char str[20];
    if (addr->sa_family == AF_INET) {
        struct sockaddr_in *v4 = (struct sockaddr_in *)addr;
        const char *result = inet_ntop(AF_INET, &(v4->sin_addr), str, 20);
        if (result == NULL) {
            return nil;
        }
    }
    if (addr->sa_family == AF_INET6) {
        struct sockaddr_in6 *v6 = (struct sockaddr_in6 *)addr;
        const char *result = inet_ntop(AF_INET6, &(v6->sin6_addr), str, 20);
        if (result == NULL) {
            return nil;
        }
    }
    return [NSString stringWithUTF8String:str];
}


- (void)acceptClientConnectionsLoop
{
    @autoreleasepool {
        while (!self.done) {
            struct sockaddr client;
            socklen_t addrLen = sizeof(client);
            const int clientSocket = accept(self.listenSocket, (struct sockaddr *)&client, &addrLen);
            if (clientSocket == -1) {
                self.done = YES;
            }else{
                int no_sig_pipe = 1;
                setsockopt(clientSocket, SOL_SOCKET, SO_NOSIGPIPE, &no_sig_pipe, sizeof(no_sig_pipe));
                NSString *clientIpAddress = [self sockaddrToNSString:&client];
                NSArray *args = [NSArray arrayWithObjects:clientIpAddress, [NSNumber numberWithInt:clientSocket], nil];
                if (clientIpAddress) {
                    [self performSelectorInBackground:@selector(handleClientConnection:) withObject:args];
                }
            }
        }
        
        [self cleanSocket:self.listenSocket];
    }
}

- (NSData *)line:(int)socket
{
    NSMutableData *lineData = [[NSMutableData alloc] initWithCapacity:100];
    char buff[1];
    ssize_t r = 0;
    do {
        r = recv(socket, buff, 1, 0);
        if (r > 0 && buff[0] > '\r') {
            [lineData appendBytes:buff length:1];
        }
    } while (r > 0 && buff[0] != '\n');
    if (r == -1) {
        return nil;
    }
    return lineData;
}

- (NSDictionary *)queryParameters:(NSURL *)url
{
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] initWithCapacity:10];
    NSString *urlQuery = [url query];
    if (urlQuery) {
        NSArray *tokens = [urlQuery componentsSeparatedByString:@"&"];
        if (tokens) {
            for (int i = 0; i < [tokens count]; ++i) {
                NSString *parameter = [tokens objectAtIndex:i];
                if (parameter) {
                    NSArray *paramTokens = [parameter componentsSeparatedByString:@"="];
                    if ([paramTokens count] >= 2) {
                        NSString *paramName = [paramTokens objectAtIndex:0];
                        NSString *paramValue = [paramTokens objectAtIndex:1];
                        if (paramValue && paramName) {
                            NSString *escapedName = [paramName stringByReplacingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
                            NSString *escapedValue = [paramValue stringByReplacingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
                            if (escapedName && escapedValue) {
                                [parameters setObject:escapedValue forKey:escapedName];
                            }
                        }
                    }
                }
            }
        }
    }
    return parameters;
}

- (NSDictionary *)headers:(int)socket
{
    NSMutableDictionary *headersDictionary = [[NSMutableDictionary alloc] initWithCapacity:10];
    NSData *tmpLine = nil;
    
    do {
        tmpLine = [self line:socket];
        if (tmpLine) {
            NSUInteger lineLength = [tmpLine length];
            if (lineLength > 0) {
                NSString *tmpLineString = [[NSString alloc] initWithData:tmpLine encoding:NSASCIIStringEncoding];
                NSArray *headerTokens = [tmpLineString componentsSeparatedByString:@":"];
                if (headerTokens && [headerTokens count] >= 2) {
                    NSString *headerName = [headerTokens objectAtIndex:0];
                    NSString *headerValue = [headerTokens objectAtIndex:1];
                    if (headerName && headerValue) {
                        [headersDictionary setObject:headerValue forKey:headerName];
                    }
                }
            }
            if (lineLength == 0) {
                break;
            }
        }
    } while (tmpLine);
    
    return headersDictionary;
}

- (void)resetRequestHandler:(SHRequestHandler)handler
{
    self.requestHandler = handler;
}

- (void)handleClientConnection:(id)data
{
    NSArray *args = (NSArray *)data;
    if (args.count < 2) {
        return;
    }
    
    @autoreleasepool {
        
        int socket = [(NSNumber *)[args objectAtIndex:1] intValue];
        NSData *httpInitLine = [self line:socket];
        if (httpInitLine) {
            NSString *httpInitLineString = [[NSString alloc] initWithData:httpInitLine encoding:NSASCIIStringEncoding];
            NSLog(@"REQUEST HTTP INIT LINE: %@", httpInitLineString);
            
            NSArray *httpRequestLine = [httpInitLineString componentsSeparatedByString:@" "];
            
            if ([httpRequestLine count] >= 3) {
                NSString *requestMethod = [httpRequestLine objectAtIndex:0];
                NSURL *requestUrl = [NSURL URLWithString:[httpRequestLine objectAtIndex:1]];
                //                NSDictionary *requestQueryParams = [self queryParameters:requestUrl];
                
                NSMutableURLRequest *urlReq = [NSMutableURLRequest requestWithURL:requestUrl];
                urlReq.HTTPMethod = requestMethod;
                urlReq.allHTTPHeaderFields = [self headers:socket];
                NSString *address = [args objectAtIndex:0];
                
                [self handleRequest:urlReq address:address socket:socket];
                
            }else{
                [self cleanSocket:socket];
            }
        }else{
            [self cleanSocket:socket];
        }
    }
}

- (void)handleRequest:(NSURLRequest *)urlReq address:(NSString *)address socket:(int)socket
{
    if (self.requestHandler) {
        
        __weak __typeof(self)weakself = self;
        SHRequestCallback callback = ^(SHHttpResponse *resp){
            __strong __typeof(weakself)self = weakself;
            [self sendResponseWithSocket:socket response:resp];
        };
        
        BOOL canHandle = self.requestHandler(urlReq, address, callback);
        
        ///不能处理时搞一个默认 404 页面。
        if(!canHandle){
            
            ///状态行
            [SHHttpResponseWriter writeText:@"HTTP/1.1 404 OK\r\n" toSocket:socket];
            ///响应头
            
            NSMutableDictionary *headerDic = [NSMutableDictionary dictionary];
            
            [headerDic setObject:@"Keep-Alive" forKey:@"Connection"];
            [headerDic setObject:@"UTF-8" forKey:@"Charset"];
            [headerDic setObject:@"text/html" forKey:@"Content-Type"];
            
            ///构建header
            __block NSString *respHeader = @"";
            
            [headerDic enumerateKeysAndObjectsUsingBlock:^(NSString * key, id obj, BOOL * _Nonnull stop) {
                respHeader = [respHeader stringByAppendingFormat:@"%@: %@\r\n",key,obj];
            }];
            
            [SHHttpResponseWriter writeText:respHeader toSocket:socket];
            
            ///空白行，这个必须有，否则浏览器里看不到响应内容；
            [SHHttpResponseWriter writeText:@"\r\n" toSocket:socket];
            
            [self cleanSocket:socket];
        }
    }
}

- (void)sendResponseWithSocket:(int)socket response:(SHHttpResponse *)resp
{
    NSInteger status = [resp statusCode];
    NSString * statusLine = [NSString stringWithFormat:@"HTTP/1.1 %ld OK\r\n",status];
    ///状态行
    [SHHttpResponseWriter writeText:statusLine toSocket:socket];
    
    NSString *mime = [resp mimeType];
    ///响应头
    //告诉浏览器使用哪种编码，否者中文会乱码的！
    if (mime.length < 1) {
        mime = @"text/html";
    }
    
    NSData *data =  [resp data];
    
    NSMutableDictionary *headerDic = [NSMutableDictionary dictionaryWithDictionary:resp.header];
    
    [headerDic setObject:@"Keep-Alive" forKey:@"Connection"];
    //告诉浏览器使用哪种编码，否者中文会乱码的！
    [headerDic setObject:@"UTF-8" forKey:@"Charset"];
    [headerDic setObject:mime forKey:@"Content-Type"];
    
    ///内容长度
    if (data.length > 0) {
        [headerDic setObject:@(data.length) forKey:@"Content-Length"];
    }
    
    ///构建header
    __block NSString *respHeader = @"";
    
    [headerDic enumerateKeysAndObjectsUsingBlock:^(NSString * key, id obj, BOOL * _Nonnull stop) {
        respHeader = [respHeader stringByAppendingFormat:@"%@: %@\r\n",key,obj];
    }];
    
    ///发送请求头
    [SHHttpResponseWriter writeText:respHeader toSocket:socket];
    
    ///空白行，这个必须有，否则浏览器里看不到响应内容；
    [SHHttpResponseWriter writeText:@"\r\n" toSocket:socket];
    
    if (data.length > 0) {
        ///响应内容
        [SHHttpResponseWriter writeData:data toSocket:socket];
    }
    
    [self cleanSocket:socket];
}

@end
