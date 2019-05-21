//
//  HighlightedButton.swift
//  CustomVisionProject
//
//  Created by Seavus on 5/20/19.
//  Copyright © 2019 Seavus. All rights reserved.
//

import UIKit

class HighlightedButton: UIButton {
    
    override var isHighlighted: Bool {
        didSet {
            backgroundColor = isHighlighted ? .red : .green
        }
    }
}
