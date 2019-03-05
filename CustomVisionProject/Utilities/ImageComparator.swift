//
//  ImageComparator.swift
//  CustomVisionProject
//
//  Created by Seavus on 2/25/19.
//  Copyright © 2019 Seavus. All rights reserved.
//

import Foundation
import UIKit

class ImageComparator {
    
    // MARK: - Class properties
    private let dispatchQueue = DispatchQueue.init(label: "imageComparator", attributes: .concurrent)
    
    private var darkCoffeeArray: [UIImage] = []
    private var lightCoffeeArray: [UIImage] = []
    private var fancyCoffeeArray: [UIImage] = []
    
    // MARK: - Init function
    private init() {
        
//        self.dispatchQueue.async {
//            self.fillUpDarkCoffeeArray()
//        }
//        
//        self.dispatchQueue.async {
//            self.fillUpLightCoffeeArray()
//        }
//        
//        self.dispatchQueue.async {
//            self.fillUpFancyCoffeeArray()
//        }
    }
    
    
    public func fillUpAll(){
        fillUpDarkCoffeeArray()
        fillUpLightCoffeeArray()
        fillUpFancyCoffeeArray()
    }
    
    public func releaseAll(){
        self.releaseDarkCoffeeArray()
        self.releaseFancyCoffeeArray()
        self.releaseLightCoffeeArray()
    }
    
    // MARK: - Data generation and release functions
    private func fillUpDarkCoffeeArray(){
//        self.darkCoffeeArray.append(#imageLiteral(resourceName: "dark_coffee_4"))
//        self.darkCoffeeArray.append(#imageLiteral(resourceName: "dark_coffee_1"))
//        self.darkCoffeeArray.append(#imageLiteral(resourceName: "dark_coffee_3"))
//        self.darkCoffeeArray.append(#imageLiteral(resourceName: "dark_coffee_2"))
        
        var bundlePath = Bundle.main.path(forResource: "dark_coffee_1", ofType: "jpg")
        self.darkCoffeeArray.append(UIImage(contentsOfFile: bundlePath!)!)
        
        bundlePath = Bundle.main.path(forResource: "dark_coffee_2", ofType: "jpg")
        self.darkCoffeeArray.append(UIImage(contentsOfFile: bundlePath!)!)
        
        bundlePath = Bundle.main.path(forResource: "dark_coffee_3", ofType: "jpg")
        self.darkCoffeeArray.append(UIImage(contentsOfFile: bundlePath!)!)
        
        bundlePath = Bundle.main.path(forResource: "dark_coffee_4", ofType: "jpg")
        self.darkCoffeeArray.append(UIImage(contentsOfFile: bundlePath!)!)
    }
    
    private func fillUpLightCoffeeArray(){
//        self.lightCoffeeArray.append(#imageLiteral(resourceName: "light_coffee_4"))
//        self.lightCoffeeArray.append(#imageLiteral(resourceName: "light_coffee_2"))
//        self.lightCoffeeArray.append(#imageLiteral(resourceName: "light_coffee_1"))
//        self.lightCoffeeArray.append(#imageLiteral(resourceName: "light_coffee_3"))
        
        var bundlePath = Bundle.main.path(forResource: "light_coffee_1", ofType: "jpg")
        self.darkCoffeeArray.append(UIImage(contentsOfFile: bundlePath!)!)
        
        bundlePath = Bundle.main.path(forResource: "light_coffee_2", ofType: "jpg")
        self.darkCoffeeArray.append(UIImage(contentsOfFile: bundlePath!)!)
        
        bundlePath = Bundle.main.path(forResource: "light_coffee_3", ofType: "png")
        self.darkCoffeeArray.append(UIImage(contentsOfFile: bundlePath!)!)
        
        bundlePath = Bundle.main.path(forResource: "light_coffee_4", ofType: "jpg")
        self.darkCoffeeArray.append(UIImage(contentsOfFile: bundlePath!)!)
    }
    
