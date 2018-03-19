//
//  Coordinator.swift
//  MVVMCKit
//
//  Created by Vincent Wayne on 3/11/18.
//  Copyright © 2018 Vincet Wayne. All rights reserved.
//

import Foundation

public protocol Coordinator: class {
    /// start coordination logic
    func start()
    
    /// finish coordination, tear down logic goes here
    func finish()
}

#if os(iOS)
public protocol WindowCoordinator: Coordinator {
    init(_ window: UIWindow)
}

public protocol TabBarCoordinator: Coordinator {
    init(_ controller: UITabBarController)
}

public protocol NavigationCoordinator: Coordinator {
    init(_ controller: UINavigationController)
}
#elseif os(macOS)
public protocol WindowCoordinator: Coordinator {
    init(_ window: NSWindow)
}
#endif
