//
//  CollectionViewFlowLayoutDelegate.swift
//  CustomVisionProject
//
//  Created by Seavus on 5/16/19.
//  Copyright © 2019 Seavus. All rights reserved.
//

import Foundation
import UIKit

class CollectionViewFlowDelegate : NSObject, UICollectionViewDelegateFlowLayout, UICollectionViewDelegate {
    private var itemsPerRow: CGFloat = 1
    private var sectionInsets = UIEdgeInsets(top: 50.0, left: 20.0, bottom: 50.0, right: 20.0)
    
    init(itemsPerRow: CGFloat = 1, sectionInsets: UIEdgeInsets = UIEdgeInsets(top: 50.0, left: 20.0, bottom: 50.0, right: 20.0)){
        self.itemsPerRow = itemsPerRow
        self.sectionInsets = sectionInsets
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let paddingSpace = sectionInsets.left * (itemsPerRow + 1)
        let availableWidth = collectionView.frame.width - paddingSpace
        let widthPerItem = availableWidth / itemsPerRow
        
        return CGSize(width: widthPerItem, height: widthPerItem)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return sectionInsets.left
    }
}