    private func fillUpFancyCoffeeArray(){
//        self.fancyCoffeeArray.append(#imageLiteral(resourceName: "fancy_coffe_3"))
//        self.fancyCoffeeArray.append(#imageLiteral(resourceName: "fancy_coffee_2"))
//        self.fancyCoffeeArray.append(#imageLiteral(resourceName: "fancy_coffee_1"))
        
        var bundlePath = Bundle.main.path(forResource: "fancy_coffee_1", ofType: "jpg")
        self.darkCoffeeArray.append(UIImage(contentsOfFile: bundlePath!)!)
        
        bundlePath = Bundle.main.path(forResource: "fancy_coffee_1", ofType: "jpg")
        self.darkCoffeeArray.append(UIImage(contentsOfFile: bundlePath!)!)
        
        bundlePath = Bundle.main.path(forResource: "fancy_coffee_1", ofType: "jpg")
        self.darkCoffeeArray.append(UIImage(contentsOfFile: bundlePath!)!)
    }
    
    private func releaseDarkCoffeeArray(){
        self.darkCoffeeArray = []
    }
    
    private func releaseLightCoffeeArray(){
        self.lightCoffeeArray = []
    }
    
    private func releaseFancyCoffeeArray(){
        self.fancyCoffeeArray = []
    }
    
    // MARK: - Compare functions
    
    ////////////////////////////////
    /// Normal histogram compare ///
    ////////////////////////////////
    
    public func findBestClassHistogramCompare(image: UIImage, completion: @escaping (Double, String, UIImage)->(), error: ((String)->())? ) {
        self.dispatchQueue.async {
            let (bestResult, bestClass, bestImg) = self.findBestClassHistogramCompare(image: image)
            
            if let img = bestImg {
                completion(bestResult, bestClass, img)
            } else {
                if let error = error {
                    error("ImageComparator -> findbestClassHistogramCompare: Error parsing the bestImage. Maybe no image was found?")
                }
            }
        }
    }
    
    private func findBestClassHistogramCompare(image: UIImage) -> (Double, String, UIImage?) {
        // 1. Look for the best score compared to the method 1 within a class
        // 2. Compare with the best results from the other classes
        // 3. return the class with the best result
        
        var bestResult = 0.0
        var tempResult = 0.0
        var bestClass = "light"
        var bestImage: UIImage?
        
        for img in self.lightCoffeeArray {
//            tempResult = OpenCVWrapper.compare(usingGrayScaleHistograms: image, with: img)
            tempResult = OpenCVWrapper.compare(usingHistograms: image, with: img)
            if tempResult > bestResult {
                bestResult = tempResult
                bestClass = "light"
                bestImage = img
            }
        }
        
        for img in self.darkCoffeeArray {
//            tempResult = OpenCVWrapper.compare(usingGrayScaleHistograms: image, with: img)
            tempResult = OpenCVWrapper.compare(usingHistograms: image, with: img)
            if tempResult > bestResult {
                bestResult = tempResult
                bestClass = "dark"
                bestImage = img
            }
        }
        
        for img in self.fancyCoffeeArray {
//            tempResult = OpenCVWrapper.compare(usingGrayScaleHistograms: image, with: img)
            tempResult = OpenCVWrapper.compare(usingHistograms: image, with: img)
            if tempResult > bestResult {
                bestResult = tempResult
                bestClass = "fancy"
                bestImage = img
            }
        }
        
        return ( bestResult, bestClass, bestImage)
    }
    
