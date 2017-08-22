//
//  SelectServerWindowController.swift
//  AMM
//
//  Created by Sinkerine on 21/08/2017.
//  Copyright © 2017 sinkerine. All rights reserved.
//

import Cocoa

class SelectServerWindowController: NSWindowController {
    var servers: [ServerProfile]?
    var urlToHandle: String?
    var onServerSelected: ((ServerProfile?) -> Void)?
    
    @IBOutlet weak var serverPopUpBtn: NSPopUpButton!
    @IBOutlet weak var urlToHandleLabel: NSTextField!
    
    convenience init() {
        self.init(windowNibName: "SelectServerWindowController")
    }
    
    convenience init(urlToHandle url: String, _ servers: [ServerProfile]) {
        self.init()
        urlToHandle = url
        self.servers = servers
    }
    
    override func windowDidLoad() {
        super.windowDidLoad()

        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
        urlToHandleLabel.toolTip = urlToHandle
    }
    
    @IBAction func okClicked(_ sender: Any) {
        onServerSelected?(servers?[serverPopUpBtn.indexOfSelectedItem])
        window?.close()
    }
    
}
