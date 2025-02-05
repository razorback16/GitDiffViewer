//
//  ContentView.swift
//  GitDiffViewer
//
//  Created by Razorback16 on 2/4/25.
//

import SwiftUI

struct ContentView: View {
    @Binding var document: GitDiffViewerDocument
    
    var fileSheets: [FileSheet] {
        DiffParser.parse(document.text.trimmingCharacters(in: .whitespacesAndNewlines))
    }

    var body: some View {
        DiffView(fileSheets: fileSheets)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    ContentView(document: .constant(GitDiffViewerDocument(text: """
diff --git a/file1.txt b/file1.txt
index 1234567..890abcd 100644
--- a/file1.txt
+++ b/file1.txt
@@ -1,3 +1,3 @@
 Context line
-Removed line
+Added line

diff --git a/file2.txt b/file2.txt
index abcdef0..123456f 100644
--- a/file2.txt
+++ b/file2.txt
@@ -1,2 +1,2 @@
-Old content
+New content
""")))
}
