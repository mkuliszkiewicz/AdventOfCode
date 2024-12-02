//: [Previous](@previous)

import Foundation

func loadInput() -> String {
    let inputPath = Bundle.main.path(forResource: "day8", ofType: nil)!
    let pathURL = URL(filePath: inputPath)
    let data = try! Data(contentsOf: pathURL)
    return String(data: data, encoding: .utf8)!
}

// determine whether there is enough tree cover here to keep a tree house hidden.
// count the number of trees that are visible from outside the grid when looking directly along a row or column.
//
// The Elves have already launched a quadcopter to generate a map with the height of each tree (your puzzle input). For example:
//
// 30373
// 25512
// 65332
// 33549
// 35390

// Each tree is represented as a single digit whose value is its height, where 0 is the shortest and 9 is the tallest.
// A tree is visible if all of the other trees between it and an edge of the grid are shorter than it.
// Only consider trees in the same row or column; that is, only look up, down, left, or right from any given tree.

// All of the trees around the edge of the grid are visible - since they are already on the edge, there are no trees to block the view.

// In this example, that only leaves the interior nine trees to consider:
//
// The top-left 5 is visible from the left and top. (It isn't visible from the right or bottom since other trees of height 5 are in the way.)
// The top-middle 5 is visible from the top and right.
// The top-right 1 is not visible from any direction; for it to be visible, there would need to only be trees of height 0 between it and an edge.
// The left-middle 5 is visible, but only from the right.
// The center 3 is not visible from any direction; for it to be visible, there would need to be only trees of at most height 2 between it and an edge.
// The right-middle 3 is visible from the right.
// In the bottom row, the middle 5 is visible, but the 3 and 4 are not.
// With 16 trees visible on the edge and another 5 visible in the interior, a total of 21 trees are visible in this arrangement.
//
// Consider your map; how many trees are visible from outside the grid?

func task1(input: String) -> Int {
    let rows: [[Int]] = input
        .components(separatedBy: CharacterSet.newlines)
        .filter { !$0.isEmpty }
        .map { (textRow: String) in
            Array(textRow).map({ (char: Character) in
                Int(String(char))!
            })
        }
    
    let maxX = rows[0].count
    let maxY = rows.count
    
    struct Pos: Hashable {
        let x: Int
        let y: Int
    }
    
    var seenTrees = Set<Pos>()
    
    // Horizontally left to right and vice versa
    
    for y in (0..<maxY) {
        for ltr in [true, false] {
            var tallestTree: Int = .min
            if ltr {
                for x in stride(from: 0, to: maxX, by: 1) {
                    print(("ltr", x, y))
                    if rows[x][y] > tallestTree {
                        seenTrees.insert(Pos(x: x, y: y))
                    }
                    
                    tallestTree = max(rows[x][y], tallestTree)
                }
            } else {
                for x in stride(from: maxX - 1, to: -1, by: -1) {
                    print(("rtl", x, y))
                    if rows[x][y] > tallestTree {
                        seenTrees.insert(Pos(x: x, y: y))
                    }
                    tallestTree = max(rows[x][y], tallestTree)
                }
            }
        }
    }
    
    // Vertically top and bottom
    
    for x in (0..<maxX) {
        for topToBottom in [true, false] {
            var tallestTree: Int = .min
            if topToBottom {
                for y in stride(from: 0, to: maxY, by: 1) {
                    print(("ttb", x, y))
                    if rows[x][y] > tallestTree {
                        seenTrees.insert(Pos(x: x, y: y))
                    }

                    tallestTree = max(rows[x][y], tallestTree)
                }
            } else {
                for y in stride(from: maxY - 1, to: -1, by: -1) {
                    print(("btt", x, y))
                    if rows[x][y] > tallestTree {
                        seenTrees.insert(Pos(x: x, y: y))
                    }
                    tallestTree = max(rows[x][y], tallestTree)
                }
            }
        }
    }
    
    print(seenTrees.count)
    return seenTrees.count
}


let testInput =
"""
30373
25512
65332
33549
35390
"""

