//
//  ProcessingImageViewController.swift
//  CustomVisionProject
//
//  Created by Seavus on 2/25/19.
//  Copyright © 2019 Seavus. All rights reserved.
//

import UIKit

class ProcessingImageViewController: UIViewController {
    
    // MARK: - Custom references and variables
    public var capturedImage: UIImageView?
    
    // MARK: - IBOutlet references
    @IBOutlet weak var processingImageView: UIImageView!
    @IBOutlet weak var processingProgressBar: NSLayoutConstraint!
    @IBOutlet weak var processingStatusLabel: UILabel!
    
    // MARK: - IBOutlets actions
    
    // MARK: - View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        DispatchQueue.main.async {
            self.initalUISetup()
        }
        //
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { timer in
            self.transitionToFortuneDisplay()
            //            self.performSegue(withIdentifier: "imageProcessToFortuneSeugeIdentifier", sender: self)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        DispatchQueue.main.async {
            self.finalUISetup()
        }
    }
    
    // MARK: - UI Functions
    func initalUISetup(){
        // Change label's text, etc.
    }
    
    func finalUISetup(){
        // Here do all the resizing and constraint calculations
        // In some cases apply the background gradient here
    }
    
    // MARK: - Logic functions
    
    // MARK: - Navigation
    func transitionToFortuneDisplay(){
        let fortuneVC = self.storyboard?.instantiateViewController(withIdentifier: "fortuneViewControllerId") as! YourFortuneViewController
        self.navigationController?.pushViewController(fortuneVC, animated: true)
    }
    
    // MARK: - Other functions
}
