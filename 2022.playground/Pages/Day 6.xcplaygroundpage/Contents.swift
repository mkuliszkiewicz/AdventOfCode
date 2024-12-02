//: [Previous](@previous)

import Foundation

//--- Day 6: Tuning Trouble ---

// To be able to communicate with the Elves, the device needs to lock on to their signal.
// The signal is a series of seemingly-random characters that the device receives one at a time.

// To fix the communication system, you need to add a subroutine to the device that detects a start-of-packet marker in the datastream.
// In the protocol being used by the Elves, the start of a packet is indicated by a sequence of four characters that are all different.

// The device will send your subroutine a datastream buffer (your puzzle input); your subroutine needs to identify the first position where the four most recently received characters were all different.

// Specifically, it needs to report the number of characters from the beginning of the buffer to the end of the first such four-character marker.

//For example, suppose you receive the following datastream buffer:
//
//mjqjpqmgbljsphdztnvjfqwrcgsmlb
//After the first three characters (mjq) have been received, there haven't been enough characters received yet to find the marker.
// The first time a marker could occur is after the fourth character is received, making the most recent four characters mjqj. Because j is repeated, this isn't a marker.

// The first time a marker appears is after the seventh character arrives. Once it does, the last four characters received are jpqm, which are all different. In this case, your subroutine should report the value 7, because the first start-of-packet marker is complete after 7 characters have been processed.
//Here are a few more examples:
//
//bvwbjplbgvbhsrlpgdmjqwftvncz: first marker after character 5
//nppdvjthqldpwncqszvftbrmjlhg: first marker after character 6
//nznrnfrfntjfmvfwmzdfjlvtqnbhcprsg: first marker after character 10
//zcfzfwzzqfrljwzlrfnpqdbhtmscgvjw: first marker after character 11
//How many characters need to be processed before the first start-of-packet marker is detected?

func loadInput() -> String {
    let inputPath = Bundle.main.path(forResource: "day6", ofType: nil)!
    let pathURL = URL(filePath: inputPath)
    let data = try! Data(contentsOf: pathURL)
    return String(data: data, encoding: .utf8)!
}

func task1(input: String) -> Int? {
    var chars = Array(input)
    var last4: [Character] = []
    
    for (idx, char) in chars.enumerated() {
        if last4.count < 4 {
            last4.append(char)
            print(("appending \(char)", last4))
        }
        
        if last4.count == 4 {
            if Set(last4).count == 4 {
                print(("found marker", last4))
                return idx + 1
            } else {
                print(("has duplicates, need to remove first", last4))
                last4.removeFirst()
            }
        }
    }
    
    return nil
}

//assert(task1(input: "mjqjpqmgbljsphdztnvjfqwrcgsmlb") == 7)
//assert(task1(input: "bvwbjplbgvbhsrlpgdmjqwftvncz") == 5)
//assert(task1(input: "nppdvjthqldpwncqszvftbrmjlhg") == 6)
//assert(task1(input: "nznrnfrfntjfmvfwmzdfjlvtqnbhcprsg") == 10)
//assert(task1(input: "zcfzfwzzqfrljwzlrfnpqdbhtmscgvjw") == 11)
//print(task1(input: loadInput()))

//--- Part Two ---
//
//Your device's communication system is correctly detecting packets, but still isn't working. It looks like it also needs to look for messages.
//
//A start-of-message marker is just like a start-of-packet marker, except it consists of 14 distinct characters rather than 4.
//
//Here are the first positions of start-of-message markers for all of the above examples:
//
//mjqjpqmgbljsphdztnvjfqwrcgsmlb: first marker after character 19
//bvwbjplbgvbhsrlpgdmjqwftvncz: first marker after character 23
//nppdvjthqldpwncqszvftbrmjlhg: first marker after character 23
//nznrnfrfntjfmvfwmzdfjlvtqnbhcprsg: first marker after character 29
//zcfzfwzzqfrljwzlrfnpqdbhtmscgvjw: first marker after character 26
//How many characters need to be processed before the first start-of-message marker is detected?
//
//


func task2(input: String) -> Int? {
    var chars = Array(input)
    var last4: [Character] = []
    
    for (idx, char) in chars.enumerated() {
        if last4.count < 14 {
            last4.append(char)
            print(("appending \(char)", last4))
        }
        
        if last4.count == 14 {
            if Set(last4).count == 14 {
                print(("found marker", last4))
                return idx + 1
            } else {
                print(("has duplicates, need to remove first", last4))
                last4.removeFirst()
            }
        }
    }
    
    return nil
}

assert(task2(input: "mjqjpqmgbljsphdztnvjfqwrcgsmlb") == 19)
assert(task2(input: "bvwbjplbgvbhsrlpgdmjqwftvncz") == 23)
assert(task2(input: "bvwbjplbgvbhsrlpgdmjqwftvncz") == 23)
assert(task2(input: "nppdvjthqldpwncqszvftbrmjlhg") == 23)
assert(task2(input: "nznrnfrfntjfmvfwmzdfjlvtqnbhcprsg") == 29)
assert(task2(input: "zcfzfwzzqfrljwzlrfnpqdbhtmscgvjw") == 26)
print(task2(input: loadInput()))
