//
//  Aria2MenuBarItem.swift
//  aria2-menubar-monitor
//
//  Created by Sinkerine on 24/01/2017.
//  Copyright © 2017 sinkerine. All rights reserved.
//

import Cocoa

class MainMenu: NSObject, ServerProfileManagerDelegate {
    var statusItem = NSStatusBar.system().statusItem(withLength: NSSquareStatusItemLength)
    var servers: [ServerProfile] = []
    var fixMenuItems: [NSMenuItem] = []
    var preferencesWindowController: PreferencesWindowController? = nil
    var profileManager = ServerProfileManager.instance
    
    @IBOutlet weak var menu: NSMenu!
    
    override func awakeFromNib() {
        statusItem.image = #imageLiteral(resourceName: "menu-icon")
        statusItem.menu = menu
        for i in ((statusItem.menu?.numberOfItems)! - 3) ..< (statusItem.menu?.numberOfItems)! {
            fixMenuItems.append((statusItem.menu?.item(at: i))!)
        }
        profileManager.delegate = self
        updateMenuItems(withServerProfiles: profileManager.servers)
    }
    
    func updateMenuItems(withServerProfiles servers: [ServerProfile]) {
        self.servers = servers
        statusItem.menu?.removeAllItems()
        for server in servers{
            statusItem.menu?.addItem(ServerProfileMenuItem(server))
        }
        for item in fixMenuItems {
            statusItem.menu?.addItem(item)
        }
    }
    
    func onServerProfilesUpdate(withServerProfiles servers: [ServerProfile]) {
        updateMenuItems(withServerProfiles: servers)
    }
    
    @IBAction func quitClicked(_ sender: NSMenuItem) {
        NSApplication.shared().terminate(self)
    }
    
    @IBAction func preferencesClicked(_ sender: NSMenuItem) {
        if preferencesWindowController != nil {
            preferencesWindowController?.close()
        }
        let ctrl = PreferencesWindowController(windowNibName: "PreferenceWindowController")
        preferencesWindowController = ctrl
        ctrl.showWindow(self)
        NSApp.activate(ignoringOtherApps: true)
        ctrl.window?.makeKeyAndOrderFront(self)
    }
}

