//
//  FortuneResultCoordinator.swift
//  CustomVisionProject
//
//  Created by Seavus on 4/25/19.
//  Copyright © 2019 Seavus. All rights reserved.
//

import Foundation
import UIKit

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
    public var capturedImage: UIImage!
    

    // MARK: - Initialization
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    // MARK: - Protocol implementation
    func start(){
        self.textGenerator.foundClasses = self.foundClasses
        self.navigationController.delegate = self // This line is a must do not remove
        self.viewController = FortuneResultViewController.instantiate()
        self.viewController.coordinator = self
        self.viewController.capturedImage = capturedImage
        self.viewController.foundClasses = foundClasses
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

    func shareImage() {
        let img = self.viewController.originalImageView.image
        let messageStr = self.viewController.shortDescriptionLabel.text
        let activityViewController:UIActivityViewController = UIActivityViewController(activityItems:  [img!, messageStr!], applicationActivities: nil)
        activityViewController.excludedActivityTypes = [UIActivity.ActivityType.print, UIActivity.ActivityType.postToWeibo, UIActivity.ActivityType.copyToPasteboard, UIActivity.ActivityType.addToReadingList, UIActivity.ActivityType.postToVimeo]
        self.viewController.present(activityViewController, animated: true, completion: nil)
    }
    

    // MARK: - Others
    
    func generateShortDescription() -> String {
        return textGenerator.generateClassText()
    }
    
    func generateLongDescription() -> String {
        return textGenerator.generateBingDebugText()
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
