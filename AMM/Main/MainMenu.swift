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
    var preferencesWindowController: NSWindowController!
    var aboutWindowController: AboutWindowController? = nil
    var profileManager = ServerProfileManager.instance

    @IBOutlet weak var menu: NSMenu!

    override func awakeFromNib() {
        let icon = NSImage(named: "menu-icon")
        icon?.isTemplate = true
        statusItem.image = icon
        statusItem.menu = menu
        for i in ((statusItem.menu?.numberOfItems)! - 3) ..< (statusItem.menu?.numberOfItems)! {
            fixMenuItems.append((statusItem.menu?.item(at: i))!)
        }
        profileManager.delegate = self
        updateMenuItems(withServerProfiles: profileManager.copyServers())
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
        let storyboard = NSStoryboard(name: "Preferences", bundle: nil)
        if let ctrl = storyboard.instantiateInitialController() {
            preferencesWindowController = ctrl as! NSWindowController
            NSApp.activate(ignoringOtherApps: true)
            preferencesWindowController.window?.center()
            preferencesWindowController.window?.makeKeyAndOrderFront(self)
        }
    }
}

