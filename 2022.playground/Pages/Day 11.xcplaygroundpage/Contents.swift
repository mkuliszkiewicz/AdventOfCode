//: [Previous](@previous)

import Foundation

func loadInput() -> String {
    let inputPath = Bundle.main.path(forResource: "day11", ofType: nil)!
    let pathURL = URL(filePath: inputPath)
    let data = try! Data(contentsOf: pathURL)
    return String(data: data, encoding: .utf8)!
}

//--- Day 11: Monkey in the Middle ---
//The monkeys take turns inspecting and throwing items. On a single monkey's turn, it inspects and throws all of the items it is holding one at a time and in the order listed. Monkey 0 goes first, then monkey 1, and so on until each monkey has had one turn. The process of each monkey taking a single turn is called a round.
//
//When a monkey throws an item to another monkey, the item goes on the end of the recipient monkey's list. A monkey that starts a round with no items could end up inspecting and throwing many items by the time its turn comes around. If a monkey is holding no items at the start of its turn, its turn ends.
//
//In the above example, the first round proceeds as follows:
//
//Monkey 0:
//  Monkey inspects an item with a worry level of 79.
//    Worry level is multiplied by 19 to 1501.
//    Monkey gets bored with item. Worry level is divided by 3 to 500.
//    Current worry level is not divisible by 23.
//    Item with worry level 500 is thrown to monkey 3.
//  Monkey inspects an item with a worry level of 98.
//    Worry level is multiplied by 19 to 1862.
//    Monkey gets bored with item. Worry level is divided by 3 to 620.
//    Current worry level is not divisible by 23.
//    Item with worry level 620 is thrown to monkey 3.
//Monkey 1:
//  Monkey inspects an item with a worry level of 54.
//    Worry level increases by 6 to 60.
//    Monkey gets bored with item. Worry level is divided by 3 to 20.
//    Current worry level is not divisible by 19.
//    Item with worry level 20 is thrown to monkey 0.
//  Monkey inspects an item with a worry level of 65.
//    Worry level increases by 6 to 71.
//    Monkey gets bored with item. Worry level is divided by 3 to 23.
//    Current worry level is not divisible by 19.
//    Item with worry level 23 is thrown to monkey 0.
//  Monkey inspects an item with a worry level of 75.
//    Worry level increases by 6 to 81.
//    Monkey gets bored with item. Worry level is divided by 3 to 27.
//    Current worry level is not divisible by 19.
//    Item with worry level 27 is thrown to monkey 0.
//  Monkey inspects an item with a worry level of 74.
//    Worry level increases by 6 to 80.
//    Monkey gets bored with item. Worry level is divided by 3 to 26.
//    Current worry level is not divisible by 19.
//    Item with worry level 26 is thrown to monkey 0.
//Monkey 2:
//  Monkey inspects an item with a worry level of 79.
//    Worry level is multiplied by itself to 6241.
//    Monkey gets bored with item. Worry level is divided by 3 to 2080.
//    Current worry level is divisible by 13.
//    Item with worry level 2080 is thrown to monkey 1.
//  Monkey inspects an item with a worry level of 60.
//    Worry level is multiplied by itself to 3600.
//    Monkey gets bored with item. Worry level is divided by 3 to 1200.
//    Current worry level is not divisible by 13.
//    Item with worry level 1200 is thrown to monkey 3.
//  Monkey inspects an item with a worry level of 97.
//    Worry level is multiplied by itself to 9409.
//    Monkey gets bored with item. Worry level is divided by 3 to 3136.
//    Current worry level is not divisible by 13.
//    Item with worry level 3136 is thrown to monkey 3.
//Monkey 3:
//  Monkey inspects an item with a worry level of 74.
//    Worry level increases by 3 to 77.
//    Monkey gets bored with item. Worry level is divided by 3 to 25.
//    Current worry level is not divisible by 17.
//    Item with worry level 25 is thrown to monkey 1.
//  Monkey inspects an item with a worry level of 500.
//    Worry level increases by 3 to 503.
//    Monkey gets bored with item. Worry level is divided by 3 to 167.
//    Current worry level is not divisible by 17.
//    Item with worry level 167 is thrown to monkey 1.
//  Monkey inspects an item with a worry level of 620.
//    Worry level increases by 3 to 623.
//    Monkey gets bored with item. Worry level is divided by 3 to 207.
//    Current worry level is not divisible by 17.
//    Item with worry level 207 is thrown to monkey 1.
//  Monkey inspects an item with a worry level of 1200.
//    Worry level increases by 3 to 1203.
//    Monkey gets bored with item. Worry level is divided by 3 to 401.
//    Current worry level is not divisible by 17.
//    Item with worry level 401 is thrown to monkey 1.
//  Monkey inspects an item with a worry level of 3136.
//    Worry level increases by 3 to 3139.
//    Monkey gets bored with item. Worry level is divided by 3 to 1046.
//    Current worry level is not divisible by 17.
//    Item with worry level 1046 is thrown to monkey 1.

