//
//  TextGenerator.swift
//  CustomVisionProject
//
//  Created by Seavus on 2/27/19.
//  Copyright © 2019 Seavus. All rights reserved.
//

import Foundation

class TextGenerator {
    // MARK: - Properties
    var foundClasses = [String]()
    private let dispatchQueue = DispatchQueue.init(label: "imageComparator", attributes: .concurrent)
    
    public func generateShortText(completion: @escaping (String) -> ()){
        self.dispatchQueue.async { [weak self] in
            var result = ""
            for className in self!.foundClasses {
                if className != self?.foundClasses.first {
                    if className == self?.foundClasses.last {
                       result.append(" and ")
                    } else {
                        result.append(", ")
                    }
                }
                
                var short_text: String? = ""
                if className.contains("contour_complexity"){
                    short_text = self?.generateShortContourComplexity(className: className)
                } else if className.contains("bound-size"){
                    short_text = self?.generateShortBoundSize(className: className)
                } else if className.contains("bound-pos"){
                    short_text = self?.generateShortBoundPos(className: className)
                } else if className.contains("rgb-full"){
                    short_text = self?.generateShortRgbFull(className: className)
                } else if className.contains("rgb-partial"){
                    short_text = self?.generateShortRgbPartial(className: className)
                } else if className.contains("coffee_class"){
                    short_text = self?.generateShortCoffeeClass(className: className)
                } else if className.contains("background_class"){
                    short_text = self?.generateShortBackgroundClass(className: className)
                }
                
                if let translatedClass = short_text {
                    result.append(translatedClass)
                }
                
            }
            completion(result)
        }
    }
    
    
    public func generateShortTextSync() -> String {
        var result = ""
        
        self.dispatchQueue.sync { [weak self] in
            
            for className in self!.foundClasses {
                if className != self?.foundClasses.first {
                    if className == self?.foundClasses.last {
                        result.append(" and ")
                    } else {
                        result.append(", ")
                    }
                }
                
                var short_text: String? = ""
                if className.contains("contour_complexity"){
                    short_text = self?.generateShortContourComplexity(className: className)
                } else if className.contains("bound-size"){
                    short_text = self?.generateShortBoundSize(className: className)
                } else if className.contains("bound-pos"){
                    short_text = self?.generateShortBoundPos(className: className)
                } else if className.contains("rgb-full"){
                    short_text = self?.generateShortRgbFull(className: className)
                } else if className.contains("rgb-partial"){
                    short_text = self?.generateShortRgbPartial(className: className)
                } else if className.contains("coffee_class"){
                    short_text = self?.generateShortCoffeeClass(className: className)
                } else if className.contains("background_class"){
                    short_text = self?.generateShortBackgroundClass(className: className)
                }
                
                if let translatedClass = short_text {
                    result.append(translatedClass)
                }
                
            }
        }
        
        return result
    }
    
    
    public func generateClassText() -> String {
        var shortLabel = ""
        for foundClass in self.foundClasses {
            shortLabel += foundClass + ", "
        }
        
        return shortLabel
    }
    
    public func generateBingDebugText() -> String {
        return "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Phasellus sollicitudin a sem non dignissim. Aenean non tincidunt ligula, vitae vestibulum libero. Curabitur vel justo ac lorem iaculis placerat eu sit amet justo. In a erat lorem. Suspendisse condimentum vitae magna a malesuada. Nullam finibus iaculis rhoncus. Aenean imperdiet blandit mauris, vel eleifend sapien vehicula ut. Nunc mollis porta lectus. Integer ut nibh ante. Vivamus quis risus nec ex fermentum maximus vel ut erat. In a malesuada justo. Vivamus viverra eget enim nec tincidunt.\nInteger elementum odio maximus maximus placerat. In hac habitasse platea dictumst. Integer facilisis iaculis est a interdum. Quisque commodo mollis pretium. Ut in lorem dapibus, viverra arcu vel, dapibus mi. Vivamus accumsan mauris a nisl sagittis egestas. Phasellus tristique venenatis odio eu facilisis. Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas. Integer velit ligula, imperdiet in posuere et, ornare pulvinar est. Nam dui dolor, sodales vel interdum at, vehicula ac enim. Phasellus mollis ut nunc ut tristique."
    }
    
    public func generateLongText() -> String {
        return "To be implemented"
    }

    
    // MARK: - Contour_complexity
    private func generateShortContourComplexity(className: String) -> String {
        // coffee_low_contour_complexity, coffee_high_contour_complexity, coffee_medium_contour_complexity
        if className.contains("low") {
            return "Coffee texture is with low complexity"
        } else if className.contains("medium") {
            return "Coffee texture is with medium complexity"
        } else if className.contains("high"){
            return "Coffee texture is with high complexity"
        }
        return ""
    }
    
    // MARK: - Bound-size
    private func generateShortBoundSize(className: String) -> String {
        if className.contains("big"){
            return "Big bounding size" // If the user selected correctly the coffee takes bigger portion of the screen
        } else if className.contains("mixed") {
            return "Mixed bounding size" // If the user selected correctly the coffee takes mixed portion of the screen
        } else if className.contains("small"){
            return "Small bounding size" // If the user selected correctly the coffee takes mixed portion of the screen
        }
        return ""
    }
    
    // MARK: - Bound-pos
    private func generateShortBoundPos(className: String) -> String {
        if className.contains("bot-right") {
            return "Coffee position is in the bottom-right part of the image"
        } else if className.contains("bot-left") {
            return "Coffee position is in the bottom-left part of the image"
        } else if className.contains("up-right") {
            return "Coffee position is in the upper-right part of the image"
        } else if className.contains("up-left") {
            return "Coffee position is in the upper-left part of the image"
        }
        
        return ""
    }
    
    // MARK: - Rgb-full
    private func generateShortRgbFull(className: String) -> String {
        if className.contains("blue") {
            return "Highest full photo pixel color value is blue"
        } else if className.contains("red") {
            return "Highest full photo pixel color value is red"
        } else if className.contains("green") {
            return "Highest full photo pixel color value is green"
        }
        return ""
    }
    
    // MARK: - Rgb-partial
    private func generateShortRgbPartial(className: String) -> String {
        if className.contains("blue") {
            return "Highest partial photo pixel color value is blue"
        } else if className.contains("red") {
            return "Highest partial photo pixel color value is red"
        } else if className.contains("green") {
            return "Highest partial photo pixel color value is green"
        }
        return ""
    }
    
    // MARK: - Coffee_class
    private func generateShortCoffeeClass(className: String) -> String {
        if className.contains("dark") {
            return "The coffee has dark color"
        } else if className.contains("light") {
            return "The coffee has light color"
        } else if className.contains("water") || className.contains("empty_notfound") {
            return "No coffee was found in the selected area"
        }
        return ""
    }
    
    // MARK: - Background_class
    private func generateShortBackgroundClass(className: String) -> String {
        if className.contains("red") {
            return "The background has red color"
        } else if className.contains("green") {
            return "The background has green color"
        } else if className.contains("blue") {
            return "The background has blue color"
        } else if className.contains("white") {
            return "The background has white color"
        } else if className.contains("dark") {
            return "The background has dark color"
        } else if className.contains("brown") {
            return "The background has brown color"
        }
        
        return ""
    }

}
