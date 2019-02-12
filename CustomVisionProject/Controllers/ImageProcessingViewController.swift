//
//  ImageProcessingViewController.swift
//  CustomVisionProject
//
//  Created by Seavus on 2/12/19.
//  Copyright © 2019 Seavus. All rights reserved.
//

import UIKit
import AVFoundation
import CoreML
import Vision

class ImageProcessingViewController: UIViewController {

    // MARK: - IBOutlets
    @IBOutlet weak var processingImageView: UIImageView!
    @IBOutlet weak var imageProcessingStatus: UILabel!
    
    // MARK: - Class properties
    public var capturedImage:UIImage?
    var visionModel = keyboardModel()
    
    
    // MARK: - View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.processTheImage()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let image = self.capturedImage {
            self.processingImageView.image = image
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    // MARK: - MachineLearning
    func processTheImage(){
        
        if let image = self.capturedImage {
            UIGraphicsBeginImageContextWithOptions(CGSize(width: 227, height: 227), true, 2.0)
            image.draw(in: CGRect(x: 0, y: 0, width: 227, height: 227))
            
            let newImage = UIGraphicsGetImageFromCurrentImageContext()!
            UIGraphicsEndImageContext()
            
            let attrs = [kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue, kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue] as CFDictionary
            var pixelBuffer : CVPixelBuffer?
            let status = CVPixelBufferCreate(kCFAllocatorDefault, Int(newImage.size.width), Int(newImage.size.height), kCVPixelFormatType_32ARGB, attrs, &pixelBuffer)
            guard (status == kCVReturnSuccess) else {
                return
            }
            
            CVPixelBufferLockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
            let pixelData = CVPixelBufferGetBaseAddress(pixelBuffer!)
            
            let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
            let context = CGContext(data: pixelData, width: Int(newImage.size.width), height: Int(newImage.size.height), bitsPerComponent: 8, bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer!), space: rgbColorSpace, bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue) //3
            
            context?.translateBy(x: 0, y: newImage.size.height)
            context?.scaleBy(x: 1.0, y: -1.0)
            
            UIGraphicsPushContext(context!)
            newImage.draw(in: CGRect(x: 0, y: 0, width: newImage.size.width, height: newImage.size.height))
            UIGraphicsPopContext()
            CVPixelBufferUnlockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
            
            self.processingImageView.image = newImage
            
            guard let prediction = try? self.visionModel.prediction(data: pixelBuffer!) else {
                return
            }
            
            self.imageProcessingStatus.text = "I think this is a \(prediction.classLabel)."
            
        }
        
    }

}
