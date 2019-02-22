//
//  ProcessingImageViewController.swift
//  CustomVisionProject
//
//  Created by Seavus on 2/22/19.
//  Copyright © 2019 Seavus. All rights reserved.
//

import UIKit

class ProcessingImageViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { timer in
            
            self.performSegue(withIdentifier: "imageProcessToFortuneSeugeIdentifier", sender: self)
        }
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
