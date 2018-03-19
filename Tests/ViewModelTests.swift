//
//  ViewModelTests.swift
//  MVVMCKitTests
//
//  Created by Vincent Wayne on 3/11/18.
//  Copyright © 2018 Vincet Wayne. All rights reserved.
//

import XCTest
import MVVMCKit
import Result
import ReactiveSwift


fileprivate final class TestViewModel: RACViewModel, ObservableActivity {}

class ViewModelTests: XCTestCase {
    
    var expectedValues: [Int] = []
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        expectedValues = []
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testDidBecomeActive() {
        let viewModel = TestViewModel()
        XCTAssertFalse(viewModel.active)
        
        var nextEvent: Int = 0
        viewModel.didBecomeActive.startWithValues { model in
            XCTAssertTrue(model === viewModel)
            XCTAssertTrue(model.active)
            nextEvent = nextEvent + 1
        }
        
        XCTAssertEqual(0, nextEvent)
        
        viewModel.active = true
        XCTAssertEqual(1, nextEvent)
        
        // Indistinct changes should not trigger the signal again.
        viewModel.active = true
        XCTAssertEqual(1, nextEvent)
        
        viewModel.active = false
        viewModel.active = true
        XCTAssertEqual(2, nextEvent)
    }
    
    func testDidBecomeInactive() {
        let viewModel = TestViewModel()
        XCTAssertFalse(viewModel.active)
        
        var nextEvent: Int = 0
        viewModel.didBecomeInactive.startWithValues { model in
            XCTAssertTrue(model === viewModel)
            XCTAssertFalse(model.active)
            nextEvent = nextEvent + 1
        }
        
        XCTAssertEqual(1, nextEvent)
        
        viewModel.active = true
        viewModel.active = false
        XCTAssertEqual(2, nextEvent)
        
        // Indistinct changes should not trigger the signal again.
        viewModel.active = false
        XCTAssertEqual(2, nextEvent)
    }
    
    func testForwardSignalWhileActive() {
        let (sink, observer) = Signal<Int, NoError>.pipe()
        let model = TestViewModel()
        var values: [Int] = []
        var completed: Bool = false
        let forwarded = model.forwardSignalWhileActive(sink)
        forwarded.observeCompleted {
            completed = true
        }
        forwarded.observeValues {value in
            values.append(value)
        }
        
        model.active = true
        observer.send(value: 1)
        observer.send(value: 2)
        expectedValues = [1, 2]
        XCTAssertEqual(expectedValues, values)
        XCTAssertFalse(completed)
        
        model.active = false
        observer.send(value: 3)
        XCTAssertEqual(expectedValues, values)
        XCTAssertFalse(completed)
        
        expectedValues = [1, 2, 4, 5]
        model.active = true
        observer.send(value: 4)
        observer.send(value: 5)
        XCTAssertEqual(expectedValues, values)
        XCTAssertFalse(completed)
    }
    
    func testThrottleSignalWhileInactive() {
        let (sink, observer) = Signal<Int, NoError>.pipe()
        let model = TestViewModel()
        var values: [Int] = []
        var completed: Bool = false
        let forwarded = model.throttleSignalWhileInactive(sink, on: UIScheduler())
        
        withExtendedLifetime(forwarded) {
            forwarded.observeCompleted {
                completed = true
            }
            
            forwarded.observeValues { value in
                values.append(value)
            }
            
            observer.send(value: 1)
            observer.send(value: 2)
            expectedValues = [2]
            model.active = true
            XCTAssertFalse(completed)
            XCTAssertEqual(expectedValues, values)
            
            model.active = false
            // Since the VM is inactive, these events should be throttled.
            observer.send(value: 3)
            observer.send(value: 4)
            
            // After reactivating, we should still get this event.
            observer.send(value: 5)
            model.active = true
            expectedValues = [2, 5]
            XCTAssertEqual(expectedValues, values)
            XCTAssertFalse(completed)
            
            observer.sendCompleted()
            XCTAssertEqual(expectedValues, values)
            XCTAssertTrue(completed)
        }
    }
}
