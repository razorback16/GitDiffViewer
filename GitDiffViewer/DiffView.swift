//
//  GitDiffViewerTests.swift
//  GitDiffViewerTests
//
//  Created by Razorback16 on 2/4/25.
//

import SwiftUI

struct FileSheetView: View {
    let fileSheet: FileSheet
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // File header
            HStack {
                VStack(alignment: .leading) {
                    Text(fileSheet.filename)
                        .font(.system(.title3, design: .monospaced))
                    HStack(spacing: 4) {
                        Text(fileSheet.commitInfo.oldHash)
                            .font(.system(.caption, design: .monospaced))
                            .foregroundStyle(.secondary)
                        Text("→")
                            .foregroundStyle(.secondary)
                        Text(fileSheet.commitInfo.newHash)
                            .font(.system(.caption, design: .monospaced))
                            .foregroundStyle(.secondary)
                        Text(fileSheet.commitInfo.fileMode)
                            .font(.system(.caption, design: .monospaced))
                            .foregroundStyle(.secondary)
                            .padding(.horizontal, 4)
                            .background(.secondary.opacity(0.1))
                            .cornerRadius(4)
                    }
                }
                Spacer()
                // Changes count
                HStack(spacing: 16) {
                    if fileSheet.commitInfo.removedLines > 0 {
                        HStack(spacing: 4) {
                            Text("-")
                            Text("\(fileSheet.commitInfo.removedLines)")
                        }
                        .foregroundColor(.red)
                    }
                    
                    if fileSheet.commitInfo.addedLines > 0 {
                        HStack(spacing: 4) {
                            Text("+")
                            Text("\(fileSheet.commitInfo.addedLines)")
                        }.foregroundColor(.green)
                    }
                }
                .font(.system(.body, design: .monospaced))
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity)
            .background(Color("diffHeader"))
            
            // Diff content
            RichTextView(attributedText: fileSheet.content)
                .lineWrapping(false)
        }
        .background(Color.white)
        .cornerRadius(8)
        .shadow(radius: 2)
        .padding(.horizontal)
        .padding(.vertical, 10)
    }
}

struct DiffView: View {
    let fileSheets: [FileSheet]
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(fileSheets) { fileSheet in
                    FileSheetView(fileSheet: fileSheet)
                }
            }
            .padding(.vertical)
        }
    }
}
