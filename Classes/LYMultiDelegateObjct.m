//
//  LYMultiDelegateObjct.m
//  LYMultiDelegateObjct
//
//  Created by admin on 16/12/24.
//  Copyright © 2016年 shangen zhang. All rights reserved.
//

#import "LYMultiDelegateObjct.h"
#import "LYWeakReferenceObject.h"
#import "NSObject+LYSelector.h"


#pragma mark - ------------------------LYMultiDelegateObjct--------------------------

@interface LYMultiDelegateObjct ()

{
    NSInteger _delegateCount;
}

/** 代理集合表 */
@property(nonatomic,strong) NSMutableSet <LYWeakReferenceObject *> *delegateSet;
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
    [set enumerateObjectsUsingBlock:^(LYWeakReferenceObject * _Nonnull obj, BOOL * _Nonnull stop) {
        if (obj.weakObject) return;
        // 加入公共缓存
        [obj saveToCache];
        // 移除对象缓存
        [self->_delegateSet removeObject:obj];
    }];
}

- (void)enumerateDeleagteUsingBlock:(void (^)(id delegate, BOOL *stop))block {
    return [_delegateSet enumerateObjectsUsingBlock:^(LYWeakReferenceObject * _Nonnull obj, BOOL * _Nonnull stop) {
        if (obj.weakObject) {
            !block ?: block(obj.weakObject,stop);
        }else {
            // 加入公共缓存
            [obj saveToCache];
            // 移除对象缓存
            [self->_delegateSet removeObject:obj];
        }
    }];
}
#pragma mark - 发消息给代理
// 给代理发消息
- (void)sendSelector:(SEL)selector toDelegatesWithObjects:(NSArray *)pargamrs {
    // 消息转发
    [_delegateSet enumerateObjectsUsingBlock:^(LYWeakReferenceObject * _Nonnull obj, BOOL * _Nonnull stop) {
        // 发消息给代理
        if ([obj.weakObject respondsToSelector:selector]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [obj.weakObject ly_performSelector:selector withObjects:pargamrs];
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
    [self.delegateSet enumerateObjectsUsingBlock:^(LYWeakReferenceObject * _Nonnull obj, BOOL * _Nonnull stop) {
        if (obj.weakObject == delegate) {
            hasAdd = YES;
            *stop = YES;
        }
    }];
    
    if(hasAdd) return;
    
    // 回收通知 所有对象
    [[NSNotificationCenter defaultCenter] postNotificationName:@"lyt_sdk_dealloc_noti" object:self];
    
    // 包装成对象弱引用 代理  （从缓存区获取）
    LYWeakReferenceObject *  objectDelegate = [LYWeakReferenceObject weakReferencePakerWithObject:delegate];
    
    // 添加到代理集合中
    [self.delegateSet addObject:objectDelegate];
    
    // 设置代理监听数
    [self setDelegateCount:_delegateSet.count];
}

- (void)deleteDelegate:(id)object {
    // nil校验
    if (!object) return;
    
    // 遍历代理集合
    [_delegateSet enumerateObjectsUsingBlock:^(LYWeakReferenceObject * _Nonnull obj, BOOL * _Nonnull stop) {
        // 代理集合中找
        if (obj.weakObject == object) {
            // 加入缓存池
            [obj saveToCache];
            
            // 移除对象代理列表
            [self->_delegateSet removeObject:obj];
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
- (NSMutableSet<LYWeakReferenceObject *> *)delegateSet {
    
    if (!_delegateSet) {
        _delegateSet = [NSMutableSet set];
    }
    return _delegateSet;
}
@end
