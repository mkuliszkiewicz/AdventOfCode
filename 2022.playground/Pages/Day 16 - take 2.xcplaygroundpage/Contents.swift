//: [Previous](@previous)

import Foundation

final class Node: Hashable, CustomDebugStringConvertible {
    static func == (lhs: Node, rhs: Node) -> Bool {
        lhs.name == rhs.name &&
        lhs.flowRate == rhs.flowRate &&
        lhs.connections == rhs.connections
    }
    
    func hash(into hasher: inout Hasher) {
        name.hash(into: &hasher)
        flowRate.hash(into: &hasher)
        connections.hash(into: &hasher)
    }
    
    let name: String
    let flowRate: Int
    let connections: [String]
    
    init(_ s: String) {
        var mutS = s
        mutS.replace("Valve ", with: "")
        mutS.replace(" has flow rate=", with: "$")
        mutS.replace("; tunnel leads to valve ", with: "$")
        mutS.replace("; tunnels lead to valves ", with: "$")
        var comps = mutS.components(separatedBy: "$")
        name = comps[0]
        flowRate = Int(comps[1])!
        connections = comps[2].replacing(" ", with: "").components(separatedBy: ",")
    }
    
    var debugDescription: String {
        "Node(name: \(name), flowRate: \(flowRate), connections: \(connections))"
    }
}

func loadInput() -> String {
    let inputPath = Bundle.main.path(forResource: "day16", ofType: nil)!
    let pathURL = URL(filePath: inputPath)
    let data = try! Data(contentsOf: pathURL)
    return String(data: data, encoding: .utf8)!
}

// Valve NQ has flow rate=0; tunnels lead to valves SU, XD
//let inputString = loadInput()