    public func findBestCropHistogramCompare(originalImage: UIImage, bounds: [CGRect], completion: @escaping (Double, String, UIImage, CGRect)->(), error: ((String)->())? ){
        self.dispatchQueue.async {
            var bestResult = 0.0
            var bestImage:UIImage?
            var bestClass:String = "None"
            var bestBound: CGRect = CGRect(x: 0.0, y: 0.0, width: 0.0, height: 0.0)
            
            for bound in bounds {
                let croppedImg = CustomUtility.cropImage(imageToCrop: originalImage, toRect: bound)
                let (tempResult, tempClass, _) = self.findBestClassHistogramCompare(image: croppedImg)
                
                if tempResult > bestResult {
                    bestResult = tempResult
                    bestImage = croppedImg
                    bestClass = tempClass
                    bestBound = bound
                }
                
            }
            
            guard let bestImageMatch = bestImage else {
                if let error = error {
                    error("ImageComparator -> findBestCropHuCompare: Error parsing the image, maybe no image was found? Or there is bug?")
                }
                
                return
            }
            
            completion(bestResult, bestClass, bestImageMatch, bestBound)
        }
    }
    
    //////////////////////////////
    /// Gray histogram compare ///
    //////////////////////////////
    
    public func findBestClassHistogramGrayCompare(image: UIImage, completion: @escaping (Double, String, UIImage)->(), error: ((String)->())? ) {
        self.dispatchQueue.async {
            let (bestResult, bestClass, bestImg) = self.findBestClassHistogramGrayCompare(image: image)
            
            if let img = bestImg {
                completion(bestResult, bestClass, img)
            } else {
                if let error = error {
                    error("ImageComparator -> findbestClassHistogramGrayCompare: Error parsing the bestImage. Maybe no image was found?")
                }
            }
        }
    }
    
    private func findBestClassHistogramGrayCompare(image: UIImage) -> (Double, String, UIImage?) {
        // 1. Look for the best score compared to the method 1 within a class
        // 2. Compare with the best results from the other classes
        // 3. return the class with the best result
        
        var bestResult = 0.0
        var tempResult = 0.0
        var bestClass = "light"
        var bestImage: UIImage?
        
        for img in self.lightCoffeeArray {
            tempResult = OpenCVWrapper.compare(usingGrayScaleHistograms: image, with: img)
//            tempResult = OpenCVWrapper.compare(usingHistograms: image, with: img)
            if tempResult > bestResult {
                bestResult = tempResult
                bestClass = "light"
                bestImage = img
            }
        }
        
        for img in self.darkCoffeeArray {
            tempResult = OpenCVWrapper.compare(usingGrayScaleHistograms: image, with: img)
//            tempResult = OpenCVWrapper.compare(usingHistograms: image, with: img)
            if tempResult > bestResult {
                bestResult = tempResult
                bestClass = "dark"
                bestImage = img
            }
        }
        
        for img in self.fancyCoffeeArray {
            tempResult = OpenCVWrapper.compare(usingGrayScaleHistograms: image, with: img)
//            tempResult = OpenCVWrapper.compare(usingHistograms: image, with: img)
            if tempResult > bestResult {
                bestResult = tempResult
                bestClass = "fancy"
                bestImage = img
            }
        }
        
        return ( bestResult, bestClass, bestImage)
    }
    
    public func findBestCropHistogramGrayCompare(originalImage: UIImage, bounds: [CGRect], completion: @escaping (Double, String, UIImage, CGRect)->(), error: ((String)->())? ){
        self.dispatchQueue.async {
            var bestResult = 0.0
            var bestImage:UIImage?
            var bestClass:String = "None"
            var bestBound: CGRect = CGRect(x: 0.0, y: 0.0, width: 0.0, height: 0.0)
            
            for bound in bounds {
                let croppedImg = CustomUtility.cropImage(imageToCrop: originalImage, toRect: bound)
                let (tempResult, tempClass, _) = self.findBestClassHistogramGrayCompare(image: croppedImg)
                
                if tempResult > bestResult {
                    bestResult = tempResult
                    bestImage = croppedImg
                    bestClass = tempClass
                    bestBound = bound
                }
                
            }
            
            guard let bestImageMatch = bestImage else {
                if let error = error {
                    error("ImageComparator -> findBestCropHistogramGrayCompare: Error parsing the image, maybe no image was found? Or there is bug?")
                }
                
                return
            }
            
            completion(bestResult, bestClass, bestImageMatch, bestBound)
        }
    }
    
    
    /////////////////
    /// HuCompare ///
    /////////////////
    
