//
//  LYMultiDelegateObjct.m
//  LYMultiDelegateObjct
//
//  Created by admin on 16/12/24.
//  Copyright © 2016年 shangen zhang. All rights reserved.
//

#import "LYMultiDelegateObjct.h"


#pragma mark - ------------------------WEAK OBJECT CACHE--------------------------
/*******************  interface ************************/
@interface LYTWeakObject : NSObject
/** weakObject 弱引用对象 */
@property(nonatomic,weak) id weakDelegate;
@end
/******************* implementation  *************************/
@implementation LYTWeakObject
@end


@implementation NSObject (Selector)

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
#pragma mark - ------------------------LYMultiDelegateObjct--------------------------

@interface LYMultiDelegateObjct ()

{
    NSInteger _delegateCount;
}

/** 代理集合表 */
@property(nonatomic,strong) NSMutableSet <LYTWeakObject *> *delegateSet;
@end


@implementation LYMultiDelegateObjct
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)init {
    if (self = [super init]) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(lyt_deallocNoti) name:@"lyt_sdk_dealloc_noti" object:nil];
    }
    return self;
}

#pragma mark - noti
- (void)lyt_deallocNoti {
    
    if (![_delegateSet count]) return ;
    
    NSMutableSet *set = [_delegateSet mutableCopy];
    // 回收被 死掉的代理包装对象
    [set enumerateObjectsUsingBlock:^(LYTWeakObject * _Nonnull obj, BOOL * _Nonnull stop) {
        if (obj.weakDelegate) return;
        // 加入公共缓存
        saveWeakObjectToCache(obj);
        // 移除对象缓存
        [_delegateSet removeObject:obj];
    }];
}

- (void)enumerateDeleagteUsingBlock:(void (^)(id delegate, BOOL *stop))block {
    return [_delegateSet enumerateObjectsUsingBlock:^(LYTWeakObject * _Nonnull obj, BOOL * _Nonnull stop) {
        if (obj.weakDelegate) {
            !block ?: block(obj.weakDelegate,stop);
        }
    }];
}
#pragma mark - 发消息给代理
// 给代理发消息
- (void)sendSelector:(SEL)selector toDelegatesWithObjects:(NSArray *)pargamrs {
    // 消息转发
    [_delegateSet enumerateObjectsUsingBlock:^(LYTWeakObject * _Nonnull obj, BOOL * _Nonnull stop) {
        // 发消息给代理
        if ([obj.weakDelegate respondsToSelector:selector]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [obj.weakDelegate ly_performSelector:selector withObjects:pargamrs];
            });
        }
    }];
}
#pragma mark - 添加移除代理
- (void)addDelegate:(id)delegate {
    // nil 校验
    if (delegate == nil) return;
    
    // 检查是否被添加过
    __block BOOL hasAdd = NO;
    [self.delegateSet enumerateObjectsUsingBlock:^(LYTWeakObject * _Nonnull obj, BOOL * _Nonnull stop) {
        if (obj.weakDelegate == delegate) {
            hasAdd = YES;
            *stop = YES;
        }
    }];
    
    if(hasAdd) return;
    
    // 回收通知 所有对象
    [[NSNotificationCenter defaultCenter] postNotificationName:@"lyt_sdk_dealloc_noti" object:self];
    
    // 包装成对象弱引用 代理  （从缓存区获取）
    LYTWeakObject *  objectDelegate =  getReuseWeakObjectWithWeakDelegate(delegate);
    // 添加到代理集合中
    [self.delegateSet addObject:objectDelegate];
    
    // 设置代理监听数
    [self setDelegateCount:_delegateSet.count];
}

- (void)deleteDelegate:(id)object {
    // nil校验
    if (!object) return;
    
    // 遍历代理集合
    [_delegateSet enumerateObjectsUsingBlock:^(LYTWeakObject * _Nonnull obj, BOOL * _Nonnull stop) {
        // 代理集合中找
        if (obj.weakDelegate == object) {
            // 加入缓存池
            saveWeakObjectToCache(obj);
            // 移除对象代理列表
            [_delegateSet removeObject:obj];
            *stop = YES;
        }
    }];
    // 设置代理监听数
    [self setDelegateCount:_delegateSet.count];
}

- (void)setDelegateCount:(NSInteger)count {
    if (_delegateCount == count) {
        return;
    }
    _delegateCount = count;
    [self delegateCountDidChange:count];
}

- (void)delegateCountDidChange:(NSInteger)count {
    // 子类实现
}

#pragma mark - 懒加载 包装集合
- (NSMutableSet<LYTWeakObject *> *)delegateSet {
    
    if (!_delegateSet) {
        _delegateSet = [NSMutableSet set];
    }
    return _delegateSet;
}

#pragma mark - ---------------- 公共缓存 ---------------
static NSMutableSet * weakObjectCache;

static LYTWeakObject * getReuseWeakObjectWithWeakDelegate(id delegate) {
    if (!weakObjectCache) {
        weakObjectCache = [NSMutableSet set];
    }
    // 缓存池加入一个对象
    LYTWeakObject *wObj = [weakObjectCache anyObject];
    
    // 校验
    if (!wObj) {
        wObj = [[LYTWeakObject alloc] init]; // 没有就创建一个
    }else {
        [weakObjectCache removeObject:wObj];
    }
    
    // 设置属性
    wObj.weakDelegate = delegate;
    
    // 返回实例对象
    return wObj;
}

static void saveWeakObjectToCache(LYTWeakObject *weakObj) {
    if (!weakObjectCache) {
        weakObjectCache = [NSMutableSet set];
    }
    weakObj.weakDelegate = nil;
    [weakObjectCache addObject:weakObj];
}
@end


