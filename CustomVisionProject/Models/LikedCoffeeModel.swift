//
//  LikedCoffeeModel.swift
//  CustomVisionProject
//
//  Created by Seavus on 5/16/19.
//  Copyright © 2019 Seavus. All rights reserved.
//

import Foundation

public class LikedCoffeeModel: Codable {
    var saveDirectoryName: String! // Only the UUID part
    var savedDate: String! // Day/Month/Year format
    var foundClasses: [String]!
    
    init(saveDirectoryName: String, savedDate: String, foundClasses: [String]) {
        self.saveDirectoryName = saveDirectoryName
        self.savedDate = savedDate
        self.foundClasses = foundClasses
    }
}
