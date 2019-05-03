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
    private var canTransition = false
    private var capturedImage: UIImage?
    private var foundClasses = [String]()
    
    // MARK: - IBOutlets references
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var quoteLabel: UILabel!
    @IBOutlet weak var discoverButton: UIButton!
    @IBOutlet weak var backgroundImageView: UIImageView!
    
    // MARK: - IBOutlets actions
    @IBAction func discoverFortuneAction(_ sender: Any) {
        if !self.canTransition {
            return
        }
        self.canTransition = false
        self.performSegue(withIdentifier: "shootYourCoffeSeugeIdentifier", sender: self)
    }
    
    // MARK: - View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        DispatchQueue.main.async {
            self.initalUISetup()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.canTransition = true
        DispatchQueue.main.async {
            self.finalUISetup()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.displayNavigationBar()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.displayNavigationBar()
    }
    
    // MARK: - UI Functions
    func initalUISetup(){
        // Change label's text, etc.
        self.quoteLabel.alpha = 0
        let bundlePath = Bundle.main.path(forResource: "blackSteamy", ofType: "jpg")
        self.backgroundImageView.image = UIImage(contentsOfFile: bundlePath!)
        self.hideNavigationBar()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        guard let statusBarView = UIApplication.shared.value(forKeyPath: "statusBarWindow.statusBar") as? UIView else {
            return .lightContent
        }
        statusBarView.backgroundColor = UIColor(named: "BackgroundBrown")
        return .lightContent
    }
    
    func finalUISetup(){        
        self.pickRandomQuote()
        self.view.layer.removeAllAnimations()
        self.quoteLabel.layer.removeAllAnimations()
        self.displayQuoteLabel()
        self.hideNavigationBar()
    }
        
    func hideNavigationBar(){
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    func displayNavigationBar(){
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touchPoint = touches.first else { return }
        
        if self.quoteLabel.frame.contains(touchPoint.location(in: self.view)) {
            if self.quoteLabel.alpha == (1.0) {
                return
            }
            
            self.quoteLabel.layer.removeAllAnimations()
            
            UIView.animate(withDuration: 0.5, delay: 0.5, options: .curveEaseOut, animations: {
                self.quoteLabel.alpha = 0
            }) { (finished: Bool) in
                if finished {
                    self.displayQuoteLabel()
                }
            }
        }
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
    }
    
    func displayQuoteLabel(){
        if self.quoteLabel.alpha < 1 {
            
            self.pickRandomQuote()
            self.quoteLabel.layer.removeAllAnimations()
            
            DispatchQueue.main.async {
                UIView.animate(withDuration: 0.5, delay: 0.5, options: .curveEaseOut, animations: {
                    self.quoteLabel.alpha = 1
                }) { (finished: Bool) in
                    if finished {
                        self.hideQuoteLabel(withDelay: 5)
                    }
                }
            }
        } else {
            self.hideQuoteLabel(withDelay: 5)
        }
    }
    
    func hideQuoteLabel(withDelay : Double = 0.5){
        if self.quoteLabel.alpha > 0 {
            self.quoteLabel.layer.removeAllAnimations()
            UIView.animate(withDuration: 0.5, delay: withDelay, options: .curveEaseIn, animations: {
                self.quoteLabel.alpha = 0
            }) { (finished: Bool) in
                if finished {
                    self.displayQuoteLabel()
                }
            }
        }
    }
    
    func setQuote(quote:QuoteModel){
        self.quoteLabel.text = quote.toString()
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "shootYourCoffeSeugeIdentifier" {
            if let destination = segue.destination as? CameraCoffeeViewController {
                destination.parentReturn = {[unowned self]  (image: UIImage) in
                    self.capturedImage = image
                    DispatchQueue.main.async {
                        self.transitionToProcessingImage()
                    }
                }
            }
        } else if segue.identifier == "ImageProcessingSegueIdentifier" {
            if let destination = segue.destination as? CombinedProcessingImageViewController {
                destination.selectedImage = self.capturedImage
                self.capturedImage = nil
                destination.parentReturn = {[unowned self]  (foundClasses: [String], capturedImage: UIImage) in
                    self.capturedImage = capturedImage
                    self.foundClasses = foundClasses
                    DispatchQueue.main.async {
                        self.transitionToYourFortune()
                    }
                }
            }
        } else if segue.identifier == "MainMenuToFortuneSeugeIdentifier" {
            if let destination = segue.destination as? YourFortuneViewController {
                destination.capturedImage = CustomUtility.imageWithWidth(sourceImage: self.capturedImage!, scaledToWidth: 480)
                destination.foundClasses = self.foundClasses
                
                self.capturedImage = nil
                self.foundClasses = []
            }
        }
    }
    
    func transitionToProcessingImage() {
        performSegue(withIdentifier: "ImageProcessingSegueIdentifier", sender: self)
    }
    
    func transitionToYourFortune() {
        performSegue(withIdentifier: "MainMenuToFortuneSeugeIdentifier", sender: self)
    }

    // MARK: - Other functions
    
}
