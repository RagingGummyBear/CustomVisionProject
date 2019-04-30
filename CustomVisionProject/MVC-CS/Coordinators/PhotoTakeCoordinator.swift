//
//  PhotoTakeCoordinator.swift
//  CustomVisionProject
//
//  Created by Seavus on 4/25/19.
//  Copyright © 2019 Seavus. All rights reserved.
//

import Foundation
import UIKit

class PhotoTakeCoordinator:NSObject, Coordinator, CameraPhotoTakeDelegate {

    // MARK: - Class properties
    lazy var dataProvider = { () -> DataProvider in
        if let parent = self.parentCoordinator {
            return parent.getDataProvider()
        } else {
            return DataProvider()
        }
    }()

    weak var parentCoordinator: Coordinator?
    weak var viewController: PhotoTakeViewController!

    var childCoordinators = [Coordinator]()
    var navigationController: UINavigationController
    
    // MARK: - Custom properties
    
    var photoTaken = false
    var capturedPhoto: UIImage!
    var cameraCaptureService: CameraCaptureService!
    

    // MARK: - Initialization
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    // MARK: - Protocol implementation
    func start(){
        self.navigationController.delegate = self // This line is a must do not remove
        self.viewController = PhotoTakeViewController.instantiate()
        self.viewController.coordinator = self
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
//    func photoCapturedTransition(){
//        self.photoTaken = true
//        self.navigationController.popViewController(animated: true)
//    }
    
    // MARK: - Logic functions
    // These are the functions that may be called by the viewcontroller. Example: Request for data, update data, etc.
    
    func startCameraSetup(){
        self.cameraCaptureService = CameraCaptureService(cameraPhotoTakeDelegate: self,
            cameraPreviewImageView: self.viewController.cameraPreviewImageView, overCameraImageView: self.viewController.overCameraImageView, captureButton: self.viewController.takePhotoButton, coffeeIndicatorLabel: self.viewController.coffeeIndicatorLabel)
        self.cameraCaptureService.setupCamera()
    }
    
    func takePhoto(){
        self.cameraCaptureService.capturePhotoAction()
    }
    
    func photoTaken(photo: UIImage) {
        self.photoTaken = true
        self.capturedPhoto = photo
        DispatchQueue.main.async {
            
            self.navigationController.popViewController(animated: true)
        }
    }
    
    func setupFailed(){
        self.photoTaken = true
        
        let bundlePath = Bundle.main.path(forResource: "photo4", ofType: "jpg")
        self.capturedPhoto = UIImage(contentsOfFile: bundlePath!)
        
        DispatchQueue.main.async {
            self.navigationController.popViewController(animated: true)
        }
    }

    // MARK: - Others


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
