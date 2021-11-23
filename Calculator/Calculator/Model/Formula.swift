import Foundation

struct Formula {
    private(set) var operands: CalculatorItemQueue<Double>
    private(set) var operators: CalculatorItemQueue<Operator>
    
    mutating func result() -> Double {
        guard var calculatedResult = operands.dequeue() else { return 0.0 }

        while let nextOperator = operators.dequeue(),
              let nextOperand = operands.dequeue() {
            calculatedResult = nextOperator.calculate(lhs: calculatedResult,
                                                      rhs: nextOperand)
            }
        
        return calculatedResult
    }
}
