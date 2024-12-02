//: [Previous](@previous)

import Foundation

func loadInput() -> String {
    let inputPath = Bundle.main.path(forResource: "day13", ofType: nil)!
    let pathURL = URL(filePath: inputPath)
    let data = try! Data(contentsOf: pathURL)
    return String(data: data, encoding: .utf8)!
}

//--- Day 13: Distress Signal ---
//For example:
//
//[1,1,3,1,1]
//[1,1,5,1,1]
//
//[[1],[2,3,4]]
//[[1],4]
//
//[9]
//[[8,7,6]]
//
//[[4,4],4,4]
//[[4,4],4,4,4]
//
//[7,7,7,7]
//[7,7,7]
//
//[]
//[3]
//
//[[[]]]
//[[]]
//
//[1,[2,[3,[4,[5,6,7]]]],8,9]
//[1,[2,[3,[4,[5,6,0]]]],8,9]


// Then:
// If both values are integers, the lower integer should come first.
// If the left integer is lower than the right integer, the inputs are in the right order.
// If the left integer is higher than the right integer, the inputs are not in the right order.
// Otherwise, the inputs are the same integer; continue checking the next part of the input.
// If both values are lists, compare the first value of each list, then the second value, and so on. If the left list runs out of items first, the inputs are in the right order. If the right list runs out of items first, the inputs are not in the right order.
// If the lists are the same length and no comparison makes a decision about the order, continue checking the next part of the input.

// If exactly one value is an integer, convert the integer to a list which contains that integer as its only value, then retry the comparison.
// For example, if comparing [0,0,0] and 2, convert the right value to [2] (a list containing 2);
// the result is then found by instead comparing [0,0,0] and [2].
// Using these rules, you can determine which of the pairs in the example are in the right order:
//
//== Pair 1 ==
//- Compare [1,1,3,1,1] vs [1,1,5,1,1]
//  - Compare 1 vs 1
//  - Compare 1 vs 1
//  - Compare 3 vs 5
//    - Left side is smaller, so inputs are in the right order

//== Pair 2 ==
//- Compare [[1],[2,3,4]] vs [[1],4]
//  - Compare [1] vs [1]
//    - Compare 1 vs 1
//  - Compare [2,3,4] vs 4
//    - Mixed types; convert right to [4] and retry comparison
//    - Compare [2,3,4] vs [4]
//      - Compare 2 vs 4
//        - Left side is smaller, so inputs are in the right order

//== Pair 3 ==
//- Compare [9] vs [[8,7,6]]
//  - Compare 9 vs [8,7,6]
//    - Mixed types; convert left to [9] and retry comparison
//    - Compare [9] vs [8,7,6]
//      - Compare 9 vs 8
//        - Right side is smaller, so inputs are not in the right order

//== Pair 4 ==
//- Compare [[4,4],4,4] vs [[4,4],4,4,4]
//  - Compare [4,4] vs [4,4]
//    - Compare 4 vs 4
//    - Compare 4 vs 4
//  - Compare 4 vs 4
//  - Compare 4 vs 4
//  - Left side ran out of items, so inputs are in the right order
//
//== Pair 5 ==
//- Compare [7,7,7,7] vs [7,7,7]
//  - Compare 7 vs 7
//  - Compare 7 vs 7
//  - Compare 7 vs 7
//  - Right side ran out of items, so inputs are not in the right order
//
//== Pair 6 ==
//- Compare [] vs [3]
//  - Left side ran out of items, so inputs are in the right order
//
//== Pair 7 ==
//- Compare [[[]]] vs [[]]
//  - Compare [[]] vs []
//    - Right side ran out of items, so inputs are not in the right order
//
//== Pair 8 ==
//- Compare [1,[2,[3,[4,[5,6,7]]]],8,9] vs [1,[2,[3,[4,[5,6,0]]]],8,9]
//  - Compare 1 vs 1
//  - Compare [2,[3,[4,[5,6,7]]]] vs [2,[3,[4,[5,6,0]]]]
//    - Compare 2 vs 2
//    - Compare [3,[4,[5,6,7]]] vs [3,[4,[5,6,0]]]
//      - Compare 3 vs 3
//      - Compare [4,[5,6,7]] vs [4,[5,6,0]]
//        - Compare 4 vs 4
//        - Compare [5,6,7] vs [5,6,0]
//          - Compare 5 vs 5
//          - Compare 6 vs 6
//          - Compare 7 vs 0
//            - Right side is smaller, so inputs are not in the right order

//What are the indices of the pairs that are already in the right order? (The first pair has index 1, the second pair has index 2, and so on.) In the above example, the pairs in the right order are 1, 2, 4, and 6; the sum of these indices is 13.
//
//Determine which pairs of packets are already in the right order. What is the sum of the indices of those pairs?

indirect enum Content: CustomDebugStringConvertible, Equatable {
    case value(Int)
    case subobjects([Content])
    
    var debugDescription: String {
        switch self {
        case .value(let val): return "\(val)"
        case .subobjects(let c): return "\(c)"
        }
    }
    
    func niceRep() -> String {
        debugDescription.components(separatedBy: .whitespaces).joined()
    }
}

func build(characters: Array<Character>, startIdx: Int) -> (Content, Int) {
    var idx = startIdx
    var elements: [Content] = []
    var intBuffer: [Character] = []
    
    func endInt() {
        guard !intBuffer.isEmpty else { return }
        let intValue = Int(String(intBuffer))!
        elements.append(.value(intValue))
        intBuffer = []
    }
    while idx < characters.count {
        switch characters[idx] {
        case "[":
            if idx != startIdx {
                let (subRes, endIndex) = build(characters: characters, startIdx: idx)
                elements.append(subRes)
                idx = endIndex
            }
            
        case "]":
            endInt()
            return (.subobjects(elements), idx)
        case " ": ()
        case ",":
            endInt()
        case let intElement:
            intBuffer.append(intElement)
        }
        
        idx += 1
    }
    
    return (.subobjects(elements), idx)
}


