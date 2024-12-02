//: [Previous](@previous)

import Foundation

func loadInput() -> String {
    let inputPath = Bundle.main.path(forResource: "day16", ofType: nil)!
    let pathURL = URL(filePath: inputPath)
    let data = try! Data(contentsOf: pathURL)
    return String(data: data, encoding: .utf8)!
}

extension Array {
    var combinations: [[Element]] {
        if count == 0 {
            return [self]
        } else {
            let tail = Array(self[1..<endIndex])
            let head = self[0]

            let first = tail.combinations
            let rest = first.map { $0 + [head] }

            return first + rest
        }
    }
}

extension Array {
    func decompose() -> (Iterator.Element, [Iterator.Element])? {
        guard let x = first else { return nil }
        return (x, Array(self[1..<count]))
    }
}

func between<T>(x: T, _ ys: [T]) -> [[T]] {
    guard let (head, tail) = ys.decompose() else { return [[x]] }
    return [[x] + ys] + between(x: x, tail).map { [head] + $0 }
}

func permutations<T>(xs: [T]) -> [[T]] {
    guard let (head, tail) = xs.decompose() else { return [[]] }
    return permutations(xs: tail).flatMap { between(x: head, $0) }
}

func calculateSum(lookup: [String: Node], events: [Int: String]) -> Int {
    var sum = 0
    for t in (1...30) {
        let keys = events.keys.filter { $0 <= t }.sorted(by: >)
        var nodeNames: [String] = []
        var releasedNow = 0
        for key in keys {
            let nodeName = events[key]!
            let node = lookup[nodeName]!
            nodeNames.append(nodeName)
            sum += node.fr
            releasedNow += node.fr
        }
    }
    
    return sum
}

func score(_ paths: [Path], lookup: [String: Node]) -> Int {
    // the target node is always the one we open valve at, we ignore the ones along the way
    var t = 0
    var events: [Int: String] = [:]
    for path in paths {
        t += path.visited.count
        events[t + 1] = path.node.name
        assert(t < 30)
    }
    return calculateSum(lookup: lookup, events: events)
}

//--- Day 16: Proboscidea Volcanium ---

// you have 30 minutes before the volcano erupts
// You scan the cave for other options and discover a network of pipes and pressure-release valves.
// your device produces a report (your puzzle input) of each valve's flow rate if it were opened (in pressure per minute) and the tunnels you could use to move between the valves.


// There's even a valve in the room you and the elephants are currently standing in labeled AA.
// You estimate it will take you one minute to open a single valve and one minute to follow any tunnel from one valve to another.
// What is the most pressure you could release?


// For example, suppose you had the following scan output:
//Valve AA has flow rate=0; tunnels lead to valves DD, II, BB
//Valve BB has flow rate=13; tunnels lead to valves CC, AA
//Valve CC has flow rate=2; tunnels lead to valves DD, BB
//Valve DD has flow rate=20; tunnels lead to valves CC, AA, EE
//Valve EE has flow rate=3; tunnels lead to valves FF, DD
//Valve FF has flow rate=0; tunnels lead to valves EE, GG
//Valve GG has flow rate=0; tunnels lead to valves FF, HH
//Valve HH has flow rate=22; tunnel leads to valve GG
//Valve II has flow rate=0; tunnels lead to valves AA, JJ
//Valve JJ has flow rate=21; tunnel leads to valve II

