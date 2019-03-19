//
//  ImageProcessingViewController.swift
//  CustomVisionProject
//
//  Created by Seavus on 2/12/19.
//  Copyright © 2019 Seavus. All rights reserved.
//
// https://www.youtube.com/watch?v=PnJlWXAjXDA
// https://developer.apple.com/documentation/vision/recognizing_objects_in_live_capture
// https://www.youtube.com/watch?v=p6GA8ODlnX0

import UIKit
import AVFoundation
import CoreML
import Vision

class ImageProcessingViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    
    var privateThreadSafeQueue = DispatchQueue.init(label: "com.seavus.imageprocessing.safe")
    var colorHistogramResult = -10.0
    var grayHistogramResult = -10.0

    // MARK: - IBOutlets
    @IBOutlet weak var processingImageView: UIImageView!
    @IBOutlet weak var imageProcessingStatus: UILabel!
    @IBOutlet weak var croppedImage: UIImageView!
    @IBOutlet weak var worstCrop: UIImageView!
    @IBOutlet weak var thresholdSlider: UISlider!
    
    // MARK: - IBOutlet actions
    @IBAction func thresholdSliderAction(_ sender: Any) {
        
        if let img = self.capturedImage {
//            self.processingImageView.image = OpenCVWrapper.draw_contour_python_bound_square(img, withThresh: Int32(self.thresholdSlider!.value))
//            self.processingImageView.image =  OpenCVWrapper.draw_color_mask(img, withBound: self.bestBound, withThresh: Int32(self.thresholdSlider!.value))
//            self.processingImageView.image =  OpenCVWrapper.find_contours(img, withBound: self.bestBound)
//            self.processingImageView.image = OpenCVWrapper.find_contours(img, withBound: self.bestBound, withThreshold: Int32(self.thresholdSlider!.value))
            self.processingImageView.image = OpenCVWrapper.bounding_circles_squares(img, withBound: self.bestBound, withThresh: Int32(self.thresholdSlider!.value))
//                        self.processingImageView.image = OpenCVWrapper.bounding_circles_squares(img, withThresh: Int32(self.thresholdSlider!.value))
            
        }
        // self.processingImageView.image = OpenCVWrapper.find_contours(self.capturedImage!, withThresh: Int32(self.thresholdSlider!.value))
        
    }
    
    // MARK: - Class properties
    @IBInspectable public var capturedImage:UIImage?
    private var cropImage: UIImage!
    private var foundCropBounds: [CGRect] = []
    private var foundCropImages: [UIImage] = []
    private var detectionOverlay: CALayer!
    
    // Maybe some of these will be useful
    private var bestBound: CGRect = CGRect(x: 0.0, y: 0.0, width: 0.0, height: 0.0)
    private var bestClass: String = "Dark-Light"
    private var bestResult = 0.0
    
    var customAnims:ContourLinesCustomAnimation!
    
    // MARK: - View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
