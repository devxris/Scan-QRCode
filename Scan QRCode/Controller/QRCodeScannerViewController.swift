//
//  QRCodeScannerViewController.swift
//  Scan QRCode
//
//  Created by Chris Huang on 26/09/2017.
//  Copyright © 2017 Chris Huang. All rights reserved.
//

import UIKit
import AVFoundation

class QRCodeScannerViewController: UIViewController {
	
	override var preferredStatusBarStyle: UIStatusBarStyle { return .lightContent }

	@IBOutlet weak var topBar: UIView!
	@IBOutlet weak var messageLabel: UILabel!
	
	var captureSession: AVCaptureSession?
	var videoPreviewLayer: AVCaptureVideoPreviewLayer?
	var qrcodeFrameView: UIView?
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		// Quick Response code is based on video capturing
		// Get AVCaptureDevice to initialize a device object and provide the video as the media type parameter
		guard let captureDevice = AVCaptureDevice.default(for: AVMediaType.video) else { return }
		do {
			// Get AVCaptureDeviceInput class using the previous device object
			let input = try AVCaptureDeviceInput(device: captureDevice)
			
			// Configure AVCaptureSession
			captureSession = AVCaptureSession()
			captureSession?.addInput(input)
			
			// Initialize a AVCaptureMetadataOutput object and set it as the output device to the capture session
			let captureMetadataOutput = AVCaptureMetadataOutput()
			captureSession?.addOutput(captureMetadataOutput)
			
			// Set delegate and use the default dispatch queue to execute the call back
			captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
			captureMetadataOutput.metadataObjectTypes = [AVMetadataObject.ObjectType.qr]
			
			// Initialize the video preview layer and add it as a sublayer to the viewPreview view's layer
			videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession!)
			videoPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
			videoPreviewLayer?.frame = view.layer.bounds
			view.layer.addSublayer(videoPreviewLayer!)
			
			// Start Video capture
			captureSession?.startRunning()
			
		} catch {
			print(error); return
		}
		
		// Move the message label and top bar to the front
		view.bringSubview(toFront: messageLabel)
		view.bringSubview(toFront: topBar)
	}
}

extension QRCodeScannerViewController: AVCaptureMetadataOutputObjectsDelegate {
	
}
