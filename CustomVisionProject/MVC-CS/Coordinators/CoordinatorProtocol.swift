//___FILEHEADER___

import Foundation
import UIKit

public protocol Coordinator: NSObject, UINavigationControllerDelegate {
    var childCoordinators: [Coordinator] { get set }
    var navigationController: UINavigationController { get set }

    func start() // This is not too important function
    func getDataProvider() -> DataProvider
    func childPop(_ child: Coordinator?)
}