var printAll = false

func coolPrint(_ str: String) {
    if printAll  { print(str) }
}

func task1(input: String) -> Int {
    let pairs = input
        .components(separatedBy: .newlines)
        .split(separator: "")
    
    func compare(lhs: Content, rhs: Content) -> Bool? {
        coolPrint("Compare \(lhs) vs \(rhs)")
        switch (lhs, rhs) {
        // If both values are integers, the lower integer should come first.
        // If the left integer is lower than the right integer, the inputs are in the right order.
        // If the left integer is higher than the right integer, the inputs are not in the right order.
        case (.value(let lhsVal), .value(let rhsVal)):
            coolPrint("Compare \(lhs) vs \(rhsVal)")
            return rhsVal >= lhsVal
            
        // If both values are lists, compare the first value of each list, then the second value, and so on.
        // If the left list runs out of items first, the inputs are in the right order.
        // If the right list runs out of items first, the inputs are not in the right order.
        case (.subobjects(let lhsArr), .subobjects(let rhsArr)):
            var lhsIdx = 0
            var rhsIdx = 0
            
            while lhsIdx < lhsArr.count, rhsIdx < rhsArr.count {
                switch (lhsArr[lhsIdx], rhsArr[rhsIdx]) {
                case (.value(let lhsVal), .value(let rhsVal)):
                    coolPrint("Comparing arrays \(lhsVal) vs \(rhsVal)")
                    
                    if rhsVal > lhsVal {
                        coolPrint("Rhs is bigger: \(lhsVal) < \(rhsVal)")
                        return true // kill it quicker
                    } else if rhsVal < lhsVal {
                        coolPrint("Lhs is bigger: \(lhsVal) < \(rhsVal)")
                        return false
                    }
                case let pair:
                    var subTreeRes = compare(lhs: pair.0, rhs: pair.1)
                    coolPrint("We dont know, need to check more")
                    if subTreeRes != nil {
                        return subTreeRes
                    }
                }
                
                // Otherwise, the inputs are the same integer; continue checking the next part of the input.
                lhsIdx += 1
                rhsIdx += 1
            }
            
            /**
             []
             */
            
            if lhsIdx < lhsArr.count, rhsIdx == rhsArr.count {
                coolPrint("Rhs was shorter: \(lhsArr) vs \(rhsArr)")
                return false
            } else if lhsIdx == lhsArr.count, rhsIdx < rhsArr.count {
                coolPrint("Lhs was shorter: \(lhsArr) vs \(rhsArr)")
                return true
            }
            
            // If the lists are the same length and no comparison makes a decision about the order, continue checking the next part of the input.
            return nil
            
        // If exactly one value is an integer, convert the integer to a list which contains that integer as its only value, then retry the comparison.
        case (.value(let lhsVal), .subobjects):
            coolPrint("Lifting lhs to array, [\(lhsVal)]")
            return compare(lhs: .subobjects([.value(lhsVal)]), rhs: rhs) // lift left to arr
            
        case (.subobjects, .value(let rhsVal)):
            coolPrint("Lifting rhs to array, [\(rhsVal)]")
            return compare(lhs: lhs, rhs: .subobjects([.value(rhsVal)])) // lift right to arr
        }
    }
    
    var sum = 0
    
    // What are the indices of the pairs that are already in the right order? (The first pair has index 1, the second pair has index 2, and so on.)
    // In the above example, the pairs in the right order are 1, 2, 4, and 6; the sum of these indices is 13.
    //
    // Determine which pairs of packets are already in the right order. What is the sum of the indices of those pairs?
    
    for (idx, pair) in pairs.enumerated() {
        let pairArray = Array(pair)
        let left = build(characters: Array(pairArray[0]), startIdx: 0).0
        let right = build(characters: Array(pairArray[1]), startIdx: 0).0
        assert(left.niceRep() == pairArray[0], "\(left.niceRep()) should be \(pairArray[0])")
        assert(right.niceRep() == pairArray[1], "\(right.niceRep()) should be \(pairArray[1])")
        let res = compare(lhs: left, rhs: right)!
        if res {
            print("-----")
            print(left.niceRep())
            print(right.niceRep())
            print("pair(\(idx + 1))", res)
            print("-----")
            sum += (idx + 1)
        }
    }
    
    return sum
}
//
//let sampleInput = """
//[1,1,3,1,1]
//[1,1,5,1,1]
//
//[[1],[2,3,4]]
//[[1],4]
//
//[9]
//[[8,7,6]]
//
//[[4,4],4,4]
//[[4,4],4,4,4]
//
//[7,7,7,7]
//[7,7,7]
//
//[]
//[3]
//
//[[[]]]
//[[]]
//
//[1,[2,[3,[4,[5,6,7]]]],8,9]
//[1,[2,[3,[4,[5,6,0]]]],8,9]
//"""
//
//task1(input: sampleInput) == 13

print(task1(input: loadInput()))

//let example1 =
//"""
//[1,1,3,1,1]
//[1,1,5,1,1]
//"""
//task1(input: example1) == 1
//
//
//let example2 =
//"""
//[[1],[2,3,4]]
//[[1],4]
//"""
//task1(input: example2) == 1
//
//let example3 =
//"""
//[9]
//[[8,7,6]]
//"""
//task1(input: example3) == 0
//
//
//let example4 =
//"""
//[[4,4],4,4]
//[[4,4],4,4,4]
//
//"""
//task1(input: example4) == 1
//
//
//let example5 =
//"""
//[7,7,7,7]
//[7,7,7]
//"""
//task1(input: example5) == 0
//
//
//
//let example6 =
//"""
//[]
//[3]
//"""
//task1(input: example6) == 1
//
//
//let example7 =
//"""
//[[[]]]
//[[]]
//"""
//task1(input: example7) == 0
//
//
//let example8 =
//"""
//[1,[2,[3,[4,[5,6,7]]]],8,9]
//[1,[2,[3,[4,[5,6,0]]]],8,9]
//"""
//
//task1(input: example8) == 0
//
//
//
//let example9 =
//"""
//[[[1,6,[1,9,0,9],6]]]
//[[],[[[5,6,3],6,[6,5,3,3]],8,3],[],[4]]
//"""
//
//task1(input: example9) == 0

