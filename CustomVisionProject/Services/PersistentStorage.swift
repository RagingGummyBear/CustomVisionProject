
import Foundation
import PromiseKit

// TIP: Make this class a protocol so it is easier to change the types of persistent storage that you might need
class PersistentStorage {

    // MARK: - Properties
    let saveLoadQueue = DispatchQueue.init(label: "com.seavus.customvision.persistent-storage")
    var captureSaveWorkItem: DispatchWorkItem?
    
    // MARK: - Functions
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
            }) .catch({ (error: Error) in
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
                    
                    seal.fulfill(true)
                    do {
                        try FileManager.default.moveItem(at: fromDirectoryHigh, to: toDirectoryHigh)
                        try FileManager.default.moveItem(at: fromDirectoryMedium, to: toDirectoryMedium)
                        try FileManager.default.moveItem(at: fromDirectoryThumbnail, to: toDirectoryThumbnail)
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
        var photoDirector = self.getSavedPhotoDirectory()
        
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
