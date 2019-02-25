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
        self.setUpNavigationBar()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    // MARK: - UI Functions
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
