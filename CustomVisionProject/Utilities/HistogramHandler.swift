//
//  HistogramHandler.swift
//  CustomVisionProject
//
//  Created by Seavus on 2/21/19.
//  Copyright © 2019 Seavus. All rights reserved.
//

import Foundation
import UIKit

class HistogramHandler {
    
    // MARK: - Histogram arrays.
    private var lightCoffeeHistograms: [NSMutableArray] = []
    private var darkCoffeeHistograms: [NSMutableArray] = []
    private var fancyCoffeeHistograms: [NSMutableArray] = []
    
    // Debug only since the histograms dont give good results
    private var lightCoffeeImages: [UIImage] = []
    private var darkCoffeeImages: [UIImage] = []
    private var fancyCoffeeImages: [UIImage] = []

    // MARK: - Class properties.
    
    // MARK: - Init functions.
    
    public func generateHistograms(){
        // 1. check if all histograms are loaded
        // 2. try to fetch the not loaded histograms
        // 3. generate the histograms if were unable to load
        if self.lightCoffeeHistograms.count == 0 {
            self.fetchLightCoffeeHistograms()
            if self.lightCoffeeHistograms.count == 0 {
                self.generateLightCoffeeHistograms()
                self.saveLightCoffeeHistograms()
            }
        }
        
        if self.darkCoffeeHistograms.count == 0 {
            self.fetchDarkCoffeeHistograms()
            if self.darkCoffeeHistograms.count == 0 {
                self.generateDarkCoffeeHistograms()
                self.saveDarkCoffeeHistograms()
            }
        }
        
        if self.fancyCoffeeHistograms.count == 0 {
            self.fetchFancyCoffeeHistograms()
            if self.fancyCoffeeHistograms.count == 0 {
                self.generateFancyCoffeeHistograms()
                self.saveFancyCoffeeHistograms()
            }
        }
    }
    
    
    // MARK: - Generating functions. These generate and save the histograms.
    private func generateDarkCoffeeHistograms(){
        var imgs = [UIImage]()
        imgs.append(#imageLiteral(resourceName: "dark_coffee_4"))
        imgs.append(#imageLiteral(resourceName: "dark_coffee_1"))
        imgs.append(#imageLiteral(resourceName: "dark_coffee_3"))
        imgs.append(#imageLiteral(resourceName: "dark_coffee_2"))
        
        for img in imgs {
            let mutable = OpenCVWrapper.create_histogram_color(img)
            self.darkCoffeeHistograms.append(mutable)
        }
        
        self.darkCoffeeImages = imgs
    }
    
    private func generateLightCoffeeHistograms(){
        var imgs = [UIImage]()
        imgs.append(#imageLiteral(resourceName: "light_coffee_3"))
        imgs.append(#imageLiteral(resourceName: "light_coffee_4"))
        imgs.append(#imageLiteral(resourceName: "light_coffee_1"))
        imgs.append(#imageLiteral(resourceName: "light_coffee_2"))
        
        for img in imgs {
            let mutable = OpenCVWrapper.create_histogram_color(img)
            self.lightCoffeeHistograms.append(mutable)
        }
        
        self.lightCoffeeImages = imgs
    }
    
    private func generateFancyCoffeeHistograms(){
        var imgs = [UIImage]()
        imgs.append(#imageLiteral(resourceName: "fancy_coffee_1"))
        imgs.append(#imageLiteral(resourceName: "fancy_coffe_3"))
        imgs.append(#imageLiteral(resourceName: "fancy_coffee_2"))
        
        for img in imgs {
            let mutable = OpenCVWrapper.create_histogram_color(img)
            self.darkCoffeeHistograms.append(mutable)
        }
        
        self.fancyCoffeeImages = imgs
    }
    
    // MARK: - Save functions. These try to save the histograms in current memory to local storage
    private func saveDarkCoffeeHistograms(){
        
    }
    
    private func saveLightCoffeeHistograms(){
        
    }
    
    private func saveFancyCoffeeHistograms(){
        
    }
    
    
    // MARK: - Fetch functions. These try to retrieve histograms from local memory
    private func fetchDarkCoffeeHistograms(){
        
    }
    
    private func fetchLightCoffeeHistograms(){
        
    }
    
    private func fetchFancyCoffeeHistograms(){
        
    }
    
    // MARK: - Public get functions. These are accessed from other classes.
    func getDarkCoffeeHistograms(){
        
    }
    
    func getLightCoffeeHistograms(){
        
    }
    
    func getFancyCoffeeHistograms(){
        
    }
    
    // MARK: - Other.
    
    func findTheBestClassHUCompare(image: UIImage) -> (String, Double, UIImage?) {
        // 1. Look for the best score compared to the method 1 within a class
        // 2. Compare with the best results from the other classes
        // 3. return the class with the best result
        if self.lightCoffeeHistograms.count == 0 {
            self.generateHistograms()
        }
        
        var bestResult = 0.0
        var tempResult = 0.0
        var bestClass = "light"
        var bestImage: UIImage?
        
        for img in self.lightCoffeeImages {
            tempResult = OpenCVWrapper.compare(usingContoursMatch: image, with: img)
            if tempResult > bestResult {
                bestResult = tempResult
                bestClass = "light"
                bestImage = img
            }
        }
        
        for img in self.darkCoffeeImages {
            tempResult = OpenCVWrapper.compare(usingContoursMatch: image, with: img)
            if tempResult > bestResult {
                bestResult = tempResult
                bestClass = "dark"
                bestImage = img
            }
        }
        
        for img in self.fancyCoffeeImages {
            tempResult = OpenCVWrapper.compare(usingContoursMatch: image, with: img)
            if tempResult > bestResult {
                bestResult = tempResult
                bestClass = "fancy"
                bestImage = img
            }
        }
        
        return (bestClass, bestResult, bestImage);
    }
    
    func findTheBestClass(image: UIImage) -> (String, Double, UIImage?, NSMutableArray?) {
        // 1. Look for the best score compared to the method 1 within a class
        // 2. Compare with the best results from the other classes
        // 3. return the class with the best result
        if self.lightCoffeeHistograms.count == 0 {
            self.generateHistograms()
        }
        
        var bestResult = 0.0
        var tempResult = 0.0
        var bestClass = "light"
        var bestHisto: NSMutableArray?
        var bestImage: UIImage?

        
//        
//        for histo in self.lightCoffeeHistograms {
//            tempResult = OpenCVWrapper.compareHistograms(image, withHistogramArray: histo)
//            if tempResult > bestResult {
//                bestResult = tempResult
//                bestHisto = histo
//                bestClass = "light"
//            }
//        }
//        
//        
//        for histo in self.darkCoffeeHistograms {
//            tempResult = OpenCVWrapper.compareHistograms(image, withHistogramArray: histo)
//            if tempResult > bestResult {
//                bestResult = tempResult
//                bestHisto = histo
//                bestClass = "dark"
//            }
//        }
//        
//        
//        for histo in self.fancyCoffeeHistograms {
//            tempResult = OpenCVWrapper.compareHistograms(image, withHistogramArray: histo)
//            if tempResult > bestResult {
//                bestResult = tempResult
//                bestHisto = histo
//                bestClass = "fancy"
//            }
//        }
        
        for img in self.lightCoffeeImages {
            tempResult = OpenCVWrapper.compareHistograms(image, with: img)
            if tempResult > bestResult {
                bestResult = tempResult
//                bestHisto = histo
                bestClass = "light"
                bestImage = img
            }
        }
        
        for img in self.darkCoffeeImages {
            tempResult = OpenCVWrapper.compareHistograms(image, with: img)
            if tempResult > bestResult {
                bestResult = tempResult
//                bestHisto = histo
                bestClass = "dark"
                bestImage = img
            }
        }
        
        for img in self.fancyCoffeeImages {
            tempResult = OpenCVWrapper.compareHistograms(image, with: img)
            if tempResult > bestResult {
                bestResult = tempResult
//                bestHisto = histo
                bestClass = "fancy"
                bestImage = img
            }
        }
        
        return (bestClass, bestResult, bestImage, bestHisto);
    }
    
    
    // MARK: - Singleton implementation
    
    private static var sharedHistogramHangler: HistogramHandler = {
        let histogramHandler = HistogramHandler()
        
        // Configuration
        // ...
        
        return histogramHandler
    }()
    
    private init() {
        
    }
    
    
    class func shared() -> HistogramHandler {
        return sharedHistogramHangler
    }
    
}
