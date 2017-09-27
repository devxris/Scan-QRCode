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
	
	// Added to support different barcodes
	let supportedBarCodes = [AVMetadataObject.ObjectType.qr,
	                         AVMetadataObject.ObjectType.code128,
	                         AVMetadataObject.ObjectType.code39,
	                         AVMetadataObject.ObjectType.code93,
	                         AVMetadataObject.ObjectType.upce,
	                         AVMetadataObject.ObjectType.pdf417,
	                         AVMetadataObject.ObjectType.ean13,
	                         AVMetadataObject.ObjectType.aztec ]
	
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
			// captureMetadataOutput.metadataObjectTypes = [AVMetadataObject.ObjectType.qr]
			// Detect all the supported bar code
			captureMetadataOutput.metadataObjectTypes = supportedBarCodes

			
			// Initialize the video preview layer and add it as a sublayer to the viewPreview view's layer
			videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession!)
			videoPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
			videoPreviewLayer?.frame = view.layer.bounds
			view.layer.addSublayer(videoPreviewLayer!)
			
			// Start Video capture
			captureSession?.startRunning()
			
			// Move the message label and top bar to the front
			view.bringSubview(toFront: messageLabel)
			view.bringSubview(toFront: topBar)
			
			// Initialize QR Code Frame to highlight the QR code
			qrcodeFrameView = UIView()
			guard let qrcodeFrameView = qrcodeFrameView else { return }
			qrcodeFrameView.layer.borderColor = UIColor.green.cgColor
			qrcodeFrameView.layer.borderWidth = 2
			view.addSubview(qrcodeFrameView)
			view.bringSubview(toFront: qrcodeFrameView)
		} catch {
			print(error); return
		}
	}
	
	// MARK: URL Schemes helper function
	
	/* URL Scheme
	1. launch app in code as below code
	2. register url scheme to open other apps: LSApplicationQueriesSchemes: Array (eg. item0: urlschemereader)
	3. make self to be opened:
	info.plist: URL types (Array)
					item 0 (Dictionary)
					URL Schemes (Array)
						item 0 (String): product name (eg. urlschemereader)
					URL Identifier (String)
	4. supported schemes:
	a. http:// -> open Safari
	b. tel://12345 -> open Phone
	c. sms://12345 -> open Messages
	d. mailto:emailaddress -> open Mail
	e. registerd app:// -> open registered app, eg. fb://feed, whatsapp://send?text=Hello!
	*/
	
	func launchApp(decodedURL: String) {
		if presentedViewController != nil { return } // make sure there is no existed presentingViewController
		let alert = UIAlertController(title: "Open App", message: "You're going to open \(decodedURL)", preferredStyle: .actionSheet)
		let confirm = UIAlertAction(title: "Confirm", style: .default) { (action) in
			if let url = URL(string: decodedURL) {
				if UIApplication.shared.canOpenURL(url) {
					UIApplication.shared.open(url, options: [:], completionHandler: nil)
				}
			}
		}
		let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
		alert.addAction(confirm)
		alert.addAction(cancel)
		present(alert, animated: true, completion: nil)
	}
}

extension QRCodeScannerViewController: AVCaptureMetadataOutputObjectsDelegate {
	
	func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
		// Check if the metadataObjects array is not nil and it contains at least one object
		if metadataObjects.count == 0 {
			qrcodeFrameView?.frame = CGRect.zero
			messageLabel.text = "No barcode/QR code is detected"
			return
		}
		
		// Get the metadata object
		let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
		// Here we use filter method to check if the type of metadataObj is supported
		// Instead of hardcoding the AVMetadataObjectTypeQRCode, we check if the type
		// can be found in the array of supported bar codes
		if supportedBarCodes.contains(metadataObj.type) {
			// if metadataObj.type == AVMetadataObjectTypeQRCode {
			// If the found metadata is equal to the QR code metadata, update status label's text, set the bounds
			let barCodeObject = videoPreviewLayer?.transformedMetadataObject(for: metadataObj)
			qrcodeFrameView?.frame = barCodeObject!.bounds
			
			if metadataObj.stringValue != nil {
				messageLabel.text = metadataObj.stringValue
				launchApp(decodedURL: metadataObj.stringValue!)
			}
		}
	}
}
