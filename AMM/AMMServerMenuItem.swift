//
//  AMMServerMenuItem.swift
//  AMM
//
//  Created by Sinkerine on 29/01/2017.
//  Copyright © 2017 sinkerine. All rights reserved.
//

import Cocoa

class AMMServerMenuItem: NSMenuItem {
    var server: AMMServer
    init(_ server: AMMServer) {
        self.server = server
        super.init(title: server.remark, action: nil, keyEquivalent: "")
        submenu = NSMenu(title: "Tasks")
        submenu?.addItem(withTitle:  "Active Tasks", action: nil, keyEquivalent: "").isEnabled = true
        submenu?.addItem(NSMenuItem.separator())
        for _ in 1...server.activeTaskMaxNum { submenu?.addItem(AMMTaskMenuItem()) }
        submenu?.addItem(withTitle: "Waiting Tasks", action: nil, keyEquivalent: "").isEnabled = true
        submenu?.addItem(NSMenuItem.separator())
        for _ in 1...server.waitingTaskMaxNum { submenu?.addItem(AMMTaskMenuItem()) }
        submenu?.addItem(withTitle: "Stopped Tasks", action: nil, keyEquivalent: "").isEnabled = true
        submenu?.addItem(NSMenuItem.separator())
        for _ in 1...server.stoppedTaskMaxNum { submenu?.addItem(AMMTaskMenuItem()) }
        
        // Init task menus
        fetchTasksLoop()
    }
    
    required init(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func fetchTasksLoop() {
        Thread(block: {
            while(true) {
                let startIndexOfActive = 2
                let startIndexOfWaiting = startIndexOfActive + self.server.activeTaskMaxNum + 2
                let startIndexOfStopped = startIndexOfWaiting + self.server.waitingTaskMaxNum + 2
                
                func updateTasksMenuItems(tasks: [Aria2Task], startIndexInMenu: Int, maxNum: Int) {
                    for i in 0 ..< maxNum {
                        let indexInMenu = i + startIndexInMenu
                        if i >= tasks.count {
                            (self.submenu?.item(at: indexInMenu) as! AMMTaskMenuItem).isDisplayed = false
                        } else {
                            (self.submenu?.item(at: indexInMenu) as! AMMTaskMenuItem).updateView(withTask: tasks[i])
                        }
                    }
                }
                self.server.tellActive(callback: {tasks in
                    updateTasksMenuItems(tasks: tasks, startIndexInMenu: startIndexOfActive, maxNum: self.server.activeTaskMaxNum)
                })
                self.server.tellWaiting(callback: {tasks in
                    updateTasksMenuItems(tasks: tasks, startIndexInMenu: startIndexOfWaiting, maxNum: self.server.waitingTaskMaxNum)
                })
                self.server.tellStopped(callback: {tasks in
                    updateTasksMenuItems(tasks: tasks, startIndexInMenu: startIndexOfStopped, maxNum: self.server.stoppedTaskMaxNum)
                })
                sleep(UInt32(self.server.refreshInterval))
            }
        }).start()
    }
}
