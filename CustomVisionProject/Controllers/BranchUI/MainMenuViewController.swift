//
//  MainMenuViewController.swift
//  CustomVisionProject
//
//  Created by Seavus on 2/25/19.
//  Copyright © 2019 Seavus. All rights reserved.
//

import UIKit

class MainMenuViewController: UIViewController {
    
    // MARK: - Custom references and variables
    
    // MARK: - IBOutlets references
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var quoteLabel: UILabel!
    @IBOutlet weak var discoverButton: UIButton!
    
    // MARK: - IBOutlets actions
    @IBAction func discoverFortuneAction(_ sender: Any) {
        self.performSegue(withIdentifier: "shootYourCoffeSeugeIdentifier", sender: self)
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
        self.applyRoundCorner(self.discoverButton)
    }
    
    func finalUISetup(){
        // Here do all the resizing and constraint calculations
        // In some cases apply the background gradient here
        self.applyRoundCorner(self.discoverButton)
    }
    
    func applyRoundCorner(_ object:AnyObject){
        object.layer?.cornerRadius = (object.frame?.size.width)! / 2
        object.layer?.masksToBounds = true
    }
    
    // MARK: - Logic functions
    
    // MARK: - Navigation

    // MARK: - Other functions
}