// All of the valves begin closed. You start at valve AA, but it must be damaged or jammed or something: its flow rate is 0, so there's no point in opening it. However, you could spend one minute moving to valve BB and another minute opening it; doing so would release pressure during the remaining 28 minutes at a flow rate of 13, a total eventual pressure release of 28 * 13 = 364. Then, you could spend your third minute moving to valve CC and your fourth minute opening it, providing an additional 26 minutes of eventual pressure release at a flow rate of 2, or 52 total pressure released by valve CC.
//
// Making your way through the tunnels like this, you could probably open many or all of the valves by the time 30 minutes have elapsed. However, you need to release as much pressure as possible, so you'll need to be methodical. Instead, consider this approach:
//
//== Minute 1 ==
//No valves are open.
//You move to valve DD.
//
//== Minute 2 ==
//No valves are open.
//You open valve DD.
//
//== Minute 3 ==
//Valve DD is open, releasing 20 pressure.
//You move to valve CC.
//
//== Minute 4 ==
//Valve DD is open, releasing 20 pressure.
//You move to valve BB.
//
//== Minute 5 ==
//Valve DD is open, releasing 20 pressure.
//You open valve BB.
//
//== Minute 6 ==
//Valves BB and DD are open, releasing 33 pressure.
//You move to valve AA.
//
//== Minute 7 ==
//Valves BB and DD are open, releasing 33 pressure.
//You move to valve II.
//
//== Minute 8 ==
//Valves BB and DD are open, releasing 33 pressure.
//You move to valve JJ.
//
//== Minute 9 ==
//Valves BB and DD are open, releasing 33 pressure.
//You open valve JJ.
//
//== Minute 10 ==
//Valves BB, DD, and JJ are open, releasing 54 pressure.
//You move to valve II.
//
//== Minute 11 ==
//Valves BB, DD, and JJ are open, releasing 54 pressure.
//You move to valve AA.
//
//== Minute 12 ==
//Valves BB, DD, and JJ are open, releasing 54 pressure.
//You move to valve DD.
//
//== Minute 13 ==
//Valves BB, DD, and JJ are open, releasing 54 pressure.
//You move to valve EE.
//
//== Minute 14 ==
//Valves BB, DD, and JJ are open, releasing 54 pressure.
//You move to valve FF.
//
//== Minute 15 ==
//Valves BB, DD, and JJ are open, releasing 54 pressure.
//You move to valve GG.
//
//== Minute 16 ==
//Valves BB, DD, and JJ are open, releasing 54 pressure.
//You move to valve HH.
//
//== Minute 17 ==
//Valves BB, DD, and JJ are open, releasing 54 pressure.
//You open valve HH.
//
//== Minute 18 ==
//Valves BB, DD, HH, and JJ are open, releasing 76 pressure.
//You move to valve GG.
//
//== Minute 19 ==
//Valves BB, DD, HH, and JJ are open, releasing 76 pressure.
//You move to valve FF.
//
//== Minute 20 ==
//Valves BB, DD, HH, and JJ are open, releasing 76 pressure.
//You move to valve EE.
//
//== Minute 21 ==
//Valves BB, DD, HH, and JJ are open, releasing 76 pressure.
//You open valve EE.
//
//== Minute 22 ==
//Valves BB, DD, EE, HH, and JJ are open, releasing 79 pressure.
//You move to valve DD.
//
//== Minute 23 ==
//Valves BB, DD, EE, HH, and JJ are open, releasing 79 pressure.
//You move to valve CC.
//
//== Minute 24 ==
//Valves BB, DD, EE, HH, and JJ are open, releasing 79 pressure.
//You open valve CC.
//
//== Minute 25 ==
//Valves BB, CC, DD, EE, HH, and JJ are open, releasing 81 pressure.
//
//== Minute 26 ==
//Valves BB, CC, DD, EE, HH, and JJ are open, releasing 81 pressure.
//
//== Minute 27 ==
//Valves BB, CC, DD, EE, HH, and JJ are open, releasing 81 pressure.
//
//== Minute 28 ==
//Valves BB, CC, DD, EE, HH, and JJ are open, releasing 81 pressure.
//
//== Minute 29 ==
//Valves BB, CC, DD, EE, HH, and JJ are open, releasing 81 pressure.
//
//== Minute 30 ==
//Valves BB, CC, DD, EE, HH, and JJ are open, releasing 81 pressure.
//This approach lets you release the most pressure possible in 30 minutes with this valve layout, 1651.
//
//Work out the steps to release the most pressure in 30 minutes. What is the most pressure you can release?
//

