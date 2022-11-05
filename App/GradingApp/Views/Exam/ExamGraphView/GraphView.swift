//
//  GraphView.swift
//  GradingApp
//
//  Created by Tom Rudnick on 04.11.22.
//

import UIKit
import QuartzCore

protocol GraphViewDelegate {
    var data: [GraphData] { get set }
    var staticData: [GraphData] { get }
    func valueChanged(label: String)
}

class GraphView: UIView {
    
    private var oldTouchPostion: CGPoint = CGPoint(x: 0.0, y: 0.0)
    private var dataPositions = [String: CGRect]()
    private var selectedData: String?
    
    private var context : CGContext?
    
    private let padding     : CGFloat = 30
    private var graphWidth  : CGFloat = 0
    private var graphHeight : CGFloat = 0
    private var axisWidth   : CGFloat = 0
    private var axisHeight  : CGFloat = 0
    private var everest     : CGFloat = 0
    private var firstSetup = true
    
    // Graph Styles
    var showLines   = true
    var showPoints  = true
    var linesColor  = UIColor.lightGray
    var graphColor  = UIColor.black
    var graphColorDarkMode = UIColor.white
    
    var staticGraphColor = UIColor.green
    
    var labelFont   = UIFont.systemFont(ofSize: 10)
    var labelColor  = UIColor.black
    
    var xAxisColor  = UIColor.black
    var yAxisColor  = UIColor.black
    var xAxisColorDarkMode = UIColor.white
    var yAxisColorDarkMode = UIColor.white
    
    var xMargin         : CGFloat = 20
    var originLabelText : String?
    var originLabelColor = UIColor.black
    
   
    var yStepSize = 10
    
    var delegate: GraphViewDelegate!
    
    
    required init(coder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    init(frame: CGRect, delegate: GraphViewDelegate) {
        
        super.init(frame: frame)
        backgroundColor = UIColor.clear
        self.delegate = delegate        
    }
    
    func getDataForSelectedPoints(point: CGPoint) -> String? {
        for (data, rect) in dataPositions {
            print("Iterating: \(data) \(rect) at position: \(point)")
            if point.x <= rect.maxX && point.x >= rect.minX && point.y <= rect.maxY && point.y >= rect.minY {
                return data
            }
        }
        return nil
    }
    
    private func calcMinValue(for index: Int) -> CGFloat {
        index == 0 ? 0.0 : delegate.data[index - 1].value
    }
    
    private func calcMaxValue(for index: Int) -> CGFloat {
        index == delegate.data.count - 1 ? 100.0 : delegate.data[index + 1].value
    }
    
    private func getGraphColor() -> CGColor {
        if traitCollection.userInterfaceStyle == .dark {
            return graphColorDarkMode.cgColor
        } else {
            return graphColor.cgColor
        }
    }
    
    private func getStaticGraphColor() -> CGColor {
        return staticGraphColor.cgColor
    }
    
    private func getXAxisColor() -> CGColor {
        return traitCollection.userInterfaceStyle == .dark ? xAxisColorDarkMode.cgColor : xAxisColor.cgColor
    }
    
    private func getYAxisColor() -> CGColor {
        return traitCollection.userInterfaceStyle == .dark ? yAxisColorDarkMode.cgColor : yAxisColor.cgColor
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let currentPoint = touch.location(in: self)
        self.oldTouchPostion = currentPoint
        self.selectedData = getDataForSelectedPoints(point: currentPoint)
        print("Selected: Point \(selectedData ?? "none")")
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first, let selectedData else { return }
        let currentPoint = touch.location(in: self)
        let yOffset = currentPoint.y - oldTouchPostion.y
        oldTouchPostion = currentPoint
        let index = self.delegate.data.firstIndex { $0.label == selectedData }
        self.delegate.data[index!].value += yOffset / (frame.height - 30) * -100
        let minValue = calcMinValue(for: index!)
        if self.delegate.data[index!].value < minValue {
            self.delegate.data[index!].value = minValue
        }
        let maxValue = calcMaxValue(for: index!)
        if self.delegate.data[index!].value > maxValue {
            self.delegate.data[index!].value = maxValue
        }
        
        self.delegate.data[index!].rounding025()
        
        setNeedsDisplay()
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let selectedData else { return }
        delegate.valueChanged(label: selectedData)
        self.selectedData = nil
        setNeedsDisplay()
    }
    
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        context = UIGraphicsGetCurrentContext()

        // Graph size
        graphWidth = (rect.size.width - padding) - 10
        graphHeight = rect.size.height - 40
        axisWidth = rect.size.width - 10
        axisHeight = (rect.size.height - padding) - 10
        
        everest = 100 ///Since we always want a scale from 0 to 100% this value is fixed
        
        // Draw graph X-AXIS
        let xAxisPath = CGMutablePath()
        xAxisPath.move(to: CGPoint(x: padding, y: rect.size.height - 31))
        xAxisPath.addLine(to: CGPoint(x: axisWidth, y: rect.size.height - 31))
        context!.addPath(xAxisPath)
        
        context!.setStrokeColor(getXAxisColor())
        context!.strokePath()
        
        // Draw graph Y-AXIS
        let yAxisPath = CGMutablePath()
        yAxisPath.move(to: CGPoint(x: padding, y: 10))
        yAxisPath.addLine(to: CGPoint(x: padding, y: rect.size.height - 31))
        context!.addPath(yAxisPath)
        
        context!.setStrokeColor(getYAxisColor())
        context!.strokePath()
        
        // Draw y axis labels and lines
        let yLabelInterval : Int = Int(everest / CGFloat(yStepSize))
        for i in 0...yStepSize {
            
            let position = CGPoint(x: 0.0, y: floor((rect.size.height - padding) - CGFloat(i) * (axisHeight / CGFloat(yStepSize)) - 10))
            drawText(in: context!, at: position, text: String(format: "%d", i * yLabelInterval), size: 10.0)
            
            if(showLines && i != 0) {
                let line = CGMutablePath()
                line.move(to: CGPoint(x: padding + 1, y: floor(rect.size.height - padding) - (CGFloat(i) * (axisHeight / CGFloat(yStepSize)))))
                line.addLine(to: CGPoint(x: axisWidth, y: floor(rect.size.height - padding) - (CGFloat(i) * (axisHeight / CGFloat(yStepSize)))))
                context!.addPath(line)
                context!.setLineWidth(1)
                context!.setStrokeColor(linesColor.cgColor)
                context!.strokePath()
            }
        }
        
        
        drawStaticPath()
        drawResizablePath()
        
        firstSetup = false
    }
    
