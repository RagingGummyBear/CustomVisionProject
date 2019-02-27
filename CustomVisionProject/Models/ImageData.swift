//
//  ImageModel.swift
//  CameraCollection
//
//  Created by Seavus on 1/10/19.
//  Copyright © 2019 Seavus. All rights reserved.
//

import Foundation

class ImageData : Codable {
    var id : String = ""
    var imagePath : String = ""
    var thumbnailPath : String = ""
    var temp : Bool = false
}
