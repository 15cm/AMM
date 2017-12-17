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
    var statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
    var servers: [ServerProfile] = []
    var fixMenuItems: [NSMenuItem] = []
    var preferencesWindowController: PreferencesWindowController!
    var preferences = AMMPreferences.instance
    var selectedServer: ServerProfile?
    var selectServerWinCtrl: SelectServerWindowController!

    @IBOutlet weak var menu: NSMenu!
    
    // https://stackoverflow.com/questions/49510/how-do-you-set-your-cocoa-application-as-the-default-web-browser
    @objc func handleUrl(_ event: NSAppleEventDescriptor, with replyEvent: NSAppleEventDescriptor) {
        if let url = event.paramDescriptor(forKeyword: keyDirectObject)?.stringValue {
            let addUriToServer = { (server: ServerProfile?) in
                server?.addUri(url: [url], callback: { res in
                    if let errorMsg = res["error"]["message"].string {
                        showNotification(server?.remark, "Error: \(errorMsg)")
                    }
                })
            }
            if let server = selectedServer {
                addUriToServer(server)
            } else {
                selectServerWinCtrl = SelectServerWindowController(urlToHandle: url, servers)
                selectServerWinCtrl.onServerSelected = { server in
                    addUriToServer(server)
                }
                selectServerWinCtrl.window?.center()
                selectServerWinCtrl.window?.makeKeyAndOrderFront(self)
            }
        } else {
            showAlert("Error", "Failed to open with unrecognized URL.")
        }
    }
    
    @IBAction func quitClicked(_ sender: NSMenuItem) {
        NSApplication.shared.terminate(self)
    }
    
    @IBAction func preferencesClicked(_ sender: NSMenuItem) {
        let storyboard = NSStoryboard(name: NSStoryboard.Name(rawValue: "Preferences"), bundle: nil)
        if let ctrl = storyboard.instantiateInitialController() {
            preferencesWindowController = ctrl as! PreferencesWindowController
            NSApp.activate(ignoringOtherApps: true)
            preferencesWindowController.window?.center()
            preferencesWindowController.window?.makeKeyAndOrderFront(self)
        }
    }
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        let icon = NSImage(named: NSImage.Name(rawValue: "menu-icon"))
        icon?.isTemplate = true
        statusItem.image = icon
        statusItem.menu = menu
        for i in ((statusItem.menu?.numberOfItems)! - 3) ..< (statusItem.menu?.numberOfItems)! {
            fixMenuItems.append((statusItem.menu?.item(at: i))!)
        }
        preferences.delegate = self
        updateMenuItems(withServerProfiles: preferences.copyServers())
        
        // Register event handler
        let em = NSAppleEventManager.shared()
        em.setEventHandler(self, andSelector: #selector(AppDelegate.handleUrl(_:with:)), forEventClass: AEEventClass(kInternetEventClass), andEventID: AEEventID(kAEGetURL))
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
        selectedServer = nil
        for server in servers {
            if(server.isDefaultServer) {
                selectedServer = server
                break
            }
        }
    }
}