/**
 
 //        for currentPossiblePath in possiblePaths {
 //            print("- \(currentPossiblePath.node.name): \(currentPossiblePath.path): \(currentPossiblePath.score)")
 //
 //            let endNodeForCurrentPath = currentPossiblePath.node
 //
 //            // points on this path that also have flow
 //            var possibleStops = nodesToVisit.filter { currentPossiblePath.path.visited.contains($0.name) }
 //            possibleStops.removeAll(where: { $0 == currentPossiblePath.node })
 //
 //            if !possibleStops.isEmpty {
 //                // [A], [A, B], [B], [B, A]
 //                let allStopsVariants: [[Node]] = possibleStops.combinations.filter { !$0.isEmpty }
 //
 //                print("  Nodes on path: \(possibleStops.map { $0.name }), variants: \(allStopsVariants.map({ $0.map(\.name) }).filter { !$0.isEmpty })")
 //
 //                // Subvariant is array of [Node]
 //                for subvariant in allStopsVariants {
 //                    // currentNode -> node in variant 1 -> ... -> node in variant 2 -> endNodeForCurrentPath
 //
 //                    var fullSubvariant = [currentNode] + subvariant + [endNodeForCurrentPath]
 //                    var subvariantPaths: [Path] = []
 //                    for i in (1..<fullSubvariant.count) {
 //                        let source = fullSubvariant[i - 1]
 //                        let target = fullSubvariant[i]
 //                        if let subPath = findPath(allNodes: lookup, source: source, destination: target) {
 //                            print("\(source.name) -> \(target.name)")
 //                            subvariantPaths.append(subPath)
 //                        } else {
 //                            print("No path from \(source.name) -> \(target.name)")
 //                            break
 //                        }
 //                    }
 //
 //                    let fullPath = selectedPaths + subvariantPaths
 //                    let fullPathScore = score(fullPath)
 //                    print("   - \(fullPath.map(\.nodesNames)) ->  \(fullPathScore); isBetter?: \(fullPathScore >= nextPath.score)")
 //
 //                    if nextPath.score <= fullPathScore {
 //                        print("Choosing subvarinat: \(subvariant.map(\.name))")
 //                        nextPath = ScoredPath(path: subvariantPaths.removeLast(), extraPaths: subvariantPaths, score: fullPathScore, node: endNodeForCurrentPath)
 //                    }
 //                }
 //            }
 //        }
 
 */


func combinations<T>(of elements: Set<T>) -> [[T]] {
    var allCombinations: [[T]] = []
    for element in elements {
        let oneElementCombo = [element]
        for i in 0..<allCombinations.count {
            allCombinations.append(allCombinations[i] + oneElementCombo)
        }
        allCombinations.append(oneElementCombo)
    }
    return allCombinations
}

let sampleInput = """
Valve AA has flow rate=0; tunnels lead to valves DD, II, BB
Valve BB has flow rate=13; tunnels lead to valves CC, AA
Valve CC has flow rate=2; tunnels lead to valves DD, BB
Valve DD has flow rate=20; tunnels lead to valves CC, AA, EE
Valve EE has flow rate=3; tunnels lead to valves FF, DD
Valve FF has flow rate=0; tunnels lead to valves EE, GG
Valve GG has flow rate=0; tunnels lead to valves FF, HH
Valve HH has flow rate=22; tunnel leads to valve GG
Valve II has flow rate=0; tunnels lead to valves AA, JJ
Valve JJ has flow rate=21; tunnel leads to valve II
"""

final class Node: Hashable, CustomDebugStringConvertible {
    static func == (lhs: Node, rhs: Node) -> Bool {
        lhs.name == rhs.name &&
        lhs.fr == rhs.fr &&
        lhs.connections == rhs.connections
    }
    
