//
//  LYMultiDelegateManager.h
//  CoinFriend
//
//  Created by Shangen Zhang on 2018/11/23.
//  Copyright © 2018 Flame. All rights reserved.
//

#import <Foundation/Foundation.h>


/**
  种多关联 多个代理
 */
@interface LYMultiDelegateManager : NSObject

/**
 添加一个代理
 
 @param delegate 需要添加的代理
 @param name 代理的标识
 */
- (void)addDelegate:(id)delegate withName:(NSString *)name;


/**
 移除一个代理
 
 @param delegate 已添加的代理
 @param name 添加代理时的标识
 */
- (void)deleteDelegate:(id)delegate withName:(NSString *)name;


/**
 代理数发生变化
 
 供子类实现
 */
- (void)delegateCountDidChange:(NSInteger)count withName:(NSString *)name;

/**
 遍历代理
 
 @param name 添加代理时的标识
 @param block 遍历回调block
 */
- (void)enumerateDeleagteWithName:(NSString *)name
                       usingBlock:(void(^_Nonnull)(id _Nonnull delegate, BOOL * _Nonnull stop))block;


/**
 遍历代理发送一个消息
 
 @param name 添加代理时的标识
 @param selector 通知代理的方法
 @param parameteres 执行代理方法 传递的参数 用数组传递 （参数 为 nil 使用 NSNull 对象传递）
 */
- (void)sendMessageToDelegatesWithName:(NSString *)name
                              selector:(SEL _Nonnull )selector
                               objects:(NSArray *_Nullable)parameteres;

@end