//assert(task1(input: testInput) == 21)
//
//task1(input: loadInput())


//--- Part Two ---
//
// they would like to be able to see a lot of trees.
//
// To measure the viewing distance from a given tree, look up, down, left, and right from that tree;
// stop if you reach an edge or at the first tree that is the same height or taller than the tree under consideration.
// (If a tree is right on the edge, at least one of its viewing distances will be zero.)
//
// The Elves don't care about distant trees taller than those found by the rules above;
// the proposed tree house has large eaves to keep it dry, so they wouldn't be able to see higher than the tree house anyway.
//
//In the example above, consider the middle 5 in the second row:
//
//30373
//25512
//65332
//33549
//35390
//Looking up, its view is not blocked; it can see 1 tree (of height 3).
//Looking left, its view is blocked immediately; it can see only 1 tree (of height 5, right next to it).
//Looking right, its view is not blocked; it can see 2 trees.
//Looking down, its view is blocked eventually; it can see 2 trees (one of height 3, then the tree of height 5 that blocks its view).
//A tree's scenic score is found by multiplying together its viewing distance in each of the four directions. For this tree, this is 4 (found by multiplying 1 * 1 * 2 * 2).
//
//However, you can do even better: consider the tree of height 5 in the middle of the fourth row:
//
//30373
//25512
//65332
//33549
//35390
//Looking up, its view is blocked at 2 trees (by another tree with a height of 5).
//Looking left, its view is not blocked; it can see 2 trees.
//Looking down, its view is also not blocked; it can see 1 tree.
//Looking right, its view is blocked at 2 trees (by a massive tree of height 9).
//This tree's scenic score is 8 (2 * 2 * 1 * 2); this is the ideal spot for the tree house.
//
//Consider each tree on your map. What is the highest scenic score possible for any tree?

func task2(input: String) -> Int {
    let rows: [[Int]] = input
        .components(separatedBy: CharacterSet.newlines)
        .filter { !$0.isEmpty }
        .map { (textRow: String) in
            Array(textRow).map({ (char: Character) in
                Int(String(char))!
            })
        }
    
    let maxX = rows[0].count
    let maxY = rows.count
    
    print(rows)
    enum Direction {
        case top, left, bottom, right
    }
    
    func countTrees(initialValue: Int, x: Int, y: Int, direction: Direction) -> Int {
        guard (0..<maxX).contains(x) && (0..<maxY).contains(y) else { return 0 }
        
        if rows[y][x] >= initialValue {
            return 1
        }
        
        switch direction {
        case .top:
            return countTrees(initialValue: initialValue, x: x, y: y - 1, direction: .top) + 1
        case .left:
            return countTrees(initialValue: initialValue, x: x - 1, y: y, direction: .left) + 1
        case .bottom:
            return countTrees(initialValue: initialValue, x: x, y: y + 1, direction: .bottom) + 1
        case .right:
            return countTrees(initialValue: initialValue, x: x + 1, y: y, direction: .right) + 1
        }
    }
    
    func findScore(initialValue: Int, x: Int, y: Int) -> Int {
        assert(rows[y][x] == initialValue)
        let top = countTrees(initialValue: initialValue, x: x, y: y - 1, direction: .top)
        let left = countTrees(initialValue: initialValue, x: x - 1, y: y, direction: .left)
        let right = countTrees(initialValue: initialValue, x: x + 1, y: y, direction: .right)
        let bottom = countTrees(initialValue: initialValue, x: x, y: y + 1, direction: .bottom)
        
        return top * left * right * bottom
    }
    
    var maxScore = Int.min
    for x in stride(from: 0, to: maxX, by: 1) {
        for y in stride(from: 0, to: maxY, by: 1) {
            let score = findScore(initialValue: rows[y][x], x: x, y: y)
            print((x, y, "score", score, "maxScore", maxScore, "new max score", score > maxScore, "height", rows[y][x]))
            maxScore = max(score, maxScore)
        }
    }
    
    return maxScore
}

//task2(input: testInput) == 8
print(task2(input: loadInput()))
