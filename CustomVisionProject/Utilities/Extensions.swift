//
//  Extensions.swift
//  CustomVisionProject
//
//  Created by Seavus on 3/1/19.
//  Copyright © 2019 Seavus. All rights reserved.
//

import Foundation

@IBDesignable extension UIButton {
    
    @IBInspectable var borderWidth: CGFloat {
        set {
            layer.borderWidth = newValue
        }
        get {
            return layer.borderWidth
        }
    }
    
    @IBInspectable var cornerRadius: CGFloat {
        set {
            layer.cornerRadius = newValue
        }
        get {
            return layer.cornerRadius
        }
    }
    
    @IBInspectable var borderColor: UIColor? {
        set {
            guard let uiColor = newValue else { return }
            layer.borderColor = uiColor.cgColor
        }
        get {
            guard let color = layer.borderColor else { return nil }
            return UIColor(cgColor: color)
        }
    }
}


// Image extension
extension UIImage {
    
    func updateImageOrientionUpSide() -> UIImage? {
        if self.imageOrientation == .up {
            return self
        }
        
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
        self.draw(in: CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height))
        if let normalizedImage:UIImage = UIGraphicsGetImageFromCurrentImageContext() {
            UIGraphicsEndImageContext()
            return normalizedImage
        }
        UIGraphicsEndImageContext()
        return nil
    }
}


extension Double {
    /// Rounds the double to decimal places value
    func rounded(toPlaces places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}


extension UIView {
    func checkIfPointInView( point: CGPoint) -> Bool {
        if(point.x >= 0 && point.x <= self.frame.width){
            if(point.y >= 0 && point.y <= self.frame.height){
                return true
            }
        }
        return false
    }
    
    func fitRectInView( rect: inout CGRect ) {
        
        if rect.origin.x < 0 {
            rect.origin.x = 0
        }
        
        if rect.origin.y < 0 {
            rect.origin.y = 0
        }
        
        if rect.origin.x + rect.width > self.frame.width {
            rect.size.width = self.frame.width
        }
        
        if rect.origin.y + rect.height > self.frame.height {
            rect.size.height = self.frame.height
        }
    }
}

extension UIColor {
    static func uicolorFromHex(rgbValue:UInt32)->UIColor{
        let red = CGFloat((rgbValue & 0xFF0000) >> 16)/256.0
        let green = CGFloat((rgbValue & 0xFF00) >> 8)/256.0
        let blue = CGFloat(rgbValue & 0xFF)/256.0
        
        return UIColor(red:red, green:green, blue:blue, alpha:1.0)
    }
}