    func hash(into hasher: inout Hasher) {
        name.hash(into: &hasher)
        fr.hash(into: &hasher)
        connections.hash(into: &hasher)
    }
    
    let name: String
    let fr: Int
    let connections: [String]
    
    init(_ s: String) {
        var mutS = s
        mutS.replace("Valve ", with: "")
        mutS.replace(" has flow rate=", with: "$")
        mutS.replace("; tunnel leads to valve ", with: "$")
        mutS.replace("; tunnels lead to valves ", with: "$")
        var comps = mutS.components(separatedBy: "$")
        name = comps[0]
        fr = Int(comps[1])!
        connections = comps[2].replacing(" ", with: "").components(separatedBy: ",")
    }
    
    var debugDescription: String {
        "Node(name: \(name), flowRate: \(fr), connections: \(connections))"
    }
}


//final class Path: CustomDebugStringConvertible {
//    let node: Node
//    let previous: Path?
//    let visited: Set<String>
//
//    init(node: Node, previous: Path?) {
//        self.node = node
//        self.previous = previous
//        var visited = Set(previous?.visited ?? [])
//        visited.insert(node.name)
//        self.visited = visited
//    }
//
//    var path: [String] {
//        [node.name] + (previous?.path ?? [])
//    }
//
//    var debugDescription: String {
//        "Path(node: \(node.name), visited: \(visited))"
//    }
//}

/**
 // first shortest path to the first interesting node
 
 var allPaths: [[Path]] = []
 
 let allPointsPermutations = permutations(xs: nodesWithFlow)
//    print(allPointsPermutations)
 var bestScore = Int.min
 for combination in allPointsPermutations {
     
     var allNodesToVisit = [startingNode] + combination
     var res: [Path] = []
     for i in (1..<allNodesToVisit.count) {
         let previous = allNodesToVisit[i - 1]
         let current = allNodesToVisit[i]
         if let path = findPath(allNodes: lookup, source: previous, destination: current) {
             res.append(path)
         } else {
             break
         }
     }
     
     allPaths.append(res)
     let currentScore = score(res)
     if currentScore > bestScore {
         print(res.map(\.nodesNames))
     }
     bestScore = max(currentScore, bestScore)
     print(bestScore)
 }
 */

final class Path: CustomDebugStringConvertible {
    var node: Node { path.last! }
    private let path: [Node]
    var visited: Set<String> { Set(path.map(\.name)) }
    
    init(rawPath: [Node]) {
        self.path = rawPath
    }
    
    init(node: Node, previous: Path?) {
        self.path = (previous?.path ?? []) + [node]
    }
    
    var nodesNames: [String] { path.map { $0.name + "(\($0.fr))" } }
    
    var debugDescription: String {
        "Path(node: \(node.name), history: \(nodesNames))"
    }
    
    var count: Int { path.count }
}

func findPath(allNodes: [String: Node], source: Node, destination: Node) -> Path? {
    var paths: [Path] = [] {
        didSet {
            paths.sort {
                return $0.count < $1.count
            }
        }
    }
    
    var visited: Set<Node> = []
    paths.append(Path(node: source, previous: nil))
    
    while !paths.isEmpty {
        let currentPath = paths.removeFirst()
        guard !visited.contains(currentPath.node) else {
            continue
        }
        
        if currentPath.node == destination {
            return currentPath
        }
        
        visited.insert(currentPath.node)
        
        for connection in currentPath.node.connections where !visited.contains(allNodes[connection]!) {
            paths.append(
                Path(
                    node: allNodes[connection]!,
                    previous: currentPath
                )
            )
        }
    }
    
    return nil
}

