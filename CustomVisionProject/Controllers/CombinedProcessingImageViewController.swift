//
//  CombinedProcessingImageViewController.swift
//  CustomVisionProject
//
//  Created by Seavus on 4/2/19.
//  Copyright © 2019 Seavus. All rights reserved.
//

import UIKit

class CombinedProcessingImageViewController: UIViewController {
    
    // MARK: - Custom references and variables
    public var selectedImage: UIImage!
    
    // Drawing view variables
    var lastPoint: CGPoint = .zero
    var brushWidth: CGFloat = 20.0
    var opacity: CGFloat = 1.0
    var swiped = false
    
    private var drawingImage: UIImage!
    private var rectDisplayImage: UIImage!
    private var workingImage: UIImage!
    
    private var boundingRectPointTL = CGPoint(x: 10000, y: 10000)
    private var boundingRectPointDR = CGPoint(x: -1, y: -1)
//    private var boundingRect = CGRect()
    
    private var displayingRect = false
    private var userCanDraw = false
    
//    public var parentReturn: ((CGRect) -> ())?
    
    // Processing view variables
    var privateThreadSafeAnimationsQueue = DispatchQueue.init(label: "com.seavus.imageprocessing.animations")
    var privateThreadSafeProcessingQueue = DispatchQueue.init(label: "com.seavus.imageprocessing.processing", attributes: .concurrent)
    
    var colorHistogramResult = -10.0
    var grayHistogramResult = -10.0
    
    var bestResult = -10.0
    var bestClass = "N/A"
    var bestBound = CGRect(x: 0.0, y: 0.0, width: 0.0, height: 0.0)
    
    var colorHistogramCompareFinished = false
    var grayHistogramCompareFinished = false
    
    var processingStarted = false
    
    public var foundClasses = [String]()
    public var parentReturn : (([String]) -> ())?
    
    
    // MARK: - IBOutlets references
    @IBOutlet weak var mainImageView: UIImageView!
    @IBOutlet weak var tempImageView: UIImageView!
    
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var splashScreenUIImage: UIImageView!
    
    @IBOutlet weak var processingStatusLabel: UILabel!
    @IBOutlet weak var progressBar: UIProgressView!
    
    @IBOutlet weak var clearButton: UIButton!
    @IBOutlet weak var doneButton: UIButton!
    
    // MARK: - IBInspectable
    var drawingColor: UIColor = UIColor(named: "NavigationText")!
    var boundingRectColor: UIColor = UIColor(red: 0.30, green: 1, blue: 0.20, alpha: 1)  // ( 32, 194, 14)
    
    // MARK: - IBOutlets actions
    @IBAction func drawBoundingBox(_ sender: Any) {
        // Create the rect
        self.tempImageView.image = UIImage()
//        self.drawRect(tl: boundingRectPointTL, dr: boundingRectPointDR)
        
        self.createRect()
        // Draw the rect
    }
    
    @IBAction func clearAllDrawings(_ sender: Any) {
        boundingRectPointTL = CGPoint(x: 10000, y: 10000)
        boundingRectPointDR = CGPoint(x: -1, y: -1)
        self.mainImageView.image = self.selectedImage;
        self.drawingImage = self.selectedImage
        self.tempImageView.image = UIImage()
    }
    
    @IBAction func doneButtonAction(_ sender: Any) {
        // transition back to the parent view and return the bounding rect
        DispatchQueue.main.async {
            self.setupViewForProcessing()
        }
        self.privateThreadSafeProcessingQueue.async {
            self.startImageProcessing()
        }
    }
    
    // MARK: - View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
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
        var bundlePath = Bundle.main.path(forResource: "coffeeOwl", ofType: "jpg")
        self.splashScreenUIImage.image = UIImage(contentsOfFile: bundlePath!)
        
        bundlePath = Bundle.main.path(forResource: "blackSteamy", ofType: "jpg")
        self.backgroundImageView.image = UIImage(contentsOfFile: bundlePath!)
        
