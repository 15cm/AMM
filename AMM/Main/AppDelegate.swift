//
//  AppDelegate.swift
//  AMM
//
//  Created by Sinkerine on 26/01/2017.
//  Copyright © 2017 sinkerine. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, AMMPreferencesDelegate {
    var statusItem = NSStatusBar.system().statusItem(withLength: NSSquareStatusItemLength)
    var servers: [ServerProfile] = []
    var fixMenuItems: [NSMenuItem] = []
    var preferencesWindowController: PreferencesWindowController!
    var preferences = AMMPreferences.instance

    @IBOutlet weak var menu: NSMenu!
    
    @IBAction func quickClicked(_ sender: NSMenuItem) {
        NSApplication.shared().terminate(self)
    }
    
    @IBAction func preferenceClicked(_ sender: NSMenuItem) {
        let storyboard = NSStoryboard(name: "Preferences", bundle: nil)
        if let ctrl = storyboard.instantiateInitialController() {
            preferencesWindowController = ctrl as! PreferencesWindowController
            NSApp.activate(ignoringOtherApps: true)
            preferencesWindowController.window?.center()
            preferencesWindowController.window?.makeKeyAndOrderFront(self)
        }
    }

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        let icon = NSImage(named: "menu-icon")
        icon?.isTemplate = true
        statusItem.image = icon
        statusItem.menu = menu
        for i in ((statusItem.menu?.numberOfItems)! - 3) ..< (statusItem.menu?.numberOfItems)! {
            fixMenuItems.append((statusItem.menu?.item(at: i))!)
        }
        preferences.delegate = self
        updateMenuItems(withServerProfiles: preferences.copyServers())
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
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
}

