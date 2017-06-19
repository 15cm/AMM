//
//  TaskMenuItemImpl.swift
//  AMM
//
//  Created by Sinkerine on 27/03/2017.
//  Copyright © 2017 sinkerine. All rights reserved.
//

import Cocoa

class TaskMenuItemImpl: TaskMenuItem {
    var server: ServerProfile?
    var revealInFinderItemAdded = false
    
    init(server: ServerProfile) {
        super.init()
        self.server = server
        self.submenu = NSMenu()
    }
    
    required init(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func updateView(withTask task: Aria2Task) {
        super.updateView(withTask: task)
        if(!revealInFinderItemAdded && fileExists()) {
            submenu?.addItem(ActionMenuItem(title: "Reveal in Finder", action: #selector(TaskMenuItemImpl.revealInFinder), keyEquivalent: "", target: self))
            revealInFinderItemAdded = true
        }
        if(revealInFinderItemAdded && !fileExists()) {
            submenu?.removeItem((submenu?.item(withTitle: "Reveal in Finder"))!)
            revealInFinderItemAdded = false
        }
    }
    
    func pauseTask() {
        server?.pause(gid: task.gid)
    }
    
    func unpauseTask() {
        server?.unpause(gid: task.gid)
    }
    
    func stopTask() {
        server?.stop(gid: task.gid)
    }
    
    func removeTask() {
        server?.remove(gid: task.gid)
    }
    
    func fileExists() -> Bool {
        if(task.files.isEmpty) {
            return false
        }
        let taskFilePath = task.files[0].path
        let fileManager = FileManager.default
        return fileManager.fileExists(atPath: taskFilePath)
    }
    
    func revealInFinder() {
        if(!fileExists()) {
            return
        }
        let taskFilePath = task.files[0].path
        NSWorkspace.shared().activateFileViewerSelecting([URL(string: taskFilePath)!])
    }
}

class ActiveTaskMenuItem: TaskMenuItemImpl {
    override init(server: ServerProfile) {
        super.init(server: server)
        submenu?.addItem(ActionMenuItem(title: "Pause", action: #selector(TaskMenuItemImpl.pauseTask), keyEquivalent: "", target: self))
        submenu?.addItem(ActionMenuItem(title: "Stop", action: #selector(TaskMenuItemImpl.stopTask), keyEquivalent: "", target: self))
    }
    
    required init(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class WaitingTaskMenuItem: TaskMenuItemImpl {
    override init(server: ServerProfile) {
        super.init(server: server)
        self.server = server
        submenu?.addItem(ActionMenuItem(title: "Resume", action: #selector(TaskMenuItemImpl.unpauseTask), keyEquivalent: "", target: self))
        submenu?.addItem(ActionMenuItem(title: "Stop", action: #selector(TaskMenuItemImpl.stopTask), keyEquivalent: "", target: self))
    }
    
    required init(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class StoppedTaskMenuItem: TaskMenuItemImpl {
    override init(server: ServerProfile) {
        super.init(server: server)
        submenu?.addItem(ActionMenuItem(title: "Remove", action: #selector(TaskMenuItemImpl.removeTask), keyEquivalent: "", target: self))
    }
    
    required init(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
