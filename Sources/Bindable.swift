//
//  Bindable.swift
//  MVVMCKit
//
//  Created by Vincent Wayne on 3/11/18.
//  Copyright © 2018 Vincet Wayne. All rights reserved.
//

import Foundation

public protocol Bindable: InputExtensionProvider, OutputExtensionProvider {
    associatedtype Bond
}

public protocol BindableView: Bindable where Bond: ViewModel {
    
    init(viewModel: Bond)
    
    var viewModel: Bond { get }
}
