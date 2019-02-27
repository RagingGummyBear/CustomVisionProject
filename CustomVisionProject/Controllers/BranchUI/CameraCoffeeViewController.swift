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
    private var session: AVCaptureSession!
    private var previewLayer: AVCaptureVideoPreviewLayer!
    private var videoDevice: AVCaptureDevice!
    private var stillImageOutput: AVCapturePhotoOutput!
    
    
    private let videoDataOutputQueue = DispatchQueue.init(label: "com.seavus.customvision.videoOutput")
    private var bufferSize = CGSize(width: 0.0, height: 0.0)
    var capturedImage: UIImage?
    
    // MARK: - IBOutlets references
    @IBOutlet weak var cameraPreviewImageView: UIImageView!
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
        self.session.stopRunning()
    }
    
    // MARK: - UI Functions
    func initalUISetup(){
        // Change label's text, etc.
        self.applyRoundCorner(self.captureButton)
    }
    
    func finalUISetup(){
        // Here do all the resizing and constraint calculations
        // In some cases apply the background gradient here
        self.applyRoundCorner(self.captureButton)
        
        self.setupCamera()
        self.setupPreview()
    }
    
    func applyRoundCorner(_ object:AnyObject){
        object.layer?.cornerRadius = (object.frame?.size.width)! / 2
        object.layer?.masksToBounds = true
    }
    
    // MARK: - Camera setup
    func setupCamera(){
        
        self.session = AVCaptureSession()
        self.session.beginConfiguration()
        self.session.sessionPreset = .vga640x480 // Model image size is smaller.
        
        self.videoDevice = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: .video, position: .back).devices.first
        
        do {
            let deviceInput = try AVCaptureDeviceInput(device: self.videoDevice!)
            
            guard session.canAddInput(deviceInput) else {
                print("Could not add video device input to the session")
                session.commitConfiguration()
                return
            }
            session.addInput(deviceInput)
            // Setting up preview
            self.setupPreview()
            
            let videoDataOutput = AVCaptureVideoDataOutput()
            
            if session.canAddOutput(videoDataOutput) {
                // Add a video data output
                videoDataOutput.alwaysDiscardsLateVideoFrames = true
                videoDataOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_420YpCbCr8BiPlanarFullRange)]
                videoDataOutput.setSampleBufferDelegate(self, queue: self.videoDataOutputQueue)
                session.addOutput(videoDataOutput)
                DispatchQueue.main.async {
                    self.session.startRunning()
                }
                //                self.session.startRunning()
            } else {
                print("Could not add video data output to the session")
                session.commitConfiguration()
                return
            }
            
            self.stillImageOutput = AVCapturePhotoOutput()
            
            if self.session.canAddOutput(self.stillImageOutput) {
                self.session.addOutput(self.stillImageOutput)
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
            session.commitConfiguration()
        } catch {
            print("Could not create video device input: \(error)")
            return
        }
        
    }
    
    func setupPreview(){
        
        self.previewLayer = AVCaptureVideoPreviewLayer(session: self.session)
        
        self.previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        self.previewLayer.frame = self.cameraPreviewImageView.layer.bounds
        
        self.previewLayer.connection?.videoOrientation = .portrait
        self.cameraPreviewImageView.layer.addSublayer(previewLayer)
        
//        self.detectionOverlay = CALayer() // container layer that has all the renderings of the observations
//        self.detectionOverlay.name = "DetectionOverlay"
//        self.detectionOverlay.bounds = CGRect(x: 0.0,
//                                              y: 0.0,
//                                              width: bufferSize.width,
//                                              height: bufferSize.height)
//        self.detectionOverlay.position = CGPoint(x: self.cameraDisplayImageView.layer.bounds.midX, y: self.cameraDisplayImageView.layer.bounds.midY)
//        self.cameraDisplayImageView.layer.addSublayer(detectionOverlay)
        
    }
    
    // MARK: - Logic functions
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return
        }
        
        var requestOptions:[VNImageOption : Any] = [:]
        guard let model = try? VNCoreMLModel(for: CoffeePorscheClass().model) else {
            return
        }
        
        let request = VNCoreMLRequest(model: model) { (finishedRequest, error) in
            if let error = error {
                print(error)
            }
            
            //            print(finishedRequest.results)
            
            guard let results = finishedRequest.results as? [VNClassificationObservation] else {
                return
            }
            
            DispatchQueue.main.async {
                self.coffeeIndicatorLabel.text = results[0].identifier
                if results[0].identifier == "coffee" {
                    self.captureButton.isEnabled = true
                } else {
                    self.captureButton.isEnabled = false
                }
            }
            
        }
        
        try? VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [ : ]).perform([request])
        if let cameraIntrinsicData = CMGetAttachment(sampleBuffer, key: kCMSampleBufferAttachmentKey_CameraIntrinsicMatrix, attachmentModeOut: nil) {
            requestOptions = [.cameraIntrinsics:cameraIntrinsicData]
        }
        //        let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: CGImagePropertyOrientation(rawValue: 1)!, options: requestOptions)
        
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
            let imageProcessingViewController = self.storyboard?.instantiateViewController(withIdentifier: "imageProcessingViewController") as! ProcessingImageViewController
            imageProcessingViewController.capturedImage = self.capturedImage
            self.navigationController?.pushViewController(imageProcessingViewController, animated: true)
        }
    }
    
    // MARK: - Other functions
}