        self.mainImageView.image = self.selectedImage
        self.drawingImage = self.mainImageView.image
        self.setupViewForDrawing()
    }
    
    func finalUISetup(){
        // Here do all the resizing and constraint calculations
        // In some cases apply the background gradient here
        if let img = self.selectedImage {
            self.workingImage = img
            self.mainImageView.image = img
            UIView.transition(with: self.splashScreenUIImage, duration: 0.3, options: .transitionFlipFromTop, animations: {
                self.splashScreenUIImage.alpha = 0
            }, completion: { (completed: Bool) in
                self.splashScreenUIImage.image = nil
            })
        } else {
            self.backToMainMenu()
        }
    }
    
    func setupViewForDrawing(){
        // TODO: adjust the title
        
        self.userCanDraw = true
        self.progressBar.isHidden = true
        self.processingStatusLabel.isHidden = true
        
        self.clearButton.isHidden = false
        self.doneButton.isHidden = false
        self.navigationItem.setHidesBackButton(false, animated: false)
        // Display: Clear, done buttons display + back button
        // Hide Processing bar + processing label
    }
    
    func setupViewForProcessing(){
        // TODO: adjust the title
        
        self.userCanDraw = false
        // Display: Processing bar + processing label
        // Hide Clear,done buttons + navbar back button
        self.progressBar.progress = (0.0)
        self.navigationItem.setHidesBackButton(true, animated: false)
        
        self.clearButton.isHidden = true
        self.doneButton.isHidden = true
        self.progressBar.isHidden = false
        self.processingStatusLabel.isHidden = false
    }
    
    func checkUITouch(touch: UITouch) -> Bool {
        return self.mainImageView.frame.contains(touch.location(in: self.mainImageView))
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !self.userCanDraw {
            return
        }
        
        autoreleasepool {
            if(!self.mainImageView.checkIfPointInView(point: touches.first!.location(in: self.mainImageView))){
                return
            }
            
            self.mainImageView.image = self.drawingImage
            self.displayingRect = false
            
            swiped = false
            self.tempImageView.image = UIImage()
            
            if let touch = touches.first {
                lastPoint = touch.location(in: self.mainImageView)
                self.addedNewPoint(point: lastPoint)
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !self.userCanDraw {
            return
        }
        
        autoreleasepool {
            swiped = true
            if let touch = touches.first {
                let currentPoint = touch.location(in: mainImageView)
                drawLineFrom(fromPoint: lastPoint, toPoint: currentPoint)
                // 7
                lastPoint = currentPoint
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !self.userCanDraw {
            return
        }
        
        autoreleasepool {
            if !swiped {
                // draw a single point
                self.addedNewPoint(point: lastPoint)
                drawLineFrom(fromPoint: lastPoint, toPoint: lastPoint)
            }
            
            // Merge tempImageView into mainImageView
            UIGraphicsBeginImageContext(mainImageView.frame.size)
            mainImageView.image?.draw(in: CGRect(x: 0, y: 0, width: mainImageView.frame.size.width, height: mainImageView.frame.size.height), blendMode: .normal, alpha: 1.0)
            tempImageView.image?.draw(in: CGRect(x: 0, y: 0, width: mainImageView.frame.size.width, height: mainImageView.frame.size.height), blendMode: .normal, alpha: opacity)
            mainImageView.image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            tempImageView.image = nil
            
            self.drawingImage = self.mainImageView.image
        }
    }
    
    // MARK: - Logic functions
    func drawLineFrom(fromPoint: CGPoint, toPoint: CGPoint) {
        autoreleasepool {
            if(!self.mainImageView.checkIfPointInView(point: toPoint)){
                return;
            }
            
            // 1
            UIGraphicsBeginImageContext(self.mainImageView.frame.size)
            let context = UIGraphicsGetCurrentContext()
            tempImageView.image?.draw(in: CGRect(x: 0, y: 0, width: self.mainImageView.frame.size.width, height: self.mainImageView.frame.size.height))
            
            // 2
            context?.move(to: CGPoint(x: fromPoint.x, y: fromPoint.y))
            context?.addLine(to: CGPoint(x: toPoint.x, y: toPoint.y))
            
            self.addedNewPoint(point: fromPoint)
            self.addedNewPoint(point: toPoint)
            
            // 3
            context?.setLineCap(.round)
            context?.setLineWidth(brushWidth)
            context?.setStrokeColor(self.drawingColor.cgColor);
            context?.setBlendMode(.normal)
            
            // 4
            context?.strokePath()
            
            // 5
            tempImageView.image = UIGraphicsGetImageFromCurrentImageContext()
            tempImageView.alpha = opacity
            UIGraphicsEndImageContext()
            
            self.drawingImage = self.mainImageView.image
        }
    }
    
    func addedNewPoint(point: CGPoint){
        if(self.mainImageView.checkIfPointInView(point: point)){
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
    }
    
    func createRect(){
        autoreleasepool {
//            DispatchQueue.main.async {
//                self.mainImageView.image = self.selectedImage
//            }
            
            /*
            let width = dr.x - tl.x + self.brushWidth * 2
            let height = dr.y - tl.y + self.brushWidth * 2
            
            self.bestBound = CGRect(x: tl.x - self.brushWidth, y: tl.y - self.brushWidth, width: width, height: height)
            
            self.mainImageView.fitRectInView(rect: &self.bestBound)
            */
            
            DispatchQueue.main.sync {
                self.mainImageView.image = self.selectedImage
                
                let width = self.boundingRectPointDR.x - self.boundingRectPointTL.x + self.brushWidth * 2
                let height = self.boundingRectPointDR.y - self.boundingRectPointTL.y + self.brushWidth * 2
                
                self.bestBound = CGRect(x: self.boundingRectPointTL.x - self.brushWidth, y: self.boundingRectPointTL.y - self.brushWidth, width: width, height: height)
            
                self.mainImageView.fitRectInView(rect: &self.bestBound)
                self.scaleTheBoundingRect()
            }
            
        }
    }
    
    func startImageProcessing(){
        print("GO Get em cowboy!")
        if self.processingStarted {
            return
        }
        self.processingStarted = true
        
        ImageComparator.shared().fillUpAll()
        
//        DispatchQueue.main.async {
//            self.drawRect(tl: self.boundingRectPointTL, dr: self.boundingRectPointDR)
//        }
        
        self.createRect()

        
        self.privateThreadSafeProcessingQueue.async {
            self.getBestBoundClass()
        }
        
        self.privateThreadSafeProcessingQueue.async {
            self.getOverallRGBClass()
        }
        
        self.privateThreadSafeProcessingQueue.async {
//            self.getPartialRGBClass()
        }
        
        self.privateThreadSafeProcessingQueue.async {
            self.getFullHistogramComparisonClass()
        }
        
        self.privateThreadSafeProcessingQueue.async {
            self.getPartialHistogramClass()
        }
        self.applyGrayscale()
    }
    
    func getBestBoundClass(){
        
        // Classify based on the sizes and location of the best bound
        guard let image = self.selectedImage else {
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
        if let image = self.selectedImage {
            let array = OpenCVWrapper.find_rgb_values(image)
            
            let blue = array[0] as? Double ?? 0
            let green = array[1] as? Double ?? 0
            let red = array[2] as? Double ?? 0
            
            if blue > green {
                if blue > red {
                    self.foundClasses.append("rgb-full-blue")
                } else {
                    self.foundClasses.append("rgb-full-red")
                }
            } else {
                if green > red {
                    self.foundClasses.append("rgb-full-green")
                } else {
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
        if let image = self.selectedImage {
            let array = OpenCVWrapper.find_rgb_values(image,withBound: self.bestBound)
            
            let blue = array[0] as? Double ?? 0
            let green = array[1] as? Double ?? 0
            let red = array[2] as? Double ?? 0
            
            if blue > green {
                if blue > red {
                    self.foundClasses.append("rgb-partial-blue")
                } else {
                    self.foundClasses.append("rgb-partial-red")
                }
            } else {
                if green > red {
                    self.foundClasses.append("rgb-partial-green")
                } else {
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
        if let image = self.selectedImage {
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
        if let image = self.selectedImage {
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
            self.workingImage = OpenCVWrapper.makeGray(self.selectedImage)
            DispatchQueue.main.async { [unowned self] in
                self.mainImageView.image = self.selectedImage
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15, execute: { [unowned self] in
                // Onto the next 1
                self.progressBar.progress += 0.07
                self.applyPartialGrayscale()
            })
        }
    }
    
    func applyPartialGrayscale(){
        // On finish
        // self.animatePartialContours()
        autoreleasepool { () -> () in
            if let image = self.selectedImage {
                
                DispatchQueue.main.async { [unowned self] in
                    
                    self.mainImageView.image = OpenCVWrapper.draw_color_mask(image, withBound: self.bestBound)
                }
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) { [unowned self] in
                self.mainImageView.image = OpenCVWrapper.draw_color_mask(self.selectedImage!, withBound: self.bestBound)
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
            if let image = self.selectedImage {
                DispatchQueue.main.async { [unowned self] in
                    self.mainImageView.image = OpenCVWrapper.draw_color_mask_reversed(image, withBound: self.bestBound)
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
        if let image = self.selectedImage {
            autoreleasepool { () -> () in
                let anim = ContourLinesCustomAnimation(targetView: self.mainImageView, image: image, completion: { [unowned self] in
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: { [unowned self] in
                        
                        self.progressBar.progress += 0.07
                        self.animatePartialContours()
                    })
                })
                self.privateThreadSafeAnimationsQueue.async {
                    anim.start()
                }
            }
        }
    }
    
    func animatePartialContours(){
        // On finish
        // self.animateBoundAndCircleContours()
        
        autoreleasepool { () -> () in
            if let image = self.selectedImage {
                
                let anim = ContourPartialCustomAnimation(targetView: self.mainImageView, image: image, bound: self.bestBound, completion: { [unowned self] in
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: { [unowned self] in
                        self.progressBar.progress += 0.07
                        self.animateBoundAndCircleContours()
                    })
                })
                self.privateThreadSafeAnimationsQueue.async {
                    anim.start()
                }
            }
        }
    }
    
    func animateBoundAndCircleContours(){
        // On finish
        // self.processingFinished()
        
        autoreleasepool { () -> () in
            if let image = self.selectedImage {
                let anim = ContourBoundCircleCustomAnimation(targetView: self.mainImageView, image: image, completion: { [unowned self] in
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: { [unowned self] in
                        
                        self.progressBar.progress += 0.07
                        self.processingFinished()
                    })
                })
                self.privateThreadSafeAnimationsQueue.async {
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

    func backToMainMenu(){
        self.navigationController?.popViewController(animated: false)
    }
    
    func transitionToFortuneDisplay(){

        print("YEEEE HAAAWWW")
        print("Done with this wild work")
        print("YEET")

        DispatchQueue.main.async {
            self.navigationController?.popViewController(animated: false)
            if let completion = self.parentReturn {
                if self.foundClasses.count > 0 {

                    self.mainImageView.image = nil
                    self.selectedImage = nil

                    ImageComparator.shared().releaseAll()
                    completion(self.foundClasses)
                }
            }
        }
        
    }
    
    // MARK: - Other functions
    func drawRect(tl: CGPoint, dr: CGPoint) {
        if self.displayingRect {
            return
        }
        self.displayingRect = false
        autoreleasepool {
            self.mainImageView.image = self.selectedImage
            
            let width = dr.x - tl.x + self.brushWidth * 2
            let height = dr.y - tl.y + self.brushWidth * 2
            
            self.bestBound = CGRect(x: tl.x - self.brushWidth, y: tl.y - self.brushWidth, width: width, height: height)
            
            self.mainImageView.fitRectInView(rect: &self.bestBound)
            
            // 1
            UIGraphicsBeginImageContext(self.mainImageView.frame.size)
            let context = UIGraphicsGetCurrentContext()
            tempImageView.image?.draw(in: CGRect(x: 0, y: 0, width: self.mainImageView.frame.size.width, height: self.mainImageView.frame.size.height))
            
            // 2
            context?.addRect(bestBound)
            
            // 3
            context?.setLineCap(.round)
            context?.setLineWidth(5)
            context?.setStrokeColor(self.boundingRectColor.cgColor);
            context?.setBlendMode(.normal)
            
            // 4
            context?.strokePath()
            
            // 5
            tempImageView.image = UIGraphicsGetImageFromCurrentImageContext()
            tempImageView.alpha = opacity
            UIGraphicsEndImageContext()
        }
    }
    
    func scaleTheBoundingRect(){
        let scaleX = self.selectedImage.size.width / self.mainImageView.frame.size.width
        let scaleY = self.selectedImage.size.height / self.mainImageView.frame.size.height
        
        let originXRatio = self.bestBound.origin.x / self.mainImageView.frame.size.width
        let originYRatio = self.bestBound.origin.y / self.mainImageView.frame.size.height
        
        self.bestBound.size.width *= scaleX
        self.bestBound.size.height *= scaleY
        
        self.bestBound.origin.x = self.selectedImage.size.width * originXRatio
        self.bestBound.origin.y = self.selectedImage.size.height * originYRatio
        
        if self.bestBound.origin.x + self.bestBound.size.width > self.selectedImage.size.width {
            self.bestBound.size.width = self.selectedImage.size.width - self.bestBound.origin.x
        }
        if self.bestBound.size.height + self.bestBound.origin.y > self.selectedImage.size.height {
            self.bestBound.size.height = self.selectedImage.size.height - self.bestBound.origin.y
        }
    }
    
    deinit {
        
        self.releaseSomeMemory()
    }
    
    func releaseSomeMemory(){
        self.mainImageView.image = nil
        self.tempImageView.image = nil
        
        self.backgroundImageView.image = nil
        self.backgroundImageView = nil
        // vvvvvvvvvvvvvvVVVVVVVvvvvv bad name!!!!
        self.splashScreenUIImage.image = nil // <- BADNAME!!!
        self.splashScreenUIImage = nil
    }
}
