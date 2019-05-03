//
//  PhotoProcessViewController.swift
//  CustomVisionProject
//
//  Created by Seavus on 4/25/19.
//  Copyright © 2019 Seavus. All rights reserved.
//

import UIKit

class PhotoProcessViewController: UIViewController, Storyboarded {
    
    // MARK: - Custom references and variables
    public var selectedImage: UIImage!
    public weak var coordinator: PhotoProcessCoordinator!
    public var navigationBarHidden = false
    
    // Drawing view variables
    var lastPoint: CGPoint = .zero
    var brushWidth: CGFloat = 40.0
    var opacity: CGFloat = 1.0
    var touchMoved = false
    
    var excessX = CGFloat(0.0)
    var excessY = CGFloat(0.0)
    lazy var aspectFit = self.coordinator.CGSizeAspectFit(aspectRatio: self.selectedImage.size, boundingSize: self.mainImageView.frame.size)
    
    private var drawingImage: UIImage!
    private var rectDisplayImage: UIImage!
    private var workingImage: UIImage!
    
    //    private var boundingRect = CGRect()
    
    private var displayingRect = false
    private var userCanDraw = false
    
    // Processing view variables
    var privateThreadSafeAnimationsQueue = DispatchQueue.init(label: "com.seavus.imageprocessing.animations") // Do not make this one .concurrent. It could cause problems

    
    //    var bestResult = -10.0
    var bestBound = CGRect(x: 0.0, y: 0.0, width: 0.0, height: 0.0)
    
    var colorHistogramCompareFinished = false
    var grayHistogramCompareFinished = false
    
    var processingStarted = false
    
    public var foundClasses = [String]()
    public var parentReturn : (([String], UIImage) -> ())?
    
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
    //    var boundingRectColor: UIColor = UIColor(red: 0.30, green: 1, blue: 0.20, alpha: 1)  // ( 32, 194, 14)
    var boundingRectColor: UIColor = UIColor(named: "NavigationText")!
    
    // MARK: - IBOutlets actions
    @IBAction func clearAllDrawings(_ sender: Any) {
        self.coordinator.clearAllDrawingsAction()
    }
    
    @IBAction func doneButtonAction(_ sender: Any) {
        self.coordinator.doneDrawingAction()
    }
    
    // MARK: - View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        DispatchQueue.main.async {
            self.initalUISetup()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        var bundlePath = Bundle.main.path(forResource: "coffeeOwl", ofType: "jpg")
        self.splashScreenUIImage.image = UIImage(contentsOfFile: bundlePath!)
        
        bundlePath = Bundle.main.path(forResource: "blackSteamy", ofType: "jpg")
        self.backgroundImageView.image = UIImage(contentsOfFile: bundlePath!)
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
        
        self.mainImageView.image = self.selectedImage
        
