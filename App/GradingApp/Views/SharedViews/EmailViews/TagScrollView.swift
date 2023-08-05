//
//  TagScrollView.swift
//  GradingApp
//
//  Created by Tom Rudnick on 01.08.23.
//
import SwiftUI

struct TagScrollView<Model: SendEmailProtocol>: View {
    @ObservedObject var emailVM: Model
    @Binding var selectionRange: NSRange
    
    var body: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 20) {
                ForEach(emailVM.emailKeys, id: \.self) { key in
                    Button(action: {
                        replaceSelection(with: key)
                        print(emailVM.emailKeys)
                    }, label: {
                        Text(emailVM.clean(key))
                            .padding()
                            .foregroundColor(.white)
                            .background(Color.blue)
                            .cornerRadius(10.0)
                    })
                }
            }
            .padding()
        }
    }
    
    func replaceSelection(with tag: String) {
        let selectionRange = selectionRange
        let lowerIndex = emailVM.emailText.index(emailVM.emailText.startIndex, offsetBy: selectionRange.lowerBound)
        let upperIndex = emailVM.emailText.index(emailVM.emailText.startIndex, offsetBy: selectionRange.upperBound)
        emailVM.emailText.replaceSubrange(lowerIndex..<upperIndex, with: tag)
        self.selectionRange = NSMakeRange(selectionRange.lowerBound + tag.count + 1, selectionRange.upperBound - selectionRange.lowerBound)
    }
}