//let example10 =
//"""
//[[[[3,10,1,8],[0,0]],[5,1,[10,8,6]],[5,7,7,[10,6,9]],[4,[],2,[3,6,2,6],0]]]
//[[8],[[[9,5],4,[3],[6,7]]],[]]
//"""
//task1(input: example10) == 0


//let example11 =
//"""
//[[8,[10,7],[4,2,[],8,[3,6,6]],[[2],[1,7,10,5,8],[],0],1],[],[]]
//[[[[3,6],10],[2,10,6,[10,10,5],9],[[],1,0]],[[7,[9,2,2],1,5,[]],6,[[0,4,6,2,9]],3,3],[0],[],[0,2]]
//"""
//task1(input: example11) == 0

// -----

//let realPair4 =
//"""
//[[],[[6],[9],[10,[9,9,8],[1]],5],[],[[1,[9,4]],10],[10,1,7]]
//[[5,2,[2,0,[10,5,6,1,7],[9,5],8],4,[[10,4,2,4,2]]],[[[1,5,8],[5,2,2,0],[7]],[10],[[10,3,1,10]],7,6],[[[6,7],7]],[[[9,9,2,4],8],[6,[8,0,5,0],[8],8,8],[],9,10]]
//"""
//task1(input: realPair4)

//let realPair8 =
//"""
//[[],[9],[7,3,5],[2,[[1],[10,9,10],[8,6,5],[]],8,[7,8,[5,3,6],[10],1],[0]]]
//[[10,0,8],[7,[[8,3,3,5,6],[4,1,1,3],[]],[3,0,[9,10,2,0],[0]],1]]
//"""
//task1(input: realPair8)


//let realPair9 =
//"""
//[[],[7,5,8,[9,[2,6,5],[1,0,0,9,6],[0,9,1,4]]],[[3,[4,5],[3,8,6,6,3]],[[],[2,7,5,8],[5,6,3,2,5],3,4],[],0],[0,[[8],[],[],[6,0,8,2]],5]]
//[[[0,[10]],[[0,7],10],2,[[9],0,8],7],[9,[[9,8,9],3,6],2,3,6],[6,5,[],[[],[3],[10,6,1,3,3]]]]
//"""
//task1(input: realPair9)

