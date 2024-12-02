//: [Previous](@previous)

import Foundation

func loadInput() -> String {
    let inputPath = Bundle.main.path(forResource: "day12", ofType: nil)!
    let pathURL = URL(filePath: inputPath)
    let data = try! Data(contentsOf: pathURL)
    return String(data: data, encoding: .utf8)!
}

struct Point: Hashable, CustomStringConvertible {
    let x: Int;
    let y: Int;
    var description: String { "Point(x: \(x), y: \(y))" }
    
    func distance(to point: Point) -> Double {
        func distanceSquared(from: Point, to: Point) -> Double {
            (Double(from.x) - Double(to.x)) * (Double(from.x) - Double(to.x)) + (Double(from.y) - Double(to.y)) * (Double(from.y) - Double(to.y))
        }
        
        return distanceSquared(from: self, to: point).squareRoot()
    }
}

//--- Day 12: Hill Climbing Algorithm ---
// You ask the device for a heightmap of the surrounding area (your puzzle input).
// The heightmap shows the local area from above broken into a grid;
// the elevation of each square of the grid is given by a single lowercase letter, where a is the lowest elevation, b is the next-lowest, and so on up to the highest elevation, z.

// Also included on the heightmap are marks for your current position (S) and the location that should get the best signal (E).

// Your current position (S) has elevation a, and the location that should get the best signal (E) has elevation z.


// You'd like to reach E, but to save energy, you should do it in as few steps as possible.
// During each step, you can move exactly one square up, down, left, or right.

// To avoid needing to get out your climbing gear, the elevation of the destination square can be at most one higher than the elevation of your current square; that is, if your current elevation is m, you could step to elevation n, but not to elevation o. (This also means that the elevation of the destination square can be much lower than the elevation of your current square.)
//
//For example:
//
//Sabqponm
//abcryxxl
//accszExk
//acctuvwj
//abdefghi
//Here, you start in the top-left corner; your goal is near the middle. You could start by moving down or right, but eventually you'll need to head toward the e at the bottom. From there, you can spiral around to the goal:
//
//v..v<<<<
//>v.vv<<^
//.>vv>E^^
//..v>>>^^
//..>>>>>^
//In the above diagram, the symbols indicate whether the path exits each square moving up (^), down (v), left (<), or right (>). The location that should get the best signal is still E, and . marks unvisited squares.
//
//This path reaches the goal in 31 steps, the fewest possible.
//
//What is the fewest steps required to move from your current position to the location that should get the best signal?

func printGrid(grid: [[Character]]) {
    print("---")
    for row in grid {
        print(row.map(String.init).joined(separator: "  "))
    }
    print("---")
}


class Path {
    public let point: Point
    public let previousPath: Path?
    public let length: Int
    
    init(to point: Point, previousPath path: Path? = nil) {
        self.point = point
        self.length = 1 + (path?.length ?? 0)
        self.previousPath = path
    }
}

extension Path {
    var array: [Point] {
        var result: [Point] = [point]
        var currentPath = self
        while let path = currentPath.previousPath {
            result.append(path.point)
            currentPath = path
        }
        return result
    }
}

let alphabet = Array("abcdefghijklmnopqrstuvwxyz")

