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

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.server = [SHHttpService startServerWithPort:4040];
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
