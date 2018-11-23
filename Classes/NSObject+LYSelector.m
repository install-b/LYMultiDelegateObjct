//
//  NSObject+LYSelector.m
//  CoinFriend
//
//  Created by Shangen Zhang on 2018/11/23.
//  Copyright © 2018 Flame. All rights reserved.
//

#import "NSObject+LYSelector.h"

@implementation NSObject (LYSelector)
- (id)ly_performSelector:(SEL)selector withObjects:(NSArray *)objects {
    
    // 获取方法签名
    NSMethodSignature *sinnature = [[self class] instanceMethodSignatureForSelector:selector];
    
    // 方法签名校验 是否实现
    if (sinnature == nil) {
#ifdef DEBUG    // debug 模式下 抛出异常
        [NSException raise:@"错误方法" format:@"-[%@ %@]%@ 方法找不到",self.class,NSStringFromSelector(selector),self];
#else           // 发布环境  容错处理
        return nil;
#endif
    }
    
    // 根据方法签名 创建消息调用对象
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:sinnature];
    
    // 默认传的两个值 参数
    invocation.selector = selector;
    invocation.target = self;
    
    // 减去默认传递的两个参数
    NSInteger argumentCount = sinnature.numberOfArguments - 2;
    
    // 数组界限获取 最高不能超过方法的参数
    argumentCount = MIN(argumentCount, objects.count);
    
    // 设置参数
    for (NSInteger i = 0; i < argumentCount; i++) {
        id obj = objects[i];
        if ([obj isKindOfClass:[NSNull class]]) {
            continue;
        }
        [invocation setArgument:&obj atIndex:i + 2];
    }
    
    // 执行方法
    [invocation invoke];
    
    // 获取返回值
    id returnValue = nil;
    if (sinnature.methodReturnLength) {
        [invocation getReturnValue:&returnValue];
    }
    
    return returnValue;
}
@end
