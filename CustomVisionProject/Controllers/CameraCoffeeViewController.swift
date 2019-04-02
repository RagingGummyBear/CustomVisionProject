//
//  CameraCoffeeViewController.swift
//  CustomVisionProject
//
//  Created by Seavus on 2/25/19.
//  Copyright © 2019 Seavus. All rights reserved.
//

import UIKit
import AVFoundation
import CoreML
import Vision

class CameraCoffeeViewController: UIViewController, AVCapturePhotoCaptureDelegate, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    // MARK: - Custom references and variables
    private var session: AVCaptureSession?
    private var previewLayer: AVCaptureVideoPreviewLayer!
    private var videoDevice: AVCaptureDevice? = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: .video, position: .back).devices.first
    lazy private var model = try? VNCoreMLModel(for: CoffeePorscheClass().model)
    private var stillImageOutput: AVCapturePhotoOutput!
    
    private let videoDataOutputQueue = DispatchQueue.init(label: "com.seavus.customvision.videoOutput")
    private var bufferSize = CGSize(width: 0.0, height: 0.0)
    public var capturedImage: UIImage?
    private var photoTaken = false
    public var parentReturn : ((UIImage) -> ())?
    
    // MARK: - IBInspectable
    @IBInspectable public var debugImage: UIImage?
    
    // MARK: - IBOutlets references
    @IBOutlet weak var cameraPreviewImageView: UIImageView!
    @IBOutlet weak var overCameraImageView: UIImageView!
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var captureButton: UIButton!
    @IBOutlet weak var coffeeIndicatorLabel: UILabel!
    
    // MARK: - IBOutlets actions
    @IBAction func captureButtonAction(_ sender: Any) {
        if self.photoTaken {
            return
        }
        self.photoTaken = true
        
        let settings = AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.jpeg])
//        settings.flashMode = .auto
        stillImageOutput.capturePhoto(with: settings, delegate: self)
    }
    
    @IBAction func debugPhotoButtonAction(_ sender: Any) {
        if let img = self.debugImage {
            self.capturedImage = img
        } else {
            let bundlePath = Bundle.main.path(forResource: "heartCoffee", ofType: "jpg")
            self.capturedImage =  UIImage(contentsOfFile: bundlePath!)
        }
        self.transitionToImageProcessing()
    }
    
    // MARK: - View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        if self.videoDevice == nil {
//            self.debugPhotoButtonAction(self)
        }
        
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
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        
        UIView.animate(withDuration: 0.1) {
            self.overCameraImageView.alpha = 0
            self.backgroundImageView.alpha = 0
        }
        
