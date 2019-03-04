//
//  QuoteModel.swift
//  CustomVisionProject
//
//  Created by Seavus on 2/27/19.
//  Copyright © 2019 Seavus. All rights reserved.
//

import Foundation

class QuoteModel : Codable {
    var author:String?
    var fromSite:String?
    var text:String?
    
    func toString() -> String {
        guard let text = self.text, let author = self.author else {
            return ""
        }
        return "\(text) \n -\(author)"
    }
    
}

class WittyCoffeeQuotes: Codable {
    var quotes: [QuoteModel]
}
