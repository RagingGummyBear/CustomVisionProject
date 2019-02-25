//
//  CameraCoffeeViewController.swift
//  CustomVisionProject
//
//  Created by Seavus on 2/25/19.
//  Copyright © 2019 Seavus. All rights reserved.
//

import UIKit

class CameraCoffeeViewController: UIViewController {
    
    // MARK: - Custom references and variables
    
    // MARK: - IBOutlets references
    @IBOutlet weak var cameraPreviewImageView: UIImageView!
    @IBOutlet weak var captureButton: UIButton!
    @IBOutlet weak var coffeeIndicatorLabel: UILabel!
    
    // MARK: - IBOutlets actions
    @IBAction func captureButtonAction(_ sender: Any) {
        self.transitionToImageProcessing()
    }
    
    // MARK: - View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        DispatchQueue.main.async {
            self.initalUISetup()
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
        self.applyRoundCorner(self.captureButton)
    }
    
    func finalUISetup(){
        // Here do all the resizing and constraint calculations
        // In some cases apply the background gradient here
        self.applyRoundCorner(self.captureButton)
    }
    
    func applyRoundCorner(_ object:AnyObject){
        object.layer?.cornerRadius = (object.frame?.size.width)! / 2
        object.layer?.masksToBounds = true
    }
    
    // MARK: - Logic functions
    
    // MARK: - Navigation
    func transitionToImageProcessing(){
        let imageProcessingViewController = self.storyboard?.instantiateViewController(withIdentifier: "imageProcessingViewController") as! ProcessingImageViewController
        self.navigationController?.pushViewController(imageProcessingViewController, animated: true)
    }
    
    // MARK: - Other functions
}