//        self.navigationController?.navigationBar.prefersLargeTitles = true
//        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.releaseSomeMemory()
    }
    
    override func willMove(toParent parent: UIViewController?) {
        super.willMove(toParent:parent)
        if parent == nil {
            // The back button was pressed or interactive gesture used
            
            self.navigationController?.setNavigationBarHidden(true, animated: false)
        }
    }
    
    // MARK: - UI Functions
    func initalUISetup(){
        // Change label's text, etc.
        var bundlePath = Bundle.main.path(forResource: "blackSteamy", ofType: "jpg")
        self.backgroundImageView.image = UIImage(contentsOfFile: bundlePath!)

        self.applyRoundCorner(self.captureButton)

        bundlePath = Bundle.main.path(forResource: "yingyangcoffee", ofType: "jpg")
        self.overCameraImageView.image = UIImage(contentsOfFile: bundlePath!)
        
        self.setupCamera()
    }
    
    func finalUISetup(){
        // Here do all the resizing and constraint calculations
        // In some cases apply the background gradient here
        self.applyRoundCorner(self.captureButton)
        
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    func applyRoundCorner(_ object:AnyObject){
        object.layer?.cornerRadius = (object.frame?.size.width)! / 2
        object.layer?.masksToBounds = true
    }
    
    // MARK: - Camera setup
    func setupCamera(){
        
        self.session = AVCaptureSession()
        self.session!.beginConfiguration()
//        self.session!.sessionPreset = .vga640x480 // Model image size is smaller.
        
                self.session!.sessionPreset = .hd1920x1080 // Model image size is smaller.
        
        self.videoDevice = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: .video, position: .back).devices.first
        
        if self.videoDevice == nil {
            self.session?.commitConfiguration()
            self.debugPhotoButtonAction(self)
            return
        }
        do {
            let deviceInput = try AVCaptureDeviceInput(device: self.videoDevice!)
            
            guard self.session!.canAddInput(deviceInput) else {
                print("Could not add video device input to the session")
                self.session!.commitConfiguration()
                return
            }
            
            self.session!.addInput(deviceInput)
            // Setting up preview
            self.setupPreview()
            
            let videoDataOutput = AVCaptureVideoDataOutput()
            
            if self.session!.canAddOutput(videoDataOutput) {
                // Add a video data output
                videoDataOutput.alwaysDiscardsLateVideoFrames = true
                videoDataOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_420YpCbCr8BiPlanarFullRange)]
                videoDataOutput.setSampleBufferDelegate(self, queue: self.videoDataOutputQueue)
                self.session!.addOutput(videoDataOutput)
                DispatchQueue.main.async {
                    self.session!.startRunning()
                }
                // self.session.startRunning()
            } else {
                print("Could not add video data output to the session")
                self.session!.commitConfiguration()
                return
            }
            
            self.stillImageOutput = AVCapturePhotoOutput()
            
            if self.session!.canAddOutput(self.stillImageOutput) {
                self.session!.addOutput(self.stillImageOutput)
            }
            
            let captureConnection = videoDataOutput.connection(with: .video)
            // Always process the frames
            captureConnection?.isEnabled = true
            do {
                try  videoDevice!.lockForConfiguration()
                let dimensions = CMVideoFormatDescriptionGetDimensions((videoDevice?.activeFormat.formatDescription)!)
                bufferSize.width = CGFloat(dimensions.width)
                bufferSize.height = CGFloat(dimensions.height)
                videoDevice!.unlockForConfiguration()
            } catch {
                print(error)
            }
            self.session!.commitConfiguration()
        } catch {
            // print("Could not create video device input: \(error)")
            self.debugPhotoButtonAction(self)
            return
        }
    }
    
    func setupPreview(){
        
        self.previewLayer = AVCaptureVideoPreviewLayer(session: self.session!)
        
        self.previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        self.previewLayer.frame = self.cameraPreviewImageView.layer.bounds
        
        self.previewLayer.connection?.videoOrientation = .portrait
        self.cameraPreviewImageView.layer.addSublayer(previewLayer)
    }
    
    // MARK: - Logic functions
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return
        }
        
        guard let model = self.model else {
            return
        }
        
        let request = VNCoreMLRequest(model: model) { (finishedRequest, error) in
            if let error = error {
                print(error)
            }
            
            guard let results = finishedRequest.results as? [VNClassificationObservation] else {
                return
            }
            
            DispatchQueue.main.async {
                if self.overCameraImageView.alpha == 1 {
                    UIView.animate(withDuration: 0.15, delay: 0, options: .curveEaseIn , animations: {
                        self.overCameraImageView.alpha = 0
                    }, completion: {(completed : Bool) in
                        self.overCameraImageView.image = nil
                    })
                }
                
//                self.coffeeIndicatorLabel.text = results[0].identifier
                if results[0].identifier == "coffee" {
                    self.coffeeIndicatorLabel.text = "Coffee detected"
                    self.captureButton.isEnabled = true
                } else {
                    self.coffeeIndicatorLabel.text = "Coffee not detected"
                    self.captureButton.isEnabled = false
                }
            }
        }
        try? VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [ : ]).perform([request])
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        DispatchQueue.global(qos: .userInitiated).async {
            
            guard let imageData = photo.fileDataRepresentation()
                else { return }
            let image = UIImage(data: imageData)
            
            self.capturedImage = image?.updateImageOrientionUpSide()
            self.transitionToImageProcessing()
        }
    }

    // MARK: - Navigation
    func transitionToImageProcessing(){
        DispatchQueue.main.async {
            self.navigationController?.popViewController(animated: false)
            if let completion = self.parentReturn, let image = self.capturedImage {
                completion(image)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        ////////////////
        // Used for debugging
        if segue.identifier == "debugImageSegueIdentifier" {
            if self.capturedImage == nil {
                let bundlePath = Bundle.main.path(forResource: "heartCoffee", ofType: "jpg")
                self.capturedImage = UIImage(contentsOfFile: bundlePath!)
            }
            
            if let destination = segue.destination as? ProcessingImageViewController {
                destination.capturedImage = self.capturedImage
            }
        }
    }
    
    // MARK: - Other functions
    private func releaseSomeMemory(){
        self.session?.commitConfiguration()
        
        self.session?.stopRunning()
        
        
        self.view.layer.removeAllAnimations()
        
        self.capturedImage = nil
        self.cameraPreviewImageView.image = nil
        
        if let sublayers = self.cameraPreviewImageView.layer.sublayers {
            for sublayer in sublayers {
                sublayer.removeFromSuperlayer()
            }
        }
        self.cameraPreviewImageView.layer.sublayers = []
    }

}
