//
//  GitDiffViewerTests.swift
//  GitDiffViewerTests
//
//  Created by Razorback16 on 2/4/25.
//

import Foundation
import AppKit

class DiffParser {
    static func parse(_ text: String) -> [FileSheet] {
        var fileSheets: [FileSheet] = []
        var currentAttributedString = NSMutableAttributedString()
        var currentFilename: String?
        var leftLineNumber = 1
        var rightLineNumber = 1
        
        // Define text attributes.
        let contextAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: NSColor.labelColor,
            .font: NSFont.monospacedSystemFont(ofSize: 12, weight: .regular)
        ]
        let additionAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: NSColor.labelColor,
            .font: NSFont.monospacedSystemFont(ofSize: 12, weight: .regular),
            .backgroundColor: NSColor(named: "diffGreen")!.withAlphaComponent(0.1)
        ]
        let removalAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: NSColor.labelColor,
            .font: NSFont.monospacedSystemFont(ofSize: 12, weight: .regular),
            .backgroundColor: NSColor(named: "diffRed")!.withAlphaComponent(0.1)
        ]
        let additionDarkAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: NSColor.labelColor,
            .font: NSFont.monospacedSystemFont(ofSize: 12, weight: .regular),
            .backgroundColor: NSColor(named: "diffGreenDark")!.withAlphaComponent(0.3)
        ]
        let removalDarkAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: NSColor.labelColor,
            .font: NSFont.monospacedSystemFont(ofSize: 12, weight: .regular),
            .backgroundColor: NSColor(named: "diffRedDark")!.withAlphaComponent(0.3)
        ]
        
        // Split the diff text into lines.
        let textLines = text.components(separatedBy: .newlines)
        
        // Track statistics for the current file.
        var addedLines = 0
        var removedLines = 0
        var currentCommitInfoStruct: CommitInfo?
        
        // Commit the current file’s accumulated data.
        func commitCurrentFile() {
            if let filename = currentFilename, currentAttributedString.length > 0 {
                // Use a default CommitInfo if none was parsed.
                var commitInfo = currentCommitInfoStruct ?? CommitInfo(oldHash: "", newHash: "", fileMode: "")
                commitInfo.addedLines = addedLines
                commitInfo.removedLines = removedLines
                fileSheets.append(FileSheet(filename: filename, commitInfo: commitInfo, content: currentAttributedString))
                currentAttributedString = NSMutableAttributedString()
                currentFilename = nil
                currentCommitInfoStruct = nil
                addedLines = 0
                removedLines = 0
                // Reset hunk line numbers.
                leftLineNumber = 1
                rightLineNumber = 1
            }
        }
        
        // Helper to add a line with optional line numbers.
        func addLineWithLineNumbers(_ line: String,
                                    attributes: [NSAttributedString.Key: Any],
                                    leftNumber: Int? = nil,
                                    rightNumber: Int? = nil) {
            var linePrefix = ""
            if let left = leftNumber {
                linePrefix += String(format: "%4d ", left)
            } else {
                linePrefix += "     "
            }
            if let right = rightNumber {
                linePrefix += String(format: "%4d ", right)
            } else {
                linePrefix += "     "
            }
            currentAttributedString.append(NSAttributedString(string: linePrefix, attributes: contextAttributes))
            currentAttributedString.append(NSAttributedString(string: line + "\n", attributes: attributes))
        }
        
        // Process each line from the diff.
        for line in textLines {
            if line.hasPrefix("diff --git") {
                // A new diff header indicates a new file.
                commitCurrentFile()
                addedLines = 0
                removedLines = 0
                leftLineNumber = 1
                rightLineNumber = 1
                
                // Example header: "diff --git a/src/main.c b/src/main.c"
                let components = line.components(separatedBy: " ")
                if components.count >= 4 {
                    let oldPath = String(components[2].dropFirst(2)) // remove "a/"
                    let newPath = String(components[3].dropFirst(2)) // remove "b/"
                    
                    if oldPath != newPath {
                        // Renamed file.
                        currentFilename = "\(oldPath) → \(newPath)"
                    } else {
                        currentFilename = oldPath
                    }
                    
                    // Sometimes /dev/null appears in the header.
                    if oldPath == "/dev/null" {
                        currentFilename = newPath + " (New File)"
                    } else if newPath == "/dev/null" {
                        currentFilename = oldPath + " (Deleted)"
                    }
                }
            } else if line.hasPrefix("index") {
                // Parse index line. Example: "index 94e72a2..b1c2d3e 100644"
                let parts = line.split(separator: " ")
                if parts.count >= 2 {
                    let hashes = parts[1].split(separator: ".")
                    if hashes.count == 2 {
                        let fileMode = parts.count > 2 ? String(parts[2]) : "100644"
                        currentCommitInfoStruct = CommitInfo(
                            oldHash: String(hashes[0]),
                            newHash: String(hashes[1]),
                            fileMode: fileMode
                        )
                    }
                }
            } else if line.hasPrefix("new file mode") {
                // Mark this file as a new file.
                if let currentName = currentFilename, !currentName.contains("New File") {
                    currentFilename = currentName + " (New File)"
                }
            } else if line.hasPrefix("deleted file mode") {
                // Mark this file as deleted.
                if let currentName = currentFilename, !currentName.contains("Deleted") {
                    currentFilename = currentName + " (Deleted)"
                }
            } else if line.hasPrefix("rename from") {
                // Optionally capture the old name.
                let _ = line.replacingOccurrences(of: "rename from ", with: "").trimmingCharacters(in: .whitespaces)
                // (Store if needed.)
            } else if line.hasPrefix("rename to") {
                // Optionally capture the new name.
                let newName = line.replacingOccurrences(of: "rename to ", with: "").trimmingCharacters(in: .whitespaces)
                if let currentName = currentFilename, !currentName.contains("→") {
                    currentFilename = currentName + " → " + newName
                }
            } else if line.hasPrefix("Binary files") {
                // Handle binary diffs.
                addLineWithLineNumbers("[Binary file differs]", attributes: contextAttributes)
            } else if line.hasPrefix("+++") || line.hasPrefix("---") {
                // Check these lines for /dev/null markers.
                if line.contains("/dev/null") {
                    if line.hasPrefix("---") {
                        if let currentName = currentFilename, !currentName.contains("New File") {
                            currentFilename = currentName + " (New File)"
                        }
                    } else if line.hasPrefix("+++") {
                        if let currentName = currentFilename, !currentName.contains("Deleted") {
                            currentFilename = currentName + " (Deleted)"
                        }
                    }
                }
                // Do not output these file path lines.
            } else if line.hasPrefix("+") || line.hasPrefix("-") {
                // Process addition or deletion lines.
                let isAddition = line.hasPrefix("+")
                let lineContent = String(line.dropFirst())
                
                if isAddition {
                    // A normal addition line.
                    addLineWithLineNumbers(lineContent, attributes: additionAttributes, rightNumber: rightLineNumber)
                    rightLineNumber += 1
                } else {
                    // A deletion line.
                    addLineWithLineNumbers(lineContent, attributes: removalAttributes, leftNumber: leftLineNumber)
                    leftLineNumber += 1
                }
            } else if line.hasPrefix("@@") {
                // Process hunk header (e.g., @@ -1,3 +1,4 @@).
                if let match = line.range(of: "@@ -(\\d+),(\\d+) \\+(\\d+),(\\d+) @@", options: .regularExpression) {
                    let numbers = line[match]
                        .components(separatedBy: CharacterSet(charactersIn: " -+,@"))
                        .compactMap { Int($0) }
                    if numbers.count >= 4 {
                        leftLineNumber = numbers[0]
                        rightLineNumber = numbers[2]
                    }
                }
                // Do not output the hunk header.
            } else {
                // Context line.
                addLineWithLineNumbers(line, attributes: contextAttributes, leftNumber: leftLineNumber, rightNumber: rightLineNumber)
                leftLineNumber += 1
                rightLineNumber += 1
            }
            
            // Update counters (skip the file header lines).
            if line.hasPrefix("+") && !line.hasPrefix("+++") {
                addedLines += 1
            } else if line.hasPrefix("-") && !line.hasPrefix("---") {
                removedLines += 1
            }
        }
        
        commitCurrentFile()
        return fileSheets
    }
}