    func drawText(in ctx: CGContext, at pos: CGPoint, text: String, size: CGFloat = 25.0) {
        ctx.saveGState()
        let font = UIFont.systemFont(ofSize: size)
        let string = NSAttributedString(string: text,
                                        attributes: [
                                                    NSAttributedString.Key.font: font,
                                                    NSAttributedString.Key.foregroundColor: UIColor(cgColor: getGraphColor())
                                                    ]
                                        )
        string.draw(at: pos)
        ctx.restoreGState()
    }
    
    private func drawResizablePath() {
        let pointPath = CGMutablePath()
        let firstPoint = delegate.data[0].value
        let initialY : CGFloat = ceil((CGFloat(firstPoint) * (axisHeight / everest))) - 10
        let initialX : CGFloat = padding + xMargin
        pointPath.move(to: CGPoint(x: initialX, y: graphHeight - initialY))
        
        // Loop over the remaining values
        for (_, value) in delegate.data.enumerated() {
            // Draw every point
            let pointPos = plotPoint(point: value, data: delegate.data, path: pointPath)
            dataPositions[value.label] = pointPos
            context?.addEllipse(in: pointPos)
            context?.setStrokeColor(getGraphColor())
            context?.setFillColor(getGraphColor())
            context?.drawPath(using: .fillStroke)
            context?.strokePath()
        }
        drawPath(path: pointPath, color: getGraphColor())
    }
    
    private func drawStaticPath() {
        let pointPath = CGMutablePath()
        let firstPoint = delegate.staticData[0].value
        let initialY : CGFloat = ceil((CGFloat(firstPoint) * (axisHeight / everest))) - 10
        let initialX : CGFloat = padding + xMargin
        pointPath.move(to: CGPoint(x: initialX, y: graphHeight - initialY))
        
        // Loop over the remaining values
        for (_, value) in delegate.staticData.enumerated() {
            // Draw every point
            let pointPos = plotPoint(point: value, data: delegate.staticData, path: pointPath, staticPath: true)
            context?.addEllipse(in: pointPos)
            context?.setStrokeColor(getStaticGraphColor())
            context?.setFillColor(getStaticGraphColor())
            context?.drawPath(using: .fillStroke)
            context?.strokePath()
        }
        drawPath(path: pointPath, color: getStaticGraphColor())
    }
    
    private func drawPath(path: CGMutablePath, color: CGColor) {
        context!.addPath(path)
        context!.setLineWidth(2)
        context!.setStrokeColor(color)
        context!.strokePath()
    }
    
    
    // Plot a point on the graph
    func plotPoint(point : GraphData, data: [GraphData], path: CGMutablePath, staticPath: Bool = false) -> CGRect {
        
        // work out the distance to draw the remaining points at
        let interval = Int(graphWidth - xMargin * 2) / (data.count - 1);
        
        let pointValue = point.value
        
        // Calculate X and Y positions
        let yposition : CGFloat = ceil((CGFloat(pointValue) * (axisHeight / everest))) - 10
    
        var index = 0
        for (ind, graphData) in data.enumerated() {
            if point.value == graphData.value && point.label == graphData.label {
                index = ind
            }
        }
        let xposition = CGFloat(interval * index) + padding + xMargin
        
        // Draw line to this value
        path.addLine(to: CGPoint(x: xposition, y: graphHeight - yposition))
        
        if !staticPath {
            drawText(in: context!, at: CGPoint(x: xposition, y: graphHeight + 20), text: point.label, size: 10.0)
        }
        
        if !staticPath {
            drawText(in: context!,
                     at: CGPoint(x: xposition - 30.0, y: graphHeight - yposition + 8),
                     text: String(format: "%.2f",point.value))
        } else {
            drawText(in: context!,
                     at: CGPoint(x: xposition - 30.0, y: 0.0),
                     text: String(format: "%.2f",point.value))
        }
        
        return CGRect(x: xposition - 8, y: CGFloat(ceil(graphHeight - yposition) - 8), width: 16, height: 16)
    }
}
