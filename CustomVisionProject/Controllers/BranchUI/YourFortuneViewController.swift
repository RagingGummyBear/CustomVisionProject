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
    @IBOutlet weak var shortDescriptionLabel: UILabel!
    @IBOutlet weak var fullDescriptionLabel: UILabel!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var sendLikeButton: UIButton!
    
    // MARK: - IBOutlets actions
    @IBAction func doneNavigationBarButton(_ sender: Any) {
        self.backToMainMenu()
    }
    
    @IBAction func shareButtonAction(_ sender: Any) {
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
    
    // MARK: - UI Functions
    func initalUISetup(){
        // Change label's text, etc.
        self.textGenerator.foundClasses = self.foundClasses
        self.textGenerator.generateShortText { (result: String) in
            DispatchQueue.main.async {
                self.shortDescriptionLabel.text = result
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
    }
    
    func setUpNavigationBar(){
        self.navigationItem.setHidesBackButton(true, animated: false)
    }
    
    
    // MARK: - Custom functions

    // MARK: - Navigation
    func backToMainMenu() {
        let viewControllers: [UIViewController] = self.navigationController!.viewControllers as [UIViewController]
        self.navigationController!.popToViewController(viewControllers[viewControllers.count - 4], animated: true)
    }

    // MARK: - Other functions
    
}
