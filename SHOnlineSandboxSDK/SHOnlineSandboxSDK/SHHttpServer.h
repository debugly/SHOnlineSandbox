//
//  SHHttpServer.h
//  SHOnlineSandboxSDK
//
//  Created by 许乾隆 on 2017/9/26.
//  Copyright © 2017年 许乾隆. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SHHttpServer : NSObject

+ (instancetype)httpServer;

- (BOOL)startWithPort:(int)port;

- (void)stop;

@end
