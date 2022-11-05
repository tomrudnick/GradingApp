//
//  GraphViewControllerRepresentable.swift
//  GradingApp
//
//  Created by Tom Rudnick on 04.11.22.
//

import Foundation
import SwiftUI
import UIKit


struct GraphViewControllerReprestable: UIViewControllerRepresentable {
    typealias UIViewControllerType = GraphViewController
    
    @ObservedObject var examVM: ExamViewModel

    func makeUIViewController(context: Context) -> GraphViewController {
        let vc = GraphViewController()
        vc.setupData(data: examVM.gradeSchema, staticData: examVM.standardGradeScheme)
        vc.delegate = context.coordinator
        return vc
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(examVM: examVM)
    }
    
    func updateUIViewController(_ uiViewController: GraphViewController, context: Context) {
        print("update called")
        uiViewController.setupData(data: examVM.gradeSchema, staticData: examVM.standardGradeScheme)
        uiViewController.graphView?.setNeedsDisplay()
    }
    
    class Coordinator: NSObject, GraphViewControllerDelegate {
        var examVM: ExamViewModel
        
        init(examVM: ExamViewModel) {
            self.examVM = examVM
        }
        
        func valueChanged(label: String, data: [GraphData]) {
            let index = self.examVM.gradeSchema.firstIndex { $0.label == label }
            guard let index else { return }
            if self.examVM.gradeSchema[index].value == data[index].value { return }
            withAnimation {
                self.examVM.gradeSchema[index].value = data[index].value
            }
            
            print("Updating Grade Schema")
        }
    }
}
