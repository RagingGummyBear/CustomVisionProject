//
//  ViewController.swift
//  CustomVisionProject
//
//  Created by Seavus on 2/12/19.
//  Copyright © 2019 Seavus. All rights reserved.
//

// https://medium.com/@hunter.ley.ward/create-your-own-object-recognizer-ml-on-ios-7f8c09b461a1
// https://medium.com/@junjiwatanabe/how-to-build-real-time-object-recognition-ios-app-ca85c193865a
// https://github.com/Jwata/sushi_detector_dataset

import UIKit

class ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        print("\(OpenCVWrapper.openCVVersionString())")
        
        specialCase()
    }
    
    func specialCase(){
        ImageComparator.shared()
        // MAKING A WILD TEST
        let image = #imageLiteral(resourceName: "light_coffee_1")
        let image2 = #imageLiteral(resourceName: "coffee18")
        print("Normal compare")
        
        let resultColorHist = OpenCVWrapper.compare(usingHistograms: image, with: image2)
        let resultColorGray = OpenCVWrapper.compare(usingGrayScaleHistograms: image, with: image2)
        print("Color result: \(resultColorHist) Gray result: \(resultColorGray)")
//        OpenCVWrapper.compareHistograms(image, with: image2)
        print("Converted compare")
//        let result = OpenCVWrapper.create_histogram_color(image2)
//        print(result);
        // NEEDS BETTER RESULTS
        OpenCVWrapper.compareHistograms(image, withHistogramArray: OpenCVWrapper.create_histogram_color(image2))
        print("Normal compare AGANE!")
        OpenCVWrapper.compare(usingHistograms: image, with: image2)
        
//        print(HistogramHandler.shared().findTheBestClass(image: #imageLiteral(resourceName: "coffee18")))
//        OpenCVWrapper.compareHistograms(OpenCV, with: T##UIImage)
        //
        
//        HistogramHandler.shared().generateHistograms()
    }
    
}

