//
//  SafeExcute.swift
//  MultiDelegate
//
//  Created by Shangen Zhang on 2019/11/28.
//  Copyright © 2019 Shangen Zhang. All rights reserved.
//

import UIKit

open class SafeExcute {
    private static let queueKey = DispatchSpecificKey<Int>()
    private lazy var safeQueue = DispatchQueue.init(label: "\(self)_queue")
    private lazy var queueContext: Int = unsafeBitCast(self, to: Int.self)

    public init() {
        safeQueue.setSpecific(key: Self.queueKey, value: queueContext)
    }
}

public extension SafeExcute {
    func excute<T>(_ block: () throws -> T) rethrows -> T {
        /// 相同队列 直接执行
        if queueContext == DispatchQueue.getSpecific(key: Self.queueKey){ return try block() }
        /// 其他的队列 串行执行
        return try safeQueue.sync(execute: block)
    }
}
