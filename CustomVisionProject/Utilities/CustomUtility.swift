//
//  CustomUtility.swift
//  
//
//  Created by Seavus on 3/1/19.
//

import Foundation

class CustomUtility {
    init(){
        
    }
    
    class func imageWithWidth (sourceImage:UIImage, scaledToWidth: CGFloat) -> UIImage {
        let oldWidth = sourceImage.size.width
        let scaleFactor = scaledToWidth / oldWidth
        
        let newHeight = sourceImage.size.height * scaleFactor
        let newWidth = oldWidth * scaleFactor
        
        UIGraphicsBeginImageContext(CGSize(width:newWidth, height:newHeight))
        sourceImage.draw(in: CGRect(x:0, y:0, width:newWidth, height:newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
    
    class func imageWithHeight (sourceImage:UIImage, scaledToHeight: CGFloat) -> UIImage {
        let oldHeight = sourceImage.size.height
        let scaleFactor = scaledToHeight / oldHeight
        
        let newHeight = sourceImage.size.height * scaleFactor
        let newWidth = oldHeight * scaleFactor
        
        UIGraphicsBeginImageContext(CGSize(width:newWidth, height:newHeight))
        sourceImage.draw(in: CGRect(x:0, y:0, width:newWidth, height:newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
    
    
    class func cropImage(){
        
    }
    
    class func cropImage(imageToCrop:UIImage, toRect rect:CGRect) -> UIImage {
        let imageRef:CGImage = imageToCrop.cgImage!.cropping(to: rect)!
        let cropped:UIImage = UIImage(cgImage:imageRef)
        return cropped
    }
    
}
