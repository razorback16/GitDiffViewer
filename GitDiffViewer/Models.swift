//
//  GitDiffViewerTests.swift
//  GitDiffViewerTests
//
//  Created by Razorback16 on 2/4/25.
//

import Foundation

// Models for the diff viewer application
struct CommitInfo {
    let oldHash: String
    let newHash: String
    let fileMode: String
    var addedLines: Int = 0
    var removedLines: Int = 0
}

struct FileSheet: Identifiable {
    let id = UUID()
    let filename: String
    let commitInfo: CommitInfo
    let content: NSAttributedString
}

enum DiffLineType {
    case header
    case addition
    case removal
    case context
    
    var color: String {
        switch self {
        case .addition: return "diffGreen"
        case .removal: return "diffRed"
        case .header: return "diffHeader"
        case .context: return "diffContext"
        }
    }
    
    var darkColor: String {
        switch self {
        case .addition: return "diffGreenDark"
        case .removal: return "diffRedDark"
        case .header: return "diffHeader"
        case .context: return "diffContext"
        }
    }
}
