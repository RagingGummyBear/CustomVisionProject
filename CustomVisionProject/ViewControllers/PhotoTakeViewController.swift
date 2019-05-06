//
//  PhotoTakeViewController.swift
//  CustomVisionProject
//
//  Created by Seavus on 4/25/19.
//  Copyright © 2019 Seavus. All rights reserved.
//

import UIKit
import AVFoundation

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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        var bundlePath = Bundle.main.path(forResource: "blackSteamy", ofType: "jpg")
//        self.backgroundImageView.image = UIImage(contentsOfFile: bundlePath!)
        
        bundlePath = Bundle.main.path(forResource: "yingyangcoffee", ofType: "jpg")
        self.overCameraImageView.image = UIImage(contentsOfFile: bundlePath!)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        DispatchQueue.main.async {
            self.finalUISetup()
        }
        if self.overCameraImageView.alpha == 1 {
            UIView.animate(withDuration: 0.15, delay: 0, options: .curveEaseIn , animations: {
                self.overCameraImageView.alpha = 0
            }, completion: {(completed : Bool) in
                self.overCameraImageView.image = nil
            })
        }
    }
    
    // MARK: - UI Functions
    func initalUISetup(){
        // Change label's text, etc.
        

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
    
    func setCameraPreviewLayer(previewLayer: AVCaptureVideoPreviewLayer){
        self.cameraPreviewImageView.layer.addSublayer(previewLayer)
    }
    
    func getCameraPreviewFrame() -> CGRect {
        return self.cameraPreviewImageView.frame
    }
    
    // MARK: - Other functions
    // Remember keep the logic and processing in the coordinator
}
