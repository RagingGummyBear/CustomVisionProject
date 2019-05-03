//
//  PhotoProcessCoordinator.swift
//  CustomVisionProject
//
//  Created by Seavus on 4/25/19.
//  Copyright © 2019 Seavus. All rights reserved.
//

import Foundation
import UIKit

class PhotoProcessCoordinator:NSObject, Coordinator {

    // MARK: - Class properties
    lazy var dataProvider = { () -> DataProvider in
        if let parent = self.parentCoordinator {
            return parent.getDataProvider()
        } else {
            return DataProvider()
        }
    }()

    weak var parentCoordinator: Coordinator?
    weak var viewController: PhotoProcessViewController!

    var childCoordinators = [Coordinator]()
    var navigationController: UINavigationController
    
    var photoDrawingService = PhotoDrawingService()
    
    // MARK: - Custom properties
    var photoProcessed = false
    var capturedPhoto: UIImage!
    var bestBound = CGRect(x: 0.0, y: 0.0, width: 1, height: 1)
    var foundClasses = [String]()
    var aspectFit = CGSize(width: 0,height: 0)

    var privateThreadSafeProcessingQueue = DispatchQueue.init(label: "com.seavus.imageprocessing.processing", attributes: .concurrent)
    
    // MARK: - Initialization
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    // MARK: - Protocol implementation
    func start(){
        self.navigationController.delegate = self // This line is a must do not remove
        self.viewController = PhotoProcessViewController.instantiate()
        self.viewController.coordinator = self
        self.viewController.selectedImage = capturedPhoto
        self.navigationController.setNavigationBarHidden(self.viewController.navigationBarHidden, animated: true)
        self.navigationController.pushViewController(self.viewController, animated: true)
    }

    func childPop(_ child: Coordinator?){
        self.navigationController.delegate = self // This line is a must do not remove
        
        // Default code used for removing of child coordinators // TODO: refactor it
        for (index, coordinator) in childCoordinators.enumerated() {
            if coordinator === child {
                childCoordinators.remove(at: index)
                break
            }
        }
    }

    internal func getDataProvider() -> DataProvider {
        return self.dataProvider
    }

    // MARK: - Transition functions
    // These are the functions that can be called by the view controller as well

    func requestReturnToMainMenu(){
        self.photoProcessed = false
        self.navigationController.popViewController(animated: true)
    }
    
    func transitionToFortuneDisplay(foundClasses: [String]){
        // TODO: change it so it doesnt have to provide found classes
        if foundClasses.count > 0 || self.foundClasses.count > 0 {
            self.foundClasses.append(contentsOf: foundClasses)
            self.photoProcessed = true
        } else {
            self.photoProcessed = false
        }
        self.navigationController.popViewController(animated: true)
    }


    // MARK: - Logic functions
    // These are the functions that may be called by the viewcontroller. Example: Request for data, update data, etc.
    func CGSizeAspectFit(aspectRatio: CGSize, boundingSize: CGSize) -> CGSize
    {
        var aspectFitSize = CGSize(width: boundingSize.width, height: boundingSize.height);
        let mW = boundingSize.width / aspectRatio.width;
        let mH = boundingSize.height / aspectRatio.height;
        if( mH < mW ){
            aspectFitSize.width = mH * aspectRatio.width;
        }
        else if( mW < mH ){
            aspectFitSize.height = mW * aspectRatio.height;
        }
        return aspectFitSize;
    }
    
    func canFinishDrawing() -> Bool {
        return self.photoDrawingService.canFinishDrawing()
    }
    
    func userTouchBegin(location: CGPoint){
        self.photoDrawingService.touchBegin(location: location)
    }
    
    func userTouchMoved(location: CGPoint){
        self.photoDrawingService.touchMoved(location: location)
    }
    
    func userTouchEnd(location: CGPoint){
        self.photoDrawingService.touchEnded(location: location)
    }
    
