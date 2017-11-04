//
//  ViewController.m
//  SHOnlineSandbox
//
//  Created by 许乾隆 on 2017/9/26.
//  Copyright © 2017年 许乾隆. All rights reserved.
//

#import "ViewController.h"
#import <SHOnlineSandboxSDK/SHHttpService.h>

@interface ViewController ()

@property (nonatomic, strong) SHHttpService *server;
@property (weak, nonatomic) IBOutlet UITextView *tx;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    const int port = 9999;
    
    self.server = [SHHttpService startServerWithPort:port];
    
    NSString *text = [NSString stringWithFormat:@"请访问：http://%@:%d/index.html",[self.server serverIP],port];
    
    NSLog(@"%@",text);
    
    self.tx.text = text;
}

- (void)dealloc
{
    [self.server stop];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
