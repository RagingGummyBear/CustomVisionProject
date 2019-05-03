//___FILEHEADER___

import Foundation
import UIKit

class MainCoordinator:NSObject, Coordinator {

    // MARK: - Class properties
    lazy var dataProvider = { () -> DataProvider in
        if let parent = self.parentCoordinator {
            return parent.getDataProvider()
        } else {
            return DataProvider()
        }
    }()
    
    var quoteTimer: Timer?

    weak var parentCoordinator: Coordinator?
    weak var viewController: MainViewController!

    var childCoordinators = [Coordinator]()
    var navigationController: UINavigationController

    // MARK: - Initialization
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
        super.init()
        self.setupNavigationController()
    }
    
    func setupNavigationController(){
        self.navigationController.navigationBar.barTintColor = UIColor.uicolorFromHex(rgbValue: 0x391F0F)
        self.navigationController.navigationBar.tintColor = UIColor.uicolorFromHex(rgbValue: 0xF8981E)
        self.navigationController.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: "AmericanTypewriter-Semibold", size: 20)!, NSAttributedString.Key.foregroundColor:UIColor.uicolorFromHex(rgbValue: 0xF8981E)]
    }

    // MARK: - Protocol implementation
    func start(){
        self.navigationController.delegate = self // This line is a must do not remove
        self.viewController = MainViewController.instantiate()
        self.viewController.coordinator = self
        self.navigationController.isNavigationBarHidden = self.viewController.navigationBarHidden
        self.navigationController.pushViewController(self.viewController, animated: true)
    }

    func childPop(_ child: Coordinator?){
        self.navigationController.delegate = self // This line is a must do not remove
        
        self.navigationController.setNavigationBarHidden(self.viewController.navigationBarHidden, animated: true)

        // Do coordinator parsing //
        if let photoTakeCoordinator = child as? PhotoTakeCoordinator {
            if photoTakeCoordinator.photoTaken {
                self.goToPhotoProcess(photo: photoTakeCoordinator.capturedPhoto)
            }
        } else if let photoProcessCoordinator = child as? PhotoProcessCoordinator {
            if photoProcessCoordinator.photoProcessed {
                self.goToFortuneResult(photo: photoProcessCoordinator.capturedPhoto, foundClasses: photoProcessCoordinator.foundClasses)
            }
        }
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
     func goToPhotoTake() {
         let child = PhotoTakeCoordinator(navigationController: navigationController)
         child.parentCoordinator = self
         childCoordinators.append(child)
         child.start()
     }
    
    func goToPhotoProcess(photo: UIImage) {
        let child = PhotoProcessCoordinator(navigationController: navigationController)
        child.parentCoordinator = self
        childCoordinators.append(child)
        child.capturedPhoto = photo
        child.start()
    }
    
    func goToFortuneResult(photo: UIImage, foundClasses: [String]) {
        let child = FortuneResultCoordinator(navigationController: navigationController)
        child.parentCoordinator = self
        childCoordinators.append(child)
        child.foundClasses = foundClasses
        child.capturedImage = photo
        child.start()
    }
    
    // MARK: - Logic functions
    // These are the functions that may be called by the viewcontroller. Example: Request for data, update data, etc.
    func startSendingQuotes(){

        if let timer = quoteTimer {
            timer.invalidate()
        }
        
        if let quote = self.pickRandomQuote() {
            self.viewController.setQuote(quote: quote)
        }
        
        self.quoteTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true, block: { (timer: Timer) in
            if let quote = self.pickRandomQuote() {
                self.viewController.setQuote(quote: quote)
            }
        })
    }

    // MARK: - Others
    public func userRequestNewQuote(){
        self.startSendingQuotes()
    }

    private func pickRandomQuote() -> QuoteModel? {
        if let path = Bundle.main.path(forResource: "wittyCoffeeQuotes", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                let quotesContainer = try JSONDecoder().decode(WittyCoffeeQuotes.self, from: data);
                if quotesContainer.quotes.count > 0 {
                    return quotesContainer.quotes.randomElement()!
                }
                return nil
            } catch {
                // handle error
                print("Unable to load json")
            }
        }
        return nil
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