func task1(input: String) -> Int {
    var lookup: [String: Node] = [:]
    
    var nodes = input
        .components(separatedBy: .newlines)
        .filter { !$0.isEmpty }
        .map(Node.init)

    for node in nodes {
        lookup[node.name] = node
    }
    
    var nodesToVisit = nodes.filter { $0.fr > 0 }.sorted(by: { lhs, rhs in lhs.fr > rhs.fr }).filter({ $0.name != "AA" })
    
    let startingNode = nodes.first(where: { $0.name == "AA" })!
    
    print(nodesToVisit.count)
    
    
    func findBestPath(path: [Path], nodesLeft: [Node]) -> [Path] {
        if nodesLeft.isEmpty {
            return path
        }
        
        var nextPaths: [[Path]] = nodesLeft.map { nextNode in
            return path + [findPath(allNodes: lookup, source: path.last!.node, destination: nextNode)!]
        }
        
        
        var bestPath: [Path] = []
        
        for nextPath in nextPaths {
            
        }
        let pathScore = score(selectedPaths + [path], lookup: lookup)
    }
    
//    var selectedPaths: [Path] = []
    
//    var currentNode = startingNode
//    while !nodesToVisit.isEmpty {
//        print("===========")
//        print("Path so far:", selectedPaths.map(\.nodesNames))
//        struct ScoredPath {
//            let path: Path
//            let extraPaths: [Path] // if path had better subvariants
//            let score: Int
//            let node: Node
//            var extraNodes: Set<Node> {
//                Set(extraPaths.map(\.node))
//            }
//        }
//
//        let possiblePaths = nodesToVisit.map { nodeToVisit in
//            let path = findPath(allNodes: lookup, source: currentNode, destination: nodeToVisit)!
//            let pathScore = score(selectedPaths + [path], lookup: lookup)
//            return ScoredPath(path: path, extraPaths: [], score: pathScore / path.count + 1, node: nodeToVisit)
//        }
//
//        print("Possible paths from: \(currentNode.name):")
//
//        var nextPath: ScoredPath = possiblePaths.sorted(by: { lhs, rhs in lhs.score > rhs.score }).first!
//
//        for currentPossiblePath in possiblePaths {
//            print("- \(currentPossiblePath.node.name): \(currentPossiblePath.path): \(currentPossiblePath.score)")
//        }
//
//        print("===")
//
//        print("Selected path: \(nextPath.node.name) \(nextPath.score)")
//
//        nodesToVisit.removeAll(where: { $0 == nextPath.node || nextPath.extraNodes.contains($0) })
//
//        currentNode = nextPath.node
//
//        selectedPaths.append(contentsOf: Array(nextPath.extraPaths.reversed()))
//        selectedPaths.append(nextPath.path)
//    }
//
//    print("===")
//    let finalPathScore = score(selectedPaths, lookup: lookup)
//    print("Final path (\(finalPathScore)): \(selectedPaths.map(\.nodesNames))")
        
    return finalPathScore
}

task1(input: sampleInput) == 1651


//print(task1(input: loadInput()))

//do {
//    print("Start \(CommandLine.arguments[1])")
//    let contents = try String(contentsOfFile: CommandLine.arguments[1], encoding: .utf8)
//    print("max flow: \(task1(input: contents))")
//} catch {
//    print("Ooops! Something went wrong: \(error)")
//}

/**
 score(
     [
 ["AA", "DD"],
 ["DD", "CC", "BB"],
 ["BB", "AA", "II", "JJ"],
 ["JJ", "II", "AA", "DD", "EE", "FF", "GG", "HH"],
 ["HH", "GG", "FF", "EE"],
 ["EE", "DD", "CC"]
     ]
         .map { subpath in
             Path(rawPath: subpath.map { lookup[$0]! })
         }, lookup: lookup
 ) == 1651
 
 //
 //    [3: DD, 6: BB, 9: JJ, 18: HH, 22: EE, 25: CC]
 //
 //    AA >> DD >> CC >> BB >> AA >> II >> JJ >> II >> AA >> DD >> EE >> FF >> GG >> HH >> GG >> FF >> EE >> DD >> CC!
 */

