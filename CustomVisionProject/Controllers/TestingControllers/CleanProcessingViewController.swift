//
//  CleanProcessingViewController.swift
//  CustomVisionProject
//
//  Created by Seavus on 2/26/19.
//  Copyright © 2019 Seavus. All rights reserved.
//

import UIKit

class CleanProcessingViewController: UIViewController {
    
    // MARK: - Custom references and variables
    var privateThreadSafeQueue = DispatchQueue.init(label: "com.seavus.imageprocessing.safe")
    
    var colorHistogramResult = -10.0
    var grayHistogramResult = -10.0
    
    var bestResult = -10.0
    var bestClass = "N/A"
    var bestBound = CGRect(x: 0.0, y: 0.0, width: 0.0, height: 0.0)
    var bestImageCrop = UIImage()
    
    var colorHistogramCompareFinished = false
    var grayHistogramCompareFinished = false
    
    var workingImage = UIImage()
    
    var selectedImageRect = [CGRect]()
    
    var fullHistogramCompareClass = "N/A"
    var partialHistogramCompareClass = "N/A"
    
    // MARK: - IBInspectable
    @IBInspectable public var capturedImage:UIImage?

    // MARK: - IBOutlets references
    @IBOutlet weak var processingImageView: UIImageView!
    // MARK: - IBOutlets actions
    
