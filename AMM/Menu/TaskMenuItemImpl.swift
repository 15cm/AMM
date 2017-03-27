//
//  TaskMenuItemImpl.swift
//  AMM
//
//  Created by Sinkerine on 27/03/2017.
//  Copyright © 2017 sinkerine. All rights reserved.
//

import Cocoa

class ActiveTaskMenuItem: TaskMenuItem {
    override init() {
        super.init()
        let menu = NSMenu()
        menu.addItem(ActionMenuItem(title: "Pause", action: #selector(TaskMenuItem.pauseTask), keyEquivalent: "", target: self))
        menu.addItem(ActionMenuItem(title: "Stop", action: #selector(TaskMenuItem.stopTask), keyEquivalent: "", target: self))
        submenu = menu
    }
    
    required init(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class WaitingTaskMenuItem: TaskMenuItem {
    override init() {
        super.init()
        let menu = NSMenu()
        menu.addItem(ActionMenuItem(title: "Resume", action: #selector(TaskMenuItem.unpauseTask), keyEquivalent: "", target: self))
        menu.addItem(ActionMenuItem(title: "Stop", action: #selector(TaskMenuItem.stopTask), keyEquivalent: "", target: self))
        submenu = menu
    }
    
    required init(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class StoppedTaskMenuItem: TaskMenuItem {
    override init() {
        super.init()
        let menu = NSMenu()
        menu.addItem(ActionMenuItem(title: "Remove", action: #selector(TaskMenuItem.removeTask), keyEquivalent: "", target: self))
        submenu = menu
    }
    
    required init(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