//-----
//[[],[7,5,8,[9,[2,6,5],[1,0,0,9,6],[0,9,1,4]]],[[3,[4,5],[3,8,6,6,3]],[[],[2,7,5,8],[5,6,3,2,5],3,4],[],0],[0,[[8],[],[],[6,0,8,2]],5]]
//[[[0,[10]],[[0,7],10],2,[[9],0,8],7],[9,[[9,8,9],3,6],2,3,6],[6,5,[],[[],[3],[10,6,1,3,3]]]]
//pair(9) true
//-----
//-----
//[[8,[[7,10,10,5],[8,4,9]],3,5],[[[3,9,4],5,[7,5,5]],[[3,2,5],[10],[5,5],0,[8]]],[4,2,[],[[7,5,6,3,0],[4,4,10,7],6,[8,10,9]]],[[4,[],4],10,1]]
//[[[[8],[3,10],[7,6,3,7,4],1,8]]]
//pair(10) true
//-----
//-----
//[[],[3],[[[9,3,7],3,[6]],2,6,[[0,2]],4]]
//[[10,7,[],9],[],[3,4],[[1,[4],8,8,2],[[1,1,7,8,5],1,7,1],[]],[]]
//pair(12) true
//-----
//-----
//[[],[],[],[[9,[0,4],10],[[1,2,2,9],5,10],[[0],0,10],[[8,2,8],[2,7,5]]],[]]
//[[[6,[9,3],8,[6]],0,2],[7,[7,[3,8,8],[6,3,6,8]],[[],[0,8,7],[],6]]]
//pair(14) true
//-----
//-----
//[[5,[3,7]],[8,[]],[1],[[[6,4,7],[]],[[2,10,9],[1,1,1,6,3],[4],1,[4,6,5,3]],5,[[10,1,10,10],[10,7]]]]
//[[8,5,[[4,6]],[8,9,10,6]],[],[[3,[3,1,5,4],[8,7,3,7,3],8],7,5,[7,10,[5,6,9,1,2],5,6]]]
//pair(15) true
//-----
//-----
//[[],[9,[2,[7],0,[]],7,2],[7,[5,5,[5,7,4,3],[7,7,10,9,8]],[4,6,[0,0,9,10],9,[9,5,9,6]],7]]
//[[[0,[],9,[],1],[4,[9,4],1,[]],[[]],[5,0,2,[3,10,2]],[[1,9,10,1],5,[4]]],[1,5,5,[2]],[5],[0,5,7]]
//pair(16) true
//-----
//-----
//[[1],[1,[[7,8],[6],[4,7,5,5],[10]],[[]],9,7],[1,[[9],[10,2],2,3],[[9,5],2,7],[10,[0],5],[[10,4],[7],6]],[5,[2],3,[8,9,[8,4,4,5,0],[],5]]]
//[[10,[3,[6,9,10,1],[0],[0,0,6],[1,3]],[1,[2,2,8,5]],[[0,10,3,10,2],[7,3,10],3,3,10],[[4,6,4],0]]]
//pair(18) true
//-----
//-----
//[[[],4,[3,[3,2,0,4,2],8]],[[0,[7,10,8,7,8],[1,4]],[[5,3,4],5,8,[7,4,3,4]],[[8,4,10],0]],[0,[[],[]]],[0,[8,9,0],[2,1,7],8,2]]
//[[[6,[7,1,7,4],9,8],[[9],[0],1],[9,0],[[],0],[[],[1,9]]],[[7,[],6,[5,5]],[[0,9,5],[6,7,5,2],[]]],[[3,0,6,5],9,0,10,[[9],10,[10,0,1,8,5],4,[]]]]
//pair(19) true
//-----
//-----
//[[],[7,1,9,[4,[1]]],[9,2]]
//[[3],[[[9,8]],[5],1,6,[4,[3,8,6,6,4]]],[[[0,1],3,[9,7],9],[],[],5],[8,[[],[2],5,[10,4,9,5,7]],[9],[[7,8,1,7],[4,2,6,4,3],6],4]]
//pair(20) true
//-----
//-----
//[[],[[]],[4,[6,10,[6,2],[3,1,10,10],3]],[[4,5,7,[3,0,5,9,1],1],[[1,10],0,[5,4,7,4]]],[3,[6,8,9,[10,10,5,5],[4,0,7,6,10]],[[0,0,1,2,8],[1,9,10,9],5,10,[4,4]]]]
//[[[[4,3],10,[3]],5,[8,9,[0,3,6,8,5],4,9],1,[[8,4,2,10,1]]],[]]
//pair(23) true
//-----
//-----
//[[0,10,[2,1,0]],[[9,10,[7]],[10],2],[[[2],1,[3,0],10]]]
//[[5,4,8,2],[[[3,2,7],8,6,[7,5,8,0,5],[2,1,0]],[[10,5,8],[]],[1,7,[]],[[]]],[[9,[6,5,5],[7,1]],[],[]]]
//pair(24) true
//-----
//-----
//[[[],10],[],[3,[2]],[[6],8,[[8,7,4,9]],[[4,3,10],[10,6,9],[4,8,10,2,5],[5,6,9,3],3]],[[[0,8],[],8,4,10],[0,1],5,[10,[0,7,7,3,3],[8,7],8]]]
//[[[],2,3,5]]
//pair(25) true
//-----
//-----
//[[],[3],[]]
//[[[7],[[0,6],[2,9],3,[4,3,7],5],[5,[4,10],[5,10],4,2],[[4],0,[],[8,7,1,5,7],2]],[[],[[8],[10,7,0,2,10],[]],[6,[10,2,7,2,8]]],[[],[4,3,[4],[3],[1,1]],0],[5,[],[1,[3,7,2,5,8],3]]]
//pair(26) true
//-----
//-----
//[[],[0,[[2],[10],[5]]],[7],[[8,[3,3],[3,5,6,2,6]]]]
//[[[4,[0,3]]],[[[8,2,1,10,0]],[],6,0,2]]
//pair(27) true
//-----
//-----
//[[[[1],9],[[],0,3,5,4],[7,10,[]],2],[[[3],9,6,1],[],[[],[8,3,7,1]],7]]
//[[[9,3,[4,2]],4,6]]
//pair(29) true
//-----
//-----
//[[],[0]]
//[[[[8,0,7,4,6],[8,7],[3,9,9],0,1],[[5,10,4],3],[6,5,[4,3,2,9]]],[[9,7,[]],[[2,6]],10,[],[5,1]],[[3,4,[]],4,5,2,[]],[10,5,2]]
//pair(33) true
//-----
//-----
//[[],[],[]]
//[[],[[8,9,3,7,[10,5,3,2,7]],[10],[5,9,1,[5,5,3,4],10]],[6]]
//pair(34) true
//-----
//-----
//[[],[[[2,10,8,8],8,9],1,8,[[2,5,8,6]]],[],[]]
//[[[5,5,[6]]],[[9,[4,7,3,0,6],5,0,8]],[[0,[10],2,5],4]]
//pair(35) true
//-----
//-----
//[[],[5,[0,[9]]],[],[[[4,9],[],[3,7,1,7],[],1],8]]
//[[[[1,8],[7,1,9],4,[],3],0,[4,2,[8,6,9]]],[[],[7,6,[1,5,0],5],[8],3,3],[],[7,[]]]
//pair(38) true
//-----
//-----
//[[[2,[1,3,6,0,5],[2,10],8],[],3],[6,6,2,[[5,5]]],[[],9],[6,[[7],2]]]
//[[9,9,[[]],4,9]]
//pair(39) true
//-----
//-----
//[[0,[],[1],8,7]]
//[[0,10,[1,[1,9],8,[]]],[[[6,3],1,1,5],10,[]]]
//pair(46) true
//-----
//-----
//[[5,[[0,9],9,[3],7,5],[10,[3],[0]],2,[[4,9,9,9],4,3,10]],[],[[[],[],0,1],[6,[8,0,5,2],3,[0,6],[5]]]]
//[[9,6],[6,3],[]]
//pair(47) true
//-----
//-----
//[[[[1,6],5,2,[3],[10,6]],9,6],[[3,0,[1],[1,2]]],[6,8,10,0]]
//[[4,[[7],0,[4,2,2,1],2],6],[8,[10],[[1,1],4,4,0]],[[[1],7,7],4,[[10,3,1,1,2],[8,9,1],9,[7,6]],4],[[2,[8,0,1,9,6],[1,0,6,6],[5,8,0]]]]
//pair(48) true
//-----
//-----
//[[[2,[1,0,8,2,5]],2,[[9,3,0,1],7,9],[8,[],[7,9,10,10],5],[4,4,[8,7]]],[1,4],[6,10,[4,[],[],6],4],[3,[7,[1],5,[9],0]]]
//[[5,1,9,8],[9,[4],1,[[7,4,5,5,6],[10,5,9,9]],[]],[9],[9,5,[8,7,[2],[8,9],9],0]]
//pair(51) true
//-----
//-----
//[[[[3,10,8,7],[9,10,3,10],8,0],[1]],[[9,8],1,[8,10,9]],[[[8,0,10],9,2],0,4],[],[[4,7,2,1,7]]]
//[[[5,[]],6],[10,[3,[8,2],3,6,[]]]]
//pair(52) true
//-----
//-----
//[[[5,[9,4,7,6],5,[8],[7,3]],[],[4],[[3,8],[8,8,9,6,9],[1,5,1]]],[[],5]]
//[[10,[8,[9,6],4,[6,0,3]]],[]]
//pair(53) true
//-----
//-----
//[[[[5,2,4],4,[0],7,[8]],[[]],[4,[3,8,5,8,6],[8,3,10,0,10],[6,9],6]],[[[7],[3,4],8],[[3,10,3],5]],[6],[[9]],[]]
//[[[6],[[],[8],5,4],[],[[8]],4],[9,[],2,5]]
//pair(55) true
//-----
//-----
//[[[8,5],6,2,[[10,1,4,2,9],[]]]]
//[[[[9,5],[9,7,7]],9,[[5,4,9,5,5],6,9],[]],[[[5,8],[],[]],5,3,[],8],[4],[],[7]]
//pair(58) true
//-----
//-----
//[[[2],10,[4],10],[]]
//[[[7],[[],[2,6,6],[],7,6],5,1],[1,1,[1,[],8,[2]]],[[[3,5,3,7,10],[3,3,8,4],[10],7],7,9,7],[10,[[8,6],[0,5,2,7],9,0,[0]],10],[2,9,2,6]]
//pair(59) true
//-----
//-----
//[[8,[],2,5],[2,[[7,0,5,6],5],[10,9,7,9],2,0],[8,7,9,10,[[6,6,9,0,7],6,[5],5,[2]]],[[2,10],9],[]]
//[[10,2,[1,4,[4,4,5,2,1],[],6]],[[10,6,7],[[0],[2,3,4,4],[7,10],[9,4]],[1],[7,5,6],[[5,3,4,5],0]],[4,[[3],[0,8,5,8],8,[],[1,7,9,9]],0,2,0],[5],[[[4,10],[1,2,10],7,[6,2]],[],[6,9,6,[6,3,3],6],9]]
//pair(61) true
//-----
//-----
//[[[[3,9],0]],[0,10,[],[]],[],[2]]
//[[10,[[5,7,4,8]],[[7,3,3,6]],[7],4],[],[[[8,6,4,0,3]],3,8,[[7,9],[1,0],4,[],[5]]],[[0,[8,9],[3,7],[]],8,4,[[4],8,[6,3],3],8],[5,9]]
//pair(62) true
//-----
//-----
//[[4,[[4,3,4,5],[3],5,6]],[0,5],[[3,10,3,4],[]],[[5,[10,8,7,3],[10,5,6,8,4],6,2],[]],[2,[[7,6,0,4,2]],3,[[6,0,1],[9,1,10],7]]]
//[[[[8,5,3],[4,2,3,6]],[8,10,[1,1,1,2,6],7]],[[0],8,2,2,[4]],[5,5,2,[3,[1,7,10,10,1],[4,3],[5,6],[4,6,10]]],[]]
//pair(63) true
//-----
//-----
//[[9],[]]
//[[10,6],[[[4],2],[9,[6,3,5],[]],[8,10,[],[0,2,1,1],[9,1,3]]],[[[6]]],[10,[[5],[],[4,8],8,0],7,[9,2,0,6,3]]]
//pair(64) true
//-----
//-----
//[[3]]
//[[9,5,2,[9,8,[10],5,[]]],[[[0]],[[6,7,7,6,10]],8,6],[[3,[10,9],2,9]]]
//pair(65) true
//-----
//-----
//[[0,[9,[],[10,9],4,[]],[[1,8,1],8,5,9],0,[[5,0,5],4]],[0,10],[10,[],[[10,4],[3],[3,0,1,6],2],[[10,0],[2]]],[[5,[],[8,0],8]],[[9,[9,6],[]],6,[[6,9,9,8],[1,4]]]]
//[[10,[5,[0],8,[10,8]],4,[[]],7],[9,7,[],10],[[[9],5,6],3],[1,0,[7,0,3],2,[[7,2,7],0,[3,2,7,3],0]],[[[2,2],10],[],4]]
//pair(66) true
//-----
//-----
//[[1],[[]]]
//[[6,[6,[6,2,3,6],2],4]]
//pair(67) true
//-----
//-----
//[[4],[2,10,[],4]]
//[[9]]
//pair(68) true
//-----
//-----
//[[[8,4,[0,5,6,10,1],[9]],3,0],[[1,[],5,[3,0,1,10],3],10,3],[4,6,[[1,2,0,3,0],[10,9,6],0,[1,0,10,7]],[],[3]]]
//[[[[9,7],3,[9,1,10]],4,[9,[1,9,10,7],[1,2,8,0],7],7]]
//pair(70) true
//-----
//-----
//[[],[[4,8,[0,8,6,0,1],[1,3,10,10,3],[1,0]],[7,0,[4,8,0,3],3]],[],[5,7]]
//[[4,3],[[0,[3],[],2],[]],[7,5,1]]
//pair(74) true
//-----
//-----
//[[[[],9,[0,5,3],10,[5,2,8,3,2]],[],9,7,9],[8,5,[10,[2,10,1],[2,3],[3,0,2,6,0],[10,1]],[],[[0],[3]]]]
//[[9,[4,2],[]],[],[[1,3,8],[[5,7,8,7],7],7,[[3],[5],2,6],[[0,5],4]],[10],[6,[],[5,8,8],8,[9,[1,2],[3],[],[7,3,0,0]]]]
//pair(76) true
//-----
//-----
//[[1,[],[[9,10,7,8],6,4,3],[[5,1,5],[0,8,5],0]],[8],[[2,[7,2,8,0],5],[[3,4,9,10],0,0,[],[9,7,3,9,0]],7,6],[5,3,[]]]
//[[3],[[7,6],[7,0],[2,[2,8,5],2],9]]
//pair(77) true
//-----
//-----
//[[[0,[9,3,5],[10],2],6,[[],5,[5,6,10]],[5,8]],[],[7,[[3],[1],2,1,[5,5]],2,6,[1,3,[5,7,1]]]]
//[[[[7],[10],7,6,[9,10,3,0,1]],4,1,4,6],[5,[[]]],[],[5,[1],[[1,0,2,6,4]],[[6,0,7,10,10],0],2],[]]
//pair(79) true
//-----
//-----
//[[],[[1,3],4,[5,2,7,[9,7,2]],10],[3,[8],6,[6]]]
//[[3,[]],[2,9,[5]],[[],9]]
//pair(80) true
//-----
//-----
//[[[2],8,[]],[0,[10],10],[9],[[5,[9,2],[0,1,1,4],2,[1]],[],[[8,8],[4,6,7],2,[7,4,3]],4,4],[[[8],[9],1]]]
//[[2,[[3,6],9,7,0,[8]]]]
//pair(82) true
//-----
//-----
//[4,0,6,0]
//[4,0,6,0,7]
//pair(84) true
//-----
//-----
//[[[0,[8,1,6,10],10,[2,9]],10],[6,[1],10],[5,5,7],[0]]
//[[1,7,[5,1]]]
//pair(86) true
//-----
//-----
//[[[[5,9,6],[1,1,6,5],[10,10]],[[5],[],[6,9,4,5,7],3],6,[],[]],[8,[[10,9,4],[6,3]]]]
//[[8,[6,[9,8,9,4,1],[0,3,8,1,0],9,4],6,[7,1,[],[0,9,7,7],9]],[10,[[0,7],9,2,5,[1,10,2,5,10]]]]
//pair(88) true
//-----
//-----
//[[3,[],[[7,2],5,3]],[3,5,0,[[8,9,3,1]],0],[[[10,10,6,7,10]],3,5],[[1,[],[],9],10,[4,[9,1],0,4],9]]
//[[7,1],[8,[9],8]]
//pair(89) true
//-----
//-----
//[[],[]]
//[[[9,[0,8,8,7,3]],8,6,[[],[4,4,2],[9,9,3,5,1],9,[0,10,7,8,5]],[[10,1,8,0,6],10]],[5]]
//pair(92) true
//-----
//-----
//[[],[1,[7,9,[6,3,9],[9,4]],4]]
//[[[],9],[5],[]]
//pair(95) true
//-----
//-----
//[[[2,10,[],6],6]]
//[[8,[8,10,[2],3],[[3,10,8,0],0,3,[8,2,1],[1,5,0,0,8]],[2,[3],3],[[1,9,8,4],[1,5,8]]],[[[10,4,6,4],[5,2,4],10,0],[],3],[4,[0,10,4],7]]
//pair(98) true
//-----
//-----
//[[7]]
//[[10,4],[10,3,4,[7,[5,3]]],[[[6],2,6]],[[2,[4,10],[2],4],8,[0,[2,10,4],4,9,3]],[8,10]]
//pair(101) true
//-----
//-----
//[[],[],[[[8,6,8],10,[3,6]]]]
//[[[4,[8,9],[8,5,10],[]],8,2,7,6]]
//pair(102) true
//-----
//-----
//[[[],7,6,[[2,6],9,[0,4,1,1],[1,1,4,2,5],[5,5,6,6]],[1,[6,9,0,6],[5,3]]],[6,[[7,8],5,[8],[8],[8,0,5,10,0]],8,[]],[10,[7,[0,7,8,5],2],[[10],[3],6,[8,7,9]],0,[[],[3,1],[0,2,8,2,1],[6,8]]],[],[[7,[2],[9],0],7]]
//[[4,[]],[[[],[5,3,0],[0,5,5,7],9],4,[10,3],[0,0,7],[7,[10],1,0]],[[[],1,[3,4,9,8]]]]
//pair(104) true
//-----
//-----
//[[],[8,[[8,2,1],4],1],[7,10,[10,10,[8,6],[10,3],[7]],[[4,2,8],8,[3,2,6,9,1],1,[0,0,4,3]],0],[6,9,7,9,6],[[[6,6,9,9],9],1,1]]
//[[],[[0],[5,0,5,6,[7,4,9]],[[7,2],[5,7,3],[],[1,9],[6,5,3]],10,[5,[0,6,9],[9,5,4,0],7,[1,2,7,10]]],[1,[[2,0,10]],[1],[8,[],[5,10,0,6],[1,2,2,9]],[1,[],[3,10,7],0,1]],[]]
//pair(106) true
//-----
//-----
//[[[0,1,[0,0],10,6],[0,[6,2,6]],[6,7,[3],8,5]]]
//[[7],[5,[1],1,8,2],[[3,[7,8,4]],9,7,0],[5,7,[2,10],[[],4],[1,8,9]],[[]]]
//pair(110) true
//-----
//-----
//[[3,[0],[0,[10],[6,8,2]],4,[1]],[6,[],[[8],[8]],[[7,6,0,3,5],[],5,[0,7,0,1]],[8]],[[7,10],9,[],8],[2,9,[9,[3,5],2,6,[9,6,5,6,8]],2]]
//[[9,[5,[2,5,1,0,5],4,5,0],8,0,0],[[[1,1,2,2,7],5,5],[0,[]],9,[[1,1],6,2,0],6]]
//pair(111) true
//-----
//-----
//[[[[3,10,1,8],[0,0]],[5,1,[10,8,6]],[5,7,7,[10,6,9]],[4,[],2,[3,6,2,6],0]]]
//[[8],[[[9,5],4,[3],[6,7]]],[]]
//pair(112) true
//-----
//-----
//[[0,[[8,0,3,3,9],0,10],6,[[9],6]],[[2,[],6],[4,[],[2,6,6],10,[2,1,2,4]]]]
//[[5,5],[7]]
//pair(114) true
//-----
//-----
//[[],[4,[4,[]]]]
//[[7,[],8,5],[4,[[3,1,1],4,6,[],[9,4,2,2]],0,6,[[6,3,7,6,6],6,4,[3,5,9,3]]],[[3,7,[0,5,6],[5,2,1,4,4]],7],[[3,[8,0],6],[[],5],[[5,10],4,[9],2,8]],[[[10,6,2]],8,[[],5]]]
//pair(115) true
//-----
//-----
//[[[],10,[1,4,5,[7,9]],[[8],7,[1,3,8],1,9]],[[[9,9,7,6],0,10,1,[2,9,3,6]],[3,[2,8,5,4,6],[8,10,1],[1,4]]],[4,10],[[4],6]]
//[[10,[9]],[[[],8,6,4],[[7,5,4,5],5,5,[9,1,1],[0,3,2,4,2]],1,4],[]]
//pair(117) true
//-----
//-----
//[[],[2,2,2,[],3]]
//[[2,10,[]],[3,0,[[8,0],1,4,[10,5,1,9,6]],6],[1,10,[6],4],[6],[[[7,7],4,10,[6,4],4],5,1]]
//pair(122) true
//-----
//-----
//[[],[9],[]]
//[[9,[],0,[[4],1,[6,7],8,[]],7],[],[8,10,[[5],[2,6,0,7,5],8,[5,9]],[3,[]],[]]]
//pair(124) true
//-----
//-----
//[[[[]],[8,8,10,[],[3,5,8]],[3],[[3,3]]],[]]
//[[[9,8,3,[9,9,3,10],[7,8]],7],[4,[[8,4,1,2],[1],3,1],[[6,0],4,[2,0],[0,0,5],[10]]],[[[6,2,4,0,1],9,4],[4,[3],3,[],[3,0,2,8]],[[9,0,1]],[]],[[[7,3],6,6,3,0]]]
//pair(127) true
//-----
//-----
//[[3,5,[[10,3],6]],[],[6,[6,2,1],[1,[7,2,6,4]],[8,[]],[4,1]],[],[[5,[2,8,7,1],8],5]]
//[[5,0,[[],9,[],3]]]
//pair(128) true
//-----
//-----
//[[[],[2],[7,[0,10,4]],[2,[],2,[],5]]]
//[[6,1,8,[]],[[9,[8],[9,6,9,7],4],5,[[],[0],[10,6]],[9,[],[],9]],[],[[],6]]
//pair(134) true
//-----
//-----
//[[[1,2,[9]],[[0,7,6],5,[]],[10,[6],5,[],10]],[[6,9],6,5],[[3,[],7,5],1,10,[5,2,5],[]],[[[4,5]]],[[5,[4]]]]
//[[8,[[5,0,4,2,1]],[3,[1,8,7,10],1,1],[],[[8,7],4,5,[2,10,10,7],0]],[]]
//pair(138) true
//-----
//-----
//[[[[],[10,0,1],4]],[[0],7],[0,[],[]],[],[]]
//[[7,[[],[1],[5,5,6],[10,3],5],10,10],[[]],[5,[2,2],1,4]]
//pair(139) true
//-----
//-----
//[[1,[[8,7,1,8]],[]],[10,6],[[]]]
//[[[[1,9],8,6,0],5,[[0,1,10]],7],[[[9,4,5]],[4,8,[3,7,5],[1,0,2,4,9],0]],[[1,4],[[2,5,10,8],9],4,5],[[4,[1,8,6],2,10,[6,0,4,0,9]],[[2,2],0,[0],4],5,[[9],5,6,0,[7,2,9,0]],3]]
//pair(140) true
//-----
//-----
//[[[[],4,5,[0,5,5,6,2]],10,8],[10,[],[4,9,2]],[[5,6,0,8,[7,0,1]],6],[[3,[9]]],[4,[]]]
//[[[10,[8]]]]
//pair(142) true
//-----
//-----
//[[[[1]],9,10,1],[3,0]]
//[[[[4,9,8]],[[],[6,4,2,10,1],0],[9,[2,6,2,0]]]]
//pair(143) true
//-----
//-----
//[[[3,[5],7,[2,10,0,0]],[[3,10,3,6],10,9,5],7,[],[[8],[4,3,9,0,1],5,1]],[[[0,7,2,3,9],[8,10,9],10,6,[0,8,7]]],[5,10,[],9,10]]
//[[5,[10,[6,9,0,3],[9,10,10,10],[2,9,1]],3,5],[[[3,3,1,5,0],[2,5,7,2,9],[2,4,4]],0,10]]
//pair(146) true
//-----
//-----
//[[[[],9,[2,3]]]]
//[[7],[[]],[8,[[7,8,0,0]],[7,[2],6,10,[0,0,2,6]],10,2]]
//pair(147) true
//-----
//-----


