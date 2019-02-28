//
//  ContourLinesCustomAnimation.swift
//  CustomVisionProject
//
//  Created by Seavus on 2/28/19.
//  Copyright © 2019 Seavus. All rights reserved.
//

import Foundation
import UIKit

class ContourLinesCustomAnimation : CustomAnimation {
    
    var targetImageView: UIImageView!
    var image:UIImage!
    
    private override init(lasting: Double) {
        super.init(lasting: lasting)
    }
    
    public init(targetView: UIImageView, image:UIImage, completion: @escaping ()->() ){
        super.init(lasting: 2.5)
        self.targetImageView = targetView
        self.image = image
        self.completion = completion
    }
    
    public init(targetView: UIImageView, lastingTime: Double){
        super.init(lasting: lastingTime)
        self.targetImageView = targetView
    }
    
    override func makeAnimation(ratio: Double) {
        let tresh = (1 - ratio) * 180
        if tresh < 25 {
            return
        }
        let img = OpenCVWrapper.find_contours(self.image, withThresh: Int32(tresh))
        DispatchQueue.main.sync {
            self.targetImageView.image = img
        }
    }
    
}
