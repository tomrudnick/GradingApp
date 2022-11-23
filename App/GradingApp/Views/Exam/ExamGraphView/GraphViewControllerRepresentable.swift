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
    
    @ObservedObject var exam: Exam

    func makeUIViewController(context: Context) -> GraphViewController {
        let vc = GraphViewController()
        vc.setupData(data: exam.gradeSchemaGraphData, staticData: exam.standardGradeSchemeGraphData)
        vc.delegate = context.coordinator
        return vc
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(exam: exam)
    }
    
    func updateUIViewController(_ uiViewController: GraphViewController, context: Context) {
        uiViewController.setupData(data: exam.gradeSchemaGraphData, staticData: exam.standardGradeSchemeGraphData)
        uiViewController.graphView?.setNeedsDisplay()
    }
    
    class Coordinator: NSObject, GraphViewControllerDelegate {
        var exam: Exam
        
        init(exam: Exam) {
            self.exam = exam
        }
        
        func valueChanged(label: String, data: [GraphData]) {
            let index = self.exam.gradeSchemaGraphData.firstIndex { $0.label == label }
            guard let index else { return }
            if self.exam.gradeSchemaGraphData[index].value == data[index].value { return }
            withAnimation {
                self.exam.gradeSchemaGraphData[index].value = data[index].value
            }
        }
    }
}