        self.drawingImage = self.mainImageView.image
        self.setupViewForDrawing() // singal to coordinator
    }
    
    func setupViewForDrawing(){
        
        // Setup Title
        self.userCanDraw = true
        self.progressBar.isHidden = true
        self.processingStatusLabel.isHidden = true
        
        self.clearButton.isHidden = false
        self.doneButton.isHidden = false
        self.navigationItem.setHidesBackButton(false, animated: false)
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
            
            // Ugly code. Used to make the drawing TempImageView same size as the MainImageView
            let emptyImg = UIImage()
            UIGraphicsBeginImageContext(CGSize(width: img.size.width, height: img.size.height))
            emptyImg.draw(in: CGRect(x: 0, y: 0, width: img.size.width, height: img.size.height))
            let newImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            self.tempImageView.image = newImage
            // /* *************************************** */ //
            
        } else {
            self.backToMainMenu()
        }
        
        self.calculateExcess()
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
            
            self.touchMoved = false
            self.tempImageView.image = UIImage()
            
            if let touch = touches.first {
                self.lastPoint = touch.location(in: self.mainImageView)
                self.coordinator.userTouchBegin(location: lastPoint)
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !self.userCanDraw {
            return
        }
        
        autoreleasepool {
            touchMoved = true
            if let touch = touches.first {
                let currentPoint = touch.location(in: self.mainImageView)
                self.drawLineFrom(fromPoint: self.lastPoint, toPoint: currentPoint)
                
                self.lastPoint = currentPoint
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !self.userCanDraw {
            return
        }
        
        autoreleasepool {
            if !self.touchMoved {
                // draw a single point
                self.coordinator.userTouchEnd(location: self.lastPoint)
                self.drawLineFrom(fromPoint: self.lastPoint, toPoint: self.lastPoint)
            }
            
            // Merge tempImageView into mainImageView
            UIGraphicsBeginImageContext(self.selectedImage.size)
            mainImageView.image?.draw(in: CGRect(x: 0, y: 0, width: self.selectedImage.size.width, height: self.selectedImage.size.height), blendMode: .normal, alpha: 1.0)
            tempImageView.image?.draw(in: CGRect(x: 0, y: 0, width: self.selectedImage.size.width, height: self.selectedImage.size.height), blendMode: .normal, alpha: opacity)
            
            mainImageView.image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            tempImageView.image = nil
            self.drawingImage = self.mainImageView.image
        }
    }
    
    // MARK: - Logic functions
    func clearAllDrawings(){
        self.mainImageView.image = self.selectedImage;
        self.drawingImage = self.selectedImage
        self.tempImageView.image = UIImage()
    }
    
    func calculateExcess(){
        let aspectFit = self.coordinator.CGSizeAspectFit(aspectRatio: self.selectedImage.size, boundingSize: self.mainImageView.frame.size)
        
        self.excessX = (self.mainImageView.frame.size.width - aspectFit.width) / 2
        self.excessY = (self.mainImageView.frame.size.height - aspectFit.height) / 2
    }
    
    func drawLineFrom(fromPoint: CGPoint, toPoint: CGPoint) {
        
        autoreleasepool {
            if(!self.mainImageView.checkIfPointInView(point: toPoint)){
                return;
            }
            
            let fromPointS = self.scalePointToImageSize(point: fromPoint)
            let toPointS = self.scalePointToImageSize(point: toPoint)
            
            self.coordinator.userTouchMoved(location: fromPoint)
            self.coordinator.userTouchMoved(location: toPoint)
            
            // 1
            UIGraphicsBeginImageContext(self.selectedImage.size)
            let context = UIGraphicsGetCurrentContext()
            tempImageView.image?.draw(in: CGRect(x: 0, y: 0, width: self.selectedImage.size.width, height: self.selectedImage.size.height), blendMode: .normal, alpha: opacity)
            
            // 2
            context?.move(to: CGPoint(x: fromPointS.x, y: fromPointS.y))
            context?.addLine(to: CGPoint(x: toPointS.x, y: toPointS.y))
            
            // 3
            context?.setLineCap(.round)
            context?.setLineWidth(brushWidth)
            context?.setStrokeColor(self.drawingColor.cgColor)
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
    
    func createRect(){
        autoreleasepool {
            self.mainImageView.image = self.selectedImage
            
            self.coordinator.aspectFit = self.aspectFit
            self.bestBound = self.coordinator.getDrawingRect()
            self.preDrawSizeCheck()
            
            self.drawRect()
            
            self.scaleTheBoundingRect()
        }
    }
    
    func preDrawSizeCheck (){
        let excessX = (self.mainImageView.frame.size.width - aspectFit.width) / 2
        let excessY = (self.mainImageView.frame.size.height - aspectFit.height) / 2
        
        if self.bestBound.origin.x < excessX {
            self.bestBound.origin.x = excessX
        }

        if self.bestBound.origin.y < excessY {
            self.bestBound.origin.y = excessY
        }

        if self.bestBound.origin.x + self.bestBound.width > self.aspectFit.width + excessX {
            self.bestBound.size.width = self.aspectFit.width + excessX - self.bestBound.origin.x   // <<<< ---- FIX THIS AS-AP  <<<< -----
        }

        if self.bestBound.origin.y + self.bestBound.height > self.aspectFit.height + excessY {
            self.bestBound.size.height = self.aspectFit.height + excessY - self.bestBound.origin.y   // <<<< ---- FIX THIS AS-AP  <<<< -----
        }
    }
    
    func scaleTheBoundingRect(){
        let aspectFit = self.coordinator.CGSizeAspectFit(aspectRatio: self.selectedImage.size, boundingSize: self.mainImageView.frame.size)
        
        let scaleX = self.selectedImage.size.width / aspectFit.width
        let scaleY = self.selectedImage.size.height / aspectFit.height
        
        let excessX = (self.mainImageView.frame.size.width - aspectFit.width) / 2
        let excessY = (self.mainImageView.frame.size.height - aspectFit.height) / 2
        
        self.bestBound.size.width *= scaleX
        self.bestBound.size.height *= scaleY
        
        self.bestBound.origin.x = (self.bestBound.origin.x - excessX) * scaleX
        self.bestBound.origin.y = (self.bestBound.origin.y - excessY) * scaleY
        
        if self.bestBound.origin.x < 0 {
            self.bestBound.size.width += self.bestBound.origin.x
            return self.bestBound.origin.x = 0
        }
        
        if self.bestBound.origin.y < 0 {
            self.bestBound.size.height += self.bestBound.origin.y
            return self.bestBound.origin.y = 0
        }
        
        if self.bestBound.origin.x + self.bestBound.size.width > self.selectedImage.size.width {
            self.bestBound.size.width = self.selectedImage.size.width - self.bestBound.origin.x
        }
        
        if self.bestBound.size.height + self.bestBound.origin.y > self.selectedImage.size.height {
            self.bestBound.size.height = self.selectedImage.size.height - self.bestBound.origin.y
        }
        
        self.coordinator.setBestBound(bestBound: self.bestBound)
    }
    
    // MARK - Finished drawing
    func startImageProcessing(){
        if self.processingStarted {
            return
        }
        
        self.processingStarted = true
        
        self.createRect()
        
        self.coordinator.startImageProcessing()
        
        self.applyGrayscale()
    }
    
    // MARK: - Animation processing functions
    func applyGrayscale(){
        DispatchQueue.global(qos: .background).async { [unowned self] in
            self.workingImage = OpenCVWrapper.makeGray(self.selectedImage)
            DispatchQueue.main.async { [unowned self] in
                self.mainImageView.image = self.selectedImage
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: { [unowned self] in
                self.progressBar.progress += 0.09
                self.applyPartialGrayscale()
            })
        }
    }
    
    func applyPartialGrayscale(){
        autoreleasepool { () -> () in
            if let image = self.selectedImage {
                DispatchQueue.main.async { [unowned self] in
                    self.mainImageView.image = OpenCVWrapper.draw_color_mask(image, withBound: self.bestBound)
                }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [unowned self] in
                self.mainImageView.image = OpenCVWrapper.draw_color_mask(self.selectedImage!, withBound: self.bestBound)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: { [unowned self] in
                    self.progressBar.progress += 0.09
                    self.applyPartialGrayscaleReversed()
                })
            }
        }
    }
    
    func applyPartialGrayscaleReversed(){
        autoreleasepool { () -> () in
            if let image = self.selectedImage {
                DispatchQueue.main.async { [unowned self] in
                    self.mainImageView.image = OpenCVWrapper.draw_color_mask_reversed(image, withBound: self.bestBound)
                }
                self.privateThreadSafeAnimationsQueue.async {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: { [unowned self] in
                        self.progressBar.progress += 0.09
                        self.animateFullContours()
                    })
                }
            }
        }
    }
    
    func animateFullContours(){
        if let image = self.selectedImage {
            autoreleasepool { () -> () in
                let anim = ContourLinesCustomAnimation(targetView: self.mainImageView, image: image, completion: { [unowned self] in
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: { [unowned self] in
                        self.progressBar.progress += 0.09
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
        autoreleasepool { () -> () in
            if let image = self.selectedImage {
                let anim = ContourPartialCustomAnimation(targetView: self.mainImageView, image: image, bound: self.bestBound, completion: { [unowned self] in
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: { [unowned self] in
                        self.progressBar.progress += 0.09
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
        autoreleasepool { () -> () in
            if let image = self.selectedImage {
                let anim = ContourBoundCircleCustomAnimation(targetView: self.mainImageView, image: image, completion: { [unowned self] in
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: { [unowned self] in
                        
                        self.progressBar.progress += 0.09
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
    func backToMainMenu(){
        self.coordinator.requestReturnToMainMenu()
    }
    
    func transitionToFortuneDisplay(){
        DispatchQueue.main.async {
            // TODO: change it so it doesnt have to provide found classes
            self.coordinator.transitionToFortuneDisplay(foundClasses: self.foundClasses)
        }
    }
    
    // MARK: - Other functions
    
    func drawRect() {
        if self.displayingRect {
            return
        }
        self.displayingRect = false
        autoreleasepool {
            self.mainImageView.image = self.selectedImage
            
            /* ************************************* */
            /* Check the code bellow it it is needed */
            /* VVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVV */
            /*
            if drawRect.origin.x < self.excessX {
                drawRect.origin.x = self.excessX
            }
            
            if drawRect.origin.y < self.excessY {
                drawRect.origin.y = self.excessY
            }
            
            if drawRect.origin.x + drawRect.size.width > self.aspectFit.width + self.excessX {
                drawRect.size.width = self.aspectFit.width - drawRect.origin.x + self.excessX
            }
            
            if drawRect.origin.y + drawRect.size.height > self.aspectFit.height + self.excessY {
                drawRect.size.height = self.aspectFit.height - drawRect.origin.y + self.excessY
            }
            */
            /* ************************************* */
            
            let drawRect = CGRect(origin: self.bestBound.origin, size: self.bestBound.size)
            UIGraphicsBeginImageContext(self.mainImageView.frame.size)
            let context = UIGraphicsGetCurrentContext()
            tempImageView.image?.draw(in: CGRect(x: 0, y: 0, width: self.mainImageView.frame.size.width, height: self.mainImageView.frame.size.height))
            
            context?.addRect(drawRect)
            
            context?.setLineCap(.round)
            context?.setLineWidth(5)
            context?.setStrokeColor(self.boundingRectColor.cgColor)
            context?.setBlendMode(.normal)
            
            context?.strokePath()
            
            tempImageView.image = UIGraphicsGetImageFromCurrentImageContext()
            tempImageView.alpha = opacity
            UIGraphicsEndImageContext()
        }
    }
    

    
    func scalePointToImageSize(point:CGPoint) -> CGPoint {
        var originXRatio = CGFloat(0)
        if point.x - self.excessX < 0 {
            originXRatio = 0
        } else if point.x - self.excessX > self.aspectFit.width {
            originXRatio = self.aspectFit.width
        }
        else {
            originXRatio = (point.x - self.excessX) / self.aspectFit.width
        }
        
        var originYRatio = CGFloat(0)
        
        if point.y - self.excessY < 0 {
            originYRatio = 0.0
        } else if point.y - self.excessY > self.aspectFit.height {
            originYRatio = self.aspectFit.height
        }
        else {
            originYRatio = (point.y - self.excessY) / self.aspectFit.height
        }
        
        return CGPoint(x: self.selectedImage.size.width * originXRatio, y: self.selectedImage.size.height * originYRatio)
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
