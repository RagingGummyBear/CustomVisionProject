//
//  PhotoTakeCoordinator.swift
//  CustomVisionProject
//
//  Created by Seavus on 4/25/19.
//  Copyright © 2019 Seavus. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

class PhotoTakeCoordinator:NSObject, Coordinator {

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
        self.navigationController.setNavigationBarHidden(self.viewController.navigationBarHidden, animated: true)
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
    
    func shouldHideNavigationBar() -> Bool{
        return self.viewController.navigationBarHidden
    }

    internal func getDataProvider() -> DataProvider {
        return self.dataProvider
    }
    
    // MARK: - Transition functions
    // These are the functions that can be called by the view controller as well
    
    // MARK: - Logic functions
    // These are the functions that may be called by the viewcontroller. Example: Request for data, update data, etc.
    
    func startCameraSetup(){
        self.cameraCaptureService = CameraCaptureService(coordinator: self)
        self.cameraCaptureService.setupCamera()
    }
    
    func takePhoto(){
        self.cameraCaptureService.capturePhotoAction()
    }
    
    func photoTaken(photo: UIImage) {
        self.dataProvider.saveCapturedPhoto(uiImage: photo).done { (saved: Bool) in
            if saved {
                self.photoTaken = true
                DispatchQueue.main.async {
                    self.navigationController.popViewController(animated: true)
                }
            }
        }.catch { (error: Error) in
            print(error)
        }
    }
    
    func useDebugPhoto(){
        self.cameraCaptureService.stop()
        self.setupFailed()
    }
    
    func setupFailed(){
        
        self.photoTaken = true // This should be false
        /* *** Only for debug *** */
        let bundlePath = Bundle.main.path(forResource: "photo7", ofType: "jpg")
        self.dataProvider.saveCapturedPhoto(uiImage: UIImage(contentsOfFile: bundlePath!)!)
            .done { (saved: Bool) in
                if saved {
                    self.photoTaken = true
                    DispatchQueue.main.async {
                        self.navigationController.popViewController(animated: true)
                    }
                }
            }.catch { (error: Error) in
                print(error)
            }
        /* ********************** */
    }

    // MARK: - Others
    func captureButtonEnable(){
        self.viewController.takePhotoButton.isEnabled = true
        self.viewController.coffeeIndicatorLabel.text = "Coffee detected"
    }
    
    func captureButtonDisable(){
        self.viewController.takePhotoButton.isEnabled = false
        self.viewController.coffeeIndicatorLabel.text = "Coffee not detected"
    }
    
    func getCameraPreviewFrame() -> CGRect {
        return self.viewController.getCameraPreviewFrame()
    }
    
    func setCameraPreviewLayer(previewLayer: AVCaptureVideoPreviewLayer){
        self.viewController.setCameraPreviewLayer(previewLayer: previewLayer)
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
        
        if fromViewController != self.viewController {
            return
        }

        if let parent = self.parentCoordinator {
            parent.childPop(self)
        }
    }
}
