//: [Previous](@previous)

import Foundation

func loadInput() -> String {
    let inputPath = Bundle.main.path(forResource: "day15", ofType: nil)!
    let pathURL = URL(filePath: inputPath)
    let data = try! Data(contentsOf: pathURL)
    return String(data: data, encoding: .utf8)!
}

//--- Day 15: Beacon Exclusion Zone ---
// measured by the Manhattan distance. (There is never a tie where two beacons are the same distance to a sensor.)

//Sensor at x=2, y=18: closest beacon is at x=-2, y=15
//Sensor at x=9, y=16: closest beacon is at x=10, y=16
//Sensor at x=13, y=2: closest beacon is at x=15, y=3
//Sensor at x=12, y=14: closest beacon is at x=10, y=16
//Sensor at x=10, y=20: closest beacon is at x=10, y=16
//Sensor at x=14, y=17: closest beacon is at x=10, y=16
//Sensor at x=8, y=7: closest beacon is at x=2, y=10
//Sensor at x=2, y=0: closest beacon is at x=2, y=10
//Sensor at x=0, y=11: closest beacon is at x=2, y=10
//Sensor at x=20, y=14: closest beacon is at x=25, y=17
//Sensor at x=17, y=20: closest beacon is at x=21, y=22
//Sensor at x=16, y=7: closest beacon is at x=15, y=3
//Sensor at x=14, y=3: closest beacon is at x=15, y=3
//Sensor at x=20, y=1: closest beacon is at x=15, y=3

//               1    1    2    2
//     0    5    0    5    0    5
// 0 ....S.......................
// 1 ......................S.....
// 2 ...............S............
// 3 ................SB..........
// 4 ............................
// 5 ............................
// 6 ............................
// 7 ..........S.......S.........
// 8 ............................
// 9 ............................
//10 ....B.......................
//11 ..S.........................
//12 ............................
//13 ............................
//14 ..............S.......S.....
//15 B...........................
//16 ...........SB...............
//17 ................S..........B
//18 ....S.......................
//19 ............................
//20 ............S......S........
//21 ............................
//22 .......................B....

// This isn't necessarily a comprehensive map of all beacons in the area, though.
// Because each sensor only identifies its closest beacon,
// if a sensor detects a beacon, you know there are no other beacons that close or closer to that sensor.

// There could still be beacons that just happen to not be the closest beacon to any sensor. Consider the sensor at 8,7:
//
//               1    1    2    2
//     0    5    0    5    0    5
//-2 ..........#.................
//-1 .........###................
// 0 ....S...#####...............
// 1 .......#######........S.....
// 2 ......#########S............
// 3 .....###########SB..........
// 4 ....#############...........
// 5 ...###############..........
// 6 ..#################.........
// 7 .#########S#######S#........
// 8 ..#################.........
// 9 ...###############..........
//10 ....B############...........
//11 ..S..###########............
//12 ......#########.............
//13 .......#######..............
//14 ........#####.S.......S.....
//15 B........###................
//16 ..........#SB...............
//17 ................S..........B
//18 ....S.......................
//19 ............................
//20 ............S......S........
//21 ............................
//22 .......................B....
//This sensor's closest beacon is at 2,10, and so you know there are no beacons that close or closer (in any positions marked #).
//
//None of the detected beacons seem to be producing the distress signal, so you'll need to work out where the distress beacon is by working out where it isn't.
// For now, keep things simple by counting the positions where a beacon cannot possibly be along just a single row.


// So, suppose you have an arrangement of beacons and sensors like in the example above and, just in the row where y=10, you'd like to count the number of positions a beacon cannot possibly exist. The coverage from all sensors near that row looks like this:
//
//                 1    1    2    2
//       0    5    0    5    0    5
// 9 ...#########################...
//10 ..####B######################..
//11 .###S#############.###########.
//In this example, in the row where y=10, there are 26 positions where a beacon cannot be present.
//
//Consult the report from the sensors you just deployed. In the row where y=2000000, how many positions cannot contain a beacon?

import CoreGraphics

struct BoundingBox: Hashable {
    let minX: Int
    let maxX: Int
    
    let minY: Int
    let maxY: Int
    
    var rect: CGRect {
        CGRect(origin: CGPoint(x: Double(minX), y: Double(minY)), size: CGSize(width: abs(Double(maxX) - Double(minX)), height: abs(Double(maxY) - Double(minY))))
    }
    
    func intersection(_ otherBB: BoundingBox) -> CGRect {
        CGRectIntersection(rect, otherBB.rect)
    }
    
