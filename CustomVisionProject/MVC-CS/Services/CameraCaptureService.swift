//
//  CameraCaptureService.swift
//  CustomVisionProject
//
//  Created by Seavus on 4/25/19.
//  Copyright © 2019 Seavus. All rights reserved.
//

import UIKit
import AVFoundation
import CoreML
import Vision

class CameraCaptureService : NSObject, AVCapturePhotoCaptureDelegate, AVCaptureVideoDataOutputSampleBufferDelegate {

    // MARK: - UI classes
    weak var cameraPhotoTakeDelegate:CameraPhotoTakeDelegate!
    weak var cameraPreviewImageView: UIImageView!
    weak var overCameraImageView: UIImageView!
    weak var captureButton: UIButton!
    weak var coffeeIndicatorLabel: UILabel!

    public init(cameraPhotoTakeDelegate:CameraPhotoTakeDelegate, cameraPreviewImageView: UIImageView, overCameraImageView: UIImageView, captureButton: UIButton, coffeeIndicatorLabel: UILabel) {
        self.cameraPhotoTakeDelegate = cameraPhotoTakeDelegate
        self.cameraPreviewImageView = cameraPreviewImageView
        self.overCameraImageView = overCameraImageView
        self.captureButton = captureButton
        self.coffeeIndicatorLabel = coffeeIndicatorLabel
    }
    
    // MARK: - Your class properties
    private var session: AVCaptureSession?
    private var previewLayer: AVCaptureVideoPreviewLayer!
    private var videoDevice: AVCaptureDevice? = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: .video, position: .back).devices.first
    lazy private var model = try? VNCoreMLModel(for: CoffeePorscheClass().model)
    private var stillImageOutput: AVCapturePhotoOutput!
    
    private let videoDataOutputQueue = DispatchQueue.init(label: "com.seavus.customvision.videoOutput")
    private var bufferSize = CGSize(width: 0.0, height: 0.0)
    
    // MARK: - Your functions
    func capturePhotoAction(){
        
        let settings = AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.jpeg])
        
        stillImageOutput.capturePhoto(with: settings, delegate: self)
    }
    
    func setupCamera(){
        
        self.session = AVCaptureSession()
        self.session!.beginConfiguration()
        //        self.session!.sessionPreset = .vga640x480 // Model image size is smaller.
        
        self.session!.sessionPreset = .hd1920x1080 // Model image size is smaller.
        
        self.videoDevice = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: .video, position: .back).devices.first
        
        if self.videoDevice == nil {
            self.session?.commitConfiguration()
            self.cameraPhotoTakeDelegate.setupFailed()
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
                if self.overCameraImageView == nil {
                    return
                }
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
            self.session?.stopRunning()
            if let img =  image, let orientedImg = img.updateImageOrientionUpSide() {
                self.cameraPhotoTakeDelegate.photoTaken(photo: orientedImg)
            }
        }
    }
    
    deinit {
        self.session?.commitConfiguration()
        self.session?.stopRunning() // https://www.youtube.com/watch?v=W6oQUDFV2C0
    }
}

public protocol CameraPhotoTakeDelegate: class {
    func photoTaken(photo: UIImage)
    func setupFailed()
}
