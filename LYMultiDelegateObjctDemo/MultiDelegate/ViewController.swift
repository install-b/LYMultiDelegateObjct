//
//  ViewController.swift
//  MultiDelegate
//
//  Created by Shangen Zhang on 2019/11/28.
//  Copyright © 2019 Shangen Zhang. All rights reserved.
//

import UIKit

@objc protocol ViewControllerDelegate: NSObjectProtocol {
    
}

class MyObject: NSObject, ViewControllerDelegate {
    
}

extension ViewController: ViewControllerDelegate {
    
}

extension ViewController: MultiProxyObjectDelegate {
    func delegateCountDidChange(_ objc: Any, count: Int) {
        print("count change \(count)")
    }
}


class ViewController: UIViewController {
    
    let mutiProxy = MultiProxyObject<ViewControllerDelegate>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        mutiProxy.delegate = self
        let obj = MyObject()
        mutiProxy.add(delegate: obj)
        
        let obj1 = obj
        let obj2 = MyObject()
        mutiProxy.add(delegate: obj1)
        mutiProxy.add(delegate: obj2)
        mutiProxy.add(delegate: self)
        
        mutiProxy.enumerateDelegate { (delegate, _) in
            print(delegate)
        }
        
        print("--------")
        print(obj, obj1, obj2)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        mutiProxy.add(delegate: self)
        mutiProxy.remove(delegate: self) //
        mutiProxy.enumerateDelegate { (delegate, _) in
            print(delegate)
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        mutiProxy.remove(delegate: self)
        mutiProxy.add(delegate: self)
        mutiProxy.add(delegate: MyObject())
        let obj = MyObject()
        mutiProxy.add(delegate: obj)
        mutiProxy.enumerateDelegate { (delegate, _) in
            print(delegate)
        }
    }
}