    func intersects(_ otherBB: BoundingBox) -> Bool {
        CGRectIntersection(rect, otherBB.rect) != CGRect.null
    }
    
    var xRange: ClosedRange<Int> { (minX...maxX) }
    var yRange: ClosedRange<Int> { (minX...maxX) }
}

struct Line {
    let p1: Point
    let p2: Point
    
    var slope: Int {
        (p1.y-p2.y) / (p1.x-p2.x)
    }
    
    func intersection(of other: Line) -> Point? {
        let ourSlope = slope
        let theirSlope = other.slope
        
        guard ourSlope != theirSlope else { return nil }
        
        let x = (ourSlope*p1.x - theirSlope*other.p1.x + other.p1.y - p1.y) / (ourSlope - theirSlope)
        return Point(x: x, y: theirSlope*(x - other.p1.x) + other.p1.y)
    }
}

struct Sensor: Hashable, CustomStringConvertible {
    let x: Int
    let y: Int
    
    let beaconX: Int
    let beaconY: Int
    
    
    var linesOutside: [Line] {
        var res = [Line]()
        // / ul
        res.append(Line(p1: Point(x: x - distance - 1, y: y), p2: Point(x: x, y: y + distance + 1)))
        // \ ur
        res.append(Line(p1: Point(x: x, y: y + distance + 1), p2: Point(x: x + distance + 1, y: y)))
        // \ ll
        res.append(Line(p1: Point(x: x - distance - 1, y: y), p2: Point(x: x, y: y - distance - 1)))
        // / lr
        res.append(Line(p1: Point(x: x + distance + 1, y: y), p2: Point(x: x, y: y - distance - 1)))
        
        return res
    }
    
    // Sensor at x=8, y=7: closest beacon is at x=2, y=10
    init(x: Int, y: Int, beaconX: Int, beaconY: Int) {
        self.x = x; self.y = y; self.beaconX = beaconX; self.beaconY = beaconY
    }
    
    init(_ s: String) {
        let matches = s.matches(of: /-?\d+/)
        
        x = Int(matches[0].output)!
        y = Int(matches[1].output)!
        beaconX = Int(matches[2].output)!
        beaconY = Int(matches[3].output)!
    }
    
    var description: String { "Sensor(x: \(x), y: \(y), beaconX: \(beaconX), beaconY: \(beaconY))" }
    
    var distance: Int {
        abs(x - beaconX) + abs(y - beaconY)
    }
    
    func coversPoint(x: Int, y: Int) -> Bool {
        (abs(self.x - x) + abs(self.y - y)) <= distance
    }
    
    func findMB(s1: Point, s2: Point) -> (Int, Int) {
        let m = s2.y - s1.y / s2.x - s1.x
        let b = s1.y - m * s1.x
        // (y = mx + b)
        
        let x = (y - b) / m
        
        return (m, b)
    }
    
    var boundingBox: BoundingBox {
        let distance = self.distance
        return .init(minX: x - distance, maxX: x + distance, minY: y - distance, maxY: y + distance)
    }
    
    func intersects(_ bbox: BoundingBox) -> Bool {
        boundingBox.intersects(bbox)
    }
}

struct Point: Hashable, CustomStringConvertible { let x: Int; let y: Int; var description: String { "Point(x: \(x), y: \(y))" } }
//Sensor at x=8, y=7: closest beacon is at x=2, y=10
let bb = Sensor(x: 8, y: 7, beaconX: 2, beaconY: 10).boundingBox
assert(bb == .init(minX: -1, maxX: 17, minY: -2, maxY: 16), "ref != bb")

