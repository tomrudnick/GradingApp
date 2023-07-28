//
//  TextEditor.swift
//  GradingApp
//
//  Created by Matthias Rudnick on 27.07.23.
//

import Foundation
import UIKit
import SwiftUI

struct TextEditor: UIViewRepresentable {
    typealias UIViewType = UITextView
    
    @Binding var fontSize: CGFloat
    @Binding var message: String
    @Binding var selectionRange: NSRange
    var regex: NSRegularExpression
    

    
    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.font = UIFont.systemFont(ofSize: CGFloat(fontSize))
        textView.attributedText = context.coordinator.generateAttributedString(with: regex, targetString: message)
        textView.delegate = context.coordinator
        return textView
    }
    
    func updateUIView(_ uiView: UITextView, context: Context) {
        if uiView.text != message {
            uiView.attributedText = context.coordinator.generateAttributedString(with: regex, targetString: message)
            uiView.selectedRange.location = selectionRange.location
        }
        uiView.font = UIFont.systemFont(ofSize: CGFloat(fontSize))
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(message: $message, selectionRange: $selectionRange,regex: regex, fontSize: $fontSize)
    }
    
    class Coordinator: NSObject, UITextViewDelegate {
        
        var message: Binding<String>
        var selectionRange: Binding<NSRange>
        var regex: NSRegularExpression
        var fontSize: Binding<CGFloat>
      
        
        
        init(message: Binding<String>, selectionRange: Binding<NSRange>, regex: NSRegularExpression, fontSize: Binding<CGFloat>) {
            self.message = message
            self.selectionRange = selectionRange
            self.regex = regex
            self.fontSize = fontSize
        }
        
        func textViewDidChange(_ textView: UITextView) {
            textView.attributedText = generateAttributedString(with: regex, targetString: textView.text)
            DispatchQueue.main.async {
                self.message.wrappedValue = textView.text
            }
            
        }
        
        func textViewDidChangeSelection(_ textView: UITextView) {
            DispatchQueue.main.async {
                self.selectionRange.wrappedValue = textView.selectedRange
            }
        }
        
        
        func generateAttributedString(with regex: NSRegularExpression, targetString: String) -> NSAttributedString? {

            let attributedString = NSMutableAttributedString(string: targetString, attributes: [.foregroundColor: UIColor.label, .font: UIFont.systemFont(ofSize: fontSize.wrappedValue)])
    
                let range = NSRange(location: 0, length: targetString.utf16.count)
                for match in regex.matches(in: targetString, range: range) {
                    attributedString.addAttribute(.backgroundColor, value: UIColor.systemBlue, range: match.range)
                }
                return attributedString

        }
    }
}

