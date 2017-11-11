//
//  SHHttpResponse.m
//  SHOnlineSandboxSDK
//
//  Created by 许乾隆 on 2017/11/11.
//  Copyright © 2017年 许乾隆. All rights reserved.
//

#import "SHHttpResponse.h"

@implementation SHHttpResponse

+ (instancetype)make:(void(^)(SHHttpResponse *maker))makeBlock
{
    SHHttpResponse *resp = [SHHttpResponse new];
    makeBlock(resp);
    return resp;
}

@end
