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
/* <#des#> */
@property (nonatomic,copy) NSString *test;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.test = @"13232dasdwdf23ff32ff";
    
    [[DelegateManager sharedManager] addDelegate:self.test withName:@"12323"];
    
    
    [[DelegateManager sharedManager] addDelegate:self withName:@"12323"];
    
    [[DelegateManager sharedManager] addDelegate:self withName:@"12323"];
    [[DelegateManager sharedManager] addDelegate:@"33" withName:@"12323"];
    
    NSString *str = @"3333232djhsdgwewf";
    [[DelegateManager sharedManager] addDelegate:str withName:@"12323"];
    
    
}


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    NSString *name = @"12323";
    [[DelegateManager sharedManager] enumerateDeleagteWithName:name usingBlock:^(id delegate, BOOL *stop) {
        NSLog(@"DELEGATE %@",delegate);
    }];
}
@end
