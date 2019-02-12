//
//  ImageModel.swift
//  CameraCollection
//
//  Created by Seavus on 1/10/19.
//  Copyright © 2019 Seavus. All rights reserved.
//

import Foundation
import RealmSwift

class ImageData : Object {
    @objc dynamic var id : String = ""
    @objc dynamic var imagePath : String = ""
    @objc dynamic var thumbnailPath : String = ""
    @objc dynamic var temp : Bool = false
}
