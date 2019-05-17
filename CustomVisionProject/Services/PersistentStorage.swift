
import Foundation
import PromiseKit

// TIP: Make this class a protocol so it is easier to change the types of persistent storage that you might need
class PersistentStorage {

    // MARK: - Properties
    let saveLoadQueue = DispatchQueue.init(label: "com.seavus.customvision.persistent-storage")
    var captureSaveWorkItem: DispatchWorkItem?
    
    // MARK: - Captured Photo Functions
    public func hasCapturedPhoto() -> Promise<Bool> {
        return Promise { resolve in
            let capturePhotoDirectory = self.getCapturedPhotoURL()
            
            let highCapture = capturePhotoDirectory.appendingPathComponent("high_quality.jpeg")
            let mediumCapture = capturePhotoDirectory.appendingPathComponent("medium_quality.jpeg")
            let thumbnail = capturePhotoDirectory.appendingPathComponent("thumbnail_quality.jpeg")
            
            resolve.fulfill(FileManager.default.fileExists(atPath: highCapture.path)
                && FileManager.default.fileExists(atPath: mediumCapture.path)
                && FileManager.default.fileExists(atPath: thumbnail.path))
        }
    }
    
    public func saveCapturedPhoto(uiImage: UIImage) -> Promise<Bool> {
        return Promise {[unowned self] seal in
            self.saveLoadQueue.async { [unowned self] in
                let capturePhotoDirectory = self.getCapturedPhotoURL()
                
                let highCapture = capturePhotoDirectory.appendingPathComponent("high_quality.jpeg")
                let mediumCapture = capturePhotoDirectory.appendingPathComponent("medium_quality.jpeg")
                let thumbnail = capturePhotoDirectory.appendingPathComponent("thumbnail_quality.jpeg")
                
                let highQuality = uiImage.jpegData(compressionQuality: 1.0)
                
                var tempImg = CustomUtility.imageWithWidth(sourceImage: uiImage, scaledToWidth: uiImage.size.width * 0.7)
                let mediumQuality = tempImg.jpegData(compressionQuality: 1.0)
                
                tempImg = CustomUtility.imageWithWidth(sourceImage: uiImage, scaledToWidth: 250)
                let thumbnailQuality = tempImg.jpegData(compressionQuality: 0.7)
                
                //Checks if file exists, removes it if so.
                if FileManager.default.fileExists(atPath: highCapture.path) {
                    do {
                        try FileManager.default.removeItem(atPath: highCapture.path)
                        try FileManager.default.removeItem(atPath: mediumCapture.path)
                        try FileManager.default.removeItem(atPath: thumbnail.path)
                    } catch let removeError {
                        print("couldn't remove file at path", removeError)
                    }
                }
                
                do {
                    try highQuality!.write(to: highCapture)
                } catch let error {
                    print("error saving high quality with error", error)
                    seal.reject(error)
                }
                
                do {
                    try mediumQuality!.write(to: mediumCapture)
                } catch let error {
                    print("error saving medium quality with error", error)
                    seal.reject(error)
                }
                
                do {
                    try thumbnailQuality!.write(to: thumbnail)
                } catch let error {
                    print("error saving thumbnail quality with error", error)
                    seal.reject(error)
                }
                
                seal.fulfill(true)
            }
        }
    }
    
    public func getHighQualityCaptured() -> Promise<UIImage> {
        return Promise { [unowned self] seal in
            self.hasCapturedPhoto().done({[unowned self] (result: Bool) in
                if (result){
                    let capturePhotoDirectory = self.getCapturedPhotoURL()
                    let highCapture = capturePhotoDirectory.appendingPathComponent("high_quality.jpeg")
                    let image = UIImage(contentsOfFile: highCapture.path)
                    if let img = image {
                        seal.fulfill(img)
                    } else {
                        seal.reject(NSError(domain: "DataProvider -> getHighQualityCapture: image not found", code: 404, userInfo: nil))
                    }
                } else {
                    seal.reject(NSError(domain: "DataProvider -> getHighQualityCapture: no image capture", code: 404, userInfo: nil))
                }
            }).catch({ (error: Error) in
                seal.reject(error)
            })
        }
    }
    
