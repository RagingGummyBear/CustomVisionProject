//
//  ProcessingImageViewController.swift
//  CustomVisionProject
//
//  Created by Seavus on 2/25/19.
//  Copyright © 2019 Seavus. All rights reserved.
//

import UIKit

class ProcessingImageViewController: UIViewController {
    
    // MARK: - Custom references and variables
    var privateThreadSafeQueue = DispatchQueue.init(label: "com.seavus.imageprocessing.safe")
    
    var colorHistogramResult = -10.0
    var grayHistogramResult = -10.0
    
    var bestResult = -10.0
    var bestClass = "N/A"
    var bestBound = CGRect(x: 0.0, y: 0.0, width: 0.0, height: 0.0)
    
    var colorHistogramCompareFinished = false
    var grayHistogramCompareFinished = false
    
    var workingImage = UIImage()
    var tempImageHolder = UIImage()
    
    var selectedImageRect = [CGRect]()
    
    var processingStarted = false
    
    var foundClasses = [String]()
    
    // CustomAnimation references
    
    let customAnimationsQueue = DispatchQueue.init(label: "com.seavus.customvision.customAnimationsQueue", attributes: .concurrent)
    
    // MARK: - IBInspectable
    @IBInspectable public var capturedImage:UIImage?
    
    // MARK: - IBOutlet references
    @IBOutlet weak var processingImageView: UIImageView!
    @IBOutlet weak var processingStatusLabel: UILabel!
    @IBOutlet weak var progressBar: UIProgressView!
    
    // MARK: - IBOutlets actions
    
    // MARK: - View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        DispatchQueue.main.async { [unowned self] in
            self.initalUISetup()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        DispatchQueue.main.async { [unowned self] in
            self.finalUISetup()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        self.processingImageView.image = nil
        self.capturedImage = nil
        self.workingImage = UIImage()
        self.tempImageHolder = UIImage()
        
        self.selectedImageRect = []
    }
    
    // MARK: - UI Functions
    func initalUISetup(){
        // Change label's text, etc.
    }
    
    func finalUISetup(){
        // Here do all the resizing and constraint calculations
        // In some cases apply the background gradient here
        if let img = self.capturedImage {
            self.workingImage = img
            self.processingImageView.image = img
            self.startImageProcessing()
        }
    }
    
