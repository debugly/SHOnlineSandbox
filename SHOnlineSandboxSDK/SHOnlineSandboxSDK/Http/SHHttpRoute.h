//
//  SHHttpRoute.h
//  SHOnlineSandboxSDK
//
//  Created by 许乾隆 on 2017/10/11.
//  Copyright © 2017年 许乾隆. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SHHttpRouteProtocol.h"
#import "SHHttpCommonHeader.h"

@interface SHHttpRoute : NSObject<SHHttpRouteProtocol>

+ (void)registAPI:(NSString *)api handler:(SHRequestHandler)handler;
+ (void)registResource:(NSString *)res handler:(SHRequestHandler)handler;

@end
