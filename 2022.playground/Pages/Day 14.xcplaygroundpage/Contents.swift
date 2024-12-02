//: [Previous](@previous)

import Foundation

func loadInput() -> String {
    let inputPath = Bundle.main.path(forResource: "day14", ofType: nil)!
    let pathURL = URL(filePath: inputPath)
    let data = try! Data(contentsOf: pathURL)
    return String(data: data, encoding: .utf8)!
}

//--- Day 14: Regolith Reservoir ---

// Your scan traces the path of each solid rock structure and reports the x,y coordinates that form the shape of the path, where x represents distance to the right and y represents distance down. Each path appears as a single line of text in your scan. After the first point of each path, each point indicates the end of a straight horizontal or vertical line to be drawn from the previous point. For example:
//
//498,4 -> 498,6 -> 496,6
//503,4 -> 502,4 -> 502,9 -> 494,9
//This scan means that there are two paths of rock; the first path consists of two straight lines, and the second path consists of three straight lines. (Specifically, the first path consists of a line of rock from 498,4 through 498,6 and another line of rock from 498,6 through 496,6.)
//
//The sand is pouring into the cave from point 500,0.
//
//Drawing rock as #, air as ., and the source of the sand as +, this becomes:
//
//
//  4     5  5
//  9     0  0
//  4     0  3
//0 ......+...
//1 ..........
//2 ..........
//3 ..........
//4 ....#...##
//5 ....#...#.
//6 ..###...#.
//7 ........#.
//8 ........#.
//9 #########.

// Sand is produced one unit at a time, and the next unit of sand is not produced until the previous unit of sand comes to rest.
// A unit of sand is large enough to fill one tile of air in your scan.
// - A unit of sand always falls down one step if possible.
// - If the tile immediately below is blocked (by rock or sand), the unit of sand attempts to instead move diagonally one step down and to the left.
// - If that tile is blocked, the unit of sand attempts to instead move diagonally one step down and to the right.
// - Sand keeps moving as long as it is able to do so, at each step trying to move down, then down-left, then down-right.
// - If all three possible destinations are blocked, the unit of sand comes to rest and no longer moves, at which point the next unit of sand is created back at the source.
//
//So, drawing sand that has come to rest as o, the first unit of sand simply falls straight down and then stops:
//
//......+...
//..........
//..........
//..........
//....#...##
//....#...#.
//..###...#.
//........#.
//......o.#.
//#########.
//The second unit of sand then falls straight down, lands on the first one, and then comes to rest to its left:
//
//......+...
//..........
//..........
//..........
//....#...##
//....#...#.
//..###...#.
//........#.
//.....oo.#.
//#########.
//After a total of five units of sand have come to rest, they form this pattern:
//
//......+...
//..........
//..........
//..........
//....#...##
//....#...#.
//..###...#.
//......o.#.
//....oooo#.
//#########.
//After a total of 22 units of sand:
//
//......+...
//..........
//......o...
//.....ooo..
//....#ooo##
//....#ooo#.
//..###ooo#.
//....oooo#.
//...ooooo#.
//#########.
//Finally, only two more units of sand can possibly come to rest:
//
//......+...
//..........
//......o...
//.....ooo..
//....#ooo##
//...o#ooo#.
//..###ooo#.
//....oooo#.
//.o.ooooo#.
//#########.

//Once all 24 units of sand shown above have come to rest, all further sand flows out the bottom, falling into the endless void.
// Just for fun, the path any new sand takes before falling forever is shown here with ~:
//
//.......+...
//.......~...
//......~o...
//.....~ooo..
//....~#ooo##
//...~o#ooo#.
//..~###ooo#.
//..~..oooo#.
//.~o.ooooo#.
//~#########.
//~..........
//~..........
//~..........
//Using your scan, simulate the falling sand. How many units of sand come to rest before sand starts flowing into the abyss below?


let sampleInput = """
498,4 -> 498,6 -> 496,6
503,4 -> 502,4 -> 502,9 -> 494,9
"""

//  4     5  5
//  9     0  0
//  4     0  3
//0 ......+...
//1 ..........
//2 ..........
//3 ..........
//4 ....#...##
//5 ....#...#.
//6 ..###...#.
//7 ........#.
//8 ........#.
//9 #########.

struct Point: Hashable, CustomStringConvertible {
    let x: Int; let y: Int
    
    init(x: Int, y: Int) {
        self.x = x
        self.y = y
    }
    
    init(_ str: String) {
        // x represents distance to the right and y represents distance down.
        let el = str.components(separatedBy: ",").map { Int($0)! }
        self.x = el[0]
        self.y = el[1]
    }
    
    var description: String { "Point(x: \(x), y: \(y))" }
    
