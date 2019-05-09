//
//  CameraCaptureService.swift
//  CustomVisionProject
//
//  Created by Seavus on 4/25/19.
//  Copyright © 2019 Seavus. All rights reserved.
//

import AVFoundation
import CoreML
import Vision

class CameraCaptureService : NSObject, AVCapturePhotoCaptureDelegate, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    // MARK: - Your class properties
    public weak var coordinator: PhotoTakeCoordinator!
    private var session: AVCaptureSession?
//    private weak var previewLayer: AVCaptureVideoPreviewLayer!
    private weak var videoDevice: AVCaptureDevice? = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: .video, position: .back).devices.first
    lazy private var model = try? VNCoreMLModel(for: CoffeePorscheClass().model)
    private var stillImageOutput: AVCapturePhotoOutput!
    
    private let videoDataOutputQueue = DispatchQueue.init(label: "com.seavus.customvision.videoOutput")
    private var bufferSize = CGSize(width: 0.0, height: 0.0)
    
    public init(coordinator: PhotoTakeCoordinator) {
        self.coordinator = coordinator
    }
    
    // MARK: - Your functions
    func capturePhotoAction(){
        
        let settings = AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.jpeg])
        
        stillImageOutput.capturePhoto(with: settings, delegate: self)
    }
    
    func setupCamera(){
        
        self.session = AVCaptureSession()
        self.session!.beginConfiguration()
        // self.session!.sessionPreset = .vga640x480 // <<< --- ugly
        // self.session!.sessionPreset = .hd1280x720 // <<< --- lowest
         self.session!.sessionPreset = .high // <<< --- this looks cool
        // self.session!.sessionPreset = .hd1920x1080 // <<< --- demanding
//         self.session?.sessionPreset = .hd4K3840x2160 // <<< --- Fantasy
        
        self.videoDevice = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: .video, position: .back).devices.first
        
        if self.videoDevice == nil {
            self.session?.commitConfiguration()
            self.coordinator.setupFailed()
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
        let previewLayer = AVCaptureVideoPreviewLayer(session: self.session!)
        
        previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        previewLayer.frame = self.coordinator.getCameraPreviewFrame()
        previewLayer.connection?.videoOrientation = .portrait
        self.coordinator.setCameraPreviewLayer(previewLayer: previewLayer)
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
            
            DispatchQueue.main.async { [weak self] in
                if self?.coordinator != nil {
                    if results[0].identifier == "coffee" {
                        self?.coordinator.captureButtonEnable()
                    } else {
                        self?.coordinator.captureButtonDisable()
                    }
                }
            }
        }
        try? VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [ : ]).perform([request])
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        DispatchQueue.global(qos: .userInitiated).async { [unowned self] in
            guard let imageData = photo.fileDataRepresentation()
                else { return }
            let image = UIImage(data: imageData)
            self.session?.stopRunning()
            if let img =  image, let orientedImg = img.updateImageOrientionUpSide() {
                self.coordinator.photoTaken(photo: orientedImg)
            }
        }
    }
        
    deinit {
        self.session?.commitConfiguration()
        self.session?.stopRunning() // https://www.youtube.com/watch?v=W6oQUDFV2C0
    }
}
