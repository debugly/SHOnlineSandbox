//
//  NSURLRequest+Query.m
//  SHOnlineSandboxSDK
//
//  Created by 许乾隆 on 2017/10/22.
//  Copyright © 2017年 许乾隆. All rights reserved.
//

#import "NSURLRequest+Query.h"

@implementation NSURLRequest (Query)

- (NSDictionary *)queries_sh
{
    if (self.URL.query.length > 0) {
        NSMutableDictionary *qs = [NSMutableDictionary dictionaryWithCapacity:3];
        NSArray *items = [self.URL.query componentsSeparatedByString:@"&"];
        
        for (NSString *item in items) {
            NSArray *keyValue = [item componentsSeparatedByString:@"="];
            NSString *key = [keyValue firstObject];
            NSString *value = [keyValue lastObject];
            if (key.length > 0 && value.length > 0) {
                [qs setObject:value forKey:key];
            }
        }
        return [qs copy];
    }
    return nil;
}

@end
