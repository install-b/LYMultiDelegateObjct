//
//  ViewController.m
//  LYMultiDelegateObjctDemo
//
//  Created by Shangen Zhang on 2018/1/4.
//  Copyright © 2018年 Shangen Zhang. All rights reserved.
//

#import "ViewController.h"
#import "DelegateManager.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [[DelegateManager sharedManager] addDelegate:self];
}


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [[DelegateManager sharedManager] enumerateDeleagteUsingBlock:^(id delegate, BOOL *stop) {
        NSLog(@"DELEGATE %@",delegate);
    }];
}
@end
