import Cocoa

"""
Maybe the lists are only off by a small amount! To find out, pair up the numbers and measure how far apart they are. 
Pair up the smallest number in the left list with the smallest number in the right list, then the second-smallest left number with the second-smallest right number, and so on.

Within each pair, figure out how far apart the two numbers are; 
you'll need to add up all of those distances. 

For example, if you pair up a 3 from the left list with a 7 from the right list, the distance apart is 4; if you pair up a 9 with a 3, the distance apart is 6.

In the example list above, the pairs and distances would be as follows:

The smallest number in the left list is 1, and the smallest number in the right list is 3. 
The distance between them is 2.
The second-smallest number in the left list is 2, and the second-smallest number in the right list is another 3. The distance between them is 1.
The third-smallest number in both lists is 3, so the distance between them is 0.
The next numbers to pair up are 3 and 4, a distance of 1.
The fifth-smallest numbers in each list are 3 and 5, a distance of 2.
Finally, the largest number in the left list is 4, while the largest number in the right list is 9; these are a distance 5 apart.
To find the total distance between the left list and the right list, add up the distances between all of the pairs you found. In the example above, this is 2 + 1 + 0 + 1 + 2 + 5, a total distance of 11!

Your actual left and right lists contain many location IDs. What is the total distance between your lists?
"""

var example = """
            3   4
            4   3
            2   5
            1   3
            3   9
            3   3
            """

enum ParsingErrors: Error {
    case empty
}

extension Bool {
    var negated: Bool {
        !self
    }
}


func loadInput() throws -> String {
    let inputPath = Bundle.main.path(forResource: "input", ofType: nil)!
    let pathURL = URL(filePath: inputPath)
    let data = try! Data(contentsOf: pathURL)
    return String(data: data, encoding: .utf8)!
}

func makeLists(input: String) throws -> ([Int], [Int]) {
    guard !input.isEmpty else { throw ParsingErrors.empty }
    let rows = input.components(separatedBy: .newlines).filter(\.isEmpty.negated)
    
    var parsedRows = rows
        .map {
            let rowElements = $0.components( // [0, 1]
                separatedBy: .whitespacesAndNewlines
            )
            .filter(\.isEmpty.negated)
            .map { Int($0)! } // dangeeerouuus
         
            assert(rowElements.count == 2)
            
            return rowElements
        }
    
    var left: [Int] = []
    var right: [Int] = []
    
    for parsedRow in parsedRows {
        left.append(parsedRow[0])
        right.append(parsedRow[1])
    }
    
    left.sort(by: <); right.sort(by: <);
    
    return (left, right)
}

func task1(input: String) async throws -> Int {
    let (left, right) = try makeLists(input: input)
    return zip(left, right)
        .map { pair in
            print(pair)
            return abs(pair.0 - pair.1)
        }
        .reduce(0, +)
    
}

func task2(input: String) async throws -> Int {
    let (left, right) = try makeLists(input: input)
    let uKeys = left
    
    let histogram = right.reduce([Int: Int]()) { partialResult, v in
        var newResult = partialResult
        newResult[v] = newResult[v, default: 0] + 1
        return newResult
    }
    
    print(histogram)
    
    // by adding up each number in the left list after multiplying it
    // by the number of times that number appears in the right list
    return uKeys.map {
        print("\($0) * \(histogram[$0, default: 0])")
        return histogram[$0, default: 0] * $0
    }.reduce(0, +)
}

//try await task1(input: example)
//let result = try await task1(input: loadInput())
//print(result)

let t2 = try await task2(
    input: loadInput()
)
print(t2)