    func getDrawingRect() -> CGRect {
        /* *** Needed offset here? *** */
        self.bestBound = self.photoDrawingService.getRect()
        
//        if self.bestBound.origin.x < 0 {
//            self.bestBound.origin.x = 0
//        }
//        
//        if self.bestBound.origin.y < 0 {
//            self.bestBound.origin.y = 0
//        }
//        
//        if self.bestBound.origin.x + self.bestBound.width > self.aspectFit.width {
//            self.bestBound.size.width = self.aspectFit.width - self.bestBound.origin.x   // <<<< ---- FIX THIS AS-AP  <<<< -----
//        }
//        
//        if self.bestBound.origin.y + self.bestBound.height > self.aspectFit.height {
//            self.bestBound.size.height = self.aspectFit.height - self.bestBound.origin.y   // <<<< ---- FIX THIS AS-AP  <<<< -----
//        }
        
        return self.bestBound
    }

    func clearAllDrawings() {
        self.photoDrawingService.clearAllDrawings()
    }
    
    func setBestBound(bestBound: CGRect){
        self.bestBound = bestBound
    }
 
    // MARK - User input functions
    func clearAllDrawingsAction(){
        self.clearAllDrawings()
        self.viewController.clearAllDrawings()
    }
    
    func doneDrawingAction(){
        if(!self.canFinishDrawing()){
            return;
        }
        
        self.viewController.setupViewForProcessing()
        self.viewController.startImageProcessing()
    }
    
    // MARK - Processing functions
    
    func startImageProcessing(){
        // Coffee texture density
        self.privateThreadSafeProcessingQueue.async {
            self.getPartialCoffeClass()
        }
        
        // Gets bound size + bound position class ( focus of the coffe )
        self.privateThreadSafeProcessingQueue.async {
            self.getBestBoundClass()
        }
        
        // Random factor
        self.privateThreadSafeProcessingQueue.async {
            self.getOverallRGBClass()
        }
        
        // Random factor
        self.privateThreadSafeProcessingQueue.async {
            self.getPartialRGBClass()
        }
        
        // Get image texture complexity
        self.privateThreadSafeProcessingQueue.async {
            self.getCoffeeComplexityClass()
        }
        
        // Get image background class
        self.privateThreadSafeProcessingQueue.async {
            self.getBackgroundClass()
        }
    }
    
    func getCoffeeComplexityClass(){
        let coffeeClass = OpenCVWrapper.find_contours_count(self.capturedPhoto, withBound: self.bestBound, withThreshold: 40)
        self.foundClasses.append("coffee_\(coffeeClass)")
        DispatchQueue.main.async {
            self.viewController.progressBar.progress += 0.09
        }
    }
    
    func getBestBoundClass(){
        // Classify based on the sizes and location of the best bound
        guard let image = self.capturedPhoto else {
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
            self.viewController.progressBar.progress += 0.09
        }
    }
    
    func getOverallRGBClass(){
        // RGB values based on the whole image
        if let image = self.capturedPhoto {
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
            self.viewController.progressBar.progress += 0.09
        }
    }
    
    
    func getPartialRGBClass(){
        // RGB values based on best bound
        if let image = self.capturedPhoto {
            let array = OpenCVWrapper.find_rgb_values(image, withBound: self.bestBound)
            
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
            self.viewController.progressBar.progress += 0.09
        }
    }
    
    func getPartialCoffeClass(){
        if let image = self.capturedPhoto {
            let bestClass = OpenCVWrapper.get_yeeted(image, withBound: self.bestBound);
            self.foundClasses.append("\(bestClass)")
        }
    }
    
    func getBackgroundClass(){
        let bestBackgroundClass = OpenCVWrapper.get_yeeted_background(self.capturedPhoto, withBound: self.bestBound)
        self.foundClasses.append("background_class_\(bestBackgroundClass)")
    }

    /* ************************************************************* */
    // Sadly I don't know how to put this code into the protocol :( //
    /* ************************************************************* */

    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        // Read the view controller we’re moving from.
        guard let fromViewController = navigationController.transitionCoordinator?.viewController(forKey: .from) else {
            return
        }

        // Check whether our view controller array already contains that view controller. If it does it means we’re pushing a different view controller on top rather than popping it, so exit.
        if navigationController.viewControllers.contains(fromViewController) {
            return
        }

        if let parent = self.parentCoordinator {
            parent.childPop(self)
        }
    }
}
