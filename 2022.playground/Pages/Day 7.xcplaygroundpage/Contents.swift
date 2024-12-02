//: [Previous](@previous)

import Foundation

func loadInput() -> String {
    let inputPath = Bundle.main.path(forResource: "day7", ofType: nil)!
    let pathURL = URL(filePath: inputPath)
    let data = try! Data(contentsOf: pathURL)
    return String(data: data, encoding: .utf8)!
}

//--- Day 7: No Space Left On Device ---
//$ system-update --please --pretty-please-with-sugar-on-top
//Error: No space left on device
//Perhaps you can delete some files to make space for the update?
//
//You browse around the filesystem to assess the situation and save the resulting terminal output (your puzzle input). For example:
//
//$ cd /
//$ ls
//dir a
//14848514 b.txt
//8504156 c.dat
//dir d
//$ cd a
//$ ls
//dir e
//29116 f
//2557 g
//62596 h.lst
//$ cd e
//$ ls
//584 i
//$ cd ..
//$ cd ..
//$ cd d
//$ ls
//4060174 j
//8033020 d.log
//5626152 d.ext
//7214296 k
//The filesystem consists of a tree of files (plain data) and directories (which can contain other directories or files). The outermost directory is called /. You can navigate around the filesystem, moving into or out of directories and listing the contents of the directory you're currently in.
//
//Within the terminal output, lines that begin with $ are commands you executed, very much like some modern computers:
//
//cd means change directory. This changes which directory is the current directory, but the specific result depends on the argument:
//cd x moves in one level: it looks in the current directory for the directory named x and makes it the current directory.
//cd .. moves out one level: it finds the directory that contains the current directory, then makes that directory the current directory.
//cd / switches the current directory to the outermost directory, /.
//ls means list. It prints out all of the files and directories immediately contained by the current directory:
//123 abc means that the current directory contains a file named abc with size 123.
//dir xyz means that the current directory contains a directory named xyz.
//Given the commands and output in the example above, you can determine that the filesystem looks visually like this:
//
//- / (dir)
//  - a (dir)
//    - e (dir)
//      - i (file, size=584)
//    - f (file, size=29116)
//    - g (file, size=2557)
//    - h.lst (file, size=62596)
//  - b.txt (file, size=14848514)
//  - c.dat (file, size=8504156)
//  - d (dir)
//    - j (file, size=4060174)
//    - d.log (file, size=8033020)
//    - d.ext (file, size=5626152)
//    - k (file, size=7214296)
//Here, there are four directories: / (the outermost directory), a and d (which are in /), and e (which is in a). These directories also contain files of various sizes.
//
//Since the disk is full, your first step should probably be to find directories that are good candidates for deletion. To do this, you need to determine the total size of each directory. The total size of a directory is the sum of the sizes of the files it contains, directly or indirectly. (Directories themselves do not count as having any intrinsic size.)
//
//The total sizes of the directories above can be found as follows:
//
//The total size of directory e is 584 because it contains a single file i of size 584 and no other directories.
//The directory a has total size 94853 because it contains files f (size 29116), g (size 2557), and h.lst (size 62596), plus file i indirectly (a contains e which contains i).
//Directory d has total size 24933642.
//As the outermost directory, / contains every file. Its total size is 48381165, the sum of the size of every file.
//To begin, find all of the directories with a total size of at most 100000, then calculate the sum of their total sizes. In the example above, these directories are a and e; the sum of their total sizes is 95437 (94853 + 584). (As in this example, this process can count files more than once!)
//
// Find all of the directories with a total size of at most 100000. What is the sum of the total sizes of those directories?

let rows = loadInput().components(separatedBy: CharacterSet.newlines).filter { !$0.isEmpty }

struct File {
    let name: String
    let size: Int
}

final class Folder: CustomStringConvertible {
    var parent: Folder?
    var children: [Folder] = []
    var files: [File] = []
    var path: String = ""
    
