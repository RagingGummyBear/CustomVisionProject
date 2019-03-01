//
//  AppleDocsCameraViewController.swift
//  CustomVisionProject
//
//  Created by Seavus on 2/19/19.
//  Copyright © 2019 Seavus. All rights reserved.
//

import UIKit
import AVFoundation
import CoreML
import Vision

class AppleDocsCameraViewController: UIViewController, AVCapturePhotoCaptureDelegate, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    // MARK: - Custom properties
    private var session: AVCaptureSession!
    private var previewLayer: AVCaptureVideoPreviewLayer!
    private var videoDevice: AVCaptureDevice!
    private var stillImageOutput: AVCapturePhotoOutput!
    
    private let videoDataOutputQueue = DispatchQueue.init(label: "videoOutput")
    private var bufferSize = CGSize(width: 0.0, height: 0.0)

    private var detectionOverlay: CALayer!
    
    private var capturedImage: UIImage!
    
    // MARK: - Outlets
    @IBOutlet weak var cameraDisplayImageView: UIImageView!
    @IBOutlet weak var imageStatusLabel: UILabel!
    @IBOutlet weak var captureImageButton: UIButton!
    
    // MARK: - UIOutlets actions
    
    @IBAction func captureButtonAction(_ sender: Any) {
//        let settings = AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.jpeg])
//        settings.flashMode = .auto
//        stillImageOutput.capturePhoto(with: settings, delegate: self)
        let settings = AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.jpeg])
//        settings.flashMode = .auto
        self.stillImageOutput.capturePhoto(with: settings, delegate: self)
    }
    
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
//        self.setupCamera()
//        self.setupPreview()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.setupCamera()
        self.setupPreview()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.session.stopRunning()
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
        self.previewLayer.frame = self.cameraDisplayImageView.layer.bounds

        self.previewLayer.connection?.videoOrientation = .portrait
        self.cameraDisplayImageView.layer.addSublayer(previewLayer)
        
        self.detectionOverlay = CALayer() // container layer that has all the renderings of the observations
        self.detectionOverlay.name = "DetectionOverlay"
        self.detectionOverlay.bounds = CGRect(x: 0.0,
                                         y: 0.0,
                                         width: bufferSize.width,
                                         height: bufferSize.height)
        self.detectionOverlay.position = CGPoint(x: self.cameraDisplayImageView.layer.bounds.midX, y: self.cameraDisplayImageView.layer.bounds.midY)
        self.cameraDisplayImageView.layer.addSublayer(detectionOverlay)
        
        
//        self.cameraDisplayImageView.addSubview(self.detectionOverlay)
//        self.cameraDisplayImageView.layer.addSublayer(self.detectionOverlay)
    }
    
    // MARK: - Custom functions
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
                self.imageStatusLabel.text = results[0].identifier
                if results[0].identifier == "coffee" {
                    self.captureImageButton.isEnabled = true
                } else {
                    self.captureImageButton.isEnabled = false
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
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "imageProcessSegueIdentifier", sender: self)
            }
        }
    }
    
    
    func drawVisionRequestResults(_ results: [Any]) {
        CATransaction.begin()
        CATransaction.setValue(kCFBooleanTrue, forKey: kCATransactionDisableActions)
        detectionOverlay.sublayers = nil // remove all the old recognized objects
        for observation in results where observation is VNRecognizedObjectObservation {
            guard let objectObservation = observation as? VNRecognizedObjectObservation else {
                continue
            }
            // Select only the label with the highest confidence.
            let topLabelObservation = objectObservation.labels[0]
            let objectBounds = VNImageRectForNormalizedRect(objectObservation.boundingBox, Int(bufferSize.width), Int(bufferSize.height))
            
            let shapeLayer = self.createRoundedRectLayerWithBounds(objectBounds)
            
            let textLayer = self.createTextSubLayerInBounds(objectBounds,
                                                            identifier: topLabelObservation.identifier,
                                                            confidence: topLabelObservation.confidence)
            shapeLayer.addSublayer(textLayer)
            detectionOverlay.addSublayer(shapeLayer)
        }
        
        self.updateLayerGeometry()
        CATransaction.commit()
    }
    
    func updateLayerGeometry() {
        let bounds = self.cameraDisplayImageView.layer.bounds
        var scale: CGFloat
        
        let xScale: CGFloat = bounds.size.width / bufferSize.height
        let yScale: CGFloat = bounds.size.height / bufferSize.width
        
        scale = fmax(xScale, yScale)
        if scale.isInfinite {
            scale = 1.0
        }
        CATransaction.begin()
        CATransaction.setValue(kCFBooleanTrue, forKey: kCATransactionDisableActions)
        
        // rotate the layer into screen orientation and scale and mirror
        detectionOverlay.setAffineTransform(CGAffineTransform(rotationAngle: CGFloat(.pi / 2.0)).scaledBy(x: scale, y: -scale))
        // center the layer
        detectionOverlay.position = CGPoint (x: bounds.midX, y: bounds.midY)
        
        CATransaction.commit()
        
    }
    
    func createTextSubLayerInBounds(_ bounds: CGRect, identifier: String, confidence: VNConfidence) -> CATextLayer {
        let textLayer = CATextLayer()
        textLayer.name = "Object Label"
        let formattedString = NSMutableAttributedString(string: String(format: "\(identifier)\nConfidence:  %.2f", confidence))
        let largeFont = UIFont(name: "Helvetica", size: 24.0)!
        formattedString.addAttributes([NSAttributedString.Key.font: largeFont], range: NSRange(location: 0, length: identifier.count))
        textLayer.string = formattedString
        textLayer.bounds = CGRect(x: 0, y: 0, width: bounds.size.height - 10, height: bounds.size.width - 10)
        textLayer.position = CGPoint(x: bounds.midX, y: bounds.midY)
        textLayer.shadowOpacity = 0.7
        textLayer.shadowOffset = CGSize(width: 2, height: 2)
        textLayer.foregroundColor = CGColor(colorSpace: CGColorSpaceCreateDeviceRGB(), components: [0.0, 0.0, 0.0, 1.0])
        textLayer.contentsScale = 2.0 // retina rendering
        // rotate the layer into screen orientation and scale and mirror
        textLayer.setAffineTransform(CGAffineTransform(rotationAngle: CGFloat(.pi / 2.0)).scaledBy(x: 1.0, y: -1.0))
        return textLayer
    }
    
    func createRoundedRectLayerWithBounds(_ bounds: CGRect) -> CALayer {
        let shapeLayer = CALayer()
        shapeLayer.bounds = bounds
        shapeLayer.position = CGPoint(x: bounds.midX, y: bounds.midY)
        shapeLayer.name = "Found Object"
        shapeLayer.backgroundColor = CGColor(colorSpace: CGColorSpaceCreateDeviceRGB(), components: [1.0, 1.0, 0.2, 0.4])
        shapeLayer.cornerRadius = 7
        return shapeLayer
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        
        if segue.identifier == "imageProcessSegueIdentifier" {
            if let dest = segue.destination as? ImageProcessingViewController {
                dest.capturedImage = self.capturedImage
            }
        }
    }

}

