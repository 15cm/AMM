//
//  AMMTaskMenuItem.swift
//  AMM
//
//  Created by Sinkerine on 30/01/2017.
//  Copyright © 2017 sinkerine. All rights reserved.
//

import Cocoa

class TaskMenuItem: NSMenuItem {
    var viewController: TaskMenuItemViewController? = nil
    var task: Aria2Task = Aria2Task()
    var server: ServerProfile?
    var isDisplayed: Bool = false{
        didSet {
            if isDisplayed {
                self.isHidden = false
                self.isEnabled = true
                self.view = self.viewController?.view
            } else {
                self.isHidden = true
                self.view = nil
            }
        }
    }
    
    init() {
        self.viewController = TaskMenuItemViewController(task: task)
        super.init(title: "", action: nil, keyEquivalent: "")
        self.isHidden = true
        self.view = nil
    }
    
    convenience init(server: ServerProfile) {
        self.init()
        self.server = server
    }
    
    func updateView(withTask task: Aria2Task) {
        task.replace(fromTask: task)
        viewController?.task.replace(fromTask: task)
        isDisplayed = true
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
    
    required init(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
