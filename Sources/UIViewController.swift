//
//  UIViewController.swift
//  MVVMCKit
//
//  Created by Vincent Wayne on 3/11/18.
//  Copyright © 2018 Vincet Wayne. All rights reserved.
//

import UIKit
import Result
import ReactiveSwift

extension Reactive where Base: UIViewController {
    
    public var didLoad: Signal<Void, NoError> {
        return signal(for: #selector(base.viewDidLoad)).map { _ in }
    }
    
    public var willAppear: Signal<Void, NoError> {
        return signal(for: #selector(base.viewWillAppear)).map { _ in }
    }
    
    public var didAppear: Signal<Void, NoError> {
        return signal(for: #selector(base.viewDidAppear)).map { _ in }
    }
    
    public var willDisappear: Signal<Void, NoError> {
        return signal(for: #selector(base.viewWillDisappear)).map { _ in }
    }
    
    public var didDisappear: Signal<Void, NoError> {
        return signal(for: #selector(base.viewDidDisappear)).map { _ in }
    }
}
