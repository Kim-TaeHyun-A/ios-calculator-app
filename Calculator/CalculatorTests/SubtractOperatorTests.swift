//
//  SubtractOperatorTests.swift
//  CalculatorTests
//
//  Created by 김진태 on 2021/11/14.
//

import XCTest
@testable import Calculator

class SubtractOperatorTests: XCTestCase {
    var sut: Operator!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        sut = .subtract
    }
    
    override func tearDownWithError() throws {
        try super.tearDownWithError()
        sut = nil
    }
    
    func testSubtractTwoNumbers() {
        let firstNumber = 3.0
        let secondNumber = 6.0
        
        let calculatedResult = sut.calculate(lhs: firstNumber, rhs: secondNumber)
        XCTAssertEqual(calculatedResult, firstNumber - secondNumber)
    }
    
    func testSubtractThreeNumbers() {
        let firstNumber = 6.0
        let secondNumber = 9.0
        let thirdNumber = 96.0
        
        var calculatedResult = sut.calculate(lhs: firstNumber, rhs: secondNumber)
        calculatedResult = sut.calculate(lhs: calculatedResult, rhs: thirdNumber)
        
        XCTAssertEqual(calculatedResult, firstNumber - secondNumber - thirdNumber)
    }
}