    public func getMediumQualityCaptured() -> Promise<UIImage> {
        return Promise { [unowned self] seal in
            self.hasCapturedPhoto().done({[unowned self] (result: Bool) in
                if (result){
                    let capturePhotoDirectory = self.getCapturedPhotoURL()
                    let mediumCapture = capturePhotoDirectory.appendingPathComponent("medium_quality.jpeg")
                    let image = UIImage(contentsOfFile: mediumCapture.path)
                    if let img = image {
                        seal.fulfill(img)
                    } else {
                        seal.reject(NSError(domain: "DataProvider -> getMediumQualityCapture: image not found", code: 404, userInfo: nil))
                    }
                } else {
                    seal.reject(NSError(domain: "DataProvider -> getMediumQualityCapture: no image capture", code: 404, userInfo: nil))
                }
            }) .catch({ (error: Error) in
                seal.reject(error)
            })
        }
    }
    
    public func getThumbnailQualityCaptured() -> Promise<UIImage> {
        return Promise { [unowned self] seal in
            self.hasCapturedPhoto().done({[unowned self] (result: Bool) in
                if (result){
                    let capturePhotoDirectory = self.getCapturedPhotoURL()
                    let thumbnailCapture = capturePhotoDirectory.appendingPathComponent("thumbnail_quality.jpeg")
                    let image = UIImage(contentsOfFile: thumbnailCapture.path)
                    if let img = image {
                        seal.fulfill(img)
                    } else {
                        seal.reject(NSError(domain: "DataProvider -> getThumbnailQualityCapture: image not found", code: 404, userInfo: nil))
                    }
                } else {
                    seal.reject(NSError(domain: "DataProvider -> getThumbnailQualityCapture: no image capture", code: 404, userInfo: nil))
                }
            }) .catch({ (error: Error) in
                seal.reject(error)
            })
        }
    }
    
    public func moveCapturedToSaved(foundClasses: [String]) -> Promise<Bool> {
        return Promise { [unowned self] seal in
            self.hasCapturedPhoto().done({ (result: Bool) in
                if !result {
                    seal.fulfill(false)
                    return
                }
                
                self.saveLoadQueue.async {
                    let uuid = self.generateImageName()
                    let toDirectoryHigh = self.getSaveDirectoryForPhoto(photoDirectoryName: uuid).appendingPathComponent("high_quality.jpeg")
                    let fromDirectoryHigh = self.getCapturedPhotoURL().appendingPathComponent("high_quality.jpeg")
                    
                    let toDirectoryMedium = self.getSaveDirectoryForPhoto(photoDirectoryName: uuid).appendingPathComponent("medium_quality.jpeg")
                    let fromDirectoryMedium = self.getCapturedPhotoURL().appendingPathComponent("medium_quality.jpeg")
                    
                    let toDirectoryThumbnail = self.getSaveDirectoryForPhoto(photoDirectoryName: uuid).appendingPathComponent("thumbnail_quality.jpeg")
                    let fromDirectoryThumbnail = self.getCapturedPhotoURL().appendingPathComponent("thumbnail_quality.jpeg")
                    
                    do {
                        try FileManager.default.moveItem(at: fromDirectoryHigh, to: toDirectoryHigh)
                        try FileManager.default.moveItem(at: fromDirectoryMedium, to: toDirectoryMedium)
                        try FileManager.default.moveItem(at: fromDirectoryThumbnail, to: toDirectoryThumbnail)
                        
                        let date = Date()
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "dd/MM/yyyy"
                        
                        let likedCoffeeModel = LikedCoffeeModel(saveDirectoryName: uuid, savedDate: dateFormatter.string(from: date), foundClasses: foundClasses)
                        
                        self.saveCoffeeModel(coffeeModel: likedCoffeeModel).done({ (result: Bool) in
                            seal.fulfill(result)
                        }).catch({ (error: Error) in
                            seal.reject(error)
                        })
                    } catch let error {
                        print(error)
                        seal.reject(error)
                    }
                }
            }).catch({ (error: Error) in
                seal.reject(error)
            })
        }
    }
    
    // MARK: - Liked Coffee Model Functions
    public func readCoffeeModel(uuid:String) -> Promise<LikedCoffeeModel> {
        return Promise { seal in
            self.readAllCoffeeModels().done({ (models: [LikedCoffeeModel]) in
                if let model = models.first(where: { (elem: LikedCoffeeModel) -> Bool in
                    return elem.saveDirectoryName == uuid
                }) {
                    seal.fulfill(model)
                } else {
                    seal.reject(NSError(domain: "PersistentStorage -> readCoffeeModel: Requested model not found", code: 404, userInfo: nil))
                }
            }) .catch({ (error: Error) in
                seal.reject(error)
            })
        }
    }
    
