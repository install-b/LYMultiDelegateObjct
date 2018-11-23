//
//  LYMultiDelegateObjct.h
//  LYMultiDelegateObjct
//
//  Created by admin on 16/12/24.
//  Copyright © 2016年 shangen zhang. All rights reserved.
//

// 多代理对象

#import <Foundation/Foundation.h>


@interface LYMultiDelegateObjct : NSObject
#pragma mark -  delegate operation
/**
 抽类方法 设置代理 (可以设置多个均为weak)

 @param delegate 代理
 */
- (void)addDelegate:(id _Nullable)delegate;


/**
 移除代理

 @param delegate 代理对象
 */
- (void)deleteDelegate:(id _Nullable)delegate;

/**
 代理数发生变化
 
  供子类实现
 */
- (void)delegateCountDidChange:(NSInteger)count;

/**
  遍历代理

 @param block 遍历回调
 */
- (void)enumerateDeleagteUsingBlock:(void(^_Nonnull)(id _Nonnull delegate, BOOL * _Nonnull stop))block;

/** 
 给代理对象发送一个消息 供子类调用
 
 @param selector 通知代理的方法
 @param parameteres 方法的参数数组 当参数为nil值时 传Null对象 如若数组后面连续全部为nil值时 后面参数可不穿
 */
- (void)sendSelector:(SEL _Nonnull )selector toDelegatesWithObjects:(NSArray *_Nullable)parameteres;

@end

