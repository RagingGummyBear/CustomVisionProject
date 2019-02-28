//
//  CameraViewController.swift
//  CameraCollection
//
//  Created by Seavus on 1/9/19.
//  Copyright © 2019 Seavus. All rights reserved.
//

// Code from https://guides.codepath.com/ios/Creating-a-Custom-Camera-View

import UIKit
import AVFoundation
import CoreML
import Vision

class CameraViewController: UIViewController, AVCapturePhotoCaptureDelegate, AVCaptureVideoDataOutputSampleBufferDelegate {

    @IBOutlet weak var cameraPreview: UIImageView!
//    @IBOutlet weak var captureImageView: UIImageView!
    @IBOutlet weak var numPhotosTakenLabel: UILabel!
    @IBOutlet weak var takePhotoUIButton: UIButton!
    
    @IBOutlet weak var classificationText: UILabel!
    
    var captureSession: AVCaptureSession!
    var stillImageOutput: AVCapturePhotoOutput!
    var videoPreviewLayer: AVCaptureVideoPreviewLayer!
    var captureDevice: AVCaptureDevice!
    
    @IBOutlet weak var detectedObject: UILabel!
    var capturedImage: UIImage?
    
    var takenPhotosUids : [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.applyRoundCorner(self.takePhotoUIButton)
//        self.setupVision()
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touchPoint = touches.first else { return }
        
        // precondition: the videoView contains the previewLayer, and the frames of the two are being kept equal
        if self.cameraPreview.frame.contains(touchPoint.location(in: self.view)) {
            let touchPointInPreviewLayer = touchPoint.location(in: cameraPreview)
            let focusPoint = videoPreviewLayer.captureDevicePointConverted(fromLayerPoint: touchPointInPreviewLayer)
            
            if let device = captureDevice {
                do {
                    try device.lockForConfiguration()
                    
                    device.focusPointOfInterest = focusPoint
                    //device.focusMode = .continuousAutoFocus
                    device.focusMode = .autoFocus
                    //device.focusMode = .locked
                    
                    device.exposurePointOfInterest = focusPoint
                    device.exposureMode = AVCaptureDevice.ExposureMode.continuousAutoExposure
                    device.unlockForConfiguration()
                }
                catch {
                    // just ignore
                }
            }
        }
        
//        if self.captureImageView.frame.contains(touchPoint.location(in: self.view)) {
//            self.modalDisplayTheImage()
//        }
    }
    
    @IBAction func takePhotoAction(_ sender: Any) {
        let settings = AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.jpeg])
        settings.flashMode = .auto
        stillImageOutput.capturePhoto(with: settings, delegate: self)
    }
    
    func applyRoundCorner(_ object:AnyObject){
        object.layer?.cornerRadius = (object.frame?.size.width)! / 2
        object.layer?.masksToBounds = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        captureSession = AVCaptureSession()
        captureSession.sessionPreset = .photo
        
        guard let captureDevice = AVCaptureDevice.default(for: AVMediaType.video)
            else {
                print("Unable to access back camera!")
                return
        }
        do {
            self.captureDevice = captureDevice
            if captureDevice.isFocusModeSupported(.continuousAutoFocus) {
                try captureDevice.lockForConfiguration()
//                captureDevice.focusMode = .continuousAutoFocus
                captureDevice.unlockForConfiguration()
            }
        }
        catch {
            print(error.localizedDescription)
        }

        
        do {
            let input = try AVCaptureDeviceInput(device: captureDevice)
            stillImageOutput = AVCapturePhotoOutput()
            
            if captureSession.canAddInput(input) && captureSession.canAddOutput(stillImageOutput) {
                captureSession.addInput(input)

//                captureSession.addOutput(stillImageOutput)
                setupLivePreview()
            }
            
            DispatchQueue.global(qos: .userInitiated).async {
                self.captureSession.startRunning()
                let dataOutput = AVCaptureVideoDataOutput()
                dataOutput.setSampleBufferDelegate(self, queue: DispatchQueue.init(label: "videoQueue"))
                self.captureSession.addOutput(dataOutput)
                DispatchQueue.main.async {
                    self.videoPreviewLayer.frame = self.cameraPreview.bounds
                }
            }
        }
        catch let error  {
            print("Error Unable to initialize back camera:  \(error.localizedDescription)")
        }
    }
    
    func setupLivePreview() {
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        videoPreviewLayer.videoGravity = .resizeAspect
        videoPreviewLayer.connection?.videoOrientation = .portrait
        cameraPreview.layer.addSublayer(videoPreviewLayer)
    }

    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        
        DispatchQueue.global(qos: .userInitiated).async {
        
            guard let imageData = photo.fileDataRepresentation()
                else { return }
            
            let image = UIImage(data: imageData)
            self.capturedImage = image
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "TransitionToImageProcessingSegueIdentifier", sender: self)
            }
        }
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return
        }
        
        var requestOptions:[VNImageOption : Any] = [:]
//        guard let model = try? VNCoreMLModel(for: SqueezeNet().model) else {
//            return
//        }
        
//        let request = VNCoreMLRequest(model: model) { (finishedRequest, error) in
//
//            if let erorr = error {
//                print(error)
//            }
//
//            print(finishedRequest.results)
//
//            guard let results = finishedRequest.results as? [VNRecognizedObjectObservation] else { return }
////            self.drawVisionRequestResults(results: results)
//            guard let firstObs = results.first else {
//                return
//            }
////            print(firstObs.identifier, firstObs.confidence)
//            DispatchQueue.main.async {
//
//                self.detectedObject.text = "\(firstObs.labels[0])"
//            }
//        }

//        try? VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [ : ]).perform([request])
//        if let cameraIntrinsicData = CMGetAttachment(sampleBuffer, key: kCMSampleBufferAttachmentKey_CameraIntrinsicMatrix, attachmentModeOut: nil) {
//            requestOptions = [.cameraIntrinsics:cameraIntrinsicData]
//        }
//        let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: CGImagePropertyOrientation(rawValue: 1)!, options: requestOptions)

    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
//        photosMemoryManagment.removeImagesWithId(imageIds: self.takenPhotosUids)
//        photosMemoryManagment.clearAllTempImages()
        super.viewWillDisappear(animated)
        self.captureSession.stopRunning()
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "TransitionToImageProcessingSegueIdentifier" {
            if let destination = segue.destination as? ImageProcessingViewController {
                destination.capturedImage = self.capturedImage
            }
        }
    }
    
    
    // MARK: - Custom functions
//    func drawVisionRequestResults(results: [VNRecognizedObjectObservation]){
//
//        let queue = DispatchQueue(label:"con",attributes:.concurrent)
//        queue.async {
//            print("Easy")
//        }
//
//
//        for objectObservation in results {
//            let topLabelObservation = objectObservation.labels[0]
//            let objectBounds = VNImageRectForNormalizedRect(objectObservation.boundingBox, Int(bufferSize.width), Int(bufferSize.height))
//
//            let shapeLayer = self.createRoundedRectLayerWithBounds(objectBounds)
//
//            let textLayer = self.createTextSubLayerInBounds(objectBounds,
//                                                            identifier: topLabelObservation.identifier,
//                                                            confidence: topLabelObservation.confidence)
//            shapeLayer.addSublayer(textLayer)
//            detectionOverlay.addSublayer(shapeLayer)
//        }
//
//    }
    
}


extension Double {
    /// Rounds the double to decimal places value
    func rounded(toPlaces places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}
