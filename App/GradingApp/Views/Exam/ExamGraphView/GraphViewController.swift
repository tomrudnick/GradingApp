//
//  GraphViewController.swift
//  GradingApp
//
//  Created by Tom Rudnick on 04.11.22.
//

import UIKit

protocol GraphViewControllerDelegate {
    func valueChanged(label: String, data: [GraphData])
}

class GraphViewController: UIViewController, GraphViewDelegate {
    
    var graphView: GraphView?
    var delegate: GraphViewControllerDelegate?
   
    var data: [GraphData] = []

    func setupData(data: [GraphData]) {
        self.data = data
        graphView?.setNeedsDisplay()
    }
    
    func valueChanged(label: String) {
        delegate?.valueChanged(label: label, data: data)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let x: CGFloat = 10
        let y: CGFloat = 50
        let width = self.view.frame.width
        let height = self.view.frame.height
        
        graphView = GraphView(frame: CGRect(x: x, y: y, width: width-x*2, height: height * 0.8), delegate: self)

        self.view.addSubview(graphView!)
    }
    
    override func viewDidLayoutSubviews() {
        let x: CGFloat = 10
        let y: CGFloat = 50
        let width = self.view.frame.width
        let height = self.view.frame.height
        graphView?.frame = CGRect(x: x, y: y, width: width-x*2, height: height * 0.8)
        graphView?.setNeedsDisplay()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