    public func readAllCoffeeModels() -> Promise<[LikedCoffeeModel]> {
        return Promise { seal in
            do {
                let data = try Data(contentsOf: self.getLikedCoffeeDataURL())
                do {
                    let elements = try JSONDecoder().decode([LikedCoffeeModel].self, from: data)
                    seal.fulfill(elements)
                } catch let error {
                    seal.reject(error)
                }
            } catch let err {
                seal.reject(err)
            }
        }
    }
    
    private func saveCoffeeModel(coffeeModel: LikedCoffeeModel) -> Promise<Bool> {
        return Promise { seal in
            self.readAllCoffeeModels().done({ (result: [LikedCoffeeModel]) in
                
                if result.contains(where: { (elem: LikedCoffeeModel) -> Bool in
                    return elem.saveDirectoryName == coffeeModel.saveDirectoryName
                }) {
                    seal.fulfill(false)
                    return
                }
                
                var newArray = result
                newArray.insert(coffeeModel, at: 0)
                
                self.saveCoffeeModels(coffeeModels: newArray).done({ (result: Bool) in
                    seal.fulfill(result)
                }) .catch({ (error: Error) in
                    seal.reject(error)
                })
            }).catch({ (error: Error) in
                seal.reject(error)
            })
        }
    }
    
    private func saveCoffeeModels(coffeeModels: [LikedCoffeeModel]) -> Promise<Bool> {
        return Promise { seal in
            do {
                let archiveData = try JSONEncoder().encode(coffeeModels)
                try archiveData.write(to: self.getLikedCoffeeDataURL())
                seal.fulfill(true)
            } catch let err {
                seal.reject(err)
            }
        }
    }
    
    private func removeCoffeeModel(coffeeModel: LikedCoffeeModel) -> Promise<Bool> {
        return self.removeCoffeeModel(withId: coffeeModel.saveDirectoryName)
    }
    
    private func removeCoffeeModel(withId: String) -> Promise<Bool> {
        return Promise { seal in
            self.readAllCoffeeModels().done({ (models: [LikedCoffeeModel]) in
                var newArray = models
                
                newArray.removeAll(where: { (elem: LikedCoffeeModel) -> Bool in
                    return elem.saveDirectoryName == withId
                })
                
                if newArray.count < models.count {
                    self.saveCoffeeModels(coffeeModels: newArray).done({ (result: Bool) in
                        seal.fulfill(result)
                    }) .catch({ (error: Error) in
                        seal.reject(error)
                    })
                } else {
                    seal.fulfill(false)
                }
            }) .catch({ (error: Error) in
                seal.reject(error)
            })
        }
    }
    
    // MARK: - Saved Photo Functions
    func fetchThumbnailPhoto(fromModel: LikedCoffeeModel) -> Promise<UIImage> {
        return Promise { seal in
            let savedPhotoDirectory = self.getSaveDirectoryForPhoto(photoDirectoryName: fromModel.saveDirectoryName).appendingPathComponent("thumbnail_quality.jpeg")
            let image = UIImage(contentsOfFile: savedPhotoDirectory.path)
            if let img = image {
                seal.fulfill(img)
            } else {
                seal.reject(NSError(domain: "DataProvider -> getHighQualityCapture: image not found", code: 404, userInfo: nil))
            }
        }
    }
    
    func fetchHighQualityPhoto(fromModel: LikedCoffeeModel) -> Promise<UIImage> {
        return Promise { seal in
            let savedPhotoDirectory = self.getSaveDirectoryForPhoto(photoDirectoryName: fromModel.saveDirectoryName).appendingPathComponent("high_quality.jpeg")
            let image = UIImage(contentsOfFile: savedPhotoDirectory.path)
            if let img = image {
                seal.fulfill(img)
            } else {
                seal.reject(NSError(domain: "DataProvider -> getHighQualityCapture: image not found", code: 404, userInfo: nil))
            }
        }
    }
    
    func fetchMediumQualityPhoto(fromModel: LikedCoffeeModel) -> Promise<UIImage> {
        return Promise { seal in
            let savedPhotoDirectory = self.getSaveDirectoryForPhoto(photoDirectoryName: fromModel.saveDirectoryName).appendingPathComponent("medium_quality.jpeg")
            let image = UIImage(contentsOfFile: savedPhotoDirectory.path)
            if let img = image {
                seal.fulfill(img)
            } else {
                seal.reject(NSError(domain: "DataProvider -> getHighQualityCapture: image not found", code: 404, userInfo: nil))
            }
        }
    }
    
