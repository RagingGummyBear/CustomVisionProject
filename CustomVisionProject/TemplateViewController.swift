//
//  TemplateViewController.swift
//  CustomVisionProject
//
//  Created by Seavus on 2/25/19.
//  Copyright © 2019 Seavus. All rights reserved.
//

import UIKit

class TemplateViewController: UIViewController {

    // MARK: - Custom references and variables
    
    // MARK: - IBOutlets references
    
    // MARK: - IBOutlets actions
    @IBAction func doneNavigationBarButton(_ sender: Any) {
        self.backToMainMenu()
    }
    
    // MARK: - View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpNavigationBar()
        
        // Do any additional setup after loading the view.
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
