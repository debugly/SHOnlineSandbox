//
//  SHHttpService.h
//  SHOnlineSandboxSDK
//
//  Created by 许乾隆 on 2017/10/12.
//  Copyright © 2017年 许乾隆. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SHHttpService : NSObject

- (instancetype)initWithPort:(int)port;
+ (instancetype)startServerWithPort:(int)port;
- (void)stop;

@end
