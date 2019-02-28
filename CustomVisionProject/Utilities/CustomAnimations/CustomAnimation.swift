//
//  CustomAnimation.swift
//  CustomVisionProject
//
//  Created by Seavus on 2/28/19.
//  Copyright © 2019 Seavus. All rights reserved.
//

import Foundation
import QuartzCore

class CustomAnimation {
    private var updater: CADisplayLink!
    private var lastingTime = 3.0 // In milisec
    private var passedTime = 0.0
    private var previousTick:TimeInterval!
  //                             ______________
  //                            |              |
     internal var completions:  [  (() -> ())  ]      = []
  //                            |    \____/    |
  //                             --------------
    
     internal var completion: (() -> ())?
    
    internal init(){
        
    }
    
    internal init(lasting: Double){
        self.lastingTime = lasting
    }
    
    public func start(){
        self.updater = CADisplayLink(target: self, selector: #selector(self.tick))
        self.updater.preferredFramesPerSecond = 50
        self.updater.add(to: .current, forMode: .common)
        self.previousTick = self.updater.timestamp
        RunLoop.current.run()
    }
    
    public func stop(){
        self.updater.invalidate()
        self.updater.remove(from: .current, forMode: .common)
        self.updater = nil
        if let completion = self.completion {
            completion()
        }
    }
    
    @objc private func tick(){
        CACurrentMediaTime()
        if self.previousTick != 0 {
            self.passedTime += self.updater.timestamp - self.previousTick
//            print("Should print")
            self.makeAnimation(ratio: (self.passedTime / self.lastingTime))
            
        }
        
        self.previousTick = self.updater.timestamp
        
        
        if self.passedTime >= self.lastingTime {
            self.stop()
        }
    }
    
    internal func makeAnimation(ratio: Double){
        
    }
    
}
