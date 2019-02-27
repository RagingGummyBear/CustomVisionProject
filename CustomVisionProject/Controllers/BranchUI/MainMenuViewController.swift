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
        self.quoteLabel.alpha = 0
        self.applyRoundCorner(self.discoverButton)
    }
    
    func finalUISetup(){
        // Here do all the resizing and constraint calculations
        // In some cases apply the background gradient here
        self.applyRoundCorner(self.discoverButton)
        
        self.pickRandomQuote()
        UIView.animate(withDuration: 0.5, delay: 0.5, options: .curveEaseOut, animations: {
            self.quoteLabel.alpha = 1
        }, completion: nil)
        
    }
    
    func applyRoundCorner(_ object:AnyObject){
        object.layer?.cornerRadius = (object.frame?.size.width)! / 2
        object.layer?.masksToBounds = true
    }
    
    // MARK: - Logic functions
    
    func pickRandomQuote(){
        if let path = Bundle.main.path(forResource: "wittyCoffeeQuotes", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                let quotesContainer = try JSONDecoder().decode(WittyCoffeeQuotes.self, from: data);
                if quotesContainer.quotes.count > 0 {
                    
                    self.setQuote(quote: quotesContainer.quotes.randomElement()!)
                }
            } catch {
                // handle error
                print("Unable to load json")
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            
            UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseOut, animations: {
                self.quoteLabel.alpha = 0
            }, completion: { (finished: Bool) in
                if finished {
                    self.pickRandomQuote()
                    UIView.animate(withDuration: 0.5, animations: {
                        self.quoteLabel.alpha = 1
                    })
                }
            })
        }
    }
    
    func setQuote(quote:QuoteModel){
        self.quoteLabel.text = quote.toString()
    }
    
    // MARK: - Navigation

    // MARK: - Other functions
}