func task1(input: String) -> Int {
    let grid: [[Character]] = input
        .components(separatedBy: CharacterSet.newlines)
        .filter { !$0.isEmpty }
        .map { Array($0) }
    
    let maxX = grid[0].count
    let maxY = grid.count
    
    printGrid(grid: grid)
    
    let startY = grid.firstIndex(where: { $0.contains("S") })!
    let startX = grid[startY].firstIndex(where: { $0 == "S" })!
    print(("start", startX, startY))
    
    let endY = grid.firstIndex(where: { $0.contains("E") })!
    let endX = grid[endY].firstIndex(where: { $0 == "E" })!
    print(("end", endX, endY))
    
    func val(_ point: Point) -> Character {
        return grid[point.y][point.x]
    }
    
    func possiblePoints(for point: Point) -> [Point] {
        var result: [Point] = []
        var directions: [(Int, Int)] = [(-1, 0), (0, 1), (1, 0), (0, -1)]
        for (x, y) in directions {
            guard
                point.x + x < maxX,
                point.x + x >= 0,
                point.y + y < maxY,
                point.y + y >= 0
            else { continue }
            
            result.append(Point(x: point.x + x, y: point.y + y))
        }
        
        let pointValue = val(point)
        
        if pointValue == "S" { return result }
        
        let currentValueIdx = alphabet.firstIndex(of: pointValue)!
        
        let allowedIndices = Array(0...currentValueIdx + 1)
        
        result = result.filter {
            var targetPointVal = val($0)
            if targetPointVal == "S" { return false }
            if targetPointVal == "E" {
                targetPointVal = "z"
            }
            let targetPointIdx = alphabet.firstIndex(of: targetPointVal)!
            return allowedIndices.contains(targetPointIdx)
        }
        
        return result
    }
    
    func findPath(source: Point, destination: Point) -> Path? {
        var paths: [Path] = [] {
            didSet {
                paths.sort {
                    return $0.length < $1.length
                }
            }
        }
        
        var visited: Set<Point> = []
        paths.append(Path(to: source))
        
        while !paths.isEmpty {
            let currentPath = paths.removeFirst()
            guard !visited.contains(currentPath.point) else {
                continue
            }
            
            if currentPath.point == destination {
                return currentPath
            }
            
            visited.insert(currentPath.point)
            
            for nextPoint in possiblePoints(for: currentPath.point).filter({ !visited.contains($0) }) {
                paths.append(Path.init(to: nextPoint, previousPath: currentPath))
            }
        }
        return nil
    }
    
    let startPoint = Point(x: startX, y: startY)
    let endPoint = Point(x: endX, y: endY)
    let shortestPath = findPath(source: startPoint, destination: endPoint)!
    return shortestPath.length - 1
}

let sampleInput = """
Sabqponm
abcryxxl
accszExk
acctuvwj
abdefghi
"""

//task1(input: sampleInput)

//task1(input: loadInput())

//--- Part Two ---

func task2_d(input: String) -> Int {
    var grid: [[Character]] = input
        .components(separatedBy: CharacterSet.newlines)
        .filter { !$0.isEmpty }
        .map { Array($0) }

    let maxX = grid[0].count
    let maxY = grid.count

    let endY = grid.firstIndex(where: { $0.contains("E") })!
    let endX = grid[endY].firstIndex(where: { $0 == "E" })!
    let endPoint = Point(x: endX, y: endY)

    let numberGrid: [[UInt8]] = grid.map { row in
        row.map { char in
            if char == "S" {
                return Character("a").asciiValue!
            }

            if char == "E" {
                return Character("z").asciiValue!
            }

            return char.asciiValue!
        }
    }

    func val(_ point: Point) -> UInt8 {
        numberGrid[point.y][point.x]
    }

    func possiblePoints(for point: Point) -> [Point] {
        var result: [Point] = []
        var directions: [(Int, Int)] = [(-1, 0), (0, 1), (1, 0), (0, -1)]
        for (x, y) in directions {
            guard
                point.x + x < maxX,
                point.x + x >= 0,
                point.y + y < maxY,
                point.y + y >= 0
            else { continue }

            result.append(Point(x: point.x + x, y: point.y + y))
        }

        let allowedValues = [val(point) - 1, val(point), val(point) + 1]

        result = result.filter { proposedPoint in
            print(
                Int(val(proposedPoint)) - Int(val(point))
            )
            return Int(val(proposedPoint)) - Int(val(point)) >= -1
        }

        return result
    }

    var seenPoints = Set<Point>()

    var paths: [Path] = [Path(to: endPoint)]

    while !paths.isEmpty {
        let currentPath = paths.removeFirst()

        if val(currentPath.point) == Character("a").asciiValue! {
            return currentPath.length - 1
        }

        if seenPoints.contains(currentPath.point) {
            continue
        }

        seenPoints.insert(currentPath.point)

        let nextPoints = possiblePoints(for: currentPath.point).filter({ !seenPoints.contains($0) })

        for nextPoint in nextPoints {
            paths.append(Path(to: nextPoint, previousPath: currentPath))
        }
    }

    return -1
}

//Sabqponm
//abcryxxl
//accszExk
//acctuvwj
//abdefghi
//Now, there are six choices for starting position (five marked a, plus the square marked S that counts as being at elevation a). If you start at the bottom-left square, you can reach the goal most quickly:
//
//...v<<<<
//...vv<<^
//...v>E^^
//.>v>>>^^
//>^>>>>>^
//This path reaches the goal in only 29 steps, the fewest possible.
//
//What is the fewest steps required to move starting from any square with elevation a to the location that should get the best signal?


// . . . v < < < <
// . . . v v < < ^
// . . . v > E ^ ^
// . > v > > > ^ ^
// > ^ > > > > > ^

task2_d(input: sampleInput)
task2_d(input: loadInput())
