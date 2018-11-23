//
//  NSObject+LYSelector.h
//  CoinFriend
//
//  Created by Shangen Zhang on 2018/11/23.
//  Copyright © 2018 Flame. All rights reserved.
//

#import <Foundation/Foundation.h>



@interface NSObject (LYSelector)

/**
 给对象动态发送一个消息

 @param selector 方法
 @param objects 执行方法的参数 （nil 使用 Null 对象代替)
 @return 执行方法返回值
 */
- (id)ly_performSelector:(SEL)selector withObjects:(NSArray *)objects;

@end
