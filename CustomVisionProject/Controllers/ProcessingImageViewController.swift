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
    
    public var foundClasses = [String]()
    public var parentReturn : (([String]) -> ())?
    
    // CustomAnimation references
    
    let customAnimationsQueue = DispatchQueue.init(label: "com.seavus.customvision.customAnimationsQueue", attributes: .concurrent)

    public var capturedImage:UIImage?
    
    // MARK: - IBOutlet references
    @IBOutlet weak var processingImageView: UIImageView!
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var splashScreenUIImage: UIImageView!
    @IBOutlet weak var processingStatusLabel: UILabel!
    @IBOutlet weak var progressBar: UIProgressView!
    
    // MARK: - IBOutlets actions
    
    // MARK: - View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        ImageComparator.shared().fillUpAll()
        self.progressBar.progress = (0.0)
        self.navigationItem.setHidesBackButton(true, animated: false)
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
    }
    
    override func willMove(toParent parent: UIViewController?) {
        super.willMove(toParent:parent)
        if parent == nil {
            self.navigationController?.setNavigationBarHidden(true, animated: false)
        }
    }
    
    
    // MARK: - UI Functions
    func initalUISetup(){
        // Change label's text, etc.
        var bundlePath = Bundle.main.path(forResource: "coffeeOwl", ofType: "jpg")
        self.splashScreenUIImage.image = UIImage(contentsOfFile: bundlePath!)
        
        bundlePath = Bundle.main.path(forResource: "blackSteamy", ofType: "jpg")
        self.backgroundImageView.image = UIImage(contentsOfFile: bundlePath!)
    }
    
    func finalUISetup(){
        // Here do all the resizing and constraint calculations
        // In some cases apply the background gradient here
        if let img = self.capturedImage {
            self.workingImage = img
            self.processingImageView.image = img
            UIView.transition(with: self.splashScreenUIImage, duration: 0.3, options: .transitionFlipFromTop, animations: {
                self.splashScreenUIImage.alpha = 0
            }, completion: { (completed: Bool) in
                self.splashScreenUIImage.image = nil
            })
            self.startImageProcessing()
        } else {
            self.backToMainMenu()
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
        
        DispatchQueue.main.async {
            self.progressBar.progress += 0.07
        }
        
    }
    
    func getOverallRGBClass(){
        // RGB values based on the whole image
        if let image = self.capturedImage {
            let array = OpenCVWrapper.find_rgb_values(image)
            
            let blue = array[0] as? Double ?? 0
            let green = array[1] as? Double ?? 0
            let red = array[2] as? Double ?? 0
            
            if blue > green {
                if blue > red {
//                    print("Biggest blue: \(blue)")
                    self.foundClasses.append("rgb-full-blue")
                } else {
//                    print("Biggest red: \(red)")
                    self.foundClasses.append("rgb-full-red")
                }
            } else {
                if green > red {
//                    print("Biggest green: \(green)")
                    self.foundClasses.append("rgb-full-green")
                } else {
//                    print("Biggest red: \(red)")
                    self.foundClasses.append("rgb-full-red")
                }
            }
        }
        
        DispatchQueue.main.async {
            self.progressBar.progress += 0.07
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
//                    print("Biggest blue: \(blue)")
                    self.foundClasses.append("rgb-partial-blue")
                } else {
//                    print("Biggest red: \(red)")
                    self.foundClasses.append("rgb-partial-red")
                }
            } else {
                if green > red {
//                    print("Biggest green: \(green)")
                    self.foundClasses.append("rgb-partial-green")
                } else {
//                    print("Biggest red: \(red)")
                    self.foundClasses.append("rgb-partial-red")
                }
            }
        }
        
        DispatchQueue.main.async {
            self.progressBar.progress += 0.07
        }
    }
    
    func getFullHistogramComparisonClass(){
        // Histogram compare based on whole image
        if let image = self.capturedImage {
            ImageComparator.shared().findBestClassHistogramCompare(image: image, completion: { [unowned self] (result: Double, bestClass: String, bestImage: UIImage) in
                self.foundClasses.append("hist-full-\(bestClass)")
                
                DispatchQueue.main.async {
                    self.progressBar.progress += 0.07
                }
            }, error: nil)
        }
    }
    
    func getPartialHistogramClass(){
        // Histogram compare based on best bound
        if let image = self.capturedImage {
            let croppedImage = CustomUtility.cropImage(imageToCrop: image, toRect: self.bestBound)
            ImageComparator.shared().findBestClassHistogramCompare(image: croppedImage, completion: { [unowned self] (result: Double, bestClass: String, bestImage: UIImage) in
                self.foundClasses.append("hist-partial-\(bestClass)")
                
                DispatchQueue.main.async {
                    self.progressBar.progress += 0.07
                }
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
//                self.findTopBounds()
                self.helpRequestDialog()
                self.progressBar.progress += 0.07
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
                        }
                    }
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: { [unowned self] in
                    self.findBestBound()
                    self.progressBar.progress += 0.07
                })
            }
        }
    }
    
    func findBestBound(){
        // On finish
        // self.applyPartialGrayscale()
        if let image = self.capturedImage {
            autoreleasepool { () -> () in
                ImageComparator.shared().findBestCropHistogramCompare(originalImage: image, bounds: self.selectedImageRect, completion: { [unowned self] (bestResult: Double, bestClass: String, croppedImage: UIImage, bestBound: CGRect) in
                    
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
                        DispatchQueue.main.async {
                            self.progressBar.progress += 0.07
                        }
                        
                        if self.grayHistogramCompareFinished {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15, execute: { [unowned self] in
                                self.processBestFoundBound()
                            })
                        }
                        
                    }
                }) { (msg: String) in
                    print(msg)
                }
                
                ImageComparator.shared().findBestCropHistogramGrayCompare(originalImage: image, bounds: self.selectedImageRect, completion: { [unowned self] (bestResult: Double, bestClass: String, croppedImage: UIImage, bestBound: CGRect) in
                    
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
                        
                        DispatchQueue.main.async {
                            self.progressBar.progress += 0.07
                        }
                        
                        if self.colorHistogramCompareFinished {
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15, execute: { [unowned self] in
                                self.processBestFoundBound()
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
    }
    
    func processBestFoundBound(){
//        self.processingImageView.image = self.workingImage
        DispatchQueue.main.async {
            
            self.getBestBoundClass()
            
            self.getPartialRGBClass()
            
            self.getFullHistogramComparisonClass()
            
            self.getPartialHistogramClass()
            
            self.applyPartialGrayscale()
        }
    }
    
    func applyPartialGrayscale(){
        // On finish
        // self.animatePartialContours()
        
        autoreleasepool { () -> () in
            if let image = self.capturedImage {
                
                DispatchQueue.main.async { [unowned self] in
                    self.processingImageView.image = OpenCVWrapper.draw_color_mask(image, withBound: self.bestBound)
                }
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) { [unowned self] in
                self.processingImageView.image = OpenCVWrapper.draw_color_mask(self.capturedImage!, withBound: self.bestBound)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.15, execute: { [unowned self] in
                    
                    self.progressBar.progress += 0.07
                    self.applyPartialGrayscaleReversed()
                })
            }
        }
    }
    
    func applyPartialGrayscaleReversed(){
        // On finish
        // self.animatePartialContours()
        // TODO: make the background comparison here
        autoreleasepool { () -> () in
            if let image = self.capturedImage {
                DispatchQueue.main.async { [unowned self] in
                    self.processingImageView.image = OpenCVWrapper.draw_color_mask_reversed(image, withBound: self.bestBound)
                }
                
                ImageComparator.shared().findTheBestBackgroundWithoutCoffee(image: image, bestBound: self.bestBound, completion: { (result:Double, backgroundClass: String, backgroundImage: UIImage) in
                    
                    
                    self.foundClasses.append(backgroundClass)
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) { [unowned self] in
                        
                        //                self.processingImageView.image = OpenCVWrapper.draw_color_mask_reversed(self.workingImage, withBound: self.bestBound)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15, execute: { [unowned self] in
                            
                            self.progressBar.progress += 0.07
                            self.animateFullContours()
                        })
                    }
                    
                }, error: { (msg:String) in
                    print("ProcessingImageViewController -> applyPartialGrayscaleReversed: Error while executing function with message: \(msg)")
                })
            }
            
            
        }
    }
    
    func animateFullContours(){
        if let image = self.capturedImage {
            autoreleasepool { () -> () in
                let anim = ContourLinesCustomAnimation(targetView: self.processingImageView, image: image, completion: { [unowned self] in
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: { [unowned self] in
                        
                        self.progressBar.progress += 0.07
                        self.animatePartialContours()
                    })
                })
                self.customAnimationsQueue.async {
                    anim.start()
                }
            }
        }
    }
    
    func animatePartialContours(){
        // On finish
        // self.animateBoundAndCircleContours()
        
        autoreleasepool { () -> () in
            if let image = self.capturedImage {
                
                let anim = ContourPartialCustomAnimation(targetView: self.processingImageView, image: image, bound: self.bestBound, completion: { [unowned self] in
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: { [unowned self] in
                        self.progressBar.progress += 0.07
                        self.animateBoundAndCircleContours()
                    })
                })
                self.customAnimationsQueue.async {
                    anim.start()
                }
            }
        }
    }
    
    func animateBoundAndCircleContours(){
        // On finish
        // self.processingFinished()
        
        autoreleasepool { () -> () in
            if let image = self.capturedImage {
                let anim = ContourBoundCircleCustomAnimation(targetView: self.processingImageView, image: image, completion: { [unowned self] in
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: { [unowned self] in
                        
                        self.progressBar.progress += 0.07
                        self.processingFinished()
                    })
                })
                self.customAnimationsQueue.async {
                    anim.start()
                }
            }
        }
    }
    
    func processingFinished(){
        // Check if background finished processing
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [unowned self] in
            self.progressBar.progress = 1.0
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [unowned self] in
            self.transitionToFortuneDisplay()
        }
    }
    
    // MARK: - Navigation
    func transitionToFortuneDisplay(){
        
        DispatchQueue.main.async {
            self.navigationController?.popViewController(animated: false)
            if let completion = self.parentReturn {
                if self.foundClasses.count > 0 {
                    
                    self.processingImageView.image = nil
                    self.capturedImage = nil
                    self.workingImage = UIImage()
                    self.tempImageHolder = UIImage()
                    
                    self.selectedImageRect = []
                    self.backgroundImageView.image = nil
                    
                    ImageComparator.shared().releaseAll()
                    completion(self.foundClasses)
                }
            }
        }
    }
    
    func backToMainMenu() {
        DispatchQueue.main.async {
            let viewControllers: [UIViewController] = self.navigationController!.viewControllers as [UIViewController]
            self.navigationController!.popToViewController(viewControllers[viewControllers.count - 3], animated: true)
        }
    }
    
    // MARK: - Other functions
    
    func helpRequestDialog(){
        // Create the alert controller
        let alertController = UIAlertController(title: "Help Request", message: "Would you like to help the detection algorithm by providing the area with coffee?", preferredStyle: .alert)
        
        // Create the actions
        let okAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default) {
            UIAlertAction in
            self.transitionToTheUserDrawBoundsController()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel) {
            UIAlertAction in
            NSLog("Cancel Pressed")
            self.continiueWithoutUserHelp()
        }
        
        // Add the actions
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        
        // Present the controller
        self.present(alertController, animated: true, completion: nil)
    }
    
    func continiueWithoutUserHelp(){
        self.findTopBounds()
    }
    
    func transitionToTheUserDrawBoundsController(){
        self.progressBar.progress += 0.14
        if let nextViewController = self.storyboard?.instantiateViewController(withIdentifier: "UserDefineRectBoundController") as? UserDefineRectBoundController {
            nextViewController.selectedImage = self.capturedImage!
            nextViewController.parentReturn = { userBound in
                if userBound.origin.x == 10000 && userBound.origin.y == 1000 {
//                 self.bestBound = userBound
                    self.continiueWithoutUserHelp()
                } else {
                    
                    self.bestBound = userBound
                    self.continiueAfterUserDefinedBound()
                }
            }
            self.navigationController?.pushViewController(nextViewController, animated: true)
        }
    }
    
    func continiueAfterUserDefinedBound(){
        self.processBestFoundBound()
    }
}
