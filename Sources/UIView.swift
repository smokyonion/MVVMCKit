//
//  UIView.swift
//  MVVMCKit
//
//  Created by Vincent Wayne on 3/11/18.
//  Copyright © 2018 Vincet Wayne. All rights reserved.
//

import UIKit
import Result
import ReactiveSwift

extension Reactive where Base: UIView {
    public var removeFromSuperview: Signal<Void, NoError> {
        return signal(for: #selector(base.removeFromSuperview)).map { _ in }
    }
}
