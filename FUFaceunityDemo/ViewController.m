//
//  ViewController.m
//  FUFaceunityDemo
//
//  Created by support on 2020/9/4.
//  Copyright © 2020 support. All rights reserved.
//

#import "ViewController.h"

#import "FURenderViewController.h"


@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
}

// 进入美颜
- (IBAction)startBtnClick:(UIButton *)sender {
    
    FURenderViewController *renderVC = [[FURenderViewController alloc] init];
    [self.navigationController pushViewController:renderVC animated:YES];
    
}


@end
