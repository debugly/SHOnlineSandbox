//
//  SHHttpResponseProtocol.h
//  SHOnlineSandboxSDK
//
//  Created by 许乾隆 on 2017/10/11.
//  Copyright © 2017年 许乾隆. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SHHttpCommonHeader.h"

@protocol SHHttpResponseProtocol <NSObject>

@required
+ (BOOL)handleRequest:(NSURLRequest *)req clientAddress:(NSString *)clientAddress callback:(SHRequestCallback)callback;

@end
