//___FILEHEADER___

import UIKit

class MainViewController: UIViewController, Storyboarded {

    // MARK: - Custom references and variables
    weak var coordinator: MainCoordinator? // Don't remove
    public let navigationBarHidden = true
    var quoteNotificationRunning = false

    // MARK: - IBOutlets references
    @IBOutlet weak var discoverFortuneButton: UIButton!
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var quoteLabel: UILabel!
    @IBOutlet weak var backgroundImageView: UIImageView!
    
    // MARK: - IBOutlets actions
    @IBAction func discoverFortuneAction(_ sender: Any) {
        self.coordinator?.goToPhotoTake()
    }
    
    @IBAction func aboutTransition(_ sender: Any) {
        self.coordinator?.goToAbout()
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
        self.coordinator?.startSendingQuotes()
    }

    // MARK: - UI Functions
    func initalUISetup(){
        // Change label's text, etc.
        self.quoteLabel.alpha = 0
        let bundlePath = Bundle.main.path(forResource: "blackSteamy", ofType: "jpg")
        self.backgroundImageView.image = UIImage(contentsOfFile: bundlePath!)
    }

    func finalUISetup(){
        
    }

    func setQuote(quote:QuoteModel){
        self.quoteLabel.layer.removeAllAnimations()
        if self.quoteLabel.alpha < 0.5 {
            
        }
        self.quoteNotificationRunning = true
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseIn, animations: {
            self.quoteLabel.alpha = 0.0
        }) { (finished: Bool) in
            if finished {
                self.quoteLabel.text = quote.toString()

                UIView.animate(withDuration: 0.5, delay: 0.5, options: .curveEaseOut, animations: {
                    self.quoteLabel.alpha = 1
                }) { [weak self] (finished: Bool) in
                    self?.quoteNotificationRunning = false
                }
            }
        }
    }
    
    
    // MARK: - Other functions
    // Remember keep the logic and processing in the coordinator
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if self.quoteNotificationRunning {
            return
        }
        guard let touchPoint = touches.first else { return }
        
        if self.quoteLabel.frame.contains(touchPoint.location(in: self.view)) {
            self.coordinator?.userRequestNewQuote()
        }
    }
}