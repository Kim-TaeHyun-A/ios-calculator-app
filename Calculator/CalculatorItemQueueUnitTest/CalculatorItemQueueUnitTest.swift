//
//  CalculatorItemQueueUnitTest.swift
//  CalculatorItemQueueUnitTest
//
//  Created by si won kim on 2021/11/09.
//

import XCTest

class CalculatorItemQueueUnitTest: XCTestCase {
    var sut: CalculatorItemQueue<Character>!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        sut = CalculatorItemQueue<Character>()
    }

    override func tearDownWithError() throws {
        try super.tearDownWithError()
        sut = nil
    }

    func test_빈_큐에_1을_enqueue하면_1이_남는다() {
        //given
        let input: Character = "1"
        
        //when
        sut.enqueue(input)
        guard let result = sut.dequeue() else { return }
        
        //then
        XCTAssertEqual(result, "1")
    }
    
    func test_빈_큐에_1과_2를_enqueue하면_1과_2가_남는다() {
        //given
        let firstInput: Character = "1"
        let secondInput: Character = "2"
        
        //when
        sut.enqueue(firstInput)
        sut.enqueue(secondInput)
        guard let firstResult = sut.dequeue() else { return }
        guard let secondResult = sut.dequeue() else { return }
        
        //then
        XCTAssertEqual(firstResult, "1")
        XCTAssertEqual(secondResult, "2")
    }
    
    func test_빈_큐에_더하기를_enqueue하면_더하기가_남는다() {
        //given
        let input: Character = "+"
        
        //when
        sut.enqueue(input)
        guard let result = sut.dequeue() else { return }
        
        //then
        XCTAssertEqual(result, "+")
    }
    
    func test_1과_2와_3이_있는_큐를_dequeue하면_1이_나온다() {
        //given
        let firstInput: Character = "1"
        let secondInput: Character = "2"
        let thirdInput: Character = "3"
        
        //when
        sut.enqueue(firstInput)
        sut.enqueue(secondInput)
        sut.enqueue(thirdInput)
        guard let result = sut.dequeue() else { return }
        
        //then
        XCTAssertEqual(result, "1")
    }
    
    func test_빈_큐에_dequeue을_하면_에러가_난다() {
        //when
        let result = sut.dequeue()
        
        //then
        XCTAssertNil(result)
    }

    func test_1과_2가_있는_큐의_모든_요소를_제거하면_빈_큐가_된다() {
        //when
        sut.removeAll()
        
        //then
        let result = sut.dequeue()
        XCTAssertNil(result)
    }
}