    var size: Int {
        if let _size { return _size }
        _size = files.reduce(0, { acc, file in return acc + file.size }) + children.reduce(0, { acc, folder in acc + folder.size })
        return _size!
    }
    
    var _size: Int?
    
    var currentPath: String {
        if let parent {
            return parent.currentPath + "/" + path
        }
        return path == "/" ? "" : path
    }
    
    var description: String {
        "{ Folder: \(currentPath), parent: \(parent?.path ?? "n/a") }"
    }
}

var rootFolder: Folder?
var currentFolder: Folder?

for row in rows {
    let rowComponents = row.components(separatedBy: CharacterSet.whitespaces)
    assert(rowComponents.count > 0)
    
    switch rowComponents[0] {
    case "$":
        let command = rowComponents[1]
        let commandInput: String? = rowComponents.count > 2 ? rowComponents[2] : nil
        switch command {
        case "cd":
            if commandInput == ".." {
                print("Going one level up")
                
                assert(currentFolder?.parent != nil, "Folder \(currentFolder!) parent was nil")
                currentFolder = currentFolder?.parent
            } else {
                print("Entering new folder \(commandInput!)")
                
                if rootFolder == nil {
                    let newFolder = Folder()
                    newFolder.path = commandInput!
                    rootFolder = newFolder
                    currentFolder = newFolder
                } else {
                    currentFolder = currentFolder!.children.first(where: { $0.path == commandInput! })!
                }
                
                
                
                print(("currentPath", currentFolder?.currentPath ?? "/"))
            }
        case "ls":
            print("Listing files")
        default:
            assertionFailure("unknown command")
        }
    case "dir":
        let newFolder = Folder()
        newFolder.path = rowComponents[1]
        newFolder.parent = currentFolder
        assert(rootFolder != nil, "root folder was nil")
        assert(currentFolder != nil, "currentFolder was nil")
        currentFolder!.children.append(newFolder)
    default: // filesize
        let fileSize = rowComponents[0]
        let fileName = rowComponents[1]
        currentFolder?.files.append(File(name: fileName, size: Int(fileSize)!))
    }
}

var folders: [Folder] = []

func findFolders(in folder: Folder) {
    if folder.size <= 100000 {
        folders.append(folder)
    }
    
    folder.children.forEach { folder in findFolders(in: folder) }
}

//findFolders(in: rootFolder!)
//
//print(folders)
//print(folders.reduce(0, { acc, folder in acc + folder.size }))

//--- Part Two ---
// The total disk space available to the filesystem is 70000000.
// To run the update, you need unused space of at least 30000000.
// You need to find a directory you can delete that will free up enough space to run the update.
//
// In the example above, the total size of the outermost directory (and thus the total amount of used space) is 48381165; this means that the size of the unused space must currently be 21618835, which isn't quite the 30000000 required by the update. Therefore, the update still requires a directory with total size of at least 8381165 to be deleted before it can run.
//
//To achieve this, you have the following options:
//
//Delete directory e, which would increase unused space by 584.
//Delete directory a, which would increase unused space by 94853.
//Delete directory d, which would increase unused space by 24933642.
//Delete directory /, which would increase unused space by 48381165.
//Directories e and a are both too small; deleting them would not free up enough space. However, directories d and / are both big enough! Between these, choose the smallest: d, increasing unused space by 24933642.
//
//Find the smallest directory that, if deleted, would free up enough space on the filesystem to run the update. What is the total size of that directory?

let total = 70000000
let required = 30000000
let usedSpace = rootFolder!.size
let spaceToFree = required - (total - usedSpace)

var foldersToRemove: [Folder] = []
func findFoldersToRemove(in folder: Folder) {
    if folder.size >= spaceToFree {
        foldersToRemove.append(folder)
    }
    
    folder.children.forEach { folder in findFoldersToRemove(in: folder) }
}

findFoldersToRemove(in: rootFolder!)

print(foldersToRemove)

print(foldersToRemove.map(\.size).min())
