//
//  .swift
//  CameraCollection
//
//  Created by Seavus on 1/9/19.
//  Copyright © 2019 Seavus. All rights reserved.
//

import UIKit
import Foundation

import RealmSwift

class PhotosMemoryManagment {
    
    private func generateImageUid () -> (String) {
        return UUID().uuidString
    }
    
    func saveImage(image: UIImage) -> String {
        guard let data = image.jpegData(compressionQuality: 1) ?? image.pngData() else {
            return "saveFailed"
        }
        
        let thumbnailImage = self.resizeImage(image: image, targetSize: CGSize(width: image.size.width / 4, height: image.size.height / 4))
        guard let dataThumbnail = thumbnailImage.jpegData(compressionQuality: 1) ?? image.pngData() else {
            return "saveFailed"
        }
        
        if !FileManager.default.fileExists(atPath: self.getImagesDocumentPath()) {
            do {
                try FileManager.default.createDirectory(atPath: self.getImagesDocumentPath(), withIntermediateDirectories: false, attributes: nil)
            } catch {
                print(error.localizedDescription)
            }
        }
        
        if !FileManager.default.fileExists(atPath: self.getThumbnailDocumentPath()) {
            do {
                try FileManager.default.createDirectory(atPath: self.getThumbnailDocumentPath(), withIntermediateDirectories: false, attributes: nil)
            } catch {
                print(error.localizedDescription)
            }
        }
        
        do {
            
            let imageData = ImageData()
            
            imageData.id = self.generateImageUid()
            
            if let url = self.getImagesDocumentUrl() {
                imageData.imagePath = url.appendingPathComponent("\(imageData.id).png").path
                try data.write(to: url.appendingPathComponent("\(imageData.id).png"))
                //                return imgId
            } else {
                return "saveFailed"
            }
            
            if let url = self.getThumbnailDocumentUrl() {
                imageData.thumbnailPath = url.appendingPathComponent("\(imageData.id).png").path
                try dataThumbnail.write(to: url.appendingPathComponent("\(imageData.id).png"))
            } else {
                return "saveFailed"
            }
            
            imageData.temp = true
            
            self.saveImageDataFromRealm(data: imageData)
            
            return imageData.id
            
        } catch {
            print(error.localizedDescription)
            return "saveFailed"
        }
    }
    
    func getSavedImage(imageId: String) -> UIImage? {
//        let imageData: Data = try! Data(contentsOf: (self.getImagesDocumentUrl()?.appendingPathComponent("/\(imageId).png"))! )
//        print(UIImage(data: imageData, scale: UIScreen.main.scale))
        return UIImage(contentsOfFile: self.getImagesDocumentPath() + "/\(imageId).png")
//        return UIImage(data: imageData, scale: UIScreen.main.scale)
    }
    
    func getSavedImageAsync(completion: @escaping (Bool, UIImage?)->(), imageId: String){
        DispatchQueue.global(qos: .background).async {
            if let img = self.getSavedImage(imageId: imageId) {
                completion(false, img)
            } else {
                completion(true, nil)
            }
        }
    }
    
    func getSavedThumbnail (imageId: String) -> UIImage? {
        return UIImage(contentsOfFile: self.getThumbnailDocumentPath() + "/\(imageId).png")
    }
    
    func removeImage(withId: String) {
        do {
            try FileManager.default.removeItem(atPath: self.getImagesDocumentPath() + "/\(withId).png")
        }
        catch {
            // Probably not fatal
            print(error.localizedDescription)
        }
    }
    
    func removeThumbnail(withId: String) {
        do {
            try FileManager.default.removeItem(atPath: self.getThumbnailDocumentPath() + "/\(withId).png")
        }
        catch {
            // Probably not fatal
            print(error.localizedDescription)
        }
    }

    
    func nukeStoredData(){
        let results = self.getAllImageDataFromRealm()
        for result in results {
            self.removeImageFromRealm(imageData: result)
        }
    }
    
    func removeImagesWithId(imageIds: [String]){
        for id in imageIds {
            self.removeImageFromRealm(imageId: id)
        }
    }
    
    
    func getThumbnailDocumentPath() -> String {
        guard let directory = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false) else {
            return ""
        }
        return (directory.appendingPathComponent("Thumbnail").path)
    }
    
    func getImagesDocumentPath() -> String {
        guard let directory = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false) else {
            return ""
        }
        return (directory.appendingPathComponent("Images").path)
    }
    
    func getThumbnailDocumentUrl() -> URL? {
        guard let directory = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false) else {
            return nil
        }
        return directory.appendingPathComponent("Thumbnail")
    }
    
    func getImagesDocumentUrl() -> URL? {
        guard let directory = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false) else {
            return nil
        }
        return directory.appendingPathComponent("Images")
    }
    
    
    func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size
        
        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height
        
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        }
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
    func clearAllTempImages(){
        let tempImages = self.getAllTempImageDataFromRealm()
        for imageData in tempImages {
            self.removeImageFromRealm(imageData: imageData)
        }
    }
    
    func approveTempImages(imageIds : [String]){
        for imageId in imageIds {
            self.approveTempImageFromRealm(imageId: imageId)
        }
    }
    
    func approveAllTempImages(){
        let tempImages = self.getAllTempImageDataFromRealm()
        
        for imageData in tempImages {
            self.approveTempImageFromRealm(imageId: imageData.id)
        }
    }
    
    /////////////////////
    // Realm functions //
    /////////////////////
    func saveImageDataFromRealm(data: ImageData){
        let realm = try! Realm()
        
        try! realm.write {
            realm.add(data)
        }
    }
    
    func approveTempImageFromRealm(imageId:String){
        let imageData = self.getImageDataFromRealm(imageId: imageId)
        
        autoreleasepool {
            let realm = try! Realm()
            try! realm.write {
                imageData.temp = false
            }
        }
//        self.saveImageDataFromRealm(data: imageData)
    }
    
    func getAllImageDataFromRealm() -> Results<ImageData> {
        return autoreleasepool { () -> Results<ImageData> in
            let realm = try! Realm()
            return realm.objects(ImageData.self).filter("temp == \(false)")
        }
    }
    
    func getImageDataFromRealm( imageId: String ) -> ImageData {
        return autoreleasepool { () -> ImageData in
            let realm = try! Realm()
            return realm.objects(ImageData.self).filter("id == '\(imageId)'")[0]
        }
    }
    
    func getAllTempImageDataFromRealm() -> Results<ImageData> {
        return autoreleasepool { () -> Results<ImageData> in
            let realm = try! Realm()
            return realm.objects(ImageData.self).filter("temp == \(true)")
        }
    }
    
    func removeImageFromRealm(imageId : String) {
        let imageData = self.getImageDataFromRealm(imageId: imageId)
        self.removeImageFromRealm(imageData: imageData)
    }
    
    func removeImageFromRealm(imageData : ImageData){
        self.removeImage(withId: imageData.id)
        self.removeThumbnail(withId: imageData.id)
        
        autoreleasepool {
            let realm = try! Realm()
            try! realm.write {
                realm.delete(imageData)
            }
        }
    }
    
}
