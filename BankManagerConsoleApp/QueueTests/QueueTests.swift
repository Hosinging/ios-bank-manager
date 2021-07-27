//
//  QueueTests.swift
//  QueueTests
//
//  Created by YongHoon JJo on 2021/07/27.
//

import XCTest
@testable import BankManagerConsoleApp

class QueueTests: XCTestCase {
    var sut: Queue<Int>!
    
    override func setUp() {
        sut = Queue<Int>()
    }
    
    func test_큐에_enqueue_메서드를_통해_임의의_데이터를_삽입하면_isEmpty_메서드의_리턴값이_false_이다() {
        // given
        let testData = Int.random(in: 1...100)
        
        // when
        sut.enqueue(value: testData)
        let expectedResult = false
        let result = sut.isEmpty()
        
        // then
        XCTAssertEqual(expectedResult, result)
    }
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
}
