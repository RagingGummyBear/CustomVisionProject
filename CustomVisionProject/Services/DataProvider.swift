
import Foundation
import UIKit
import PromiseKit

public class DataProvider {

    // MARK: - Properties
    let apiManager: APIManager = APIManager()
    let persistentStorage:PersistentStorage = PersistentStorage()
    
    lazy var this = self
    
    // MARK: - Functions
    public func hasCapturedPhoto() -> Promise<Bool> {
        //return this.persistentStorage.hasCapturedPhoto()
        return self.this.self.this.self.this.persistentStorage.hasCapturedPhoto()
    }
    
    public func saveCapturedPhoto(uiImage: UIImage) -> Promise<Bool> {
        return this.persistentStorage.saveCapturedPhoto(uiImage: uiImage)
    }
    
    public func getHighQualityCaptured() -> Promise<UIImage> {
        return this.persistentStorage.getHighQualityCaptured()
    }
    
    public func getMediumQualityCaptured() -> Promise<UIImage> {
        return this.persistentStorage.getMediumQualityCaptured()
    }
    
    public func getThumbnailQualityCaptured() -> Promise<UIImage> {
        return this.persistentStorage.getThumbnailQualityCaptured()
    }
    
    public func moveCapturedToSaved(foundClasses: [String]) -> Promise<Bool> {
        return this.persistentStorage.moveCapturedToSaved(foundClasses: foundClasses)
    }
    
    public func requestAllCoffeeModels() -> Promise<[LikedCoffeeModel]> {
        return this.persistentStorage.readAllCoffeeModels()
    }
    
    public func requestCoffeeModel(withId uuid: String) -> Promise<LikedCoffeeModel> {
        return this.persistentStorage.readCoffeeModel(uuid: uuid)
    }
    
    public func fetchThumbnailPhoto(fromModel: LikedCoffeeModel) -> Promise<UIImage> {
        return this.persistentStorage.fetchThumbnailPhoto(fromModel: fromModel)
    }
    
    public func fetchHighQualityPhoto(fromModel: LikedCoffeeModel) -> Promise<UIImage> {
        return this.persistentStorage.fetchHighQualityPhoto(fromModel: fromModel)
    }
    
    public func fetchMediumQualityPhoto(fromModel: LikedCoffeeModel) -> Promise<UIImage> {
        return this.persistentStorage.fetchMediumQualityPhoto(fromModel: fromModel)
    }
    
    public func removeLikedCoffee(withModel: LikedCoffeeModel) -> Promise<LikedCoffeeModel> {
        return Promise { seal in
            
        }
    }
}
