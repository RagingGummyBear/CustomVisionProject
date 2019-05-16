//
//  CollectionViewDataSource.swift
//  CustomVisionProject
//
//  Created by Seavus on 5/16/19.
//  Copyright © 2019 Seavus. All rights reserved.
//

import Foundation

class CollectionViewDataSource<Model>: NSObject, UICollectionViewDataSource {
    typealias CellConfigurator = (Model, UICollectionViewCell) -> Void
    var models: [Model]
    
    private let reuseIdentifier: String
    private let cellConfigurator: CellConfigurator
    
    init(models: [Model],
         reuseIdentifier: String,
         cellConfigurator: @escaping CellConfigurator) {
        self.models = models
        self.reuseIdentifier = reuseIdentifier
        self.cellConfigurator = cellConfigurator
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return models.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let model = models[indexPath.row]
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: reuseIdentifier,
            for: indexPath
        )
        cellConfigurator(model, cell)
        return cell
    }
}

extension CollectionViewDataSource where Model == ExampleModel {
    static func make(for models: [ExampleModel],
                     reuseIdentifier: String = "userDataCell") -> CollectionViewDataSource {
        return CollectionViewDataSource(
            models: models,
            reuseIdentifier: reuseIdentifier
        ) { (model, cell) in
//            cell.textLabel?.text = model.title
//            cell.detailTextLabel?.text = model.description
//            if let cell = cell as? ImageDisplayCollectionViewCell {
//                cell.displayUIImageView.image = image
//            }
        }
    }
}

extension CollectionViewDataSource where Model == LikedCoffeeModel {
    static func make(for models: [LikedCoffeeModel], photoFetch: PhotoFetchProtocol, reuseIdentifier:String = "ImageDisplayCollectionViewCell") -> CollectionViewDataSource {
        return CollectionViewDataSource(models: models, reuseIdentifier: reuseIdentifier, cellConfigurator: { (model, cell) in
            if let cell = cell as? ImageDisplayCollectionViewCell {
                photoFetch.fetchThumbnailPhoto(fromModel: model).done({ (image: UIImage) in
                    cell.displayUIImageView.image = image
                }).catch({ (error: Error) in
                    print(error)
                })
            }
        })
    }
}