/*
 --- Day 16: Proboscidea Volcanium ---

 - this isn't just a cave, it's a volcano!
 - you have 30 minutes before the volcano erupts
 - it will take you one minute to open a single valve
 -

 .. network of pipes and pressure-release valves ...
your device produces a report (your puzzle input) of each valve's flow rate if it were opened (in pressure per minute) and the tunnels you could use to move between the valves.

 There's even a valve in the room you and the elephants are currently standing in labeled AA.

 You estimate it will take you one minute to open a single valve and one minute to follow any tunnel from one valve to another. What is the most pressure you could release?

 For example, suppose you had the following scan output:

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
 
 All of the valves begin closed. You start at valve AA, but it must be damaged or jammed or something: its flow rate is 0, so there's no point in opening it. However, you could spend one minute moving to valve BB and another minute opening it; doing so would release pressure during the remaining 28 minutes at a flow rate of 13, a total eventual pressure release of 28 * 13 = 364. Then, you could spend your third minute moving to valve CC and your fourth minute opening it, providing an additional 26 minutes of eventual pressure release at a flow rate of 2, or 52 total pressure released by valve CC.

 Making your way through the tunnels like this, you could probably open many or all of the valves by the time 30 minutes have elapsed. However, you need to release as much pressure as possible, so you'll need to be methodical. Instead, consider this approach:

 == Minute 1 ==
 No valves are open.
 You move to valve DD.

 == Minute 2 ==
 No valves are open.
 You open valve DD.

 == Minute 3 ==
 Valve DD is open, releasing 20 pressure.
 You move to valve CC.

 == Minute 4 ==
 Valve DD is open, releasing 20 pressure.
 You move to valve BB.

 == Minute 5 ==
 Valve DD is open, releasing 20 pressure.
 You open valve BB.

 == Minute 6 ==
 Valves BB and DD are open, releasing 33 pressure.
 You move to valve AA.

 == Minute 7 ==
 Valves BB and DD are open, releasing 33 pressure.
 You move to valve II.

 == Minute 8 ==
 Valves BB and DD are open, releasing 33 pressure.
 You move to valve JJ.

 == Minute 9 ==
 Valves BB and DD are open, releasing 33 pressure.
 You open valve JJ.

 == Minute 10 ==
 Valves BB, DD, and JJ are open, releasing 54 pressure.
 You move to valve II.

 == Minute 11 ==
 Valves BB, DD, and JJ are open, releasing 54 pressure.
 You move to valve AA.

 == Minute 12 ==
 Valves BB, DD, and JJ are open, releasing 54 pressure.
 You move to valve DD.

 == Minute 13 ==
 Valves BB, DD, and JJ are open, releasing 54 pressure.
 You move to valve EE.

 == Minute 14 ==
 Valves BB, DD, and JJ are open, releasing 54 pressure.
 You move to valve FF.

 == Minute 15 ==
 Valves BB, DD, and JJ are open, releasing 54 pressure.
 You move to valve GG.

 == Minute 16 ==
 Valves BB, DD, and JJ are open, releasing 54 pressure.
 You move to valve HH.

 == Minute 17 ==
 Valves BB, DD, and JJ are open, releasing 54 pressure.
 You open valve HH.

 == Minute 18 ==
 Valves BB, DD, HH, and JJ are open, releasing 76 pressure.
 You move to valve GG.

 == Minute 19 ==
 Valves BB, DD, HH, and JJ are open, releasing 76 pressure.
 You move to valve FF.

 == Minute 20 ==
 Valves BB, DD, HH, and JJ are open, releasing 76 pressure.
 You move to valve EE.

 == Minute 21 ==
 Valves BB, DD, HH, and JJ are open, releasing 76 pressure.
 You open valve EE.

 == Minute 22 ==
 Valves BB, DD, EE, HH, and JJ are open, releasing 79 pressure.
 You move to valve DD.

 == Minute 23 ==
 Valves BB, DD, EE, HH, and JJ are open, releasing 79 pressure.
 You move to valve CC.

 == Minute 24 ==
 Valves BB, DD, EE, HH, and JJ are open, releasing 79 pressure.
 You open valve CC.

 == Minute 25 ==
 Valves BB, CC, DD, EE, HH, and JJ are open, releasing 81 pressure.

 == Minute 26 ==
 Valves BB, CC, DD, EE, HH, and JJ are open, releasing 81 pressure.

 == Minute 27 ==
 Valves BB, CC, DD, EE, HH, and JJ are open, releasing 81 pressure.

 == Minute 28 ==
 Valves BB, CC, DD, EE, HH, and JJ are open, releasing 81 pressure.

 == Minute 29 ==
 Valves BB, CC, DD, EE, HH, and JJ are open, releasing 81 pressure.

 == Minute 30 ==
 Valves BB, CC, DD, EE, HH, and JJ are open, releasing 81 pressure.
 This approach lets you release the most pressure possible in 30 minutes with this valve layout, 1651.
 */

extension Node {
    func pressure(time: Int) -> Int {
        flowRate * time
    }
}

final class Path {
    var previous: Path?
    let node: Node
    
    var length: Int {
        1 + (previous?.length ?? 0)
    }
    
    init(previous: Path? = nil, node: Node) {
        self.previous = previous
        self.node = node
    }
    
    func make(for nextNode: Node) -> Path {
        .init(previous: self, node: nextNode)
    }
    
    func nodesPath() -> String {
        var nodes = [String]()
        var currentPath: Path? = self
        while let cp = currentPath {
            nodes.append(cp.node.name)
            currentPath = cp.previous
        }
        return nodes.joined(separator: ",")
    }
}

func dfs(start: Node, end: Node, lookup: [String: Node]) -> Path? {
    var stack = [Path(node: start)] // nodes to visit
    var visited = Set<Node>()
    while !stack.isEmpty {
        var currentPath = stack.removeFirst()
        
        if currentPath.node == end {
            return currentPath
        }
        
        if !visited.contains(currentPath.node) {
            visited.insert(currentPath.node)
            
            for nextNode in currentPath.node.connections.map({ lookup[$0]! }) {
                stack = [currentPath.make(for: nextNode)] + stack
            }
        }
    }
    
    return nil
}