//        self.processTheImage()
        DispatchQueue.init(label: "customAnims").async {
//            self.customAnims = ContourLinesCustomAnimation(targetView: self.processingImageView, image: self.capturedImage!)
//            self.customAnims.start()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.processingImageView.image = self.capturedImage
        DispatchQueue.global(qos: .background).async {
            self.findTopBounds()
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
    
    // MARK: - Custom Functions
    
    func findTopBounds(){
        if let image = self.capturedImage {
            let bounds = OpenCVWrapper.contour_python_bound_square(image, withThresh: Int32(10))
            for bound in bounds {
                if let rect = bound as? CGRect {
                    self.foundCropBounds.append(rect)
                } else if let img = bound as? UIImage {
                    self.capturedImage = img
                    DispatchQueue.main.async {
                        self.processingImageView.image = img
                    }
                }
            }
            
            ImageComparator.shared().findBestCropHistogramCompare(originalImage: image, bounds: self.foundCropBounds, completion: { (bestResult: Double, bestClass: String, croppedImage: UIImage, bestBound: CGRect) in
                
//                print("Color histogram result: \(bestResult)")
                DispatchQueue.main.async {
//                    self.processingImageView.image = croppedImage
                    self.croppedImage.image = croppedImage
                }
                self.privateThreadSafeQueue.sync {
                    if self.bestResult < bestResult {
                        self.bestBound = bestBound
                        self.bestClass = bestClass
                        self.bestResult = bestResult
                        
                        DispatchQueue.main.async {
//                            self.processingImageView.image = croppedImage
                        }
                    }
                }
            }) { (msg: String) in
                print(msg)
            }
            
            ImageComparator.shared().findBestCropHistogramGrayCompare(originalImage: image, bounds: self.foundCropBounds, completion: { (bestResult: Double, bestClass: String, croppedImage: UIImage, bestBound: CGRect) in
                
                DispatchQueue.main.async {
                    self.processingImageView.image = croppedImage
                    self.worstCrop.image = croppedImage
                }
                self.privateThreadSafeQueue.sync {
                    if self.bestResult < bestResult {
                        self.bestBound = bestBound
                        self.bestClass = bestClass
                        self.bestResult = bestResult
                        
                        DispatchQueue.main.async {
                            self.processingImageView.image = croppedImage
                        }
                    }
                }
            }) { (msg: String) in
                print(msg)
            }
//            self.findTheBestBound()
        }
    }
    
    // MARK: - MachineLearning
    func processTheImage(){
//        return
        if let image = self.capturedImage {
//            UIGraphicsBeginImageContextWithOptions(CGSize(width: 227, height: 227), true, 2.0)
//            image.draw(in: CGRect(x: 0, y: 0, width: 227, height: 227))

//            UIGraphicsBeginImageContextWithOptions(CGSize(width: 299, height: 299), true, 2.0)
//            image.draw(in: CGRect(x: 0, y: 0, width: 299, height: 299))
            
            UIGraphicsBeginImageContextWithOptions(CGSize(width: 416, height: 416), true, 2.0)
            image.draw(in: CGRect(x: 0, y: 0, width: 416, height: 416))
            
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
            
//            self.processingImageView.image = self.capturedImage

//            guard let model = try? VNCoreMLModel(for: PorscheCoffee().model) else {
//                return
//            }
//
//            let request = VNCoreMLRequest(model: model) { (finishedRequest, error) in
//                if let error = error {
//                    print(error)
//                }
//                self.drawVisionRequestResults(finishedRequest.results!)
//
//                guard let results = finishedRequest.results as? [VNRecognizedObjectObservation] else {
//                    return
//                }
//            }
            
//            let imageRequestHandler = VNImageRequestHandler(cgImage: newImage.cgImage!, options: [:])
//            _ = try? imageRequestHandler.perform([request])
            
        }
    }
    
    func cropImage(imageToCrop:UIImage, toRect rect:CGRect) -> UIImage {
        
        let imageRef:CGImage = imageToCrop.cgImage!.cropping(to: rect)!
        let cropped:UIImage = UIImage(cgImage:imageRef)
        return cropped
    }
    
    func drawVisionRequestResults(_ results: [Any]) {
        CATransaction.begin()
        CATransaction.setValue(kCFBooleanTrue, forKey: kCATransactionDisableActions)
//        detectionOverlay.sublayers = nil // remove all the old recognized objects
        let bufferSize = CGSize(width: capturedImage!.size.width, height: capturedImage!.size.height)
        for observation in results where observation is VNRecognizedObjectObservation {
            guard let objectObservation = observation as? VNRecognizedObjectObservation else {
                continue
            }
            // Select only the label with the highest confidence.
            let topLabelObservation = objectObservation.labels[0]
            let objectBounds = VNImageRectForNormalizedRect(objectObservation.boundingBox, Int(bufferSize.width), Int(bufferSize.height))
            
//            self.croppedImage.image = self.cropImage(imageToCrop: self.capturedImage!, toRect: objectBounds)
            self.cropImage = self.cropImage(imageToCrop: self.capturedImage!, toRect: objectBounds)
            
            let shapeLayer = self.createRoundedRectLayerWithBounds(objectBounds)
            
            let textLayer = self.createTextSubLayerInBounds(objectBounds,
                                                            identifier: topLabelObservation.identifier,
                                                            confidence: topLabelObservation.confidence)
            shapeLayer.addSublayer(textLayer)
        }
        
        self.updateLayerGeometry()
        CATransaction.commit()
    }
    
    func createRoundedRectLayerWithBounds(_ bounds: CGRect) -> CALayer {
        let shapeLayer = CALayer()
        shapeLayer.bounds = bounds
        shapeLayer.position = CGPoint(x: bounds.midX, y: bounds.midY)
        shapeLayer.name = "Found Object"
        shapeLayer.backgroundColor = CGColor(colorSpace: CGColorSpaceCreateDeviceRGB(), components: [1.0, 1.0, 0.2, 0.4])
        shapeLayer.cornerRadius = 7
        return shapeLayer
    }

    
    func updateLayerGeometry() {
        let bounds = self.processingImageView.layer.bounds
        var scale: CGFloat
        let bufferSize = CGSize(width: capturedImage!.size.width, height: capturedImage!.size.height)
        
        let xScale: CGFloat = 1
        let yScale: CGFloat = 1
        
        scale = fmax(xScale, yScale)
        if scale.isInfinite {
            scale = 1.0
        }
        CATransaction.begin()
        CATransaction.setValue(kCFBooleanTrue, forKey: kCATransactionDisableActions)
        
        // rotate the layer into screen orientation and scale and mirror
//        detectionOverlay.setAffineTransform(CGAffineTransform(rotationAngle: CGFloat(.pi / 2.0)).scaledBy(x: scale, y: -scale))
        // center the layer
//        detectionOverlay.position = CGPoint (x: bounds.midX, y: bounds.midY)
        
        CATransaction.commit()
    }
    
    func createTextSubLayerInBounds(_ bounds: CGRect, identifier: String, confidence: VNConfidence) -> CATextLayer {
        let textLayer = CATextLayer()
        textLayer.name = "Object Label"
        let formattedString = NSMutableAttributedString(string: String(format: "\(identifier)\nConfidence:  %.2f", confidence))
        let largeFont = UIFont(name: "Helvetica", size: 24.0)!
        formattedString.addAttributes([NSAttributedString.Key.font: largeFont], range: NSRange(location: 0, length: identifier.count))
        textLayer.string = formattedString
        textLayer.bounds = CGRect(x: 0, y: 0, width: bounds.size.height - 10, height: bounds.size.width - 10)
        textLayer.position = CGPoint(x: bounds.midX, y: bounds.midY)
        textLayer.shadowOpacity = 0.7
        textLayer.shadowOffset = CGSize(width: 2, height: 2)
        textLayer.foregroundColor = CGColor(colorSpace: CGColorSpaceCreateDeviceRGB(), components: [0.0, 0.0, 0.0, 1.0])
        textLayer.contentsScale = 2.0 // retina rendering
        // rotate the layer into screen orientation and scale and mirror
        textLayer.setAffineTransform(CGAffineTransform(rotationAngle: CGFloat(.pi / 2.0)).scaledBy(x: 1.0, y: -1.0))
        return textLayer
    }
    

}
