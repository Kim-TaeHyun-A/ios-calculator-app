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

[step 3 PR](https://github.com/yagom-academy/ios-calculator-app/pull/203)

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
2. 연결 리스트
    - 처음에는 큐를 배열로 만들었지만 리스트를 직접 만들고 싶어서 큐와 비슷하게 선입선출이 가능한 연결 리스트를 정의했습니다.
    - 정의한 연결 리스트 타입에서 고차함수를 사용하고 싶어서 프로토콜을 채택했습니다. ~~테스트를 해본 결과 무한루프에 빠지는데요. 프로토콜 채택 시 구현한 메서드의 내용이 잘못된 것 같습니다. 어떤 부분에서 잘못되었는지 알 수 있을까요?~~ 😭
        
        current  값 갱신을 안했더라구요. 아래처럼 구현하면 정의된 타입에서 고차함수를 사용할 수 있습니다.
        
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
    - extension끼리 묶는 것이 좋을지 고민입니다. 파일을 구분하는 기준이 명확하지 않아 어떤 기준으로 나누는 것이 좋을지 궁금합니다.
    - 지금 기준은 중요하다 생각되는 타입은 개별적인 파일에 두고 그 타입과 관련되는 것들을 같은 파일 내에 위치시켰습니다. 만약 extension이라는 group을 생성한다면 extension한 타입별로 파일을 나눠야 할까요? 그렇다면 확인을 위해 파일 이동을 해야하는데 코드 수정 시 가독성은 괜찮을까요?
5. TDD
    - 처음에 배열로 리스트를 만들고 테스트 코드를 작성했습니다. 이후 리스트를 연결리스트로 바꾸면서 테스트 코드를 전체적으로 다 수정했는데요. 테스트가 타입에 의존해서 발생한 문제일까요?
    - 프로토콜로 진행하게 되어도 채택한 타입에서 정의한 프로퍼티나 메서드를 사용하려면 다운 캐스팅을 진행해야 할 것 같은데요. 테스트 케이스는 타입을 수정할 때마다 변경하는 것이 맞을까요?
    - 테스트 시 @testable 해도 private으로 선언된 것은 타입 외부이므로 접근이 불가능하다고 알고 있습니다. 그렇다면 테스트용 타입을 따로 만들어야 할까요? 아니면 테스트할 때만 기존 코드의 접근제어자를 수정했다가 다시 private을 붙여야 할까요?
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

### 고민한 점

1. 네이밍
    - 테스트 케이스의 네이밍: 내부에 구현된 데이터를 자세히 명시하지 않고, 확인하려는 기능에 대해서만 설명하도록 작성했습니다. 이 경우, 내부에서 다른 데이터를 넣어서 확인해도 테스트 케이스의 이름은 수정할 필요가 없어 좋을 것 같습니다.
2. UML에 충실하게
3. 유닛 테스트
    - 외부에서 사용되지 않는다는 생각에 모든 테스트 케이스에 private을 설정했지만 제대로 테스트가 돌아가지 않아 무조건 테스트를 성공하는 것을 확인했습니다.
    - 정확한 이유는 모르겠지만 import한 모듈에서 접근이 필요해서 internal으로 설정하는 것 같습니다.
    - 타겟을 설정할 때 import가 되지 않아 target membership을 임의로 체크했는데 이 때문에 Calcaultor 모듈이나 UIKit에 접근 불가능했습니다. 확인해보니, 해당 파일이 속한 최상위 그룹이 그 파일의 타겟이 되는 것 같습니다. 또 @testable로 모듈을 import하는 경우 굳이 target memebership을 하나하나 설정할 필요가 없는 것 같습니다.
4. 다른 타입과의 의존도
    - 이니셜라이저 내부에서 다른 타입의 인스턴스를 생성하기 보다는 외부에서 주입 받을 수 있도록 했습니다.
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
    - Operator의 경우 CalculateItem과 CaseIterable을 채택합니다. 채택 시 구현이 필요한 부분이 있으면 extension으로 따로 작성했겠지만, 이 경우 구현을 요구하지도 않아 타입 구현에서 2가지를 다 채택합니다. 구현되는 내용이 없어도 extension으로 다 빼는 것이 가독성이 좋은지 궁금합니다. 또 한 개 이상을 채택하는 경우 선호되는 채택 순서가 있을지 궁금합니다.
12. 메스드만 가지는 enum
    - 기존에 값 타입은 주로 struct을 사용하고 case가 필요한 경우만 enum을 사용했습니다. 그런데, 이번 스탭의 UML을 보니 case가 없는 enum의 구현을 요구해서 그 이유에 대한 고민을 했습니다.
    - enum의 경우 케이스가 없으니 인스턴스 생성이 제한적이어서 특정 목적의 타입 메서드를 모아놓기에 좋을 것이라고 생각됩니다.

 
---
    
## Step3
    
---
    
##구현한 내용

CalculatorViewController: UIViewController

calculatorInput 프로퍼티 : 누적으로 입력된 숫자와 연산자 문자열을 저장

hasFirstInput 프로퍼티 : 스크롤 뷰 내부의 content인 스택에 값을 넣은 적이 있는지 확인. 제일 앞에 연산자가 오지 않기 때문에 구분 필요.

아울렛 변수

scrollView : 스크롤 뷰 제일 하단에 추가되는 스택이 고정적으로 출력되게 할 때 사용됨
inputStackView : 입력된 숫자와 연산자가 한 줄씩(각각 하나의 스택 구성하여) 들어가는 스택뷰
operatorLabel : 입력된 연산자를 보임
numberLabel : 현재 입력 중인 숫자 보임
acButton : 전체 입력 스택(inputStackView)을 비움
ceButton : 현재 입력 중인 숫자(numberLabel.text)를 제거
prefixButton : 현재 입력 중인 숫자의 제일 앞에서 -/+를 반전시킴
연산자 버튼들(+, -, /, *, = )
dotButton
zeroButton : 0
doubleZeroButton : 00
숫자 버튼(1~9)
@IBAction func touchUpNumberButton(_ sender: UIButton)

: 모든 숫자 버튼이 연결된 액션 메서드

: 입력된 버튼을 확인하고 옳은 입력인지 확인(ex. 00이 눌렸는지, “.”이 한 번 이상 눌렸는지 확인)

: 첫 숫자가 아닌 경우는 0이나 00을 눌러도 0이 입력될 수 있도록 처리

: 현재 숫자 레이블에 입력될 첫 숫자이면서 .이 아닌 경우는 현재 입력값으로 숫자 레이블을 대체하고

그렇지 않다면 기존 값에 연결되어야 하기에 append 시킴

@IBAction func touchUpOperatorButton(_ sender: UIButton)

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

@IBAction func touchUpFunctionButton(_ sender: UIButton)

: AC, CE, prefix(-/+)를 구분하여 적절한 기능 수행

viewDidLoad() : 숫자 레이블과 연산자 레이블 초기화

addStack()

: 수평으로 쌓이는 스택에 연산자와 숫자를 넣고 해당 스택을 inputStackView에 추가

: 첫 스택인 경우는 operator가 없지만 이후는 있으므로 구분

: calculatorInput 에 스택에 들어간 내용 추가

: 스크롤 뷰에서 새로운 값이 제일 하단에 고정되어 위치하도록

removeStack()

: inputStack의 서브뷰를 순회하면 제거

: 초기화 진행

findNumber(of button: UIButton) throws -> String

findOperator(of button: UIButton) throws -> String

findFunction(of button: UIButton) throws

configurePrefix()

isValidNumber(input: String, currentNumber: String?) -> Bool : 0과 . 에 관하여 유효한 입력인지 확인

고민한 점

numberLabel.text 값 갱신

가독성을 위해 nubmerLabel.text를 변수에 담아서 사용하고 값을 갱신하려고 했지만 해당 값이 String이어서 의도대로 수정되지 않았습니다. 따라서, 값을 수정할 때는 원래 프로퍼티에 직접 접근하여 값을 갱신합니다.

스토리보드의 stackView 이용

이번 프로젝트에서는 동적으로 스택뷰가 스크롤뷰에 추가됩니다. 이때, 기존에 스토리보드에 있던 스택뷰를 사용하면 새로운 값이 추가되는 것이 아니라 기존 값이 변경됩니다. 따라서, 스택이 추가될 때마다 새로운 스택뷰를 만들어서 추가하는 방식으로 구현했습니다.

스크롤 뷰 제일 하단에 최신 값 오도록 구성

스크롤 뷰의 func setContentOffset(_ contentOffset: CGPoint, animated: Bool)

를 사용해서 CGPoint를 설정합니다.

https://www.objc.io/issues/3-views/scroll-view/

스크린샷 2022-03-24 오후 1 21 00

scrollView.bounds 높이가 추가되는 스택뷰의 높이인 것 같습니다. y좌표를 컨텐츠 높이에서 스택뷰의 높이를 뺀 값으로 설정해서 스크롤 뷰의 제일 하단에 위치되는 것으로 생각됩니다.🤔

NumberFormatter 이용해서 숫자 표현하기

스크린샷 2022-03-24 오후 12 04 47
스크린샷 2022-03-24 오후 12 07 19

반올림이 어떻게 되는지, 소수점이 어디까지 표현되는지를 디버깅을 통해 확인해서 원하는 결과를 얻을 수 있도록 구현했습니다.

20자리를 최대 수로 설정하기

String(format:) 을 사용해서 20자리의 숫자를 얻어내고 이후 NumberFormatter를 적용시키 원하는 형태의 숫자로 만들고 싶었지만 두 개를 동시에 적용시키는 것에 실패했습니다.😭

String(format: “%20f”, 결과) 한 값을 Formatte.string()의 인자로 전달하니 출력값이 아예 나오지를 않습니다. Double형태가 아니어서 오류나는 것 같아서 타입을 바꾸기도 했지만 의도대로 동작하지는 않았습니다.

그래서, 간단하게 20자리가 이상인 경우에서 에러처리를 하도록 구현하게 되었습니다.😢

함수 작게 나누기
기능적으로 하나의 역할을 한다고 생각되어 몇 함수의 길이가 너무 길어져서 고민입니다.🤔
개인적으로 addStack() 나 touchUpOperatorButton() 의 경우 함수를 나누기가 애매하다고 생각됩니다. 😭
