//
//  PreferencesWindowController.swift
//  AMM
//
//  Created by Sinkerine on 19/02/2017.
//  Copyright © 2017 sinkerine. All rights reserved.
//

import Cocoa

@objcMembers
class PreferencesWindowController: NSWindowController, NSWindowDelegate {
    let preferences = AMMPreferences.instance

    override func windowDidLoad() {
        super.windowDidLoad()
    
        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    }
    
    func windowWillClose(_ notification: Notification) {
                preferences.save()
                preferences.load()
    }
}
