//
//  FeatureMatchingTestViewController.swift
//  CustomVisionProject
//
//  Created by Seavus on 2/22/19.
//  Copyright © 2019 Seavus. All rights reserved.
//

import UIKit

class FeatureMatchingTestViewController: UIViewController {

    @IBOutlet weak var displayImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let img = OpenCVWrapper.compareFeaturesHomography(#imageLiteral(resourceName: "coffee10"), with: #imageLiteral(resourceName: "coffee8"))
        // Do any additional setup after loading the view.s
        self.displayImage.image = img
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