//let realPair150 =
//"""
//[[[]],[[3,9],[[],[10,8,3],10,[4,5,3]],[8],[[2],2],0],[3,1,[2],3,[4]]]
//[[[],[[6,3,4,1]],3],[5,4,8,[6,[7,1,8],[]],[[],3,0]],[[5]],[[[8,3],[9,1,8,5,3],[6],[]]],[]]
//"""
//task1(input: realPair150)



//--- Part Two ---
//
//Now, you just need to put all of the packets in the right order. Disregard the blank lines in your list of received packets.
//
//The distress signal protocol also requires that you include two additional divider packets:
//
//[[2]]
//[[6]]
//Using the same rules as before, organize all packets - the ones in your list of received packets as well as the two divider packets - into the correct order.
//
//For the example above, the result of putting the packets in the correct order is:
//
//[]
//[[]]
//[[[]]]
//[1,1,3,1,1]
//[1,1,5,1,1]
//[[1],[2,3,4]]
//[1,[2,[3,[4,[5,6,0]]]],8,9]
//[1,[2,[3,[4,[5,6,7]]]],8,9]
//[[1],4]
//[[2]]
//[3]
//[[4,4],4,4]
//[[4,4],4,4,4]
//[[6]]
//[7,7,7]
//[7,7,7,7]
//[[8,7,6]]
//[9]

