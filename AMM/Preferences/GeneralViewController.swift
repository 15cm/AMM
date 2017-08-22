//
//  GeneralViewController.swift
//  AMM
//
//  Created by Sinkerine on 19/02/2017.
//  Copyright © 2017 sinkerine. All rights reserved.
//

import Cocoa

class GeneralViewController: NSViewController {
    let preferences = AMMPreferences.instance

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    @IBAction func magnetAssocBtnClicked(_ sender: Any) {
        if let bundleIdentifier = Bundle.main.bundleIdentifier {
            if(confirmAlert("Confirmation", "Are you sure to set AMM as the default program to open magnet link?")) {
                LSSetDefaultHandlerForURLScheme("magnet" as CFString, bundleIdentifier as CFString)
            }
        } else {
            showAlert("Error",  "BundleIdenrifier not found!")
        }
    }
}
