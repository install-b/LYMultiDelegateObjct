//
//  LYMultiDelegateManager.m
//  CoinFriend
//
//  Created by Shangen Zhang on 2018/11/23.
//  Copyright © 2018 Flame. All rights reserved.
//

#import "LYMultiDelegateManager.h"
#import "LYMultiDelegateObjct.h"


#pragma mark - LYMultiDelegateObjctAssociate 关联对象

@class LYMultiDelegateObjctAssociate;
@protocol LYMultiDelegateObjctAssociateDelegate <NSObject>

/**
 代理数发送变化

 @param mDelegateMgr 代理关联对象
 @param count 变化后的数量
 */
- (void)multiDelegateObjct:(LYMultiDelegateObjctAssociate *)mDelegateMgr
    delegateCountDidChange:(NSInteger)count;
@end


@interface LYMultiDelegateObjctAssociate : LYMultiDelegateObjct
/* 关联名称 */
@property (nonatomic,copy,readonly) NSString *name;
/* 代理 */
@property (nonatomic,weak,readonly) id <LYMultiDelegateObjctAssociateDelegate> delegate;

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;


/**
 构造方法

 @param name 对象名称
 @param delegate 代理
 @return 实例对象
 */
- (instancetype)initWithName:(NSString *)name
                    delegate:(id <LYMultiDelegateObjctAssociateDelegate>)delegate;

@end

@implementation LYMultiDelegateObjctAssociate

- (instancetype)initWithName:(NSString *)name
                    delegate:(id <LYMultiDelegateObjctAssociateDelegate>)delegate {
    if (name.length < 1) {
        return nil;
    }
    if (self = [super init]) {
        _name = name;
        _delegate = delegate;
    }
    return self;
}
@end


#pragma mark - LYMultiDelegateManager
/**
 *  多对象关联多代理管理对象
 *
 */
@interface LYMultiDelegateManager () <LYMultiDelegateObjctAssociateDelegate>
{
    dispatch_semaphore_t _lock;
    NSMutableDictionary <NSString *,LYMultiDelegateObjctAssociate *>*_delegateDict;
}
@end



@implementation LYMultiDelegateManager

- (instancetype)init {
    if (self = [super init]) {
        _delegateDict = [NSMutableDictionary dictionary];
        _lock = dispatch_semaphore_create(1);
    }
    return self;
}

- (LYMultiDelegateObjctAssociate *)p_getAssociateWithName:(NSString *)name lazyLoad:(BOOL)lazyLoad {
    
    LYMultiDelegateObjctAssociate  *associate = nil;
    // 开启信号量 锁住
    dispatch_semaphore_wait(_lock, DISPATCH_TIME_FOREVER);
    
    
    associate = [_delegateDict objectForKey:name];
    
    if (!associate && lazyLoad) {
        // 没有就构造一个
        associate = [[LYMultiDelegateObjctAssociate alloc] initWithName:name delegate:self];
        
        [_delegateDict setObject:associate forKey:name];
    }
    
    // 释放信号量 解锁
    dispatch_semaphore_signal(_lock);
    
    return associate;
}


- (void)addDelegate:(id)object withName:(NSString *)name {
    if (object == nil || name.length == 0) {
        return ;
    }
    // 懒加载关联代理对象
    LYMultiDelegateObjctAssociate  *associate = [self p_getAssociateWithName:name lazyLoad:YES];
    
    // 添加代理
    [associate addDelegate:object];
}

- (void)deleteDelegate:(id)object withName:(NSString *)name {
    if (object == nil || name.length == 0) {
        return ;
    }
    // 直接获取关联代理对象
    LYMultiDelegateObjctAssociate  *associate = [self p_getAssociateWithName:name lazyLoad:NO];
    // 移除代理
    [associate deleteDelegate:object];
}


/**
 遍历代理包装对象
 */
- (void)enumerateDeleagteWithName:(NSString *)name usingBlock:(void(^_Nonnull)(id _Nonnull delegate, BOOL * _Nonnull stop))block {
    if (!block) {
        return;
    }
    // 直接获取关联代理对象
    LYMultiDelegateObjctAssociate  *associate = [self p_getAssociateWithName:name lazyLoad:NO];
    
    // 遍历该代理
    [associate enumerateDeleagteUsingBlock:block];
}

/**
 给代理对象发送一个消息
 */
- (void)sendMessageToDelegatesWithName:(NSString *)name
                              selector:(SEL _Nonnull )selector
                               objects:(NSArray *_Nullable)pargamrs {
    
    // 直接获取关联代理对象
    LYMultiDelegateObjctAssociate  *associate = [self p_getAssociateWithName:name lazyLoad:NO];
    
    // 发送消息
    [associate sendSelector:selector toDelegatesWithObjects:pargamrs];
}

#pragma mark - LYMultiDelegateObjctAssociate Delegate
- (void)multiDelegateObjct:(LYMultiDelegateObjctAssociate *)mDelegateMgr delegateCountDidChange:(NSInteger)count {
    [self delegateCountDidChange:count withName:mDelegateMgr.name];
}


/**
 代理数发生变化
 */
- (void)delegateCountDidChange:(NSInteger)count withName:(NSString *)name {}

@end
