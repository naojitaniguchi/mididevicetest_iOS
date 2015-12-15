//
//  BTMidiScanViewController.m
//  mididevicetest
//
//  Created by 谷口 直嗣 on 2015/12/08.
//  Copyright © 2015年 谷口 直嗣. All rights reserved.
//

#import "BTMidiScanViewController.h"
#import "CoreAudioKit/CABTMIDICentralViewController.h"

@implementation BTMidiScanViewController


- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.userInteractionEnabled = YES;
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIButton *connectButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    connectButton.frame = CGRectMake(100, 100, 100, 44);
    [connectButton setTitle:@"connect" forState:UIControlStateNormal];
    [connectButton addTarget:self action:@selector(respondToConnectButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:connectButton];

    
    UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    closeButton.frame = CGRectMake(100, 200, 100, 44);
    [closeButton setTitle:@"close" forState:UIControlStateNormal];
    [closeButton addTarget:self action:@selector(respondToCloseButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:closeButton];


}

- (IBAction) respondToConnectButtonClick:(id)sender
{
    NSLog(@"respondToConnectButtonClick");
    
    CABTMIDICentralViewController *midiCentralCtr = [[CABTMIDICentralViewController alloc] init];
    [self.navigationController pushViewController:midiCentralCtr animated:YES];
    
}

- (IBAction) respondToCloseButtonClick:(id)sender
{
    NSLog(@"respondToCloseButtonClick");
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}


@end
