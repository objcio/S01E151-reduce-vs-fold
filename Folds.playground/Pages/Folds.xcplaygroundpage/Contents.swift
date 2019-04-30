indirect enum Tree<Element> {
    case leaf(Element)
    case node(Tree<Element>, Tree<Element>)
}

extension Tree {
    func fold<Result>(_ leafCase: (Element) -> Result, _ nodeCase: (Result, Result) -> Result) -> Result {
        switch self {
        case let .leaf(value):
            return leafCase(value)
        case let .node(l, r):
            return nodeCase(l.fold(leafCase, nodeCase), r.fold(leafCase, nodeCase))
        }
    }
}

extension Tree where Element == Int {
    func sum() -> Int {
        return fold({ $0 }, +)
    }
}

extension Tree {
    func height() -> Int {
        return fold({ _ in 0 }, { 1 + Swift.max($0, $1)})
    }
    
    func map<B>(_ transform: (Element) -> B) -> Tree<B> {
        return fold({ Tree<B>.leaf(transform($0)) }, { Tree<B>.node($0, $1)})
    }
}

let sample = Tree<Int>.node(.node(.leaf(1), .leaf(2)), .leaf(3))
sample.sum()
sample.height()
dump(sample.map { "\($0 * 2)" })

extension Tree: Sequence {
    public func makeIterator() -> AnyIterator<Element> {
        var stack: [Tree<Element>] = [self]
        return AnyIterator {
            while let next = stack.popLast() {
                switch next {
                case let .leaf(el): return el
                case let .node(l, r):
                    stack.append(r)
                    stack.append(l)
                }
            }
            return nil
        }
    }
}

Array(sample)
sample.reduce(0, +)


extension Result {
    func fold<R>(_ successCase: (Success) -> R, _ failureCase: (Failure) -> R) -> R {
        switch self {
        case .success(let x): return successCase(x)
        case .failure(let x): return failureCase(x)
        }
    }
}

extension Optional {
    func fold<R>(_ nilCase: R, _ someCase: (Wrapped) -> R) -> R {
        return map(someCase) ?? nilCase
    }
}
