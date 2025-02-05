//
//  RichTextView.swift
//  TestApp
//
//  Created by Razorback16 on 2/4/25.
//

import SwiftUI
import AppKit

// MARK: - IntrinsicHeightScrollView
class IntrinsicHeightScrollView: NSScrollView {
    override var intrinsicContentSize: NSSize {
        guard let textView = documentView as? NSTextView,
              let textContainer = textView.textContainer,
              let layoutManager = textView.layoutManager else {
            return super.intrinsicContentSize
        }
        layoutManager.ensureLayout(for: textContainer)
        let usedRect = layoutManager.usedRect(for: textContainer)
        let inset = textView.textContainerInset
        return NSSize(width: NSView.noIntrinsicMetric,
                      height: usedRect.height + inset.height * 2)
    }
}

// MARK: - RichTextEditor
struct RichTextView: NSViewRepresentable {
    var attributedText: NSAttributedString

    // Configuration properties
    var isLineWrappingEnabled: Bool = true
    var fontSize: CGFloat = 14
    var backgroundColor: NSColor = .white

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeNSView(context: Context) -> IntrinsicHeightScrollView {
        let scrollView = IntrinsicHeightScrollView()
        scrollView.hasVerticalScroller = false
        scrollView.hasHorizontalScroller = false
        scrollView.drawsBackground = false
        
        let textView = NSTextView()
        textView.delegate = context.coordinator
        textView.isRichText = true
        textView.importsGraphics = true
        textView.drawsBackground = true
        textView.backgroundColor = backgroundColor
        textView.textContainerInset = NSSize(width: 8, height: 8)
        textView.textContainer?.lineFragmentPadding = 0
        
        // Enable vertical resizing and set the autoresizing mask.
        textView.isVerticallyResizable = true
        textView.autoresizingMask = [.width]
        
        // Set the text color explicitly (optional but useful).
        textView.textColor = .labelColor
        
        // Configure line wrapping.
        if isLineWrappingEnabled {
            textView.isHorizontallyResizable = false
            textView.textContainer?.widthTracksTextView = true
            // No need to set containerSize here; let it track the text view’s width.
        } else {
            textView.isHorizontallyResizable = true
            textView.textContainer?.widthTracksTextView = false
            textView.textContainer?.containerSize = NSSize(width: CGFloat.greatestFiniteMagnitude,
                                                           height: CGFloat.greatestFiniteMagnitude)
        }
        
        // Set the font.
        textView.font = NSFont.systemFont(ofSize: fontSize)
        
        // Set the initial text.
        textView.textStorage?.setAttributedString(attributedText)
        
        scrollView.documentView = textView
        
        return scrollView
    }
    
    func updateNSView(_ nsView: IntrinsicHeightScrollView, context: Context) {
        guard let textView = nsView.documentView as? NSTextView else { return }
        
        textView.isEditable = false
        
        if textView.font?.pointSize != fontSize {
            textView.font = NSFont.systemFont(ofSize: fontSize)
        }
        
        if isLineWrappingEnabled {
            textView.isHorizontallyResizable = false
            textView.textContainer?.widthTracksTextView = true
        } else {
            textView.isHorizontallyResizable = true
            textView.textContainer?.widthTracksTextView = false
            textView.textContainer?.containerSize = NSSize(width: CGFloat.greatestFiniteMagnitude,
                                                           height: CGFloat.greatestFiniteMagnitude)
        }
        
        // Update the text if it has changed.
        if textView.attributedString() != attributedText {
            textView.textStorage?.setAttributedString(attributedText)
        }
    }
    
    class Coordinator: NSObject, NSTextViewDelegate {
        var parent: RichTextView
        
        init(_ parent: RichTextView) {
            self.parent = parent
        }
        
        func textDidChange(_ notification: Notification) {
            guard let textView = notification.object as? NSTextView else { return }
            DispatchQueue.main.async {
                self.parent.attributedText = textView.attributedString()
            }
        }
    }
}

// MARK: - Modifiers
extension RichTextView {
    func lineWrapping(_ enabled: Bool) -> RichTextView {
        var copy = self
        copy.isLineWrappingEnabled = enabled
        return copy
    }
    
    func fontSize(_ size: CGFloat) -> RichTextView {
        var copy = self
        copy.fontSize = size
        return copy
    }
    
    func backgroundColor(_ color: NSColor) -> RichTextView {
        var copy = self
        copy.backgroundColor = color
        return copy
    }
}
