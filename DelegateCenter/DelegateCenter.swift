//
//  DelegateCenter.swift
//  MultiDelegate
//
//  Created by Shangen Zhang on 2019/11/28.
//  Copyright © 2019 Shangen Zhang. All rights reserved.
//

import UIKit

open class DelegateCenter: SafeExcute {
    public static let `default` = DelegateCenter()
    private(set) var delegateCollection: [String: Any] = [String: Any]()
    
    private func lazyGetMultiProxyObject<T>() -> MultiProxyObject<T> where T: NSObjectProtocol {
        excute {
            let name = "\(T.self)"
            if let mProxy = delegateCollection[name] as? MultiProxyObject<T> {
                return mProxy
            }
            let obj = MultiProxyObject<T>()
            delegateCollection[name] = obj
            return obj
        }
    }
}

public extension DelegateCenter {
    func add<T>(_ delegate: T) where T: NSObjectProtocol {
        let object: MultiProxyObject<T> = lazyGetMultiProxyObject()
        object.add(delegate: delegate)
    }
    
    func remove<T>(_ delegate: T) where T: NSObjectProtocol {
        let object: MultiProxyObject<T> = lazyGetMultiProxyObject()
        object.remove(delegate: delegate)
    }


    func enumDelegate<T>(_ : T.Type,
                         using block: (_: T, _: UnsafeMutablePointer<ObjCBool>) -> Void)
        where T: NSObjectProtocol {
        let object: MultiProxyObject<T>? = excute {  return delegateCollection["\(T.self)"] as? MultiProxyObject<T> }
        object?.enumerateDelegate(using: block)
    }
}
