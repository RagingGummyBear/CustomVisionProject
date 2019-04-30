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
        self.dispatchQueue.async {
            var result = ""
            for className in self.foundClasses {
                if className != self.foundClasses.first {
                    if className == self.foundClasses.last {
                       result.append(" and ")
                    } else {
                        result.append(", ")
                    }
                }
                if className.contains("bound"){
                    result.append(self.short_bound(className: className))
                } else if className.contains("rgb"){
                    result.append(self.short_rgb(className: className))
                } else if className.contains("hist"){
                    result.append(self.short_hist(className: className))
                } else if className.contains("background"){
                    result.append(self.short_background(className: className))
                }
            }
            completion(result)
        }
    }
    
    public func generateShortText() -> String {
        var result = ""
        for className in self.foundClasses {
            if className != self.foundClasses.first {
                if className == self.foundClasses.last {
                    result.append(" and ")
                } else {
                    result.append(", ")
                }
            }
            if className.contains("bound"){
                result.append(self.short_bound(className: className))
            } else if className.contains("rgb"){
                result.append(self.short_rgb(className: className))
            } else if className.contains("hist"){
                result.append(self.short_hist(className: className))
            } else if className.contains("background"){
                result.append(self.short_background(className: className))
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
    
    // MARK: - Short text functions
    
    // MARK: - Short Bound
    private func short_bound(className: String) -> String {
        if className.contains("size"){
            return self.short_bound_size(className:className)
        } else if className.contains("pos"){
            return self.short_bound_pos(className:className)
        }
        return ""
    }
    
    private func short_bound_size(className:String) -> String {
        if className.contains("big"){
            return short_bound_size_big()
        } else if className.contains("small"){
            return short_bound_size_small()
            
        } else if className.contains("mixed"){
            return short_bound_size_mixed()
        }
        return ""
    }
    
    private func short_bound_size_big() -> String {
        return "Focused"
    }
    
    private func short_bound_size_small() -> String {
        return "Objective"
    }
    
    private func short_bound_size_mixed() -> String {
        return "Creative"
    }
    
    private func short_bound_pos(className:String) -> String {
        if className.contains("bound-pos-bot-right"){
            return self.short_bound_pos_bot_right()
        } else if className.contains("bound-pos-bot-left"){
            return self.short_bound_pos_bot_left()
        } else if className.contains("bound-pos-up-right"){
            return self.short_bound_pos_up_right()
        } else if className.contains("bound-pos-up-left"){
            return self.short_bound_pos_up_left()
        }
        return ""
    }
    
    private func short_bound_pos_bot_right() -> String {
        return "Optimistic"
    }
    
    private func short_bound_pos_bot_left() -> String {
        return "Realistic"
    }
    
    private func short_bound_pos_up_right() -> String {
        return "Chill"
    }
    
    private func short_bound_pos_up_left() -> String {
        return "Fantasizing"
    }
    
    // MARK: - Short Histogram
    private func short_hist(className: String) -> String {
        if className.contains("full") {
            return short_hist_full(className: className)
        } else if className.contains("partial"){
            return short_hist_partial(className: className)
        }
        return ""
    }
    
    private func short_hist_full(className: String) -> String {
        if className.contains("fancy"){
            return short_hist_full_fancy()
        } else if className.contains("dark"){
            return short_hist_full_dark()
        } else if className.contains("light"){
            return short_hist_full_light()
        }
        return ""
    }
    
    private func short_hist_full_fancy() -> String {
        return "Wishful"
    }
    
    private func short_hist_full_dark() -> String {
        return "Mistery"
    }
    
    private func short_hist_full_light() -> String {
        return "Idea"
    }
    
    private func short_hist_partial(className: String) -> String {
        if className.contains("fancy"){
            return short_hist_partial_fancy()
        } else if className.contains("dark"){
            return short_hist_partial_dark()
        } else if className.contains("light"){
            return short_hist_partial_light()
        }
        return ""
    }
    
    private func short_hist_partial_fancy() -> String {
        return "Spare time at hand"
    }
    
    private func short_hist_partial_dark() -> String {
        return "Achievement INC"
    }
    
    private func short_hist_partial_light() -> String {
        return "Idea"
    }
    
    // MARK: - Short RGB
    private func short_rgb(className: String) -> String {
        
        if className.contains("full") {
            return self.short_rgb_full(className:className)
        } else if className.contains("partial"){
            return self.short_rgb_partial(className:className)
        }
        
        return ""
    }
    
    private func short_rgb_full(className: String) -> String {
        if className.contains("red"){
            return short_rgb_full_red()
        } else if className.contains("blue"){
            return short_rgb_full_blue()
        } else if className.contains("green"){
            return short_rgb_full_green()
        }
        return ""
    }
    
    private func short_rgb_full_red() -> String {
        return "Strive"
    }
    
    private func short_rgb_full_blue() -> String {
        return "Energy acquisition"
    }
    
    private func short_rgb_full_green() -> String {
        return "Healing"
    }
    
    private func short_rgb_partial(className: String) -> String {
        if className.contains("red"){
            return short_rgb_partial_red()
        } else if className.contains("blue"){
            return short_rgb_partial_blue()
        } else if className.contains("green"){
            return short_rgb_partial_green()
        }
        return ""
    }
    
    private func short_rgb_partial_red() -> String {
        return "Aggressive"
    }
    
    private func short_rgb_partial_blue() -> String {
        return "Calm"
    }
    
    private func short_rgb_partial_green() -> String {
        return "Luck"
    }
    
    // MARK: - Short Background
    private func short_background(className: String) -> String {
        
        if className.contains("white"){
            return self.generateShortTextBackgroundWhite()
        } else if className.contains("blue") {
            return self.generateShortTextBackgroundWhite()
        } else if className.contains("green") {
            return self.generateShortTextBackgroundGreen()
        } else if className.contains("red") {
            return self.generateShortTextBackgroundRed()
        } else if className.contains("brown") {
            return self.generateShortTextBackgroundBrown()
        } else if className.contains("asphalt") {
            return self.generateShortTextBackgroundAsphalt()
        }
        return ""
    }
    
    private func generateShortTextBackgroundBrown() -> String {
        return "Brown background"
    }
    
    private func generateShortTextBackgroundAsphalt() -> String {
        return "Asphalt background"
    }
    
    private func generateShortTextBackgroundGreen() -> String {
        return "Green background"
    }
    
    private func generateShortTextBackgroundBlue() -> String {
        return "Blue background"
    }
    
    private func generateShortTextBackgroundRed() -> String {
        return "Red background"
    }
    
    private func generateShortTextBackgroundWhite() -> String {
        return "White background"
    }
    
    
    // MARK: - Long text functions
    
    // MARK: - Long Background
    
    private func long_background(className: String) -> String {
        if className.contains("white"){
            return self.generateLongTextBackgroundWhite()
        } else if className.contains("blue") {
            return self.generateLongTextBackgroundWhite()
        } else if className.contains("green") {
            return self.generateLongTextBackgroundGreen()
        } else if className.contains("red") {
            return self.generateLongTextBackgroundRed()
        } else if className.contains("brown") {
            return self.generateLongTextBackgroundBrown()
        } else if className.contains("asphalt") {
            return self.generateLongTextBackgroundAsphalt()
        }
        return ""
    }
    
    private func generateLongTextBackgroundBrown() -> String {
        return "Brown background"
    }
    
    private func generateLongTextBackgroundAsphalt() -> String {
        return "Asphalt background"
    }
    
    private func generateLongTextBackgroundGreen() -> String {
        return "Green background"
    }
    
    private func generateLongTextBackgroundBlue() -> String {
        return "Blue background"
    }
    
    private func generateLongTextBackgroundRed() -> String {
        return "Red background"
    }
    
    private func generateLongTextBackgroundWhite() -> String {
        return "White background"
    }
    // MARK: - Long text functions
    
}