//After round 1, the monkeys are holding items with these worry levels:
//
//Monkey 0: 20, 23, 27, 26
//Monkey 1: 2080, 25, 167, 207, 401, 1046
//Monkey 2:
//Monkey 3:
//Monkeys 2 and 3 aren't holding any items at the end of the round; they both inspected items during the round and threw them all before the round ended.
//
//This process continues for a few more rounds:
//
//After round 2, the monkeys are holding items with these worry levels:
//Monkey 0: 695, 10, 71, 135, 350
//Monkey 1: 43, 49, 58, 55, 362
//Monkey 2:
//Monkey 3:
//
//After round 3, the monkeys are holding items with these worry levels:
//Monkey 0: 16, 18, 21, 20, 122
//Monkey 1: 1468, 22, 150, 286, 739
//Monkey 2:
//Monkey 3:
//
//After round 4, the monkeys are holding items with these worry levels:
//Monkey 0: 491, 9, 52, 97, 248, 34
//Monkey 1: 39, 45, 43, 258
//Monkey 2:
//Monkey 3:
//
//After round 5, the monkeys are holding items with these worry levels:
//Monkey 0: 15, 17, 16, 88, 1037
//Monkey 1: 20, 110, 205, 524, 72
//Monkey 2:
//Monkey 3:
//
//After round 6, the monkeys are holding items with these worry levels:
//Monkey 0: 8, 70, 176, 26, 34
//Monkey 1: 481, 32, 36, 186, 2190
//Monkey 2:
//Monkey 3:
//
//After round 7, the monkeys are holding items with these worry levels:
//Monkey 0: 162, 12, 14, 64, 732, 17
//Monkey 1: 148, 372, 55, 72
//Monkey 2:
//Monkey 3:
//
//After round 8, the monkeys are holding items with these worry levels:
//Monkey 0: 51, 126, 20, 26, 136
//Monkey 1: 343, 26, 30, 1546, 36
//Monkey 2:
//Monkey 3:
//
//After round 9, the monkeys are holding items with these worry levels:
//Monkey 0: 116, 10, 12, 517, 14
//Monkey 1: 108, 267, 43, 55, 288
//Monkey 2:
//Monkey 3:
//
//After round 10, the monkeys are holding items with these worry levels:
//Monkey 0: 91, 16, 20, 98
//Monkey 1: 481, 245, 22, 26, 1092, 30
//Monkey 2:
//Monkey 3:
//
//...
//
//After round 15, the monkeys are holding items with these worry levels:
//Monkey 0: 83, 44, 8, 184, 9, 20, 26, 102
//Monkey 1: 110, 36
//Monkey 2:
//Monkey 3:
//
//...
//
//After round 20, the monkeys are holding items with these worry levels:
//Monkey 0: 10, 12, 14, 26, 34
//Monkey 1: 245, 93, 53, 199, 115
//Monkey 2:
//Monkey 3:
//Chasing all of the monkeys at once is impossible; you're going to have to focus on the two most active monkeys if you want any hope of getting your stuff back.
// Count the total number of times each monkey inspects items over 20 rounds:
//
//Monkey 0 inspected items 101 times.
//Monkey 1 inspected items 95 times.
//Monkey 2 inspected items 7 times.
//Monkey 3 inspected items 105 times.
//In this example, the two most active monkeys inspected items 101 and 105 times. The level of monkey business in this situation can be found by multiplying these together: 10605.
//
//Figure out which monkeys to chase by counting how many items they inspect over 20 rounds. What is the level of monkey business after 20 rounds of stuff-slinging simian shenanigans?
//

let sampleInput = """
Monkey 0:
  Starting items: 79, 98
  Operation: new = old * 19
  Test: divisible by 23
    If true: throw to monkey 2
    If false: throw to monkey 3

Monkey 1:
  Starting items: 54, 65, 75, 74
  Operation: new = old + 6
  Test: divisible by 19
    If true: throw to monkey 2
    If false: throw to monkey 0

Monkey 2:
  Starting items: 79, 60, 97
  Operation: new = old * old
  Test: divisible by 13
    If true: throw to monkey 1
    If false: throw to monkey 3

Monkey 3:
  Starting items: 74
  Operation: new = old + 3
  Test: divisible by 17
    If true: throw to monkey 0
    If false: throw to monkey 1
"""

