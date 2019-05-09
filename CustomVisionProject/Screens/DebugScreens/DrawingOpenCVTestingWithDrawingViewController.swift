
//
//  DrawingOpenCVTestingWithDrawingViewController.swift
//  CustomVisionProject
//
//  Created by Seavus on 4/5/19.
//  Copyright © 2019 Seavus. All rights reserved.
//

import UIKit

class DrawingOpenCVTestingWithDrawingViewController: UIViewController {
    
    // MARK: - Custom references and variables
    var lastPoint: CGPoint = .zero
    var brushWidth: CGFloat = 20.0
    var opacity: CGFloat = 1.0
    var swiped = false
    
//    public var selectedImage: UIImage!
    private var drawingImage: UIImage!
    private var rectDisplayImage: UIImage!
    
    private var boundingRectPointTL = CGPoint(x: 10000, y: 10000)
    private var boundingRectPointDR = CGPoint(x: -1, y: -1)
    private var boundingRect = CGRect()
    
    private var displayingRect = false
    
    public var parentReturn: ((CGRect) -> ())?
    
    // MARK: - IBOutlets references
    @IBOutlet weak var mainImageView: UIImageView!
    @IBOutlet weak var tempImageView: UIImageView!
    
    // MARK: - IBInspectable
    var drawingColor: UIColor = UIColor(named: "NavigationText")!
    var boundingRectColor: UIColor = UIColor(red: 0.30, green: 1, blue: 0.20, alpha: 1)  // ( 32, 194, 14)
    
    @IBInspectable var selectedImage: UIImage!
    
    // MARK: - IBOutlets actions
    @IBAction func drawBoundingBox(_ sender: Any) {
        // Create the rect
        self.tempImageView.image = UIImage()
        self.createRect()
        
        print(self.boundingRect)
        self.mainImageView.image = OpenCVWrapper.find_contours(self.selectedImage, withBound: self.boundingRect, withThreshold: 40)
        
        
        let complexity_class = OpenCVWrapper.find_contours_count(self.selectedImage, withBound: self.boundingRect, withThreshold: 40)
        print(complexity_class)
//        self.mainImageView.image = OpenCVWrapper.bounding_circles_squares(self.selectedImage, withThresh: 225)
        
        /** Dark array **/
        
        /** Light Array **/
        //        let highEnd = NSMutableArray(array: [115, 255, 220])
        //        let lowEnd = NSMutableArray(array: [80, 90, 72])
        
//        self.mainImageView.image = OpenCVWrapper.get_color_contour_sizeM(self.selectedImage, withBound: self.boundingRect, withLowRange: lowEnd, withHighRange: highEnd)
        let yeet = OpenCVWrapper.get_yeeted(self.selectedImage, withBound: self.boundingRect)
        print(yeet)
//        self.drawRect(tl: boundingRectPointTL, dr: boundingRectPointDR)
        
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
        print("UserDefineRectBoundController -> doneButtonAction: I am yet to be implemented!!!")
        
        /** Dark array **/
        let highEnd = NSMutableArray(array: [140, 22, 100])
        let lowEnd = NSMutableArray(array: [80, 10, 2])
        
        /** Light Array **/
//        let highEnd = NSMutableArray(array: [115, 255, 220])
//        let lowEnd = NSMutableArray(array: [80, 90, 72])
        
        self.mainImageView.image = OpenCVWrapper.get_color_contour_sizeRR(self.selectedImage, withBound: self.boundingRect, withLowRange: lowEnd, withHighRange: highEnd)
    }
    
    
    @IBAction func helperSliderAction(_ sender: UISlider) {
        self.createRect()
        self.mainImageView.image = OpenCVWrapper.find_contours(self.selectedImage, withThresh: Int32(sender.value))
        print(sender.value)
    }
    
    // MARK: - View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // ImageComparator.shared().fillUpAll()
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
        self.mainImageView.image = self.selectedImage
        self.drawingImage = self.mainImageView.image
    }
    
    func finalUISetup(){
        // Here do all the resizing and constraint calculations
        // In some cases apply the background gradient here
    }
    
    func checkUITouch(touch: UITouch) -> Bool {
        return self.mainImageView.frame.contains(touch.location(in: self.mainImageView))
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
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
        // 6
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
        self.mainImageView.image = self.selectedImage
        let width = self.boundingRectPointDR.x - self.boundingRectPointTL.x + self.brushWidth * 2
        let height = self.boundingRectPointDR.y - self.boundingRectPointTL.y + self.brushWidth * 2
        self.boundingRect = CGRect(x: self.boundingRectPointTL.x - self.brushWidth, y: self.boundingRectPointTL.y - self.brushWidth, width: width, height: height)
        self.mainImageView.fitRectInView(rect: &self.boundingRect)
        self.scaleTheBoundingRect()
        
    }
    
    func drawRect(tl: CGPoint, dr: CGPoint) {
        if self.displayingRect {
            return
        }
        self.displayingRect = false
        autoreleasepool {
            self.mainImageView.image = self.selectedImage
            
            let width = dr.x - tl.x + self.brushWidth * 2
            let height = dr.y - tl.y + self.brushWidth * 2
            
            self.boundingRect = CGRect(x: tl.x - self.brushWidth, y: tl.y - self.brushWidth, width: width, height: height)
            
//            self.mainImageView.fitRectInView(rect: &self.boundingRect)
            
            // 1
            UIGraphicsBeginImageContext(self.mainImageView.frame.size)
            let context = UIGraphicsGetCurrentContext()
            tempImageView.image?.draw(in: CGRect(x: 0, y: 0, width: self.mainImageView.frame.size.width, height: self.mainImageView.frame.size.height))
            
            // 2
            context?.addRect(boundingRect)
            
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
    
    // MARK: - Other functions
    
    func scaleTheBoundingRect(){
        let scaleX = self.selectedImage.size.width / self.mainImageView.frame.size.width
        let scaleY = self.selectedImage.size.height / self.mainImageView.frame.size.height
        
        let originXRatio = self.boundingRect.origin.x / self.mainImageView.frame.size.width
        let originYRatio = self.boundingRect.origin.y / self.mainImageView.frame.size.height
        
        self.boundingRect.size.width *= scaleX
        self.boundingRect.size.height *= scaleY
        
        self.boundingRect.origin.x = self.selectedImage.size.width * originXRatio
        self.boundingRect.origin.y = self.selectedImage.size.height * originYRatio
        
        if self.boundingRect.origin.x + self.boundingRect.size.width > self.selectedImage.size.width {
            self.boundingRect.size.width = self.selectedImage.size.width - self.boundingRect.origin.x
        }
        if self.boundingRect.size.height + self.boundingRect.origin.y > self.selectedImage.size.height {
            self.boundingRect.size.height = self.selectedImage.size.height - self.boundingRect.origin.y
        }
    }
}
