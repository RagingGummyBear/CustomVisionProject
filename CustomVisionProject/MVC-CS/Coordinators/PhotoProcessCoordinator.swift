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
    var photoProcessed = true
    var capturedPhoto: UIImage!
    var foundClasses = [String]()

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

        // Do coordinator parsing //

        // ////////////////////// //

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



    // MARK: - Logic functions
    // These are the functions that may be called by the viewcontroller. Example: Request for data, update data, etc.

    
    // MARK: - Others
    
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
        return self.photoDrawingService.getRect()
    }

    func clearAllDrawings() {
        self.photoDrawingService.clearAllDrawings()
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
