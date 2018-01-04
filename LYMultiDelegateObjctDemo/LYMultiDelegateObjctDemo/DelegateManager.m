//
//  DelegateManager.m
//  LYMultiDelegateObjctDemo
//
//  Created by Shangen Zhang on 2018/1/4.
//  Copyright © 2018年 Shangen Zhang. All rights reserved.
//

#import "DelegateManager.h"

@implementation DelegateManager
+ (instancetype)sharedManager {
    static DelegateManager *_instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init];
    });
    return _instance;
}
@end