final class Monkey: CustomDebugStringConvertible {
    
    let id: Int
    var items: [Int] = []
    let operation: String
    let operationOperand: Int?
    let testVal: Int
    let trueTargetMonkey: Int
    let falseTargetMonkey: Int
    var inspectionCtr = 0
    
    var debugDescription: String {
        return "Monkey(id: \(String(describing: id)), "
        + "items: \(String(describing: items)), "
        + "operation: \(String(describing: operation)), "
        + "operationOperand: \(String(describing: operationOperand)), "
        + "testVal: \(String(describing: testVal)), "
        + "trueTargetMonkey: \(String(describing: trueTargetMonkey)), "
        + "falseTargetMonkey: \(String(describing: falseTargetMonkey)))"
    }
    
    init(componentsList: [String]) {
        assert(componentsList.count == 6)
        id = componentsList[0].matches(of: /(\d+)+/).compactMap({ Int($0.0) })[0]
        
        items = componentsList[1].matches(of: /(\d+)+/).compactMap({ Int($0.0) })
        
        if componentsList[2].contains("*") {
            operation = "mul"
        } else {
            operation = "add"
        }
        
        operationOperand = componentsList[2].matches(of: /(\d+)+/).compactMap({ Int($0.0) }).first
        testVal = componentsList[3].matches(of: /(\d+)+/).compactMap({ Int($0.0) })[0]
        trueTargetMonkey = componentsList[4].matches(of: /(\d+)+/).compactMap({ Int($0.0) })[0]
        falseTargetMonkey = componentsList[5].matches(of: /(\d+)+/).compactMap({ Int($0.0) })[0]
    }
    
    
    
    func operation(item: Int) -> Int {
        switch operation {
        case "add":
            return item + (operationOperand ?? item)
        case "mul":
            return item * (operationOperand ?? item)
        default:
            fatalError()
        }
    }
    
    func test(item: Int) -> Bool {
        item % testVal == 0
    }
    
    func targetMonkey(result: Bool) -> Int {
        result ? trueTargetMonkey : falseTargetMonkey
    }
}

func makeMonkeys(input: String) -> [Monkey] {
    return input
        .components(separatedBy: .newlines)
        .split(separator: "")
        .map({
            Monkey(componentsList: Array($0))
        })
}

func task1(input: String) -> Int {
    var monkeys = makeMonkeys(input: input)
    
    for _ in (0..<20) {
        
//        Monkey 0:
//          Monkey inspects an item with a worry level of 79.
//            Worry level is multiplied by 19 to 1501.
//            Monkey gets bored with item. Worry level is divided by 3 to 500.
//            Current worry level is not divisible by 23.
//            Item with worry level 500 is thrown to monkey 3.
//          Monkey inspects an item with a worry level of 98.
//            Worry level is multiplied by 19 to 1862.
//            Monkey gets bored with item. Worry level is divided by 3 to 620.
//            Current worry level is not divisible by 23.
//            Item with worry level 620 is thrown to monkey 3.
//
        for monkey in monkeys {
            if monkey.items.isEmpty { continue }
            while !monkey.items.isEmpty {
                var currenItem = monkey.items.removeFirst()
                let stress = (monkey.operation(item: currenItem) / 3)
                let targetM = monkey.targetMonkey(result: monkey.test(item: stress))
//                print("Moving \(stress) \(currenItem) to \(targetM)")
                monkeys[targetM].items.append(stress)
                monkey.inspectionCtr += 1
            }
        }
        
        // Test shows how the monkey uses your worry level to decide where to throw an item next.
        // If true shows what happens with an item if the Test was true.
        // If false shows what happens with an item if the Test was false.

        // After each monkey inspects an item but before it tests your worry level, your relief that the monkey's inspection didn't damage the item causes your worry level to be divided by three and rounded down to the nearest integer.
    }
    
    print(monkeys.sorted(by: { lhs, rhs in
        lhs.inspectionCtr > rhs.inspectionCtr
    }).map(\.inspectionCtr)[0..<2].reduce(1, *))
    
    return 0
}

//task1(input: sampleInput)

//task1(input: loadInput())

