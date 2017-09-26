//
//  QRCodeViewController.swift
//  Scan QRCode
//
//  Created by Chris Huang on 26/09/2017.
//  Copyright © 2017 Chris Huang. All rights reserved.
//

import UIKit

class QRCodeViewController: UIViewController {

	override var preferredStatusBarStyle: UIStatusBarStyle { return .lightContent }

	@IBAction func unwind(segue: UIStoryboardSegue) {
		dismiss(animated: true, completion: nil)
	}
}

