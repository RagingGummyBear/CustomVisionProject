//
//  DrawUIView.swift
//  CustomVisionProject
//
//  Created by Seavus on 3/29/19.
//  Copyright © 2019 Seavus. All rights reserved.
//

import UIKit

class DrawUIView: UIImageView {

    override func awakeFromNib() {
        super.awakeFromNib()
        self.setupGestureRecognizers()
    }
    
    // MARK: Drawing a path
    override func draw(_ rect: CGRect) {
        // 4. Redraw whole rect, ignoring parameter. Please note we always invalidate whole view.
        let context = UIGraphicsGetCurrentContext()
        self.drawColor.setStroke()
        self.path.lineWidth = self.drawWidth
        self.path.lineCapStyle = .round
//        self.path.lineCapStyle = kCGLineCapRound
        self.path.stroke()
    }
    
    private func drawLine(a: CGPoint, b: CGPoint, buffer: UIImage?) -> UIImage {
        let size = self.bounds.size
        
        // Initialize a full size image. Opaque because we don’t need to draw over anything. Will be more performant.
        UIGraphicsBeginImageContextWithOptions(size, true, 0)
        let context = UIGraphicsGetCurrentContext()!
        
        context.setFillColor(self.backgroundColor?.cgColor ?? UIColor.white.cgColor)
        context.fill(self.bounds)
        
        // Draw previous buffer first
        if let buffer = buffer {
            buffer.draw(in: self.bounds)
        }
        
        // Draw the line
        self.drawColor.setStroke()
        context.setLineWidth(self.drawWidth)
        context.setLineCap(.square)
        
        context.move(to: CGPoint(x: a.x, y: a.y))
        context.addLine(to: CGPoint(x: b.x, y: b.y))
        context.strokePath()
        
        // Grab the updated buffer
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
    
    // MARK: Gestures
    
    private func setupGestureRecognizers() {
        // 1. Set up a pan gesture recognizer to track where user moves finger
        let panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePan(sender:)))
        self.addGestureRecognizer(panRecognizer)
    }
    
    @objc private func handlePan(sender: UIPanGestureRecognizer) {
        let point = sender.location(in: self)
        switch sender.state {
        case .began:
            self.startAtPoint(point: point)
        case .changed:
            self.continueAtPoint(point: point)
        case .ended:
            self.endAtPoint(point: point)
        case .failed:
            self.endAtPoint(point: point)
        default:
//            assert(false, "State not handled”)
//            assert(
            assert(false, "W00w")
        }
    }
    
    // MARK: Tracing a line
    
    private func startAtPoint(point: CGPoint) {
        self.lastPoint = point
    }
    
    private func continueAtPoint(point: CGPoint) {
        autoreleasepool {
            
            // 2. Draw the current stroke in an accumulated bitmap
            self.buffer = self.drawLine(a: self.lastPoint, b: point, buffer: self.buffer)
            
            // 3. Replace the layer contents with the updated image
            self.layer.contents = self.buffer.cgImage ?? nil
            
            // 4. Update last point for next stroke
            self.lastPoint = point
        }
    }
    
    private func endAtPoint(point: CGPoint) {
        self.lastPoint = .zero
    }
    
    var drawColor: UIColor = UIColor.black
    var drawWidth: CGFloat = 10.0
    var lastPoint = CGPoint()
    var buffer = UIImage()
    
    private var path: UIBezierPath = UIBezierPath()
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
