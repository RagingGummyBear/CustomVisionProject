//
//  YourFortuneViewController.swift
//  CustomVisionProject
//
//  Created by Seavus on 2/22/19.
//  Copyright © 2019 Seavus. All rights reserved.
//

import UIKit

class YourFortuneViewController: UIViewController {

    // MARK: - Custom references and variables
    public var capturedImage: UIImage?
    public var foundClasses = [String]()
    
    private var textGenerator = TextGenerator()
    
    // MARK: - IBOutlets references
    @IBOutlet weak var originalImageView: UIImageView!
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var shortDescriptionLabel: UILabel!
    @IBOutlet weak var fullDescriptionLabel: UILabel!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var sendLikeButton: UIButton!
    
    // MARK: - IBOutlets actions
    @IBAction func doneNavigationBarButton(_ sender: Any) {
        self.backToMainMenu()
    }
    
    @IBAction func shareButtonAction(_ sender: Any) {
        self.shareImage()
    }
    
    @IBAction func sendLikeButtonAction(_ sender: Any) {
    }
    
    // MARK: - View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.initalUISetup()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.finalUISetup()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UIView.animate(withDuration: 0.1) {
            self.backgroundImageView.alpha = 0
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.capturedImage = nil
//        self.originalImageView.image = nil
//        self.shortDescriptionLabel.text = nil
//        self.fullDescriptionLabel.text = nil
//        self.backgroundImageView.image = nil
    }
    
    // MARK: - UI Functions
    func initalUISetup(){
        let bundlePath = Bundle.main.path(forResource: "blackSteamy", ofType: "jpg")
        self.backgroundImageView.image = UIImage(contentsOfFile: bundlePath!)
        
        // Change label's text, etc.
        self.textGenerator.foundClasses = self.foundClasses
        self.textGenerator.generateShortText { (result: String) in
            DispatchQueue.main.async {
//                self.shortDescriptionLabel.text = result
                var shortLabel = ""
                for foundClass in self.foundClasses {
                    shortLabel += foundClass + ", "
                }
                
                self.shortDescriptionLabel.text = shortLabel
//                self.shortDescriptionLabel.text = self.foundClasses
            }
        }
        self.setUpNavigationBar()
        if let img = self.capturedImage {
            self.originalImageView.image = img
        }
    }
    
    func finalUISetup(){
        // Here do all the resizing and constraint calculations
        // In some cases apply the background gradient here
        self.backgroundImageView.layer.removeAllAnimations()
        self.backgroundImageView.layer.removeAllAnimations()
        UIView.commitAnimations()
    }
    
    func setUpNavigationBar(){
        self.navigationItem.setHidesBackButton(true, animated: false)
    }
    
    // MARK: - Custom functions
    func shareImage() {
        let img = self.capturedImage
        let messageStr = self.shortDescriptionLabel.text
        let activityViewController:UIActivityViewController = UIActivityViewController(activityItems:  [img!, messageStr], applicationActivities: nil)
        activityViewController.excludedActivityTypes = [UIActivity.ActivityType.print, UIActivity.ActivityType.postToWeibo, UIActivity.ActivityType.copyToPasteboard, UIActivity.ActivityType.addToReadingList, UIActivity.ActivityType.postToVimeo]
        self.present(activityViewController, animated: true, completion: nil)
        
    }

    // MARK: - Navigation
    func backToMainMenu() {
        DispatchQueue.main.async {
            self.navigationController?.popViewController(animated: true)
        }
    }

    // MARK: - Other functions
    
}
