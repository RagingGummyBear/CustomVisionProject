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
    var capturedImage: UIImage?
    private var photoTaken = false
    
    // MARK: - IBOutlets references
    @IBOutlet weak var cameraPreviewImageView: UIImageView!
    @IBOutlet weak var overCameraImageView: UIImageView!
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var captureButton: UIButton!
    @IBOutlet weak var coffeeIndicatorLabel: UILabel!
    
    // MARK: - IBOutlets actions
    @IBAction func captureButtonAction(_ sender: Any) {
        
        let settings = AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.jpeg])
//        settings.flashMode = .auto
        stillImageOutput.capturePhoto(with: settings, delegate: self)
    }
    
    // MARK: - View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        if self.videoDevice == nil {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.performSegue(withIdentifier: "debugImageSegueIdentifier", sender: self)
            }
        }
        
        DispatchQueue.main.async {
            self.initalUISetup()
        }
        
//        self.performSegue(withIdentifier: "debugImageSegueIdentifier", sender: self)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        DispatchQueue.main.async {
            self.finalUISetup()
        }
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.session?.stopRunning()
        
        self.view.layer.removeAllAnimations()
        
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
        self.capturedImage = nil
        self.cameraPreviewImageView.image = nil
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
        self.applyRoundCorner(self.captureButton)
        
        self.setupCamera()
//        self.setupPreview()
    }
    
    func finalUISetup(){
        // Here do all the resizing and constraint calculations
        // In some cases apply the background gradient here
        self.applyRoundCorner(self.captureButton)
    }
    
    func applyRoundCorner(_ object:AnyObject){
        object.layer?.cornerRadius = (object.frame?.size.width)! / 2
        object.layer?.masksToBounds = true
    }
    
    // MARK: - Camera setup
    func setupCamera(){
        
        self.session = AVCaptureSession()
        self.session!.beginConfiguration()
        self.session!.sessionPreset = .vga640x480 // Model image size is smaller.
        
        self.videoDevice = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: .video, position: .back).devices.first
        
        if self.videoDevice == nil {
            // TO SOON FOR PERFORMSEGUE!
//            DispatchQueue.main.asyncAfter(deadline: .now() + 15) {
//                print("15 have passed brah")
//                self.performSegue(withIdentifier: "debugImageSegueIdentifier", sender: self)
//            }
            self.session?.commitConfiguration()
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.performSegue(withIdentifier: "debugImageSegueIdentifier", sender: self)
            }
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
            print("Could not create video device input: \(error)")
            return
        }
    }
    
    func setupPreview(){
        
        self.previewLayer = AVCaptureVideoPreviewLayer(session: self.session!)
        
        self.previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        self.previewLayer.frame = self.cameraPreviewImageView.layer.bounds
        
        self.previewLayer.connection?.videoOrientation = .portrait
        self.cameraPreviewImageView.layer.addSublayer(previewLayer)
        print("Me here ! /WAVE")
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
                    }, completion: nil)
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
        if photoTaken {
            return
        }
        photoTaken = true
        DispatchQueue.main.async {
            let imageProcessingViewController = self.storyboard?.instantiateViewController(withIdentifier: "imageProcessingViewController") as! ProcessingImageViewController
            imageProcessingViewController.capturedImage = self.capturedImage
            self.navigationController?.pushViewController(imageProcessingViewController, animated: true)
        }
    }
    
    // MARK: - Other functions
    
    private func releaseSomeMemory(){
        self.session?.stopRunning()
        
        if let sublayers = self.cameraPreviewImageView.layer.sublayers {
            for sublayer in sublayers {
                sublayer.removeFromSuperlayer()
            }
        }
        self.cameraPreviewImageView.layer.sublayers = []
    }

}