//--- Part Two ---
//At this rate, you might be putting up with these monkeys for a very long time - possibly 10000 rounds!
//
//With these new rules, you can still figure out the monkey business after 10000 rounds. Using the same example above:
//
//== After round 1 ==
//Monkey 0 inspected items 2 times.
//Monkey 1 inspected items 4 times.
//Monkey 2 inspected items 3 times.
//Monkey 3 inspected items 6 times.
//
//== After round 20 ==
//Monkey 0 inspected items 99 times.
//Monkey 1 inspected items 97 times.
//Monkey 2 inspected items 8 times.
//Monkey 3 inspected items 103 times.
//
//== After round 1000 ==
//Monkey 0 inspected items 5204 times.
//Monkey 1 inspected items 4792 times.
//Monkey 2 inspected items 199 times.
//Monkey 3 inspected items 5192 times.
//
//== After round 2000 ==
//Monkey 0 inspected items 10419 times.
//Monkey 1 inspected items 9577 times.
//Monkey 2 inspected items 392 times.
//Monkey 3 inspected items 10391 times.
//
//== After round 3000 ==
//Monkey 0 inspected items 15638 times.
//Monkey 1 inspected items 14358 times.
//Monkey 2 inspected items 587 times.
//Monkey 3 inspected items 15593 times.
//
//== After round 4000 ==
//Monkey 0 inspected items 20858 times.
//Monkey 1 inspected items 19138 times.
//Monkey 2 inspected items 780 times.
//Monkey 3 inspected items 20797 times.
//
//== After round 5000 ==
//Monkey 0 inspected items 26075 times.
//Monkey 1 inspected items 23921 times.
//Monkey 2 inspected items 974 times.
//Monkey 3 inspected items 26000 times.
//
//== After round 6000 ==
//Monkey 0 inspected items 31294 times.
//Monkey 1 inspected items 28702 times.
//Monkey 2 inspected items 1165 times.
//Monkey 3 inspected items 31204 times.
//
//== After round 7000 ==
//Monkey 0 inspected items 36508 times.
//Monkey 1 inspected items 33488 times.
//Monkey 2 inspected items 1360 times.
//Monkey 3 inspected items 36400 times.
//
//== After round 8000 ==
//Monkey 0 inspected items 41728 times.
//Monkey 1 inspected items 38268 times.
//Monkey 2 inspected items 1553 times.
//Monkey 3 inspected items 41606 times.
//
//== After round 9000 ==
//Monkey 0 inspected items 46945 times.
//Monkey 1 inspected items 43051 times.
//Monkey 2 inspected items 1746 times.
//Monkey 3 inspected items 46807 times.
//
//== After round 10000 ==
//Monkey 0 inspected items 52166 times.
//Monkey 1 inspected items 47830 times.
//Monkey 2 inspected items 1938 times.
//Monkey 3 inspected items 52013 times.
//After 10000 rounds, the two most active monkeys inspected items 52166 and 52013 times. Multiplying these together, the level of monkey business in this situation is now 2713310158.
//
//Worry levels are no longer divided by three after each item is inspected; you'll need to find another way to keep your worry levels manageable. Starting again from the initial state in your puzzle input, what is the level of monkey business after 10000 rounds?


func task2(input: String) -> Int {
    var monkeys = makeMonkeys(input: input)
    
    var dividerThingy = monkeys.reduce(1, { res, m in res * m.testVal })
    for _ in (0..<10000) {
        for monkey in monkeys {
            if monkey.items.isEmpty { continue }
            while !monkey.items.isEmpty {
                var currenItem = monkey.items.removeFirst()
                /**
                 Rangsk, reddit:
                 The key to this is a modular arithmetic concept.
                 First, you need to multiply all the monkeys' mod values together.
                 Let's call this M.
                 
                 Some say find the LCM but they're small enough you can get away with just the product. Now, after every operation you do to an item worry level, after doing the computation, mod that value with M. If you're adding, add then take that result and mod with M.
                 
                 If you're multiplying, multiply and then mod with M.
                 This will keep your worry values small.
                 Everything else is the same.
                 We are exploiting the property that for all integers k: (a mod km) mod m = a mod m
                 */
                let stress = monkey.operation(item: currenItem) % dividerThingy
                let targetM = monkey.targetMonkey(result: monkey.test(item: stress))
                monkeys[targetM].items.append(stress)
                monkey.inspectionCtr += 1
            }
        }
//          14398800016 - input
        
        
        // Test shows how the monkey uses your worry level to decide where to throw an item next.
        // If true shows what happens with an item if the Test was true.
        // If false shows what happens with an item if the Test was false.

        // After each monkey inspects an item but before it tests your worry level, your relief that the monkey's inspection didn't damage the item causes your worry level to be divided by three and rounded down to the nearest integer.
    }
    
    print(monkeys.sorted(by: { lhs, rhs in
        lhs.inspectionCtr > rhs.inspectionCtr
    }).map(\.inspectionCtr)[0..<2].reduce(1, *))
    
    return 0
}

//task2(input: sampleInput)
task2(input: loadInput())