    public func deleteLikedCoffee( coffeeModel: LikedCoffeeModel) -> Promise<Bool> {
        return Promise { seal in
            self.removeCoffeeModel(coffeeModel: coffeeModel).done({ (result: Bool) in

                let savedPhotoDirectoryH = self.getSaveDirectoryForPhoto(photoDirectoryName: coffeeModel.saveDirectoryName).appendingPathComponent("high_quality.jpeg")
                let savedPhotoDirectoryM = self.getSaveDirectoryForPhoto(photoDirectoryName: coffeeModel.saveDirectoryName).appendingPathComponent("medium_quality.jpeg")
                let savedPhotoDirectoryT = self.getSaveDirectoryForPhoto(photoDirectoryName: coffeeModel.saveDirectoryName).appendingPathComponent("thumbnail_quality.jpeg")
                
                do {
                    try FileManager.default.removeItem(at: savedPhotoDirectoryH)
                } catch let error {
                    seal.reject(error)
                    return
                }
                
                do {
                    try FileManager.default.removeItem(at: savedPhotoDirectoryM)
                } catch let error {
                    seal.reject(error)
                    return
                }
                
                do {
                    try FileManager.default.removeItem(at: savedPhotoDirectoryT)
                } catch let error {
                    seal.reject(error)
                    return
                }
                seal.fulfill(true)
            }).catch({ (error: Error) in
                seal.reject(error)
            })
        }
    }
    
    
    // MARK: - URL generation functions
    private func getLikedCoffeeDataURL() -> URL {
        let path = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        var documentsDirectoryURL = path.appendingPathComponent("likedCoffee")
        if !FileManager.default.fileExists(atPath: documentsDirectoryURL.path) {
            _ = try? FileManager.default.createDirectory(at: documentsDirectoryURL, withIntermediateDirectories: true, attributes: nil)
        }
        documentsDirectoryURL = documentsDirectoryURL.appendingPathComponent("likedCoffeeArray.likedcoffeemodel")
        if !FileManager.default.fileExists(atPath: documentsDirectoryURL.path) {
            FileManager.default.createFile(atPath: documentsDirectoryURL.path, contents: nil, attributes: nil)
            do {
                let elems = [LikedCoffeeModel]()
                let archiveData = try JSONEncoder().encode(elems)
                try archiveData.write(to: documentsDirectoryURL)
            } catch let error {
                print(error)
            }
        }
        return documentsDirectoryURL
    }
    
    
    private func getCapturedPhotoURL() -> URL {
        let path = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        let capturedPhotoDirectory = path.appendingPathComponent("capturedPhoto")
        if !FileManager.default.fileExists(atPath: capturedPhotoDirectory.path) {
            _ = try? FileManager.default.createDirectory(at: capturedPhotoDirectory, withIntermediateDirectories: true, attributes: nil)
        }
        return capturedPhotoDirectory
    }
    
    private func getSavedPhotoDirectory() -> URL {
        let path = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        let savedPhotoDirectory = path.appendingPathComponent("savedPhotos")
        if !FileManager.default.fileExists(atPath: savedPhotoDirectory.path) {
            _ = try? FileManager.default.createDirectory(at: savedPhotoDirectory, withIntermediateDirectories: true, attributes: nil)
        }
        return savedPhotoDirectory
    }
    
    private func getSaveDirectoryForPhoto(photoDirectoryName:String) -> URL {
        var savedPhotoDirectory = self.getSavedPhotoDirectory()
        savedPhotoDirectory = savedPhotoDirectory.appendingPathComponent(photoDirectoryName)
        if !FileManager.default.fileExists(atPath: savedPhotoDirectory.path) {
            _ = try? FileManager.default.createDirectory(at: savedPhotoDirectory, withIntermediateDirectories: true, attributes: nil)
        }
        return savedPhotoDirectory
    }
    
    private func generateImageName() -> String {
        let photoDirector = self.getSavedPhotoDirectory()
        
        var flag = true
        
        while(flag){
            let uuid = UUID().uuidString
            if !FileManager.default.fileExists(atPath: photoDirector.appendingPathComponent(uuid).path) {
                flag = false;
                return uuid
            }
        }
        
    }

}