//Afterward, locate the divider packets. To find the decoder key for this distress signal, you need to determine the indices of the two divider packets and multiply them together. (The first packet is at index 1, the second packet is at index 2, and so on.)
// In this example, the divider packets are 10th and 14th, and so the decoder key is 140.
//
//Organize all of the packets into the correct order. What is the decoder key for the distress signal?


func bubbleSort<T: Comparable> (array: [T]) -> [T] {
    var swapped = false
    var sortedArray = array
    
    repeat {
        swapped = false
        for i in 0...array.count - 2 {
            if sortedArray[i] > sortedArray[i + 1] {
                sortedArray.swapAt(i, i + 1)
                swapped = true
            }
        }
    } while swapped
                
    return sortedArray
}

func task2(input: String) -> Int {
    var allRows = input
        .components(separatedBy: .newlines)
        .filter { !$0.isEmpty }
        .map { build(characters: Array($0), startIdx: 0).0 }
        +
    [
        .subobjects([.subobjects([.value(2)])]),
        .subobjects([.subobjects([.value(6)])])
    ]
    
    
    func compare(lhs: Content, rhs: Content) -> Bool? {
        coolPrint("Compare \(lhs) vs \(rhs)")
        switch (lhs, rhs) {
        // If both values are integers, the lower integer should come first.
        // If the left integer is lower than the right integer, the inputs are in the right order.
        // If the left integer is higher than the right integer, the inputs are not in the right order.
        case (.value(let lhsVal), .value(let rhsVal)):
            coolPrint("Compare \(lhs) vs \(rhsVal)")
            return rhsVal >= lhsVal
            
        // If both values are lists, compare the first value of each list, then the second value, and so on.
        // If the left list runs out of items first, the inputs are in the right order.
        // If the right list runs out of items first, the inputs are not in the right order.
        case (.subobjects(let lhsArr), .subobjects(let rhsArr)):
            var lhsIdx = 0
            var rhsIdx = 0
            
            while lhsIdx < lhsArr.count, rhsIdx < rhsArr.count {
                switch (lhsArr[lhsIdx], rhsArr[rhsIdx]) {
                case (.value(let lhsVal), .value(let rhsVal)):
                    coolPrint("Comparing arrays \(lhsVal) vs \(rhsVal)")
                    
                    if rhsVal > lhsVal {
                        coolPrint("Rhs is bigger: \(lhsVal) < \(rhsVal)")
                        return true // kill it quicker
                    } else if rhsVal < lhsVal {
                        coolPrint("Lhs is bigger: \(lhsVal) < \(rhsVal)")
                        return false
                    }
                case let pair:
                    var subTreeRes = compare(lhs: pair.0, rhs: pair.1)
                    coolPrint("We dont know, need to check more")
                    if subTreeRes != nil {
                        return subTreeRes
                    }
                }
                
                // Otherwise, the inputs are the same integer; continue checking the next part of the input.
                lhsIdx += 1
                rhsIdx += 1
            }
            
            /**
             []
             */
            
            if lhsIdx < lhsArr.count, rhsIdx == rhsArr.count {
                coolPrint("Rhs was shorter: \(lhsArr) vs \(rhsArr)")
                return false
            } else if lhsIdx == lhsArr.count, rhsIdx < rhsArr.count {
                coolPrint("Lhs was shorter: \(lhsArr) vs \(rhsArr)")
                return true
            }
            
            // If the lists are the same length and no comparison makes a decision about the order, continue checking the next part of the input.
            return nil
            
        // If exactly one value is an integer, convert the integer to a list which contains that integer as its only value, then retry the comparison.
        case (.value(let lhsVal), .subobjects):
            coolPrint("Lifting lhs to array, [\(lhsVal)]")
            return compare(lhs: .subobjects([.value(lhsVal)]), rhs: rhs) // lift left to arr
            
        case (.subobjects, .value(let rhsVal)):
            coolPrint("Lifting rhs to array, [\(rhsVal)]")
            return compare(lhs: lhs, rhs: .subobjects([.value(rhsVal)])) // lift right to arr
        }
    }
    
    // What are the indices of the pairs that are already in the right order? (The first pair has index 1, the second pair has index 2, and so on.)
    // In the above example, the pairs in the right order are 1, 2, 4, and 6; the sum of these indices is 13.
    //
    // Determine which pairs of packets are already in the right order. What is the sum of the indices of those pairs?
    
    
    var swapped = false
    repeat {
        swapped = false
        for i in 0...allRows.count - 2 {
            if !compare(lhs: allRows[i], rhs: allRows[i + 1])! {
                allRows.swapAt(i, i + 1)
                swapped = true
            }
        }
    } while swapped
    
    print("sorted ++++++")
    var prod = 1
    for (idx, row) in allRows.enumerated() {
        if row == .subobjects([.subobjects([.value(2)])]) {
            prod *= (idx + 1)
        } else if row == .subobjects([.subobjects([.value(6)])]) {
            prod *= (idx + 1)
        }
        print(row)
    }
    print("sorted ++++++")
    return prod
}

let sampleInput = """
[1,1,3,1,1]
[1,1,5,1,1]

[[1],[2,3,4]]
[[1],4]

[9]
[[8,7,6]]

[[4,4],4,4]
[[4,4],4,4,4]

[7,7,7,7]
[7,7,7]

[]
[3]

[[[]]]
[[]]

[1,[2,[3,[4,[5,6,7]]]],8,9]
[1,[2,[3,[4,[5,6,0]]]],8,9]
"""

//task2(input: sampleInput)
//task2(input: loadInput())

