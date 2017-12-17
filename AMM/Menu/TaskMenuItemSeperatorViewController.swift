//
//  TaskMenuItemSeperatorViewController.swift
//  AMM
//
//  Created by Sinkerine on 02/02/2017.
//  Copyright © 2017 sinkerine. All rights reserved.
//

import Cocoa

class TaskMenuItemSeperatorViewController: NSViewController {
    @objc var name: String? = nil

    @IBOutlet var viewDark: NSView!
    
    override func viewDidLoad() {
        if AMMPreferences.instance.darkModeEnabled {
            self.view = viewDark
        }
        super.viewDidLoad()
        // Do view setup here.
    }
    
}
