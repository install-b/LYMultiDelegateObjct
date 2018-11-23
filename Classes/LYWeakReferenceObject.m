//
//  LYWeakReferenceObject.m
//  CoinFriend
//
//  Created by Shangen Zhang on 2018/11/8.
//  Copyright © 2018 Flame. All rights reserved.
//

#import "LYWeakReferenceObject.h"

@implementation LYWeakReferenceObject

static NSMutableSet * weakObjectCache;
+ (void)initialize {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        weakObjectCache = [NSMutableSet set];
    });
}

+ (void)clearCache {
    [weakObjectCache removeAllObjects];
}

+ (instancetype)weakReferencePakerWithObject:(id)weakReferenceObjc {
    // 缓存池加入一个对象
    LYWeakReferenceObject *wObj = [weakObjectCache anyObject];
    
    // 校验
    if (!wObj) {
        wObj = [[LYWeakReferenceObject alloc] init]; // 没有就创建一个
    }else {
        [weakObjectCache removeObject:wObj];
    }
    
    // 设置属性
    wObj.weakObject = weakReferenceObjc;
    
    // 返回实例对象
    return wObj;
}

- (void)saveToCache {
    self.weakObject = nil;
    [weakObjectCache addObject:self];
}
@end
