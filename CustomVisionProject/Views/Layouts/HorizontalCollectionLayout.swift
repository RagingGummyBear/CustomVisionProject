//
//  HorizontalCollectionLayout.swift
//  CustomVisionProject
//
//  Created by Seavus on 5/17/19.
//  Copyright © 2019 Seavus. All rights reserved.
//

import Foundation

class HorizontalCollectionLayout : UICollectionViewLayout {
    //    weak var delegate: PinterestLayoutDelegate!
    
    fileprivate var numberOfRows = 1
    fileprivate var numberOfColumns: CGFloat = 6
    fileprivate var cellPadding: CGFloat = 6
    
    fileprivate var cache = [UICollectionViewLayoutAttributes]()
    
    fileprivate var contentHeight: CGFloat {
        guard let collectionView = collectionView else {
            return 0
        }
        let insets = collectionView.contentInset
        return collectionView.bounds.height - (insets.left + insets.right)
    }
    
    fileprivate var contentWidth: CGFloat = 0
    
    override var collectionViewContentSize: CGSize {
        return CGSize(width: contentWidth, height: contentHeight)
    }
    
    override func prepare() {
        guard cache.isEmpty == true, let collectionView = collectionView else {
            return
        }
        
        let columnHeight = contentHeight / CGFloat(numberOfRows)
        var yOffset = [CGFloat]()
        for column in 0 ..< numberOfRows {
            yOffset.append(CGFloat(column) * columnHeight)
        }
        var column = 0
        var xOffset = [CGFloat](repeating: 0, count: numberOfRows)
        
        for item in 0 ..< collectionView.numberOfItems(inSection: 0) {
            
            let indexPath = IndexPath(item: item, section: 0)
            
            let photoWidth = collectionView.frame.width / numberOfColumns - (cellPadding + cellPadding)
            let width = cellPadding * 2 + photoWidth
            
            let frame = CGRect(x: xOffset[column], y: yOffset[column], width: width, height: columnHeight)
            let insetFrame = frame.insetBy(dx: cellPadding, dy: cellPadding)
            
            let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            attributes.frame = insetFrame
            cache.append(attributes)
            
            contentWidth = max(contentWidth,frame.maxX)
            xOffset[column] = xOffset[column] + width
            
            column = column < (numberOfRows - 1) ? (column + 1) : 0
        }
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        
        var visibleLayoutAttributes = [UICollectionViewLayoutAttributes]()
        
        // Loop through the cache and look for items in the rect
        for attributes in cache {
            if attributes.frame.intersects(rect) {
                visibleLayoutAttributes.append(attributes)
            }
        }
        return visibleLayoutAttributes
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return cache[indexPath.item]
    }
}