func task1(input: String, targetY: Int) -> Int {
    let sensors = input
        .components(separatedBy: .newlines)
        .filter { !$0.isEmpty }
        .map {
            Sensor($0)
        }
    
    
    var minX = Int.max
    var maxX = Int.min
    
    var minY = Int.max
    var maxY = Int.min
    
    for sensor in sensors {
        minX = min(min(minX, sensor.x), sensor.beaconX)
        maxX = max(max(maxX, sensor.x), sensor.beaconX)
        
        minY = min(min(minY, sensor.y), sensor.beaconY)
        maxY = max(max(maxY, sensor.y), sensor.beaconY)
    }
    
    let sensorWithLowestX = sensors.min(by: { $0.x < $1.x })!
    let sensorWithHighestX = sensors.min(by: { $0.x > $1.x })!
    
    var targetBoundingBox = BoundingBox(minX: minX - sensorWithLowestX.distance, maxX: maxX + sensorWithHighestX.distance, minY: targetY, maxY: targetY)
    
    var possibleSensors: Set<Sensor> = Set(sensors.filter { $0.intersects(targetBoundingBox) })
    
    var occupiedPoints: Set<Point> = []
    var occupied: Set<Point> = []
    
    print("X to check \((targetBoundingBox.minX...targetBoundingBox.maxX).count)")
    for x in (targetBoundingBox.minX...targetBoundingBox.maxX) {
        for possibleSensor in possibleSensors {
            if possibleSensor.coversPoint(x: x, y: targetY) {
                occupied.insert(.init(x: possibleSensor.beaconX, y: possibleSensor.beaconY))
                occupied.insert(.init(x: possibleSensor.x, y: possibleSensor.y))
                occupiedPoints.insert(Point(x: x, y: targetY))
            }
        }
    }
    
    // In the row where y=2000000, how many positions cannot contain a beacon?
    return occupiedPoints.subtracting(occupied).count
}

let sampleInput = """
Sensor at x=2, y=18: closest beacon is at x=-2, y=15
Sensor at x=9, y=16: closest beacon is at x=10, y=16
Sensor at x=13, y=2: closest beacon is at x=15, y=3
Sensor at x=12, y=14: closest beacon is at x=10, y=16
Sensor at x=10, y=20: closest beacon is at x=10, y=16
Sensor at x=14, y=17: closest beacon is at x=10, y=16
Sensor at x=8, y=7: closest beacon is at x=2, y=10
Sensor at x=2, y=0: closest beacon is at x=2, y=10
Sensor at x=0, y=11: closest beacon is at x=2, y=10
Sensor at x=20, y=14: closest beacon is at x=25, y=17
Sensor at x=17, y=20: closest beacon is at x=21, y=22
Sensor at x=16, y=7: closest beacon is at x=15, y=3
Sensor at x=14, y=3: closest beacon is at x=15, y=3
Sensor at x=20, y=1: closest beacon is at x=15, y=3
"""

//task1(input: sampleInput, targetY: 10)

//task1(input: loadInput(), targetY: 2000000)

//do {
//    let contents = try String(contentsOfFile: CommandLine.arguments[1], encoding: .utf8)
//    print("old: 5768553, res: \(task1(input: contents, targetY: 2000000))")
//} catch {
//    print("Ooops! Something went wrong: \(error)")
//}

// Part 2
// The distress beacon is not detected by any sensor, but the distress beacon must have x and y coordinates each no lower than 0 and no larger than 4000000.
//
//To isolate the distress beacon's signal, you need to determine its tuning frequency, which can be found by multiplying its x coordinate by 4000000 and then adding its y coordinate.
//
//In the example above, the search space is smaller: instead, the x and y coordinates can each be at most 20.
// With this reduced search area, there is only a single position that could have a beacon: x=14, y=11. The tuning frequency for this distress beacon is 56000011.
//
//Find the only possible position for the distress beacon. What is its tuning frequency?

func task2(input: String, gridSide: Int) -> Int {
    let sensors = input
        .components(separatedBy: .newlines)
        .filter { !$0.isEmpty }
        .map {
            Sensor($0)
        }
    
    let allLines: [Line] = sensors.flatMap { $0.linesOutside }
    
    for lhsLine in allLines {
        for rhsLine in allLines {
            if let intersection = lhsLine.intersection(of: rhsLine), intersection.x <= gridSide, intersection.y <= gridSide, intersection.x >= 0, intersection.y >= 0 {
                
                if sensors.first(where: { $0.coversPoint(x: intersection.x, y: intersection.y) }) == nil {
                    print(intersection)
                    print((intersection.x, intersection.y, intersection.x * 4000000 + intersection.y))
                    return intersection.x * 4000000 + intersection.y
                }
            }
        }
    }
        
//        if possibleSensors.first(where: { $0.coversPoint(x: x, y: y) }) == nil {
//            fatalError("Found it \(x), \(y), \(x * 4000000 + y)")
//        }
//
//        if x % 1_000_000 == 0 {
//            print((x, y))
//        }
//    }
    
    return 0
}

//task2(input: sampleInput, gridSide: 20)
task2(input: loadInput(), gridSide: 4000000)
//print("Start")
//do {
//    let contents = try String(contentsOfFile: CommandLine.arguments[1], encoding: .utf8)
//    print("freq: \(task2(input: contents, gridSide: 4000000))")
//} catch {
//    print("Ooops! Something went wrong: \(error)")
//}
