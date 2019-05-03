//
//  PhotoDrawingService.swift
//  CustomVisionProject
//
//  Created by Seavus on 4/25/19.
//  Copyright © 2019 Seavus. All rights reserved.
//

import Foundation

class PhotoDrawingService {
    
    var lastPoint: CGPoint = .zero
    var brushWidth: CGFloat = 50.0
    var opacity: CGFloat = 1.0
    var swiped = false
    
    private var boundingRectPointTL = CGPoint(x: 10000, y: 10000)
    private var boundingRectPointDR = CGPoint(x: -1, y: -1)
    
    var drawingColor: UIColor = UIColor(named: "NavigationText")!
    var boundingRectColor: UIColor = UIColor(red: 0.30, green: 1, blue: 0.20, alpha: 1)
    
    func clearAllDrawings() {
        boundingRectPointTL = CGPoint(x: 10000, y: 10000)
        boundingRectPointDR = CGPoint(x: -1, y: -1)
    }
    
    func canFinishDrawing() -> Bool {
        return self.boundingRectPointTL.x != self.boundingRectPointTL.y && self.boundingRectPointDR.y != self.boundingRectPointDR.x
    }
    
    func touchBegin(location: CGPoint){
        self.addedNewPoint(point: location)
        self.lastPoint = location
    }
    
    func touchMoved(location: CGPoint){
        self.addedNewPoint(point: location)
        self.lastPoint = location
    }
    
    func touchEnded(location: CGPoint){
        self.addedNewPoint(point: location)
        self.lastPoint = location
    }
    
    func addedNewPoint(point: CGPoint){
        if (point.x < self.boundingRectPointTL.x){
            self.boundingRectPointTL.x = point.x
        }
        if (point.x > self.boundingRectPointDR.x){
            self.boundingRectPointDR.x = point.x
        }
        if (point.y < self.boundingRectPointTL.y){
            self.boundingRectPointTL.y = point.y
        }
        if (point.y > self.boundingRectPointDR.y){
            self.boundingRectPointDR.y = point.y
        }
    }
    
    func getRect() -> CGRect {
        let width = self.boundingRectPointDR.x - self.boundingRectPointTL.x + self.brushWidth
        let height = self.boundingRectPointDR.y - self.boundingRectPointTL.y + self.brushWidth
        
        return CGRect(x: self.boundingRectPointTL.x - self.brushWidth / 2, y: self.boundingRectPointTL.y - self.brushWidth / 2, width: width, height: height)
    }
    
}
