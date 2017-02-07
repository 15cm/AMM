//
//  PreferencesWindowController.swift
//  AMM
//
//  Created by Sinkerine on 01/02/2017.
//  Copyright © 2017 sinkerine. All rights reserved.
//

import Cocoa

class PreferencesWindowController: NSWindowController, NSWindowDelegate {
    let profileManager = ServerProfileManager.instance
    
    @IBOutlet weak var protocolPopUpButton: NSPopUpButton!
    @IBOutlet weak var serverTableScrollView: NSScrollView!
    
    override var windowNibName: String? {
        return "PreferencesWindowController"
    }
    
    @IBOutlet var arrayController: NSArrayController!
    
    override func windowDidLoad() {
        super.windowDidLoad()

        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
        serverTableScrollView.borderType = .noBorder
        protocolPopUpButton.addItems(withTitles: Aria2Protocols.allValues.map({$0.rawValue}))
        let protocolOfSelection = (arrayController.selection as AnyObject).value(forKey: "protocolRawValue") as! String?
        protocolPopUpButton.selectItem(withTitle: protocolOfSelection!)
    }

    func reloadProfiles() {
        profileManager.loadPref()
        arrayController.content = profileManager.servers
    }
    
    @IBAction func okClicked(_ sender: Any) {
        profileManager.savePref()
        window?.performClose(self)
    }
    
    @IBAction func cancelClicked(_ sender: Any) {
        window?.performClose(self)
    }
    
    func windowShouldClose(_ sender: Any) -> Bool {
        reloadProfiles()
        return true
    }
}
