//: [Previous](@previous)

import Foundation

func loadInput() -> String {
    let inputPath = Bundle.main.path(forResource: "day5", ofType: nil)!
    let pathURL = URL(filePath: inputPath)
    let data = try! Data(contentsOf: pathURL)
    return String(data: data, encoding: .utf8)!
}



let stacksHeader =
"""
    [V] [G]             [H]
[Z] [H] [Z]         [T] [S]
[P] [D] [F]         [B] [V] [Q]
[B] [M] [V] [N]     [F] [D] [N]
[Q] [Q] [D] [F]     [Z] [Z] [P] [M]
[M] [Z] [R] [D] [Q] [V] [T] [F] [R]
[D] [L] [H] [G] [F] [Q] [M] [G] [W]
[N] [C] [Q] [H] [N] [D] [Q] [M] [B]
 1   2   3   4   5   6   7   8   9
"""

func parse(header: String) -> [[String]] {
    var res: [Int: [String]] = [:]
    for headerRow in stacksHeader.components(separatedBy: .newlines) {
        var headerElements = Array(headerRow)
        
        if !headerElements.contains(where: { ["[", "]"].contains($0) }) {
            continue
        }
        
        let pairs = headerElements.enumerated().filter { !["[", " ", "]"].contains($0.element) }.map { ($0.element, $0.offset / 4) }
        
        for pair in pairs {
            var row = res[pair.1, default: []]
            row.append(String(pair.0))
            res[pair.1] = row
        }
    }

    let parsedHeader = res.reduce(into: Array<[String]>(repeating: [], count: res.count)) { partialResult, pair in
        partialResult[pair.key] = pair.value
    }
    return parsedHeader
}

var stacks = parse(header: stacksHeader)


//var stacks: [[String]] = [
//    [
//        "V",
//        "Z",
//        "P",
//        "B",
//        "Q",
//        "M",
//        "D",
//        "N"
//    ],
//    [
//        "G",
//        "H",
//        "D",
//        "M",
//        "Q",
//        "Z",
//        "L",
//        "C"
//    ],
//    [
//        "Z",
//        "F",
//        "V",
//        "D",
//        "R",
//        "H",
//        "Q"
//    ],
//    [
//        "N",
//        "F",
//        "D",
//        "G",
//        "H"
//    ],
//    [
//        "Q",
//        "F",
//        "N"
//    ],
//    [
//        "H",
//        "T",
//        "B",
//        "F",
//        "Z",
//        "V",
//        "Q",
//        "D"
//    ],
//    [
//        "S",
//        "V",
//        "D",
//        "Z",
//        "T",
//        "M",
//        "Q"
//    ],
//    [
//        "Q",
//        "N",
//        "P",
//        "F",
//        "G",
//        "M"
//    ],
//    [
//        "M",
//        "R",
//        "W",
//        "B"
//    ]
//]

let input = loadInput()

func task1(rows: [String], stacks: inout [[String]]) {
    for row in rows {
        let components = row.components(separatedBy: .whitespaces).compactMap { Int($0) }
        let numberOfCratesToMove = components[0]
        let from = components[1] - 1
        let to = components[2] - 1
        
        print("--=---------")
        print((row, numberOfCratesToMove, from, to))
        
        var sourceStack = stacks[from]
        var targetStack = stacks[to]
        
        
        
        assert((0..<numberOfCratesToMove).count == numberOfCratesToMove, "Not okay")
        for _ in (0..<numberOfCratesToMove) {
            
            targetStack = [sourceStack.removeFirst()] + targetStack
        }
        
        stacks[to] = targetStack
        stacks[from] = sourceStack
        
        print("Target stack \(to) \(stacks[to])")
        print("Source stack \(from) \(stacks[from])")
    }
}

//let rows = input.components(separatedBy: CharacterSet.newlines).filter { !$0.isEmpty }
//task1(rows: rows, stacks: &stacks)
//
//print(stacks.map { $0[0] }.joined())
//print(stacks)
//
//do {
//    var refStacks: [[String]] = [
//        ["N", "Z"],
//        ["D", "C", "M"],
//        ["P"]
//    ]
//
//    task1(
//        rows: ["move 1 from 2 to 1",
//               "move 3 from 1 to 3",
//               "move 2 from 2 to 1",
//               "move 1 from 1 to 2"],
//        stacks: &refStacks
//    )
//
//    assert("CMZ" == refStacks.map { $0[0] }.joined())
//    print(refStacks)
//
//}


//--- Part Two ---
//Again considering the example above, the crates begin in the same configuration:
//
//    [D]
//[N] [C]
//[Z] [M] [P]
// 1   2   3
//Moving a single crate from stack 2 to stack 1 behaves the same as before:
//
//[D]
//[N] [C]
//[Z] [M] [P]
// 1   2   3
//However, the action of moving three crates from stack 1 to stack 3 means that those three moved crates stay in the same order, resulting in this new configuration:
//
//        [D]
//        [N]
//    [C] [Z]
//    [M] [P]
// 1   2   3
//Next, as both crates are moved from stack 2 to stack 1, they retain their order as well:
//
//        [D]
//        [N]
//[C]     [Z]
//[M]     [P]
// 1   2   3
//Finally, a single crate is still moved from stack 1 to stack 2, but now it's crate C that gets moved:
//
//        [D]
//        [N]
//        [Z]
//[M] [C] [P]
// 1   2   3
//In this example, the CrateMover 9001 has put the crates in a totally different order: MCD.
//
//Before the rearrangement process finishes, update your simulation so that the Elves know where they should stand to be ready to unload the final supplies. After the rearrangement procedure completes, what crate ends up on top of each stack?

func task2(rows: [String], stacks: inout [[String]]) {
    for row in rows {
        let components = row.components(separatedBy: .whitespaces).compactMap { Int($0) }
        let numberOfCratesToMove = components[0]
        let from = components[1] - 1
        let to = components[2] - 1
        
        print("--=---------")
        print((row, numberOfCratesToMove, from, to))
        
        var sourceStack = stacks[from]
        var targetStack = stacks[to]
        
        
        
        assert((0..<numberOfCratesToMove).count == numberOfCratesToMove, "Not okay")
        var tmp = [String]()
        for _ in (0..<numberOfCratesToMove) {
            tmp += [sourceStack.removeFirst()]
        }
        
        stacks[to] = tmp + targetStack
        stacks[from] = sourceStack
        
        print("Target stack \(to) \(stacks[to])")
        print("Source stack \(from) \(stacks[from])")
    }
}

//do {
//    var refStacks: [[String]] = [
//        ["N", "Z"],
//        ["D", "C", "M"],
//        ["P"]
//    ]
//
//    task2(
//        rows: ["move 1 from 2 to 1",
//               "move 3 from 1 to 3",
//               "move 2 from 2 to 1",
//               "move 1 from 1 to 2"],
//        stacks: &refStacks
//    )
//
//    assert("MCD" == refStacks.map { $0[0] }.joined())
//    print(refStacks)
//
//}

var stacks2 = parse(header: stacksHeader)

let rows = input.components(separatedBy: CharacterSet.newlines).filter { !$0.isEmpty }
task2(rows: rows, stacks: &stacks2)
//
print(stacks2.map { $0[0] }.joined())
print(stacks2)