    // MARK: - View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        if let img = self.capturedImage {
            self.workingImage = img
        }
        DispatchQueue.main.async {
            self.initalUISetup()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        DispatchQueue.main.async {
            self.finalUISetup()
        }
    }
    
    // MARK: - UI Functions
    func initalUISetup(){
        // Change label's text, etc.
        if let img = self.capturedImage {
            self.processingImageView.image = img
            self.startImageProcessing()
        }
    }
    
    func finalUISetup(){
        // Here do all the resizing and constraint calculations
        // In some cases apply the background gradient here
    }
    
    // MARK: - Logic functions
    func startImageProcessing(){
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.applyGrayscale()
        }
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
        } else if xSize < 0 && ySize < 0 {
            // coffee is smaller
            // more objective
        } else {
            // coffee is mixed
            // more creative
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
        } else if xPos < 0 && yPos > 0 {
            // bot left
        } else if xPos > 0 && yPos < 0 {
            // up right
        } else if xPos < 0 && yPos < 0 {
            // up left
        }
        
    }
    
    func getOverallRGBClass(){
        // RGB values based on the whole image
        if let image = self.capturedImage {
            let array = OpenCVWrapper.find_rgb_values(image)
            print(array)
            
            let blue = array[0] as? Double ?? 0
            let green = array[1] as? Double ?? 0
            let red = array[2] as? Double ?? 0
            
            if blue > green {
                if blue > red {
                    print("Biggest blue: \(blue)")
                } else {
                    print("Biggest red: \(red)")
                }
            } else {
                if green > red {
                    print("Biggest green: \(green)")
                } else {
                    print("Biggest red: \(red)")
                }
            }
        }
    }
    
    func getPartialRGBClass(){
        // RGB values based on best bound
        if let image = self.capturedImage {
            let array = OpenCVWrapper.find_rgb_values(image,withBound: self.bestBound)
            print(array)
            
            let blue = array[0] as? Double ?? 0
            let green = array[1] as? Double ?? 0
            let red = array[2] as? Double ?? 0
            
            if blue > green {
                if blue > red {
                    print("Biggest blue: \(blue)")
                } else {
                    print("Biggest red: \(red)")
                }
            } else {
                if green > red {
                    print("Biggest green: \(green)")
                } else {
                    print("Biggest red: \(red)")
                }
            }
        }
    }
    
    func getFullHistogramComparisonClass(){
        // Histogram compare based on whole image
        if let image = self.capturedImage {
            ImageComparator.shared().findBestClassHistogramCompare(image: image, completion: { (result: Double, bestClass: String, bestImage: UIImage) in
                self.fullHistogramCompareClass = bestClass
                print("FullHistogramCompareClass : \(bestClass)")
            }, error: nil)
        }
    }
    
    func getPartialHistogramClass(){
        // Histogram compare based on best bound
        if let image = self.capturedImage {
            let croppedImage = CustomUtility.cropImage(imageToCrop: image, toRect: self.bestBound)
            ImageComparator.shared().findBestClassHistogramCompare(image: croppedImage, completion: { (result: Double, bestClass: String, bestImage: UIImage) in
                self.partialHistogramCompareClass = bestClass
                print("PartialHistogramCompareClass : \(bestClass)")
            }, error: nil)
        }
    }
    
    // MARK: - Animation processing functions
    func applyGrayscale(){
        // On finish
        // self.findTopBounds()
        DispatchQueue.global(qos: .background).async {
            self.workingImage = OpenCVWrapper.makeGray(self.workingImage)
            DispatchQueue.main.async {
                self.processingImageView.image = self.workingImage
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: {
                self.findTopBounds()
            })
        }
    }
    
    func findTopBounds(){
        // On finish
        // self.findBestBound()
        DispatchQueue.global(qos: .background).async {
            if let image = self.capturedImage {
                let array = OpenCVWrapper.contour_python_bound_square(image, withThresh: Int32(1))
                for elem in array {
                    if let rect = elem as? CGRect {
                        self.selectedImageRect.append(rect)
                    } else if let img = elem as? UIImage {
                        self.workingImage = img
                        DispatchQueue.main.async {
                            self.processingImageView.image = img
                        }
                    }
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: {
                    self.findBestBound()
                })
            }
        }
    }
    
    func findBestBound(){
        // On finish
        // self.applyPartialGrayscale()
        print("HERE WE STOP FOR NOW")
        print("We shall continiue")
        
        
        if let image = self.capturedImage {
            ImageComparator.shared().findBestCropHistogramCompare(originalImage: image, bounds: self.selectedImageRect, completion: { (bestResult: Double, bestClass: String, croppedImage: UIImage, bestBound: CGRect) in
                
                print("Color histogram result: \(bestResult)")

                self.privateThreadSafeQueue.sync {
                    if self.bestResult < bestResult {
                        self.bestBound = bestBound
                        self.bestClass = bestClass
                        self.bestResult = bestResult
                    }
                    DispatchQueue.main.async {
                        self.processingImageView.image = croppedImage
                    }
                    self.colorHistogramCompareFinished = true
                    
                    if self.grayHistogramCompareFinished {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15, execute: {
                            self.processingImageView.image = self.workingImage
                            
                            self.getPartialRGBClass()
                            
                            
                            self.getFullHistogramComparisonClass()
                            self.getPartialHistogramClass()
                            
                            self.applyPartialGrayscale()
                        })
                    }
                }
            }) { (msg: String) in
                print(msg)
            }
            
            ImageComparator.shared().findBestCropHistogramGrayCompare(originalImage: image, bounds: self.selectedImageRect, completion: { (bestResult: Double, bestClass: String, croppedImage: UIImage, bestBound: CGRect) in
                
                print("Gray histogram result: \(bestResult)")
                DispatchQueue.main.async {
                }
                self.privateThreadSafeQueue.sync {
                    if self.bestResult < bestResult {
                        self.bestBound = bestBound
                        self.bestClass = bestClass
                        self.bestResult = bestResult
                    }
                    DispatchQueue.main.async {
                        self.processingImageView.image = croppedImage
                    }
                    self.grayHistogramCompareFinished = true
                    
                    if self.colorHistogramCompareFinished {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15, execute: {
                            self.processingImageView.image = self.workingImage
                            
                            self.getPartialRGBClass()
                            
                            self.getFullHistogramComparisonClass()
                            self.getPartialHistogramClass()
                            
                            self.applyPartialGrayscale()
                        })
                    }
                }
            }) { (msg: String) in
                print(msg)
            }
        }
    }
    
    func applyPartialGrayscale(){
        // On finish
        // self.animatePartialContours()
        print("New pit stop")
        if let image = self.capturedImage {
            self.processingImageView.image = OpenCVWrapper.draw_color_mask(image, withBound: self.bestBound)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            self.processingImageView.image = OpenCVWrapper.draw_color_mask(self.workingImage, withBound: self.bestBound)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15, execute: {
                self.animateFullContours()
            })
        }
    }
    
    func animateFullContours(){
        var threshold = 256
        DispatchQueue.global(qos: .background).async {
            if let image = self.capturedImage {
                for i in (0...((256/30) - 2)) {
                    DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + 0.2 * Double(i), execute: {
                        threshold -= 20
                        DispatchQueue.main.async {
                            self.processingImageView.image = OpenCVWrapper.find_contours(image, withThresh: Int32(threshold))
                        }
                        
                        if threshold == 116 {
                            self.workingImage = OpenCVWrapper.find_contours(self.workingImage, withThresh: Int32(threshold))
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
                                self.animatePartialContours()
                            })
                        }
                    })
                }
            }
        }
    }
    
    
    func animatePartialContours(){
        // On finish
        // self.animateBoundAndCircleContours()
        var threshold = 256
        
        DispatchQueue.global(qos: .background).async {
            if let img = self.capturedImage {
                for i in (0...((256/20) - 2)) {
                    //                    print("I : \(i) + value: \(threshold -= 20)")
                    DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + 0.2 * Double(i), execute: {
                        threshold -= 20
                        DispatchQueue.main.async {
                            self.processingImageView.image = OpenCVWrapper.find_contours(img, withBound: self.bestBound, withThreshold: Int32(threshold))
                        }
                        
                        if threshold < 37 {
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
                                //                                self.animateFullContours()
                                self.animateBoundAndCircleContours()
                            })
                        }
                    })
                }
            }
        }
    }
    
    func animateBoundAndCircleContours(){
        // On finish
        // self.processingFinished()
        
        var threshold = 256
        
        if let image = self.capturedImage {
            
            for i in (0...((256/20) - 2)) {
                DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + 0.2 * Double(i), execute: {
                    threshold -= 20
                    DispatchQueue.main.async {
                        self.processingImageView.image = OpenCVWrapper.bounding_circles_squares(image, withThresh: Int32(threshold))
                    }
                    if threshold < 37 {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
                            self.processingImageView.image = image
                            self.processingFinished()
                        })
                    }
                })
            }
        }
    }
    
    func processingFinished(){
        // Check if background finished processing
    }
    
    // MARK: - Navigation
    /*
    func transitionToNextViewController(){
     if let nextViewController = self.storyboard?.instantiateViewController(withIdentifier: "ViewControllerIdentifier") as? UIViewController {
         self.navigationController?.pushViewController(nextViewController, animated: true)
     }
    }
     */
    /*
    func transitionBackMultiple() {
        let viewControllers: [UIViewController] = self.navigationController!.viewControllers as [UIViewController]
        self.navigationController!.popToViewController(viewControllers[viewControllers.count - 3], animated: true)
    }
    */

    // MARK: - Other functions
}
