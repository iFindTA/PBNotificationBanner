//
//  ViewController.m
//  PBBanner
//
//  Created by nanhujiaju on 2017/9/13.
//  Copyright © 2017年 nanhujiaju. All rights reserved.
//

#import "ViewController.h"
#import "PBNotificationBanner.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)infoEvent:(id)sender {
    [PBNotificationBanner showInfoWithStatus:@"传输进行中..."];
}

- (IBAction)errorEvent:(id)sender {
    [PBNotificationBanner showErrorWithStatus:@"3个上传任务失败"];
}

- (IBAction)successEvent:(id)sender {
    [PBNotificationBanner showSuccessWithStatus:@"上传任务完成了"];
}

@end
