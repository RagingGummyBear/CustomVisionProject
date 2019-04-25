//
//  OpenCVTestingViewController.swift
//  CustomVisionProject
//
//  Created by Seavus on 4/2/19.
//  Copyright © 2019 Seavus. All rights reserved.
//

import UIKit

class OpenCVTestingViewController: UIViewController {
    
    // MARK: - Custom references and variables
    @IBOutlet weak var highHUISlider: UISlider!
    @IBOutlet weak var highSUISlider: UISlider!
    @IBOutlet weak var highVUISlider: UISlider!
    
    @IBOutlet weak var lowHUISlider: UISlider!
    @IBOutlet weak var lowSUISlider: UISlider!
    @IBOutlet weak var lowVUISlider: UISlider!
    
    @IBOutlet weak var highHValueLabel: UILabel!
    @IBOutlet weak var highSValueLabel: UILabel!
    @IBOutlet weak var highVValueLabel: UILabel!
    
    @IBOutlet weak var lowHValueLabel: UILabel!
    @IBOutlet weak var lowSValueLabel: UILabel!
    @IBOutlet weak var lowVValueLabel: UILabel!
    
    // MARK: - IBOutlets references
    @IBOutlet weak var mainImageView: UIImageView!
    
    // MARK: - IBInspectable
    @IBInspectable var selectedImage: UIImage!
    
    // MARK: - IBOutlets actions
    @IBAction func startButtonAction(_ sender: Any) {
//        self.mainImageView.image = OpenCVWrapper.get_color_content(self.selectedImage)
//        self.displayNewImage()
        
//        self.mainImageView.image = OpenCVWrapper.draw_color_mask_reversed_void(self.selectedImage, withBound: CGRect(x: 1, y: 1, width: 25, height: 25))
//
//        let lowerC = NSMutableArray(array: [Double.init(self.lowHValueLabel.text!)!, Double.init(self.lowSValueLabel.text!)!, Double.init(self.lowVValueLabel.text!)!])
//
//        let highC = NSMutableArray(array: [Double.init(self.highHValueLabel.text!)!, Double.init(self.highSValueLabel.text!)!, Double.init(self.highVValueLabel.text!)!])

//        self.mainImageView.image = OpenCVWrapper.get_color_contour_sizeRR(self.selectedImage, withBound: CGRect(x: 25, y: 25, width: 200, height: 200), withLowRange: lowerC, withHighRange: highC)
////
//         let backgroundClass = OpenCVWrapper.get_yeeted_background(self.selectedImage, withBound: CGRect(x: 25, y: 25, width: 200, height: 200))
//         print(backgroundClass)
        
        
//        let foundClass = self.getSelectedImageColorClass()
//        print(foundClass)
        
        
    }
    
    @IBAction func returnButtonAction(_ sender: Any) {
        self.mainImageView.image = self.selectedImage
    }
    
    @IBAction func highHUISliderChange(_ sender: Any) {
        self.highHValueLabel.text = String(format: "%.2f", self.highHUISlider.value)
        self.displayNewImage()
    }
    
    @IBAction func highSUISliderChange(_ sender: Any) {
        self.highSValueLabel.text = String(format: "%.2f", self.highSUISlider.value)
        self.displayNewImage()
    }
    
    @IBAction func highVUISliderChange(_ sender: Any) {
        self.highVValueLabel.text = String(format: "%.2f", self.highVUISlider.value)
        self.displayNewImage()
    }
    
    @IBAction func lowHUISliderChange(_ sender: Any) {
        self.lowHValueLabel.text = String(format: "%.2f", self.lowHUISlider.value)
        self.displayNewImage()
    }
    
    @IBAction func lowSUISliderChange(_ sender: Any) {
        self.lowSValueLabel.text = String(format: "%.2f", self.lowSUISlider.value)
        self.displayNewImage()
    }
    
    @IBAction func lowVUISliderChange(_ sender: Any) {
        self.lowVValueLabel.text = String(format: "%.2f", self.lowVUISlider.value)
        self.displayNewImage()
    }
    
    // MARK: - View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let lowerC = NSMutableArray(array: [214,21,11])
        
//        OpenCVWrapper.get_color_content_(with_range: self.selectedImage, withLowRange: lowerC, withHighRange: lowerC)
        // Do any additional setup after loading the view.
        self.mainImageView.image = self.selectedImage
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
    
    func displayNewImage(){
        
        let lowerC = NSMutableArray(array: [Double.init(self.lowHValueLabel.text!)!, Double.init(self.lowSValueLabel.text!)!, Double.init(self.lowVValueLabel.text!)!])
        
        let highC = NSMutableArray(array: [Double.init(self.highHValueLabel.text!)!, Double.init(self.highSValueLabel.text!)!, Double.init(self.highVValueLabel.text!)!])
        
        self.mainImageView.image = OpenCVWrapper.get_color_content_(with_range: self.selectedImage, withLowRange: lowerC, withHighRange: highC)
    }
    
    func getSelectedImageColorClass() -> String {
//        let lowerC = NSMutableArray(array: [Double.init(self.lowHValueLabel.text!)!, Double.init(self.lowSValueLabel.text!)!, Double.init(self.lowVValueLabel.text!)!])
//
//        let highC = NSMutableArray(array: [Double.init(self.highHValueLabel.text!)!, Double.init(self.highSValueLabel.text!)!, Double.init(self.highVValueLabel.text!)!])
        
        let foundClass =  OpenCVWrapper.get_yeeted(self.selectedImage, withBound: CGRect())
        
        return foundClass
    }
}
