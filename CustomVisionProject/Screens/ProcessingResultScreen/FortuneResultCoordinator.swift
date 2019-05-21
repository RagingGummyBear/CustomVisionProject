//
//  FortuneResultCoordinator.swift
//  CustomVisionProject
//
//  Created by Seavus on 4/25/19.
//  Copyright © 2019 Seavus. All rights reserved.
//

import Foundation
import UIKit
import PromiseKit

class FortuneResultCoordinator:NSObject, Coordinator {

    // MARK: - Class properties
    lazy var dataProvider = { () -> DataProvider in
        if let parent = self.parentCoordinator {
            return parent.getDataProvider()
        } else {
            return DataProvider()
        }
    }()

    weak var parentCoordinator: Coordinator?
    weak var viewController: FortuneResultViewController!

    var childCoordinators = [Coordinator]()
    var navigationController: UINavigationController
    
    
    private var textGenerator = TextGenerator()
    
    public var foundClasses: [String]!
    
    var popupBuilder = PopUpBuilder()

    // MARK: - Initialization
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    // MARK: - Protocol implementation
    func start(){
        self.navigationController.delegate = self // This line is a must do not remove
        self.viewController = FortuneResultViewController.instantiate()
        self.viewController.coordinator = self
        self.navigationController.setNavigationBarHidden(self.viewController.navigationBarHidden, animated: true)
        self.navigationController.pushViewController(self.viewController, animated: true)
        
        if self.foundClasses.count == 0 {
            self.requestReturnToMainMenu()
        } else {
            self.textGenerator.foundClasses = self.foundClasses
        }
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

    func shouldHideNavigationBar() -> Bool{
        return self.viewController.navigationBarHidden
    }
    
    internal func getDataProvider() -> DataProvider {
        return self.dataProvider
    }

    // MARK: - Transition functions
    // These are the functions that can be called by the view controller as well
    func requestReturnToMainMenu(){
        self.navigationController.popViewController(animated: true)
    }
    
    // MARK: - Logic functions
    // These are the functions that may be called by the viewcontroller. Example: Request for data, update data, etc.

    func shareImage() {
        let img = self.viewController.originalImageView.image
        let messageStr = self.viewController.shortDescriptionLabel.text
        let activityViewController:UIActivityViewController = UIActivityViewController(activityItems:  [img!, messageStr!], applicationActivities: nil)
        activityViewController.excludedActivityTypes = [UIActivity.ActivityType.print, UIActivity.ActivityType.postToWeibo, UIActivity.ActivityType.copyToPasteboard, UIActivity.ActivityType.addToReadingList, UIActivity.ActivityType.postToVimeo]
        self.viewController.present(activityViewController, animated: true, completion: nil)
    }
    

    // MARK: - Others
    
    func generateShortDescription() -> String {
//        return textGenerator.generateShortText()
        return textGenerator.generateShortTextSync()
    }
    
    func generateLongDescription() -> String {
        return textGenerator.generateBingDebugText()
    }
    
    func requestThumbnailCaptureImage() -> Promise<UIImage> {
        return Promise { [unowned self] seal in
            self.dataProvider.getThumbnailQualityCaptured()
                .done({ (result: UIImage) in
                    seal.fulfill(result)
                })
                .catch({ [unowned self] (error: Error) in
                    self.dataProvider.getHighQualityCaptured()
                        .done({ (result:UIImage) in
                            seal.fulfill(result)
                        })
                        .catch({ (error: Error) in
                            seal.reject(error)
                        })
                })
        }
    }
    
    func requestSaveCapturedImage(){
        self.dataProvider.moveCapturedToSaved(foundClasses: self.foundClasses)
            .done { (result: Bool) in
                if result {
//                    let popup = self.popupBuilder.okSimplePopup(title: "Photo saved! 👌", message: "Your coffee photo and data were saved. You can access them at any time and share them! 🤩")
//                    self.viewController.presentPopup(popupDialog: popup)
                    self.viewController.toastMessage(message: "Your coffee photo and data were saved. You can access them at any time and share them! 🤩")
                } else {
//                    let popup = self.popupBuilder.okSimplePopup(title: "Photo not saved! 😕", message: "Your coffee photo and data were not saved. You probably already saved them. 🤷‍♂️")
//                    self.viewController.presentPopup(popupDialog: popup)
                    self.viewController.toastMessage(message: "Your coffee photo and data were not saved. You probably already saved them. 🤷‍♂️")
                }
            }
            .catch { (error: Error) in
//                let popup = self.popupBuilder.okSimplePopup(title: "Photo not saved! 😕", message: "Your coffee photo and data were not saved. You probably already saved them. 🤷‍♂️")
//                self.viewController.presentPopup(popupDialog: popup)
                self.viewController.toastMessage(message: "Your coffee photo and data were not saved. You probably already saved them. 🤷‍♂️")
                print(error)
            }
    }
    
    func sendLikeButtonPressed(){
        let popup = self.popupBuilder.likeThankPopup()
        self.viewController.presentPopup(popupDialog: popup)
    }
    
    /* ************************************************************ */
    // Sadly I don't know how to put this code into the protocol :( //
    /* ************************************************************ */

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
