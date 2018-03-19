//
//  ViewModel.swift
//  MVVMCKit
//
//  Created by Vincent Wayne on 3/11/18.
//  Copyright © 2018 Vincet Wayne. All rights reserved.
//

import Foundation
import Result
import ReactiveSwift
import ReactiveCocoa

public protocol ViewModel: InputExtensionProvider, OutputExtensionProvider {}

// FIXME:
// There is a Swift compiler bug (https://bugs.swift.org/browse/SR-4678)
// that prevents us from using the following syntax:
// public typealias ReactiveViewModel = RACViewModel & ObservableActivity
// final public class AnotherViewModel: ReactiveViewModel {}

/// Subclass must be defined as final to satisify ObservableActivity contract
open class RACViewModel: NSObject, ViewModel {
    
    /// Underlying variable that we'll listen to for changes
    private let _active: MutableProperty<Bool> = MutableProperty(false)
    
    /// Public «active» variable
    @objc public dynamic var active: Bool {
        get { return _active.value }
        set {
            // Skip mutation when the property hasn't actually changed. This is
            // especially important because self.active can have very expensive
            // observers attached.
            if newValue == _active.value { return }
            
            _active.swap(newValue)
        }
    }
    
    /// the observable signal for `active`
    public lazy var activeObservable: SignalProducer<Bool, NoError> = {
        return _active.producer.observe(on: UIScheduler())
    }()
    
    /// Initializes a `RACViewModel`
    public override init() {
        super.init()
    }
    
    /// Subscribes (or resubscribes) to the given signal whenever
    /// `didBecomeActiveSignal` fires.
    ///
    /// When `didBecomeInactive` fires, any active subscription to `signal` is
    /// disposed.
    ///
    /// Returns a signal which forwards `next`s from the latest subscription to
    /// `signal`, and completes when the receiver is deallocated. If `signal` sends
    /// an error at any point, the returned signal will error out as well
    public func forwardSignalWhileActive<Value, Error>(_ signal: Signal<Value, Error>) -> Signal<Value, Error> {
        return Signal<Value, Error>.forward(signal, while: activeObservable)
    }
    
    /// Throttles events on the given signal while the receiver is inactive.
    ///
    /// Unlike -forwardSignalWhileActive:, this method will stay subscribed to
    /// `signal` the entire time, except that its events will be throttled when the
    /// receiver becomes inactive.
    ///
    /// Returns a signal which forwards events from `signal` (throttled while the
    /// receiver is inactive), and completes when `signal` completes or the receiver
    /// is deallocated.
    public func throttleSignalWhileInactive<Value, Error>(_ signal: Signal<Value, Error>, on scheduler: Scheduler) -> Signal<Value, Error> {
        return Signal<Value, Error>.throttle(signal, until: activeObservable, on: scheduler)
    }

}

public protocol ObservableActivity: class {
    
    var active: Bool { get }
    
    var activeObservable: SignalProducer<Bool, NoError> { get }
    
    /// `SignalProducer` for the `active` flag. (when it becomes `true`).
    ///
    /// Will send messages only to *new* & *different* values.
    var didBecomeActive: SignalProducer<Self, NoError> { get }
    
    
    /// `SignalProducer` for the `active` flag. (when it becomes `false`).
    ///
    /// Will send messages only to *new* & *different* values.
    var didBecomeInactive: SignalProducer<Self, NoError> { get }
}

extension ObservableActivity {
    public var didBecomeActive: SignalProducer<Self, NoError> {
        return activeObservable.filter { $0 }.map { [unowned self] _ in
            return self
        }
    }
    
    public var didBecomeInactive: SignalProducer<Self, NoError> {
        return activeObservable.filter { !$0 }.map { [unowned self] _ in
            return self
        }
    }
}
