//
//  FortuneResultViewController.swift
//  CustomVisionProject
//
//  Created by Seavus on 4/25/19.
//  Copyright © 2019 Seavus. All rights reserved.
//

import UIKit

class FortuneResultViewController: UIViewController, Storyboarded {

    // MARK: - Custom references and variables
    weak var coordinator: FortuneResultCoordinator? // Don't remove
    public let navigationBarHidden = false
    
    public var capturedImage: UIImage?
    public var foundClasses = [String]()
    
    // MARK: - IBOutlets references
    @IBOutlet weak var originalImageView: UIImageView!
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var shortDescriptionLabel: UILabel!
    @IBOutlet weak var fullDescriptionLabel: UILabel!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var sendLikeButton: UIButton!

    // MARK: - IBOutlets actions
    @IBAction func doneNavigationBarButton(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func shareButtonAction(_ sender: Any) {
        self.coordinator?.shareImage()
    }
    
    @IBAction func sendLikeButtonAction(_ sender: Any) {
       print("Thanks for the like")
    }
    
    // MARK: - View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        DispatchQueue.main.async {
            self.initalUISetup()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let bundlePath = Bundle.main.path(forResource: "blackSteamy", ofType: "jpg")
        self.backgroundImageView.image = UIImage(contentsOfFile: bundlePath!)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        DispatchQueue.main.async {
            self.finalUISetup()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UIView.animate(withDuration: 0.1) {
            self.backgroundImageView.alpha = 0
        }
    }

    // MARK: - UI Functions
    
    func initalUISetup(){
        self.originalImageView.image = self.capturedImage
        DispatchQueue.main.async {
            self.shortDescriptionLabel.text = self.coordinator?.generateShortDescription()
            self.fullDescriptionLabel.text = self.coordinator?.generateLongDescription()
        }
    }

    func finalUISetup(){

    }

    // MARK: - Other functions
}