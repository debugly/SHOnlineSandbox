//
//  SHHttpResponse.h
//  SHOnlineSandboxSDK
//
//  Created by 许乾隆 on 2017/11/11.
//  Copyright © 2017年 许乾隆. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SHHttpResponse : NSObject

@property (nonatomic, assign) NSInteger statusCode;
@property (nonatomic, copy) NSString *mimeType;
@property (nonatomic, strong) NSData *data;
@property (nonatomic, strong) NSDictionary *header;

+ (instancetype)make:(void(^)(SHHttpResponse *maker))makeBlock;

@end
