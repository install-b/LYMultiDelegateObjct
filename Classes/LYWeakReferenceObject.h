//
//  LYWeakReferenceObject.h
//  CoinFriend
//
//  Created by Shangen Zhang on 2018/11/8.
//  Copyright © 2018 Flame. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface LYWeakReferenceObject : NSObject
/** weakObject 弱引用对象 */
@property (nonatomic,weak) id weakObject;


+ (instancetype)weakReferencePakerWithObject:(id)weakReferenceObjc;

+ (void)clearCache;

- (void)saveToCache;
@end
