//
//  CustomCameraController.swift
//  RosenergoMobileAgentiOS
//
//  Created by Дмитрий Лисин on 29.05.2020.
//  Copyright © 2020 Дмитрий Лисин. All rights reserved.
//

import AVFoundation
import SwiftUI

class CustomCameraController: UIViewController {
    var captureSession = AVCaptureSession()
    var newCamera: AVCaptureDevice.Position = .back
    var deviceInput: AVCaptureDeviceInput?
    var selectCamera: AVCaptureDevice?
    var currentCamera: AVCaptureDevice?
    var photoOutput: AVCapturePhotoOutput?
    var cameraPreviewLayer: AVCaptureVideoPreviewLayer?
    var delegate: AVCapturePhotoCaptureDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    func setup() {
        setupCaptureSession()
        setupDevice()
        setupInputOutput()
        setupPreviewLayer()
        startRunningCaptureSession()
    }
    
    func didTapRecord(flashMode: AVCaptureDevice.FlashMode) {
        let settings = AVCapturePhotoSettings()
        settings.flashMode = flashMode
        photoOutput?.capturePhoto(with: settings, delegate: delegate!)
    }
    
    func setupCaptureSession() {
        captureSession.sessionPreset = AVCaptureSession.Preset.photo
    }
    
    func setupDevice() {
        let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [AVCaptureDevice.DeviceType.builtInWideAngleCamera], mediaType: AVMediaType.video, position: newCamera)
        
        for device in deviceDiscoverySession.devices {
            switch device.position {
            case AVCaptureDevice.Position.front:
                selectCamera = device
            case AVCaptureDevice.Position.back:
                selectCamera = device
            default:
                break
            }
        }
        currentCamera = selectCamera
    }
    
    func setupInputOutput() {
        do {
            let setDeviceInput = try AVCaptureDeviceInput(device: currentCamera!)
            if captureSession.canAddInput(setDeviceInput) {
                captureSession.addInput(setDeviceInput)
                deviceInput = setDeviceInput
            }
            let setPhotoOutput = AVCapturePhotoOutput()
            setPhotoOutput.setPreparedPhotoSettingsArray([AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.jpeg])], completionHandler: nil)
            if captureSession.canAddOutput(setPhotoOutput) {
                captureSession.addOutput(setPhotoOutput)
                photoOutput = setPhotoOutput
            }
        } catch {
            log(error.localizedDescription)
        }
    }
    
    func setupPreviewLayer() {
        cameraPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        cameraPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        cameraPreviewLayer?.connection?.videoOrientation = .portrait
        cameraPreviewLayer?.frame = view.frame
        view.layer.insertSublayer(cameraPreviewLayer!, at: 0)
    }
    
    func startRunningCaptureSession() {
        captureSession.startRunning()
    }
}
