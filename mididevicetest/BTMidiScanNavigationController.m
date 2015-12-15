//
//  BTMidiScanNavigationController.m
//  mididevicetest
//
//  Created by 谷口 直嗣 on 2015/12/11.
//  Copyright © 2015年 谷口 直嗣. All rights reserved.
//

#import "BTMidiScanNavigationController.h"
#import "BTMidiScanViewController.h"

@interface BTMidiScanNavigationController ()

@end

@implementation BTMidiScanNavigationController

- (instancetype) init{
    BTMidiScanViewController *btMidiScanViewController = [[BTMidiScanViewController alloc]init];
    
    return [self initWithRootViewController:btMidiScanViewController];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    
    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
