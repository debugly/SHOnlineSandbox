//
//  SHHttpCommonHeader.h
//  SHOnlineSandboxSDK
//
//  Created by 许乾隆 on 2017/10/12.
//  Copyright © 2017年 许乾隆. All rights reserved.
//

#ifndef SHHttpCommonHeader_h
#define SHHttpCommonHeader_h

typedef void(^SHRequestCallback)(NSData *data,NSString *mime);
typedef BOOL(^SHRequestHandler)(NSURLRequest *req,NSString *clientAddress,SHRequestCallback callback);

#endif /* SHHttpCommonHeader_h */
