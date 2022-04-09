# 계산기 I
> 프로젝트 기간 2022.03.14 ~ 2022.03.25 </br>

## 프로젝트 소개

계산기를 만듭니다.

## 키워드
- TDD 시작하기
- Queue 자료구조의 이해와 구현
- UML을 기반으로 한 코드구현
- 숫자와 연산자 입력에 큐 활용
- IBOutlet / IBAction의 활용
- 스택뷰의 활용
- 스크롤뷰의 활용

---

## PR

[STEP 1 PR](https://github.com/yagom-academy/ios-calculator-app/pull/163)

[STEP 2 PR](https://github.com/yagom-academy/ios-calculator-app/pull/183)

[STEP 3 PR](https://github.com/yagom-academy/ios-calculator-app/pull/203)

---
## [STEP 1]

## UML

![Class Diagram-6](https://user-images.githubusercontent.com/70807352/158533031-c41acf4d-19f3-4650-a556-c4ed11d0aa31.png)


### 구현한 내용

- **class** CalculatorItemQueue : 계산기에서 사용되는 큐
    - queue: LinkedList<CalculatorItem> : 큐
    - isEmpty() -> Bool : 큐가 비어있는가?
    - enqueue(_ node: Node<CalculatorItem>) : 큐에 값 넣기
    - dequeue() -> CalculatorItem? : 큐에서 값 빼기
    - clear() : 큐 전체 비우기
- **class** Node<T>: Equatable
    - data: T : 노드 데이터
    - next: Node? : 다음 노드 가리킨다.
- **class** LinkedList<T>: Sequence
    - head: Node<T>? : 연결 리스트의 첫 노드
    - tail: Node<T>? : 연결 리스트의 마지막 노드
    - isEmpty() -> Bool : 연결 리스트가 비었는가?
    - append(node: Node<T>) : 연결 리스트에 맨 뒤에 노드 추가
    - removeFirst() -> T? : 연결 리스트에 맨 앞 노드 제거
    - clear() : 연결 리스트 전체 비우기
    - makeIterator() -> LinkedListIterator<T>
- **class** LinkedListIterator<T>: IteratorProtocol
    - **typealias** Element = Node<T>
    - current: Element
    - next() -> Element?
- **enum** Operator : 연산자
- **enum** CalculatorItem : 연산자와 정수, 실수
- **protocol** CalculateItem : 빈 프로토콜

---


### 고민 사항

1. 네이밍

2. . 연결 리스트
    - 처음에는 큐를 배열로 만들었지만 리스트를 직접 만들고 싶어서 큐와 비슷하게 선입선출이 가능한 연결 리스트를 정의했습니다.
    - 정의한 연결 리스트 타입에서 고차함수를 사용하고 싶어서 프로토콜을 채택했습니다.아래처럼 구현하면 정의된 타입에서 고차함수를 사용할 수 있습니다.
        
    ```swift
        func test_sequence채택_고차함수사용가능한지() {
                sut.enqueue(MockNode.mockOperator)
                sut.enqueue(MockNode.mockDouble)
        
                let result: [CalculatorItem] = sut.map { $0.data }
                let expectation = [CalculatorItem.integer(10), CalculatorItem.operator(.devision), CalculatorItem.double(3.5)]
        
                XCTAssertEqual(result, expectation)
        }
    ```
        
    
    ```swift
    extension CalculatorItemQueue: Sequence {
        func makeIterator() -> queueIterator<T> {
            return queueIterator(current: self.queue.head)
        }
    }
    
    struct queueIterator<T>: IteratorProtocol {
        typealias Element = Node<T>
        
        var current: Element?
        
        mutating func next() -> Element? {
            if let node = current {
                current = node.next
                return node
            } else {
                return nil
            }
        }
    }
    ```
    
    ```swift
    func test_sequence채택_고차함수사용가능한지() {
            sut?.append(node: Node(data: 2))
    
            let result: [Int] = sut!.map {test in test.data}
    
            XCTAssertEqual(result, [1, 2])
    }
    ```
    
    ```swift
    extension LinkedList: Sequence {
        func makeIterator() -> LinkedListIterator<T> {
            return LinkedListIterator(current: self.head)
        }
    }
    
    struct LinkedListIterator<T>: IteratorProtocol {
        var current: Node<T>?
        
        mutating func next() -> Node<T>? {
            if let node = current {
                current = node.next
                return node
            } else {
                return nil
            }
        }
    }
    ```
    
    - 기존에 시도했던 배열과 달리 인덱스를 통한 값 찾기가 불가능하고 next로 하나씩 찾아가서 search의 성능은 좋지 않은 것 같습니다.
    - 배열의 경우 값 변경이 발생하면 전체 요소들의 이동이 발생하지만 연결 리스트의 경우는 삽입과 삭제에서 유리합니다. 그러니까 제일 앞의 값을 삭제할 때 유리할 것 같습니다.
    
3. 연산자와 숫자를 타입으로 묶기
    - 제너릭을 사용하면 하나의 타입만 넣을 수 있습니다.
    - 계산기에서 입력될 값이 연산자와 숫자일 것 같아 다른 타입을 하나의 리스트에 넣고 싶었습니다.
    
4. 파일 분리
    - 직접 작성한 class일 경우에는 extension을 따로 파일로 분리하지 않습니다.
    - 만약 Int와 같이 Swift에서 제공하는 타입을 extension으로 구현할 경우, 별도의 Utils > Extension 그룹을 생성하여 Int+extension.swift와 같은 네이밍으로 파일을 분리하여 작성합니다.
    - Extension말고도 Common(전역 상수, typealias)같은 것도 들어갑니다.
    
5. UnitTest와 TDD
    * Unit Test는 특정 타입의 메서드가 잘 동작하는지 확인하는 것이 목적인 것 같습니다. 그러니까 테스트 케이스를 만들 때, given/when/then과 같은 방식으로 메서드에 input을 넣었을 때 기대하는 output과 실제 메서드의 output을 비교하면서 메서드가 개발자의 의도에 맞게 동작하는지를 확인해야 하는 것으로 이해했습니다.

    * TDD는 테스트를 반복적으로 하면서 기능을 완성시키는 개발 방법 중 하나입니다.

6. commit 작게 하기

---

## [STEP 2]

### 구현한 내용

- CalculatorError
- **extension** String
    - split(with target: Character) -> [String] : target을 기준으로 나뉜 문자열 배열을 반환
- Operator : 연산자에 맞는 연산 진행
    - calculate(lhs: Double, rhs: Double) **throws** -> Double
    - add(lhs: Double, rhs: Double) -> Double
    - subtract(lhs: Double, rhs: Double) -> Double
    - devide(lhs: Double, rhs: Double) **throws** -> Double
    - multiply(lhs: Double, rhs: Double) -> Double
- Formula : 연산자 큐와 피연산자 큐를 이용해서 결과값 반환
    - result() **throws** -> Double
- ExpressionParser
    - parse(from input: String) -> Formula : 연결 리스트를 이용해서 큐를 생성
    - componentsByOperators(from input: String) -> [String] : 숫자로만 이워진 배열을 추출

---

### 고민한점

1. 네이밍
    - 테스트 케이스의 네이밍: 내부에 구현된 데이터를 자세히 명시하지 않고, 확인하려는 기능에 대해서만 설명하도록 작성했습니다. 이 경우, 내부에서 다른 데이터를 넣어서 확인해도 테스트 케이스의 이름은 수정할 필요가 없어 좋을 것 같습니다.
    
2. UML에 충실하게
    
3. 유닛 테스트
    - 외부에서 사용되지 않는다는 생각에 모든 테스트 케이스에 private을 설정했지만 제대로 테스트가 돌아가지 않아 무조건 테스트를 성공하는 것을 확인했습니다.
    - 정확한 이유는 모르겠지만 import한 모듈에서 접근이 필요해서 internal으로 설정하는 것 같습니다.
    - 타겟을 설정할 때 import가 되지 않아 target membership을 임의로 체크했는데 이 때문에 Calcaultor 모듈이나 UIKit에 접근 불가능했습니다. 확인해보니, 해당 파일이 속한 최상위 그룹이 그 파일의 타겟이 되는 것 같습니다. 또 @testable로 모듈을 import하는 경우 굳이 target memebership을 하나하나 설정할 필요가 없는 것 같습니다.
    
4. 다른 타입과의 의존도
    - 이니셜라이저 내부에서 다른 타입의 인스턴스를 생성하기 보다는 외부에서 주입 받을 수 있도록 했습니다.
    ```swift
    init(linkedList: LinkedList<T>) {
        self.linkedList = linkedList
    }
    ```
    * 문제 발생 : Queue 내부에서의 사용을 위해 private으로 접근제어한 linkedList를 외부에서 주입을 받게 되면 외부에서도 linkedList에 접근할 수 있는 가능성이 생기는 것
    ```siwft
    let headNode = Node<Double>(data: 3.0)
    let nextNode = Node<Double>(data: 5.0)
    let linkedList = LinkedList(head: headNode)
    let queue = CalculatorItemQueue(linkedList: linkedList)
    linkedList.append(node: nextNode)
    queue.enqueue(nextNode)
    ```
    - 구현 당시에는 private으로 선언했지만 이니셜라이저로 초기화할 때를 제외하면 접근이 불가능한 상태이며, 프로퍼티에 직접 접근은 불가능하지만 메서드를 통해 간접적으로 값을 변경하기에 괜찮다고 생각했습니다. 또 기존의 이니셜라이저는 node를 통해 인스턴스를 생성하는 방식이라 한 번에 리스트를 주입하는 것이 더 자연스러운 것 같았습니다. 이때 개굴이 보여주신 예시처럼 문제점이 있는데, 리스트가 참조타입이라 주입된 값이 외부에서도 변경될 위험이 있음을 고려하지 못했습니다.(private으로 한 것이 아무 의미가 없어지네요..😢)
    - 타입간의 의존도를 낮추는 것이 무조건 좋다고 생각했는데 외부 타입이 해당 타입에서 꼭 필요한 요소의 경우는 의존을 하도록 설계하는 것이 더 바람직할 것 같습니다. 또한 타입의 사용자가 알 필요가 없는 외부 타입의 경우는 완전 숨기는 것이 좋은 것 같네요. 또, 주입할 값이 참조 타입인 경우는 더 고민해서 접근제어자나 생성/주입 방법에 대해 고민해야겠습니다😭

* 이니셜라이저에서나 프로퍼티의 기본값으로 빈 리스트를 생성하고 enqueue로만 node를 주입받는 것이 적절한 것 같습니다. 조언해주신 것을 고민해보니 큐의 형태가 연결리스트라는 것을 굳이 노출하지 않고 프로퍼티에 기본값으로 빈 리스트를 할당하고 enqueue로만 node를 추가하도록 하는 것이 더 좋을 것 같습니다! 이러면 이 타입이 사용되는 메서드 parse()에서도 리스트를 굳이 생성할 필요가 없어서 더 간결하게 큐를 만들 것 같네요

* 타입간의 의존도를 낮추는 것이 무조건 좋다고 생각했는데 외부 타입이 해당 타입에서 꼭 필요한 요소의 경우는 의존을 하도록 설계하는 것이 더 바람직할 것 같습니다. 또한 타입의 사용자가 알 필요가 없는 외부 타입의 경우는 완전 숨기는 것이 좋은 것 같네요. 또, 주입할 값이 참조 타입인 경우는 더 고민해서 접근제어자나 생성/주입 방법에 대해 고민해야겠습니다😭

* 이니셜라이저에서나 프로퍼티의 기본값으로 빈 리스트를 생성하고 enqueue로만 node를 주입받는 것이 적절한 것 같습니다. 조언해주신 것을 고민해보니 큐의 형태가 연결리스트라는 것을 굳이 노출하지 않고 프로퍼티에 기본값으로 빈 리스트를 할당하고 enqueue로만 node를 추가하도록 하는 것이 더 좋을 것 같습니다! 이러면 이 타입이 사용되는 메서드 parse()에서도 리스트를 굳이 생성할 필요가 없어서 더 간결하게 큐를 만들 것 같네요🤔
    
5. error handling
    - 0으로 나뉘는 것을 제외한 경우(ex. 연속된 연산자 입력)은 UI 쪽에서 제어가 가능하다고 판단하여 추가적인 에러 처리는 없습니다.
    
6. 파일 분리
    - Utils라는 그룹 내에 Error와 Extension을 넣었습니다.
    
7. commit 단위 작게
    
8. ExpressionParser
    - 이번 스탭에서 가능 고민했던 구현 부분이지만 구현이 깔끔하지 못한 것 같아 아쉬운 부분입니다.😭
    - UML에서 요구한 split() 메서드를 사용해서 연산자와 숫자를 분리하는 방법에 대해 고민했습니다.
    - prefix로 올 -/ +를 처리하는 방법에 대해 고민했습니다. 뷰에서 빈 칸을 넣어주고 이를 이용하는 것보다는 입력된 값에서 자체적으로 연산자와 숫자들을 분리하고 싶었습니다. 이 과정에서 연달아서 어떤 값이 오는지 확인해야 하지만 뷰에서 값을 직관적으로 받아올 수 있기 때문에 이 방법을 사용했습니다.
    
9. 테스트 삭제 시 타겟 제거
    - 불필요한 테스트를 삭제하는 경우 타겟을 지우지 않으니 모든 테스트를 통과해도 테스트가 실패했다고 나왔습니다. 이를 해결하기 위해 프로젝트 설정에서 남아있는 타겟을 제거했습니다.
    
10. 고차함수 활용
    
11. 프로토콜 채택 표기 순서
    - Operator의 경우 CalculateItem과 CaseIterable을 채택합니다. 채택 시 구현이 필요한 부분이 있으면 extension으로 따로 작성했겠지만, 이 경우 구현을 요구하지도 않아 타입 구현에서 2가지를 다 채택합니다. 구현되는 내용이 없어도 extension으로 다 빼는 것이 가독성이 좋은지 궁금합니다. 또 한 개 이상을 채택하는 경우 선호되는 채택 순서는 rawValue로 사용되는 타입이 가장 처음에 상속되어야하고 나머지에 대해서는 implement되어 있는 프로토콜 -> 직접 정의한 프로토콜 순서로 작성한다고 합니다.
    
12. 메스드만 가지는 enum
    - 기존에 값 타입은 주로 struct을 사용하고 case가 필요한 경우만 enum을 사용했습니다. 그런데, 이번 스탭의 UML을 보니 case가 없는 enum의 구현을 요구해서 그 이유에 대한 고민을 했습니다.
    - enum의 경우 케이스가 없으니 인스턴스 생성이 제한적이어서 특정 목적의 타입 메서드를 모아놓기에 좋을 것이라고 생각됩니다.

13. 하드 코딩 지양

    Separator 타입으로 값 구분용으로 사용된 underScore를 간접적으로 표기합니다.
14. 고차함수

    고차함수를 연결해서 계속 사용하는 것과 반복문을 사용했을 때의 차이점에 대해 고민했습니다.
https://medium.com/skoumal-studio/performance-of-built-in-higher-order-function-vs-for-in-loop-in-swift-166fa41b545f

    시간 복잡도를 생각했을 때 반복적으로 element에 접근하니까 체이닝하는 경우는 반복문보다 더 안좋을 것 같은데요. 단편적으로 고차함수 하나와 반복문을 비교하는 경우는 비슷하거나 고차함수의 성능이 더 좋을 것 같습니다. 그렇지만 여러 개를 연결할 경우 체이닝이 더 나쁜 것 같네요. 구현을 어떻게 하느냐의 차이일수도 있지만 성능의 차이나 시간 복잡도(그 외에 최적화에 대한 차이도 있는 것 같은데 잘 모르겠습니다.🤔)에 대해 고민했습니다.
    
    * 실행 속도는 반복문이 더 빠른 것 같습니다.
    ```swift
    let elementsCount = 100000
    let fahrenheit = Array(repeating: 0.0, count: elementsCount).map { _ -> Double in
        return Double.random(in: 32.0 ... 113.0)
    }

    func forVersionOfForEach() {
        let startTime = CFAbsoluteTimeGetCurrent()
        for degreesFahrenheit in fahrenheit {
        let _ = (degreesFahrenheit - 32.0) / 1.8
        }
        let durationTime = CFAbsoluteTimeGetCurrent() - startTime
        print("for문 경과 시간: \(durationTime)")
    }

    func singleForEach() {
        let startTime = CFAbsoluteTimeGetCurrent()
        fahrenheit.forEach({ (degreesFahrenheit) in
            let _ = (degreesFahrenheit - 32.0) / 1.8
        })
        let durationTime = CFAbsoluteTimeGetCurrent() - startTime
        print("forEach 경과 시간: \(durationTime)")
    }

    // for문 경과 시간: 0.016786932945251465
    // forEach 경과 시간: 0.08115100860595703
    ```
    
    * 고차함수는 상수에 바로 값을 할당할 수 있습니다. 컬렉션에 반복적으로 접근하여 수행하고자 하는 일을 완료한 뒤 임시적으로 어딘가에 할당하지 않고 모든 일이 완료된 후 결과를 생성합니다. 따라서 할당 후 변경의 여지를 주고 싶지 않은 경우 의도대로 설계할 수 있습니다. 반면, 반복문은 반복해서 컬렉션에 접근할 수 있지만 변경하려는 대상이 변수로 선언되어야 수정이 가능해서 추후 예상치 못한 변경의 위험에 노출됩니다.

    * 이번 스탭에서 ex: parse 메서드에서 map으로 생성된 결과를 이후 forEach에서 반복적으로 접근 가능합니다.

    * 또 고차함수는 내부에서 return을 해도 다음 element를 가져와서 명령문을 수행하지만, 반복문의 경우는 반복문을 종료합니다.


    
15. struct vs final class
    * 구조체는 값 타입으로 생성된 인스턴스를 다른 곳에 할당해서 서로 영향을 주지 않지만, 클래스의 경우 참조 타입이므로 다른 곳에서 할당하여 사용하는 경우 그 인스턴스를 공유하는 모든 곳에서 변경이 가능합니다.

    * 구조체 타입의 인스턴스를 변수에 할당하면 해당 인스턴스의 변수 프로퍼티의 값 변경이 가능한 반면, 인스턴스를 상수에 할당하면 변수 프로퍼티라도 값 변경이 불가능합니다. 클래스는 인스턴스 할당을 변수에 하든 상수에 하든 상관없이 변수의 프로퍼티라면 값 변경이 가능합니다. 이때의 차이점이라면, 클래스 인스턴스를 상수에 할당하면 그 상수에는 다른 인스턴스를 할당할 수 없습니다.

    * 구조체의 경우 프로퍼티의 값을 변경한다면, mutating 키워드가 필요하고 클래스는 그렇지 않습니다. 프로퍼티가 값 타입이냐 참조 타입이냐에 따라 다르지만 CalculatorItemQueue는 참조타입의 인스턴스를 상수 프로퍼티로 가져서 별도의 키워드 없이도 프로퍼티 내부를 수정할 수 있습니다.

    * class는 원래 vTable을 사용하지만 final class의 경우 상속의 가능성을 배제시켰기에 compile 시점에 메서드가 결정되는 static dispatch가 되어 run time에서의 성능은 struct과 비슷할 것으로 생각됩니다.

 
---
    
## Step3
    
## 구현한 내용

* enum CalculatorConstant

* 아울렛 변수

    * scrollView : 스크롤 뷰 제일 하단에 추가되는 스택이 고정적으로 출력되게 할 때 사용됨
    * inputStackView : 입력된 숫자와 연산자가 한 줄씩(각각 하나의 스택 구성하여) 들어가는 스택뷰
    * operatorLabel : 입력된 연산자를 보임
    * numberLabel : 현재 입력 중인 숫자 보임
    * acButton : 전체 입력 스택(inputStackView)을 비움
    * ceButton : 현재 입력 중인 숫자(numberLabel.text)를 제거
    * prefixButton : 현재 입력 중인 숫자의 제일 앞에서 -/+를 반전시킴
    * 연산자 버튼들(+, -, /, *)
    * dotButton
    * zeroButton : 0
    * doubleZeroButton : 00
    * 숫자 버튼(1~9)
* @IBAction func touchUpNumberButton(_ sender: UIButton)

    : 모든 숫자 버튼이 연결된 액션 메서드

    : 입력된 버튼을 확인하고 옳은 입력인지 확인(ex. 00이 눌렸는지, “.”이 한 번 이상 눌렸는지 확인)

    : 첫 숫자가 아닌 경우는 0이나 00을 눌러도 0이 입력될 수 있도록 처리

    : 현재 숫자 레이블에 입력될 첫 숫자이면서 .이 아닌 경우는 현재 입력값으로 숫자 레이블을 대체하고

    그렇지 않다면 기존 값에 연결되어야 하기에 append 시킴
* @IBAction func touchUpEqualButton(_ sender: UIButton)
    : stack을 추가하고 결과를 계산한다.
    
* @IBAction func touchUpOperatorButton(_ sender: UIButton)

    : 모든 연산자 버튼과 연결된 액션 메서드

    : 현재 숫자 레이블의 값이 0이고 이제껏 입력된 숫자가 없으면 무시

    : 연산자가 눌리면 inputStackView에 스택을 추가

    : 연산자가 = 이면 calculatorInput을 파싱하여 계산

    : 계산된 결과가 20자리 이상이면 에러 처리

    : 소수점은 10자리까지

    : 숫자는 3자리씩 끊어서 , 로 구분

    : 결과를 숫자 레이블에 출력하고 연산자 레이블은 값을 없앰

    : 결과가 에러면 NaN 출력

    : 계산기에서 입력된 숫자가 있는 경우에만 연산자가 연산자 레이블에 표시되고 현재 입력 중이던 숫자가 0으로 갱신 되도록

* @IBAction func touchUpFunctionButton(_ sender: UIButton)

    : AC, CE, prefix(-/+)를 구분하여 적절한 기능 수행

* viewDidLoad() : 숫자 레이블과 연산자 레이블 초기화
* findNumber(of button: UIButton) throws -> String
* isValidNumber(inputNumber: String) -> Bool
* isValidLength(inputNumber: String) -> Bool
* updateNumberLabel(with inputNumber: String)
* addInputStack()
* generateStack() -> UIStackView?
* generateStackLabels() -> (UILabel, UILabel)?
* setAnimation(of stack: UIStackView)
* setScrollViewLayout()
* calculate()
* findOperator(of button: UIButton) throws -> String
* setLabelsText(inputOperator: String = CalculatorConstant.defaultOperator,
                              inputNumber: String = CalculatorConstant.defaultNumber)
* findFunction(of button: UIButton) throws
* removeStack()
* removeLabelText()
* configurePrefix()

---

## 고민한 점

* numberLabel.text 값 갱신

    가독성을 위해 nubmerLabel.text를 변수에 담아서 사용하고 값을 갱신하려고 했지만 해당 값이 String이어서 의도대로 수정되지 않았습니다. 따라서, 값을 수정할 때는 원래 프로퍼티에 직접 접근하여 값을 갱신합니다.

* 스토리보드의 stackView 이용

    이번 프로젝트에서는 동적으로 스택뷰가 스크롤뷰에 추가됩니다. 이때, 기존에 스토리보드에 있던 스택뷰를 사용하면 새로운 값이 추가되는 것이 아니라 기존 값이 변경됩니다. 따라서, 스택이 추가될 때마다 새로운 스택뷰를 만들어서 추가하는 방식으로 구현했습니다.

    스크롤 뷰 제일 하단에 최신 값 오도록 구성

    스크롤 뷰의 `func setContentOffset(_ contentOffset: CGPoint, animated: Bool)`

    를 사용해서 CGPoint를 설정합니다.


* NumberFormatter 이용해서 숫자 표현하기

    반올림이 어떻게 되는지, 소수점이 어디까지 표현되는지를 디버깅을 통해 확인해서 원하는 결과를 얻을 수 있도록 구현했습니다.

* 20자리를 최대 수로 설정하기
    Double의 경우 최대로 표현하는 자리수가 15자리입니다.
    String의 경우는 count로 자리수를 확인하고 허용되는 자리수인 경우에만 입력받습니다.

* 함수 작게 나누기
    함수가 어떤 책임을 가지고 있는지를 고려하여 함수를 작게 나눴습니다.
    이를 통해 오류 발생 시 함수 수정에 용이하고 재사용성이 좋아집니다.
