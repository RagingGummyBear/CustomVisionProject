//
//  AboutViewController.swift
//  CustomVisionProject
//
//  Created by Seavus on 2/25/19.
//  Copyright © 2019 Seavus. All rights reserved.
//

import UIKit

class AboutViewController: UIViewController {
    
    // MARK: - Custom references and variables
    
    // MARK: - IBOutlets references
    @IBOutlet weak var wildPorsche: UIImageView!
    
    // MARK: - IBOutlets actions
    @IBAction func touchMe(_ sender: Any) {
        
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
    }
    
    func finalUISetup(){
        // Here do all the resizing and constraint calculations
        // In some cases apply the background gradient here
        
    }
    
    // MARK: - Logic functions
    
    // MARK: - Navigation
    /*
    func transitionToNextViewController(){
     if let nextViewController = self.storyboard?.instantiateViewController(withIdentifier: "ViewControllerIdentifier") as? UIViewController {
         self.navigationController?.pushViewController(nextViewController, animated: true)
     }
    }
     */
    /*
    func transitionBackMultiple() {
        let viewControllers: [UIViewController] = self.navigationController!.viewControllers as [UIViewController]
        self.navigationController!.popToViewController(viewControllers[viewControllers.count - 3], animated: true)
    }
    */

    // MARK: - Other functions

    
}

