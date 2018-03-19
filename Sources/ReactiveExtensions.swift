//
//  ReactiveExtensions.swift
//  MVVMCKit
//
//  Created by Vincent Wayne on 3/11/18.
//  Copyright © 2018 Vincet Wayne. All rights reserved.
//

import Foundation
import Result
import ReactiveSwift

extension Signal {
    
    /// Subscribes (or resubscribes) to the given signal whenever
    /// `shouldContinue` is true.
    ///
    /// When `shouldContinue` is false, any active subscription to `signal` is
    /// disposed.
    ///
    /// Returns a signal which forwards `next`s from the latest subscription to
    /// `signal`, and completes when the receiver is deallocated. If `signal` sends
    /// an error at any point, the returned signal will error out as well.
    public static func forward<Value, Error>(_ signal: Signal<Value, Error>, while shouldContinue: Signal<Bool, NoError>) -> Signal<Value, Error> {
        return forward(signal, while: shouldContinue.producer)
    }

    /// Subscribes (or resubscribes) to the given signal whenever
    /// `shouldContinue` is true.
    ///
    /// When `shouldContinue` is false, any active subscription to `signal` is
    /// disposed.
    ///
    /// Returns a signal which forwards `next`s from the latest subscription to
    /// `signal`, and completes when the receiver is deallocated. If `signal` sends
    /// an error at any point, the returned signal will error out as well.
    public static func forward<Value, Error>(_ signal: Signal<Value, Error>, while shouldContinue: SignalProducer<Bool, NoError>) -> Signal<Value, Error> {
        return Signal<Value, Error> { observer, lifetime in
            let serialDisposable = SerialDisposable()
            lifetime += serialDisposable
            lifetime += shouldContinue.startWithValues { active in
                if active {
                    serialDisposable.inner = signal.observe(observer)
                } else {
                    serialDisposable.inner = nil
                }
            }
        }
    }
    
    /// Throttles events on the given signal until `trigger` becomes true.
    ///
    /// Unlike -forward:, this method will stay subscribed to
    /// `signal` the entire time, except that its events will be throttled when
    /// `trigger` is false.
    ///
    /// Returns a signal which forwards events from `signal` (throttled while the
    /// `trigger` is false), and completes when `signal` completes or the receiver
    /// is deallocated.
    public static func throttle<Value, Error>(_ signal: Signal<Value, Error>, until trigger: Signal<Bool, NoError>, on scheduler: Scheduler) -> Signal<Value, Error> {
        return throttle(signal, until: trigger.producer, on: scheduler)
    }

    /// Throttles events on the given signal until `trigger` becomes true.
    ///
    /// Unlike -forward:, this method will stay subscribed to
    /// `signal` the entire time, except that its events will be throttled when
    /// `trigger` becomes false.
    ///
    /// Returns a signal which forwards events from `signal` (throttled while the
    /// `trigger` is false), and completes when `signal` completes or the receiver
    /// is deallocated.
    public static func throttle<Value, Error>(_ signal: Signal<Value, Error>, until trigger: SignalProducer<Bool, NoError>, on scheduler: Scheduler) -> Signal<Value, Error> {
        return Signal<Value, Error> { observer, lifetime in
            let shouldThrottle: MutableProperty<Bool> = MutableProperty(false)

            lifetime += trigger.startWithValues { value in
                shouldThrottle.swap(!value)
            }

            let throttledSignal = signal.throttle(while: shouldThrottle, on: scheduler)
            
            lifetime += throttledSignal.observeCompleted {
                observer.sendCompleted()
            }
            
            lifetime += throttledSignal.observeInterrupted {
                observer.sendInterrupted()
            }
            
            lifetime += throttledSignal.observeResult { result in
                switch result {
                case .success(let value):
                    observer.send(value: value)
                case .failure(let error):
                    observer.send(error: error)
                }
            }
        }
    }
    
    
}

extension Signal {
    /// Convert receiver with typed Error to Signal<Value, NoError>
    public func ignoreErrors() -> Signal<Value, NoError> {
        return Signal<Value, NoError> { [weak self] observer, lifetime in
            lifetime += self?.observeResult { result in
                switch result {
                case .success(let value):
                    observer.send(value: value)
                case .failure:
                    break
                }
            }
        }
    }
    
    /// Convert receiver to a signal that only emit errors
    public func ignoreValues() -> Signal<Void, Error> {
        return Signal<Void, Error> { [weak self] observer, lifetime in
            lifetime += self?.observeResult { result in
                switch result {
                case .success:
                    break
                case .failure(let error):
                    observer.send(error: error)
                }
            }
        }
    }
}

