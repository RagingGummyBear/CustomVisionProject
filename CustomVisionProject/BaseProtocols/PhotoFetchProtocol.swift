 //
//  PhotoFetchProtocol.swift
//  CustomVisionProject
//
//  Created by Seavus on 5/16/19.
//  Copyright © 2019 Seavus. All rights reserved.
//

import Foundation
import PromiseKit

protocol PhotoFetchProtocol {
    func fetchThumbnailPhoto (fromModel: LikedCoffeeModel) -> Promise<UIImage>
    func fetchHighQualityPhoto (fromModel: LikedCoffeeModel) -> Promise<UIImage>
    func fetchMediumQualityPhoto (fromModel: LikedCoffeeModel) -> Promise<UIImage>
}
