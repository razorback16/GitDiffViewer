//
//  GitDiffViewerTests.swift
//  GitDiffViewerTests
//
//  Created by Razorback16 on 2/4/25.
//

import Foundation

struct WordDiffCalculator {
    enum ChangeType {
        case same
        case added
        case removed
    }
    
    struct WordChange {
        let word: String
        let type: ChangeType
    }
    
    static func diffWords(oldLine: String, newLine: String) -> ([WordChange], [WordChange]) {
        // Remove the first character (+ or -) for diff lines
        let oldText = oldLine.dropFirst()
        let newText = newLine.dropFirst()
        
        // Split into words (including whitespace)
        let oldWords = splitIntoWords(String(oldText))
        let newWords = splitIntoWords(String(newText))
        
        // Find longest common subsequence
        let lcs = longestCommonSubsequence(oldWords, newWords)
        
        // Generate word changes for both lines
        let oldChanges = generateWordChanges(words: oldWords, commonWords: lcs, isAddition: false)
        let newChanges = generateWordChanges(words: newWords, commonWords: lcs, isAddition: true)
        
        return (oldChanges, newChanges)
    }
    
    private static func splitIntoWords(_ text: String) -> [String] {
        var words: [String] = []
        var currentWord = ""
        
        for char in text {
            if char.isWhitespace || char.isPunctuation {
                if !currentWord.isEmpty {
                    words.append(currentWord)
                    currentWord = ""
                }
                words.append(String(char))
            } else {
                currentWord.append(char)
            }
        }
        
        if !currentWord.isEmpty {
            words.append(currentWord)
        }
        
        return words
    }
    
    private static func longestCommonSubsequence(_ a: [String], _ b: [String]) -> [String] {
        let m = a.count
        let n = b.count
        var dp = Array(repeating: Array(repeating: 0, count: n + 1), count: m + 1)
        
        // Fill the dp table using half-open ranges to handle empty arrays safely.
        for i in 1..<(m+1) {
            for j in 1..<(n+1) {
                if a[i-1] == b[j-1] {
                    dp[i][j] = dp[i-1][j-1] + 1
                } else {
                    dp[i][j] = max(dp[i-1][j], dp[i][j-1])
                }
            }
        }
        
        // Reconstruct the sequence
        var lcs: [String] = []
        var i = m
        var j = n
        
        while i > 0 && j > 0 {
            if a[i-1] == b[j-1] {
                lcs.insert(a[i-1], at: 0)
                i -= 1
                j -= 1
            } else if dp[i-1][j] > dp[i][j-1] {
                i -= 1
            } else {
                j -= 1
            }
        }
        
        return lcs
    }
    
    private static func generateWordChanges(words: [String], commonWords: [String], isAddition: Bool) -> [WordChange] {
        var changes: [WordChange] = []
        var commonIndex = 0
        
        for word in words {
            if commonIndex < commonWords.count && word == commonWords[commonIndex] {
                changes.append(WordChange(word: word, type: .same))
                commonIndex += 1
            } else {
                changes.append(WordChange(word: word, type: isAddition ? .added : .removed))
            }
        }
        
        return changes
    }
}
