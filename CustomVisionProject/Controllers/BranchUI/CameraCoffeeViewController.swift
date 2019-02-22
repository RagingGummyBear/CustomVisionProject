//
//  CameraCoffeeViewController.swift
//  CustomVisionProject
//
//  Created by Seavus on 2/22/19.
//  Copyright © 2019 Seavus. All rights reserved.
//

import UIKit

class CameraCoffeeViewController: UIViewController {
    
    // MARK: Custom variables
    
    // MARK: IBOutlet references
    @IBOutlet weak var cameraPreviewImageView: UIImageView!
    @IBOutlet var foundCoffeIndicatorLabel: UILabel!
    @IBOutlet weak var captureButton: UIButton!
    
    // MARK: IBOutlet Actions
    
    
    // MARK: - View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.applyRoundCorner(self.captureButton)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    // MARK: - Other functions
    func applyRoundCorner(_ object:AnyObject){
        object.layer?.cornerRadius = (object.frame?.size.width)! / 2
        object.layer?.masksToBounds = true
    }

}