struct Solution {
    enum Action {
        // Go to <node> using <path>
        case visit(Node, Path?)
        case open(Node)
        
        var node: Node {
            switch self {
            case .visit(let node, let path):
                return node
            case .open(let node):
                return node
            }
        }
        
        var cost: Int {
            switch self {
            case .visit(_, .none):
                return 0 // Start
            case .visit(_, let .some(path)):
                return path.length
            case .open:
                return 1
            }
        }
    }
    
    var time: Int {
        actions.map(\.cost).reduce(0, +)
    }
    
    var currentNode: Node { actions.last!.node }
    
    var actions: [Action] = []
    
    var pressureReleased: Int {
        var pressureReleased = 0
        
        var time = 30
        
        for action in actions {
            switch action {
            case let .visit(node, .none):
            
            case let .visit(node, .some(path)):
                
            case .open(let node):
                
            }
        }
        
        
        return pressureReleased
    }
    
    var visitedNodes: Set<String> {
        Set(actions.map(\.node.name))
    }
    
    var pathSoFar: [String] {
        actions.map(\.node.name)
    }
    
    func move(to node: Node, path: Path) -> Solution {
        .init(actions: actions + [.visit(node, path)])
    }
}

func task1(input: String) -> Int {
    let nodesMap: [String: Node] = input
        .components(separatedBy: .newlines)
        .filter { !$0.isEmpty }
        .map(Node.init)
        .reduce([String: Node]()) { partialResult, node in
            var newResult = partialResult
            assert(newResult[node.name] == nil)
            newResult[node.name] = node
            return newResult
        }
    
    let startingNode = nodesMap["AA"]!
    
//    print(dfs(start: startingNode, end: nodesMap["HH"]!, lookup: nodesMap)?.nodesPath() as Any)
    
    var openValves = Set<Node>()
    
    // All the valves worth inspecting
    let nodesWithFlow = Set(nodesMap.values.filter { $0.flowRate > 0 }.map(\.name))
    
    print(nodesWithFlow)
    
    // 1. We are only interested in visiting nodes that have a flow rate > 0
    // 2. We start with AA
    // 3. Costs of operation is 1 minute for both opening and closing
    // 4. We need to remember each chain [AA, BB, CC etc ...] and at an each step evalute 3 possible scenarios (given we are at valve XYZ):
    // - open the valve XYZ, 1 minute penalty but pressure release starts
    // - skip this valve and go further (if any unopened valves remain)
    // - idle if empty (finish)
    
    var solutions: [Solution] = [
        Solution(actions: [.visit(startingNode, nil)])
    ]
    
    var outerflowPin = true
    while outerflowPin { // this loop will only finish if all nodes were visited
        var currentSolutions = solutions
        var newSolutions: [Solution] = []
        var hasUnfinishedFlow = false
        for currentSolution in currentSolutions {
            if currentSolution.time > 30 { continue }
            let nodesLeftToVisit = nodesWithFlow.subtracting(currentSolution.visitedNodes)
            
            if !nodesLeftToVisit.isEmpty { // loop breaker
                hasUnfinishedFlow = true
            }
            
            for nextNode in nodesLeftToVisit {
                if let path = dfs(start: currentSolution.currentNode, end: nodesMap[nextNode]!, lookup: nodesMap) {
                    newSolutions.append(currentSolution.move(to: nodesMap[nextNode]!, path: path))
                }
            }
            
            solutions = newSolutions
        }
        
        if !hasUnfinishedFlow {
            break
        }
    }
    
    return solutions.map(\.pressureReleased).max() ?? 0
}

//let sampleInput = """
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
//"""

let sampleInput = """
Valve AA has flow rate=0; tunnels lead to valves DD, BB
Valve BB has flow rate=13; tunnels lead to valves CC, AA
Valve CC has flow rate=2; tunnels lead to valves DD, BB
Valve DD has flow rate=20; tunnels lead to valves CC, AA
"""

//print(task1(input: sampleInput) == 1651)

print(task1(input: sampleInput))

//task1(input: inputString)

//: [Next](@next)
