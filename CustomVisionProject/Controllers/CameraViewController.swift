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

class CameraViewController: UIViewController, AVCapturePhotoCaptureDelegate {

    @IBOutlet weak var cameraPreview: UIImageView!
//    @IBOutlet weak var captureImageView: UIImageView!
    @IBOutlet weak var numPhotosTakenLabel: UILabel!
    @IBOutlet weak var takePhotoUIButton: UIButton!
    
    @IBOutlet weak var classificationText: UILabel!
    
    var captureSession: AVCaptureSession!
    var stillImageOutput: AVCapturePhotoOutput!
    var videoPreviewLayer: AVCaptureVideoPreviewLayer!
    var captureDevice: AVCaptureDevice!
    
    var capturedImage: UIImage?
    
    var takenPhotosUids : [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.applyRoundCorner(self.takePhotoUIButton)
        self.setupVision()
        
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
                captureSession.addOutput(stillImageOutput)
                setupLivePreview()
            }
            
            DispatchQueue.global(qos: .userInitiated).async {
                self.captureSession.startRunning()
                
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
        if let cameraIntrinsicData = CMGetAttachment(sampleBuffer, key: kCMSampleBufferAttachmentKey_CameraIntrinsicMatrix, attachmentModeOut: nil) {
            requestOptions = [.cameraIntrinsics:cameraIntrinsicData]
        }
        let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: CGImagePropertyOrientation(rawValue: 1)!, options: requestOptions)
        do {
            try imageRequestHandler.perform(self.requests)
        } catch {
            print(error)
        }
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
    
    // MARK: - MachineLearning
    private var requests = [VNRequest]()
    
    func setupVision() {
        guard let visionModel = try? VNCoreMLModel(for: keyboardModel().model)
            else { fatalError("Can't load VisionML model") }
        let classificationRequest = VNCoreMLRequest(model: visionModel, completionHandler: handleClassifications)
        classificationRequest.imageCropAndScaleOption = VNImageCropAndScaleOption.centerCrop
        self.requests = [classificationRequest]
    }
    
    func handleClassifications(request: VNRequest, error: Error?) {
        guard let observations = request.results
            else { print("no results: \(error!)"); return }
        let classifications = observations[0...4]
            .flatMap({ $0 as? VNClassificationObservation })
            .filter({ $0.confidence > 0.3 })
            .map {
                (prediction: VNClassificationObservation) -> String in
                return "\(round(prediction.confidence * 100 * 100)/100)%: \(prediction.identifier)"
        }
        DispatchQueue.main.async {
            print(classifications.joined(separator: "###"))
            self.classificationText.text = classifications.joined(separator: "\n")
        }
    }

    
}
