//
//  PhotoTakeViewController.swift
//  CustomVisionProject
//
//  Created by Seavus on 4/25/19.
//  Copyright © 2019 Seavus. All rights reserved.
//

import UIKit

class PhotoTakeViewController: UIViewController, Storyboarded {

    // MARK: - Custom references and variables
    weak var coordinator: PhotoTakeCoordinator? // Don't remove
    public let navigationBarHidden = false

    // MARK: - IBOutlets references
    @IBOutlet weak var takePhotoButton: UIButton!
    
    @IBOutlet weak var cameraPreviewImageView: UIImageView!
    @IBOutlet weak var overCameraImageView: UIImageView!
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var coffeeIndicatorLabel: UILabel!
    
    // MARK: - IBOutlets actions
    @IBAction func takePhotoAction(_ sender: Any) {
        // Signal coordinator to take photo
        self.coordinator?.takePhoto()
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
        
        var bundlePath = Bundle.main.path(forResource: "blackSteamy", ofType: "jpg")
        self.backgroundImageView.image = UIImage(contentsOfFile: bundlePath!)
        
        bundlePath = Bundle.main.path(forResource: "yingyangcoffee", ofType: "jpg")
        self.overCameraImageView.image = UIImage(contentsOfFile: bundlePath!)
//        self.setupCamera()
        self.coordinator?.startCameraSetup()
    }

    func applyRoundCorner(_ object:AnyObject){
        object.layer?.cornerRadius = (object.frame?.size.width)! / 2
        object.layer?.masksToBounds = true
    }
    
    func finalUISetup(){
        // Here do all the resizing and constraint calculations
        // In some cases apply the background gradient here
        self.applyRoundCorner(self.takePhotoButton)
    }

    // MARK: - Other functions
    // Remember keep the logic and processing in the coordinator
}
