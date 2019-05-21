//
//  LikedCoffeeCoordinator.swift
//  CustomVisionProject
//
//  Created by Seavus on 5/16/19.
//  Copyright © 2019 Seavus. All rights reserved.
//

import Foundation
import UIKit
import PromiseKit

class LikedCoffeeCoordinator:NSObject, Coordinator, PhotoFetchProtocol {
    
    var popupBuilder = PopUpBuilder()

    // MARK: - Class properties
    lazy var dataProvider = { () -> DataProvider in
        if let parent = self.parentCoordinator {
            return parent.getDataProvider()
        } else {
            return DataProvider()
        }
    }()

    weak var parentCoordinator: Coordinator?
    weak var viewController: LikedCoffeeViewController!

    var childCoordinators = [Coordinator]()
    var navigationController: UINavigationController
    
    var textGenerator = TextGenerator()

    // MARK: - Initialization
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    // MARK: - Protocol implementation
    func start(){
        self.navigationController.delegate = self // This line is a must do not remove
        self.viewController = LikedCoffeeViewController.instantiate()
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

    internal func getDataProvider() -> DataProvider {
        return self.dataProvider
    }

    // MARK: - Transition functions
    // These are the functions that can be called by the view controller as well


    // MARK: - Logic functions
    // These are the functions that may be called by the viewcontroller. Example: Request for data, update data, etc.
    func fetchThumbnailPhoto(fromModel: LikedCoffeeModel) -> Promise<UIImage> {
        return self.dataProvider.fetchThumbnailPhoto(fromModel: fromModel)
    }
    
    func fetchHighQualityPhoto(fromModel: LikedCoffeeModel) -> Promise<UIImage> {
        return self.dataProvider.fetchHighQualityPhoto(fromModel: fromModel)
    }
    
    func fetchMediumQualityPhoto(fromModel: LikedCoffeeModel) -> Promise<UIImage> {
        return self.dataProvider.fetchMediumQualityPhoto(fromModel: fromModel)
    }

    func requestAllLikedCoffeeModels() -> Promise<[LikedCoffeeModel]> {
        return self.dataProvider.requestAllCoffeeModels()
    }
    
    // MARK: - Others
    func shouldHideNavigationBar() -> Bool {
        return self.viewController.navigationBarHidden
    }
    
    func requestShortDescription(coffeeModel: LikedCoffeeModel) -> String {
        textGenerator.foundClasses = coffeeModel.foundClasses
        return textGenerator.generateShortTextSync()
    }
    
    func requestFullDescription(coffeeModel: LikedCoffeeModel) -> String {
        return textGenerator.generateBingDebugText()
    }
    
    private func requestRemoveSelectedCoffee(coffeeModel: LikedCoffeeModel){
        self.dataProvider.removeLikedCoffee(coffeeModel: coffeeModel).done { (result: Bool) in
            if result {
                self.dataProvider.requestAllCoffeeModels().done({ (models: [LikedCoffeeModel]) in
                    self.viewController.newCoffeeModelsData(models: models)
                    let popup = self.popupBuilder.okSimplePopup(title: "Removed coffee photo and data", message: "The selected coffee photo and data were removed!😭\nBut HEY! You get more memory now!🤟🤟")
                    self.viewController.presentPopup(popupDialog: popup)
                }).catch({ (error: Error) in
                    print(error)
                })
            }
        } .catch { (error: Error) in
            print(error)
        }
    }

    func starButtonPressed(){
        let popup = popupBuilder.okSimplePopup(title: "IT BECAME TRUE?", message: "IT is quite shocking that I can foretell the future! Shocking I know! 😎🔮")
        self.viewController.presentPopup(popupDialog: popup)
    }
    
    func removeSelectedButtonPressed(){
        let popup = popupBuilder.areYouSurePopup(title: "⚠️Remove selected⚠️", message: "Are you sure you want to remove the selected coffee shot? It will the photo and all of the data associated with it!") {
            self.removeSelectedCoffee()
        }
        self.viewController.presentPopup(popupDialog: popup)
    }
    
    private func removeSelectedCoffee(){
        print("GONNA REMOVE IT WHEN I GET IMPLEMENTED OK!?!?!?")
        if let mode = self.viewController.selectedCoffeeModel {
            self.requestRemoveSelectedCoffee(coffeeModel: mode)
        }
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
        
        if fromViewController != self.viewController {
            return
        }

        if let parent = self.parentCoordinator {
            parent.childPop(self)
        }
    }
}
