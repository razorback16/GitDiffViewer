//
//  GitDiffViewerApp.swift
//  GitDiffViewer
//
//  Created by Razorback16 on 2/4/25.
//

import SwiftUI

@main
struct GitDiffViewerApp: App {
    var body: some Scene {
        DocumentGroup(newDocument: GitDiffViewerDocument()) { file in
            ContentView(document: file.$document)
        }
    }
}
