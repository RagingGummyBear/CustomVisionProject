//
//  CollectionViewDataSource.swift
//  CustomVisionProject
//
//  Created by Seavus on 5/16/19.
//  Copyright © 2019 Seavus. All rights reserved.
//

import Foundation

class CollectionViewDataSource<Model>: NSObject, UICollectionViewDataSource {
    typealias CellConfigurator = (Model, UICollectionViewCell, Bool) -> Void
    var models: [Model]
    var selectedModel = -1
    
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
        let cell = collectionView.dequeueReusableCell (
            withReuseIdentifier: reuseIdentifier,
            for: indexPath
        )
        cellConfigurator(model, cell, (indexPath.row == self.selectedModel))
        return cell
    }
    
    func setSelectedModel(index: Int){
        self.selectedModel = index
    }
    
    func getSelectedModel() -> Int {
        return self.selectedModel
    }
}


extension CollectionViewDataSource where Model == LikedCoffeeModel {
    static func make(for models: [LikedCoffeeModel], photoFetch: PhotoFetchProtocol, reuseIdentifier:String = "ImageDisplayCollectionViewCell") -> CollectionViewDataSource {
        return CollectionViewDataSource(models: models, reuseIdentifier: reuseIdentifier, cellConfigurator: { (model, cell, selected) in
            if let cell = cell as? ImageDisplayCollectionViewCell {
                photoFetch.fetchThumbnailPhoto(fromModel: model).done({ (image: UIImage) in
                    cell.displayUIImageView.image = image
                }).catch({ (error: Error) in
                    print(error)
                })
                if selected {
                    cell.backgroundColor = UIColor.init(named: "NavigationText")
                } else {
                    cell.backgroundColor = UIColor.clear
                }
            }
        })
    }
}