    // MARK: - Logic functions
    func startImageProcessing(){
        if self.processingStarted {
            return
        }
        self.processingStarted = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [unowned self] in
            self.applyGrayscale()
        }
        self.getOverallRGBClass()
    }
    
    // MARK: - Background processing functions
    func getBestBoundClass(){
        // Classify based on the sizes and location of the best bound
        guard let image = self.capturedImage else {
            return
        }
        
        let centerX = image.size.width / 2
        let centerY = image.size.height / 2
        
        // Size check
        var xSize = 0
        var ySize = 0
        if self.bestBound.size.width > centerX {
            xSize = 1
        } else {
            xSize = -1
        }
        
        if self.bestBound.size.height > centerY {
            ySize = 1
        } else {
            ySize = -1
        }
        
        if xSize > 0 && ySize > 0 {
            // coffee is bigger
            // more focused
            self.foundClasses.append("bound-size-big")
        } else if xSize < 0 && ySize < 0 {
            // coffee is smaller
            // more objective
            self.foundClasses.append("bound-size-small")
        } else {
            // coffee is mixed
            // more creative
            self.foundClasses.append("bound-size-mixed")
        }
        
        // Position check
        
        var xPos = 0
        var yPos = 0
        
        if self.bestBound.origin.x > centerX {
            xPos = 1
        } else {
            xPos = -1
        }
        
        if self.bestBound.origin.y > centerY {
            yPos = 1
        } else {
            yPos = -1
        }
        if xPos > 0 && yPos > 0 {
            // bot right
            self.foundClasses.append("bound-pos-bot-right")
        } else if xPos < 0 && yPos > 0 {
            // bot left
            self.foundClasses.append("bound-pos-bot-left")
        } else if xPos > 0 && yPos < 0 {
            // up right
            self.foundClasses.append("bound-pos-up-right")
        } else if xPos < 0 && yPos < 0 {
            // up left
            self.foundClasses.append("bound-pos-up-left")
        }
        
    }
    
    func getOverallRGBClass(){
        // RGB values based on the whole image
        if let image = self.capturedImage {
            let array = OpenCVWrapper.find_rgb_values(image)
//            print(array)
            
            let blue = array[0] as? Double ?? 0
            let green = array[1] as? Double ?? 0
            let red = array[2] as? Double ?? 0
            
            if blue > green {
                if blue > red {
                    print("Biggest blue: \(blue)")
                    self.foundClasses.append("rgb-full-blue")
                } else {
                    print("Biggest red: \(red)")
                    self.foundClasses.append("rgb-full-red")
                }
            } else {
                if green > red {
                    print("Biggest green: \(green)")
                    self.foundClasses.append("rgb-full-green")
                } else {
                    print("Biggest red: \(red)")
                    self.foundClasses.append("rgb-full-red")
                }
            }
        }
    }
    
    func getPartialRGBClass(){
        // RGB values based on best bound
        if let image = self.capturedImage {
            let array = OpenCVWrapper.find_rgb_values(image,withBound: self.bestBound)
//            print(array)
            
            let blue = array[0] as? Double ?? 0
            let green = array[1] as? Double ?? 0
            let red = array[2] as? Double ?? 0

            if blue > green {
                if blue > red {
                    print("Biggest blue: \(blue)")
                    self.foundClasses.append("rgb-partial-blue")
                } else {
                    print("Biggest red: \(red)")
                    self.foundClasses.append("rgb-partial-red")
                }
            } else {
                if green > red {
                    print("Biggest green: \(green)")
                    self.foundClasses.append("rgb-partial-green")
                } else {
                    print("Biggest red: \(red)")
                    self.foundClasses.append("rgb-partial-red")
                }
            }
        }
    }
    
    func getFullHistogramComparisonClass(){
        // Histogram compare based on whole image
        if let image = self.capturedImage {
            ImageComparator.shared().findBestClassHistogramCompare(image: image, completion: { [unowned self] (result: Double, bestClass: String, bestImage: UIImage) in
                self.foundClasses.append("hist-full-\(bestClass)")
            }, error: nil)
        }
    }
    
    func getPartialHistogramClass(){
        // Histogram compare based on best bound
        if let image = self.capturedImage {
            let croppedImage = ImageComparator.shared().cropImage(imageToCrop: image, toRect: self.bestBound)
            ImageComparator.shared().findBestClassHistogramCompare(image: croppedImage, completion: { [unowned self] (result: Double, bestClass: String, bestImage: UIImage) in
//                self.partialHistogramCompareClass = bestClass
//                print("PartialHistogramCompareClass : \(bestClass)")
                self.foundClasses.append("hist-partial-\(bestClass)")
            }, error: nil)
        }
    }
    
    // MARK: - Animation processing functions
    func applyGrayscale(){
        DispatchQueue.global(qos: .background).async { [unowned self] in
            self.workingImage = OpenCVWrapper.makeGray(self.workingImage)
            DispatchQueue.main.async { [unowned self] in
                self.processingImageView.image = self.workingImage
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: { [unowned self] in
                self.findTopBounds()
            })
        }
    }
    
    func findTopBounds(){
        
        DispatchQueue.global(qos: .background).async { [unowned self] in
            if let image = self.capturedImage {
                let array = OpenCVWrapper.contour_python_bound_square(image, withThresh: Int32(1))
                for elem in array {
                    if let rect = elem as? CGRect {
                        self.selectedImageRect.append(rect)
                    } else if let img = elem as? UIImage {
                        self.workingImage = img
                        DispatchQueue.main.async { [unowned self] in
 
                            self.processingImageView.image = self.workingImage
//                            self.processingImageView.image = self.capturedImage
                        }
                    }
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: { [unowned self] in
                    self.findBestBound()
                })
            }
        }
    }
    
    func findBestBound(){
        // On finish
        // self.applyPartialGrayscale()
        
        
        if let image = self.capturedImage {
            ImageComparator.shared().findBestCropHistogramCompare(originalImage: image, bounds: self.selectedImageRect, completion: { [unowned self] (bestResult: Double, bestClass: String, croppedImage: UIImage, bestBound: CGRect) in
                
                print("Color histogram result: \(bestResult)")
                
                self.privateThreadSafeQueue.sync { [unowned self] in
                    if self.bestResult < bestResult {
                        self.bestBound = bestBound
                        self.bestClass = bestClass
                        self.bestResult = bestResult
                    }
                    DispatchQueue.main.async { [unowned self] in
                        self.processingImageView.image = croppedImage
                    }
                    
                    self.colorHistogramCompareFinished = true
                    
                    if self.grayHistogramCompareFinished {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15, execute: { [unowned self] in
                            self.processingImageView.image = self.workingImage
                            
                            self.getPartialRGBClass()
                            
                            self.getBestBoundClass()
                            
                            self.getFullHistogramComparisonClass()
                            self.getPartialHistogramClass()
                            
                            self.applyPartialGrayscale()
                        })
                    }
                }
            }) { (msg: String) in
                print(msg)
            }
            
            ImageComparator.shared().findBestCropHistogramGrayCompare(originalImage: image, bounds: self.selectedImageRect, completion: { [unowned self] (bestResult: Double, bestClass: String, croppedImage: UIImage, bestBound: CGRect) in
                
                print("Gray histogram result: \(bestResult)")
                DispatchQueue.main.async {
                }
                self.privateThreadSafeQueue.sync { [unowned self] in
                    if self.bestResult < bestResult {
                        self.bestBound = bestBound
                        self.bestClass = bestClass
                        self.bestResult = bestResult
                    }
                    DispatchQueue.main.async { [unowned self] in
                        self.processingImageView.image = croppedImage
                    }
                    
                    self.grayHistogramCompareFinished = true
                    
                    if self.colorHistogramCompareFinished {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15, execute: { [unowned self] in
                            self.processingImageView.image = self.workingImage
                            
                            self.getBestBoundClass()
                            
                            self.getPartialRGBClass()
                            
                            self.getFullHistogramComparisonClass()
                            self.getPartialHistogramClass()
                            
                            self.applyPartialGrayscale()
                        })
                    }
                }
            }) { (msg: String) in
                // Maybe notify the user: Unable to process well
                print(msg)
                self.applyPartialGrayscale()
            }
        }
    }
    
    func applyPartialGrayscale(){
        // On finish
        // self.animatePartialContours()
        print("New pit stop")
        if let image = self.capturedImage {
            DispatchQueue.main.async { [unowned self] in
                self.processingImageView.image = OpenCVWrapper.draw_color_mask(image, withBound: self.bestBound)
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) { [unowned self] in
            self.processingImageView.image = OpenCVWrapper.draw_color_mask(self.workingImage, withBound: self.bestBound)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15, execute: { [unowned self] in
                self.animateFullContours()
            })
        }
    }
    
    func animateFullContours(){
        
        if let image = self.capturedImage {
            let anim = ContourLinesCustomAnimation(targetView: self.processingImageView, image: image, completion: { [unowned self] in
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: { [unowned self] in
                    self.animatePartialContours()
                })
            })
            self.customAnimationsQueue.async {
                anim.start()
            }
        }
    }
    
    
    func animatePartialContours(){
        // On finish
        // self.animateBoundAndCircleContours()
        
        if let image = self.capturedImage {
            let anim = ContourPartialCustomAnimation(targetView: self.processingImageView, image: image, bound: self.bestBound, completion: { [unowned self] in
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: { [unowned self] in
                    self.animateBoundAndCircleContours()
                })
            })
            self.customAnimationsQueue.async {
                anim.start()
            }
        }
    }
    
    func animateBoundAndCircleContours(){
        // On finish
        // self.processingFinished()
        
        if let image = self.capturedImage {
            let anim = ContourBoundCircleCustomAnimation(targetView: self.processingImageView, image: image, completion: { [unowned self] in
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: { [unowned self] in
                    self.processingFinished()
                })
            })
            self.customAnimationsQueue.async {
                anim.start()
            }
        }
    }
    
    func processingFinished(){
        // Check if background finished processing
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [unowned self] in
            self.transitionToFortuneDisplay()
        }
    }
    
    // MARK: - Navigation
    func transitionToFortuneDisplay(){
        let fortuneVC = self.storyboard?.instantiateViewController(withIdentifier: "fortuneViewControllerId") as! YourFortuneViewController
        fortuneVC.capturedImage = self.capturedImage
        fortuneVC.foundClasses = self.foundClasses
        self.navigationController?.pushViewController(fortuneVC, animated: true)
    }
    
    // MARK: - Other functions
}