    func makeAllPoints(to otherPoint: Point) -> [Point] {
        guard self != otherPoint else { return [] }
        if x != otherPoint.x {
            var minX = min(x, otherPoint.x)
            var maxX = max(x, otherPoint.x)
            return (minX...maxX).map { Point(x: $0, y: y) }
        } else {
            var minY = min(y, otherPoint.y)
            var maxY = max(y, otherPoint.y)
            return (minY...maxY).map { Point(x: x, y: $0) }
        }
    }
    
    func adjustX(by val: Int) -> Point {
        Point(x: x + val, y: y)
    }
    
    func adjustY(by val: Int) -> Point {
        Point(x: x, y: y + val)
    }
    
    func flipY() -> Point {
        Point(x: x, y: y * -1)
    }
    
}


final class Sand {
    var position = Point(x: 0, y: 0)
}

func task1(input: String) -> Int {
    
    let rawRows = input
        .components(separatedBy: .newlines)
        .filter { !$0.isEmpty }
        .map { $0.components(separatedBy: " -> ").map(Point.init) }
    
    var rawRockPoints: Set<Point> = []
    
    for row in rawRows where !row.isEmpty {
        for i in (1..<row.count) {
            let current = row[i]
            let previous = row[i - 1]
            previous
                .makeAllPoints(to: current)
                .forEach {
                    rawRockPoints.insert($0)
                }
        }
    }
    
    
    var rocksPoints = rawRockPoints.map { $0.adjustX(by: -500).flipY() }
    var lowestRockPoint = rocksPoints.min(by: { $0.y < $1.y })!
    var sandBuffer: Set<Point> = []
    var sandCounter = 0
    
    var hasFallenDown = false

    while !hasFallenDown {
        sandCounter += 1
        var currentSand = Sand()
        
        func nextMove() -> Point? {
            var currentPosition = currentSand.position
            
            let oneDown = currentPosition.adjustY(by: -1)
            let oneDownLeft = currentPosition.adjustY(by: -1).adjustX(by: -1)
            let oneDownRight = currentPosition.adjustY(by: -1).adjustX(by: 1)
            
            if !rocksPoints.contains(oneDown) && !sandBuffer.contains(oneDown) {
                return oneDown
            }
            
            if !rocksPoints.contains(oneDownLeft) && !sandBuffer.contains(oneDownLeft) {
                return oneDownLeft
            }
            
            if !rocksPoints.contains(oneDownRight) && !sandBuffer.contains(oneDownRight) {
                return oneDownRight
            }
            
            return nil
        }
        
        while let next = nextMove(), !hasFallenDown {
            currentSand.position = next
            hasFallenDown = currentSand.position.y < lowestRockPoint.y
            if hasFallenDown {
                print("Has fallen down")
            }
        }
        
        print("Settled at \(currentSand.position)")
        sandBuffer.insert(currentSand.position)
    }
    
    
    return sandCounter - 1
}

//task1(input: sampleInput)

//task1(input: loadInput())

func task2(input: String) -> Int {
    let rawRows = input
        .components(separatedBy: .newlines)
        .filter { !$0.isEmpty }
        .map {
            $0.components(separatedBy: " -> ")
              .map(Point.init)
              .map {
                $0.adjustX(by: -500)
                  .flipY()
              }
        }
    
    var rawRockPoints: Set<Point> = []
    for row in rawRows where !row.isEmpty {
        for i in (1..<row.count) {
            let current = row[i]
            let previous = row[i - 1]
            previous
                .makeAllPoints(to: current)
                .forEach {
                    rawRockPoints.insert($0)
                }
        }
    }
    
    
    var rocksPoints = rawRockPoints
    let lowestRockPoint = rocksPoints.min(by: { $0.y < $1.y })!
    
    let floorLevel = lowestRockPoint.y - 2
    print("Floor level \(floorLevel)")
    
    var sandCounter = 0
    
    while true {
        sandCounter += 1
        var currentSand = Point(x: 0, y: 0)
        
        func nextMove() -> Point? {
            
            let oneDown = currentSand.adjustY(by: -1)
            let oneDownLeft = currentSand.adjustY(by: -1).adjustX(by: -1)
            let oneDownRight = currentSand.adjustY(by: -1).adjustX(by: 1)
            
            if oneDown.y == floorLevel {
                return nil
            }
            
            if !rocksPoints.contains(oneDown) {
                return oneDown
            }
            
            if !rocksPoints.contains(oneDownLeft) {
                return oneDownLeft
            }
            
            if !rocksPoints.contains(oneDownRight) {
                return oneDownRight
            }
            
            return nil
        }
        
        while let next = nextMove() {
            currentSand = next
        }
        
        rocksPoints.insert(currentSand)
        
        if currentSand == .init(x: 0, y: 0) {
            return sandCounter
        }
    }
    
    fatalError()
}

task2(input: loadInput())
