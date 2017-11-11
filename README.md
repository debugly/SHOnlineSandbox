# SHOnlineSandbox

用于在线查看 iOS 沙盒文件；测试人员可以用来验证开发逻辑是否正确，文件管理是否正常；开发人员可以在需要的时候导出文件，日志等。该工程也是学习底层 socket，掌握 HTTP 协议的良好范例，里面使用到了 200， 301，404 等状态码！

# 使用方法

- 编译 SHOnlineSandboxSDK 工程，生成 SHOnlineSandboxSDK.framework 静态库，然后添加到你的工程。
- 启动服务:

    ```objc
    #import <SHOnlineSandboxSDK/SHHttpService.h>
    
    @property (nonatomic, strong) SHHttpService *server;
    
    const int port = 9999;
    self.server = [SHHttpService startServerWithPort:port];
    
    [SHHttpService startServerWithPort:port];
    
    NSString *text = [NSString stringWithFormat:@"请访问：http://%@:%d/index.html",[self.server serverIP],port];
    ```

# 原理

- 使用 socket 建立通信，实现了一个 HTTP 协议的服务器，服务器可配置文件服务，API 服务。
- 使用 vue.js 搭建 H5 页面。
- 使用 ajax 异步请求数据。


# 效果

响应式设计，支持各种尺寸的设备。

![](./SHOnlineSandbox.gif)

# TODO

在线预览，下载沙盒文件。