    public func findBestClassHuCompare(captureImage: UIImage, completion: @escaping (Double, String, UIImage) -> (), error: ((String)->())? ){
        dispatchQueue.async {
            let (bestResult, bestClass, bestImage) = self.findBestClassHuCompare(captureImage: captureImage)
            if let bestImage = bestImage {
                
                completion(bestResult, bestClass, bestImage)
            } else {
                
                guard let error = error else { return }
                error("ImageComparator -> findBestClassHuCompare: Error while parsing best image")
            }
        }
    }
    
    private func findBestClassHuCompare(captureImage: UIImage) -> (Double, String, UIImage?){
        var bestResult = 0.0
        var tempResult = 0.0
        var bestClass = "light"
        var bestImage: UIImage?
        
        for image in self.darkCoffeeArray {
            tempResult = OpenCVWrapper.compare(usingContoursMatch: captureImage, with: image)
            if tempResult > bestResult {
                bestClass = "dark"
                bestResult = tempResult
                bestImage = image
            }
        }
        
        for image in self.lightCoffeeArray {
            tempResult = OpenCVWrapper.compare(usingContoursMatch: captureImage, with: image)
            if tempResult > bestResult {
                bestClass = "light"
                bestResult = tempResult
                bestImage = image
            }
        }
        
        for image in self.fancyCoffeeArray {
            tempResult = OpenCVWrapper.compare(usingContoursMatch: captureImage, with: image)
            if tempResult > bestResult {
                bestClass = "fancy"
                bestResult = tempResult
                bestImage = image
            }
        }
        
        return (bestResult, bestClass, bestImage)
        
    }
    
    public func findBestClassColorHistogramCompare(image: UIImage, completion: () -> ()){
        completion()
        
    }
    
    public func findBestClassGrayHistogramCompare(image: UIImage, completion: () -> ()){
        completion()
    }
    
    // MARK: - Custom functions
    public func findBestCropHuCompare(originalImages: [UIImage], completion: @escaping (Double, String, UIImage)->(), error: ((String)->())? ){
        self.dispatchQueue.async {
            var bestResult = 0.0
            var bestImage:UIImage?
            var bestClass:String = "None"
            for originalImage in originalImages {
                let (tempResult, tempClass, _) = self.findBestClassHuCompare(captureImage: originalImage)
                
                if tempResult > bestResult {
                    bestResult = tempResult
                    bestImage = originalImage
                    bestClass = tempClass
                }
            }
            guard let bestImageMatch = bestImage else {
                if let error = error {
                    error("ImageComparator -> findBestCropHuCompare: Error parsing the image, maybe no image was found? Or there is bug?")
                }
                return
            }
            completion(bestResult, bestClass, bestImageMatch)
        }
    }
    
    private func findBestCropHistogramCompare(originalImages: [UIImage], completion: @escaping (Double, String, UIImage)->(), error: ((String)->())? ){
        self.dispatchQueue.async {
            
            var bestResult = 0.0
            var bestImage:UIImage?
            var bestClass:String = "None"
            for originalImage in originalImages {
                let (tempResult, tempClass, _) = self.findBestClassHistogramCompare(image: originalImage)
                
                if tempResult > bestResult {
                    bestResult = tempResult
                    bestImage = originalImage
                    bestClass = tempClass
                }
            }
            
            guard let bestImageMatch = bestImage else {
                if let error = error {
                    error("ImageComparator -> findBestCropHistogramCompare: Error parsing the image, maybe no image was found? Or there is bug?")
                }
                return
            }
            completion(bestResult, bestClass, bestImageMatch)
        }
    }
    
    
    
    // MARK: - Other functions

    
    // MARK: - Singleton implementation
    private static var singletonPrivateInstance: ImageComparator = {
        let singleton = ImageComparator()
        
        // Configuration
        // ...
        
        return singleton
    }()
    
    class func shared() -> ImageComparator {
        return singletonPrivateInstance
    }
    
}
