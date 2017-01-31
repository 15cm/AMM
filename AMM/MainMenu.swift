//
//  Aria2MenuBarItem.swift
//  aria2-menubar-monitor
//
//  Created by Sinkerine on 24/01/2017.
//  Copyright © 2017 sinkerine. All rights reserved.
//

import Cocoa

class MainMenu: NSObject {
    var statusItem = NSStatusBar.system().statusItem(withLength: NSSquareStatusItemLength)
    var amm: AMM
    var serverMenuItems: [AMMServerMenuItem] = []
    
    override init() {
        self.amm = AMM(servers: [AMMServer(host: "localhost", port: 6800, path: "jsonrpc", secret: "15cm", remark: "test", taskStatRefreshInterval: 2, activeTaskMaxNum: 5, waitingTaskMaxNum: 5, stoppedTaskMaxNum: 5)])
        super.init()
    }
    
    @IBOutlet weak var menu: NSMenu!
    override func awakeFromNib() {
        self.statusItem.title = "AMM"
        self.statusItem.menu = menu
        // Init AMM Model
        for server in amm.servers {
            self.serverMenuItems.append(AMMServerMenuItem(server))
        }
        updateMenuItems()
    }
    
    func updateMenuItems() {
        for (index, item) in self.serverMenuItems.enumerated() {
            self.statusItem.menu?.insertItem(item, at: index)
        }
    }
    
    @IBAction func quitClicked(_ sender: NSMenuItem) {
        NSApplication.shared().terminate(self)
    }
    
}

