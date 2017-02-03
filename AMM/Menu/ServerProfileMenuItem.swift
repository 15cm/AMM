//
//  AMMServerMenuItem.swift
//  AMM
//
//  Created by Sinkerine on 29/01/2017.
//  Copyright © 2017 sinkerine. All rights reserved.
//

import Cocoa

class ServerProfileMenuItem: NSMenuItem {
    var server: ServerProfile
    var viewController: ServerProfileMenuItemViewController?
    var timer: DispatchSourceTimer?
    init(_ profile: ServerProfile) {
        server = profile
        server.startConnectTimer()
        viewController = ServerProfileMenuItemViewController(nibName: "ServerProfileMenuItemViewController", bundle: nil)
        viewController?.server = server
        super.init(title: server.remark, action: nil, keyEquivalent: "")
        self.view = viewController?.view
        
        // Init fixed task array
        submenu = NSMenu(title: "Tasks")
        submenu?.addItem(TaskMenuItemSeperator(name: "Active"))
        for _ in 1...server.activeTaskMaxNum { submenu?.addItem(TaskMenuItem()) }
        submenu?.addItem(TaskMenuItemSeperator(name: "Waiting"))
        for _ in 1...server.waitingTaskMaxNum { submenu?.addItem(TaskMenuItem()) }
        submenu?.addItem(TaskMenuItemSeperator(name: "Stopped"))
        for _ in 1...server.stoppedTaskMaxNum { submenu?.addItem(TaskMenuItem()) }
        
        // Fetch tasks loop
        startTimer()
    }
    
    required init(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func startTimer()  {
        timer?.cancel()
        timer = DispatchSource.makeTimerSource()
        timer?.scheduleRepeating(deadline: .now(), interval: self.server.globalStatRefreshInterval)
        timer?.setEventHandler {
            [weak self] in
            if let strongSelf = self {
                if strongSelf.server.aria2?.status == .connected {
                    let startIndexOfActive = 1
                    let startIndexOfWaiting = startIndexOfActive + strongSelf.server.activeTaskMaxNum + 1
                    let startIndexOfStopped = startIndexOfWaiting + strongSelf.server.waitingTaskMaxNum + 1
                    
                    func updateTasksMenuItems(menuItem: ServerProfileMenuItem, tasks: [Aria2Task], startIndexInMenu: Int, maxNum: Int) {
                        for i in 0 ..< maxNum {
                            let indexInMenu = i + startIndexInMenu
                            if i >= tasks.count {
                                (menuItem.submenu?.item(at: indexInMenu) as! TaskMenuItem).isDisplayed = false
                            } else {
                                (menuItem.submenu?.item(at: indexInMenu) as! TaskMenuItem).updateView(withTask: tasks[i])
                            }
                        }
                    }
                    
                    strongSelf.server.tellActive(callback: {tasks in
                        updateTasksMenuItems(menuItem: strongSelf, tasks: tasks, startIndexInMenu: startIndexOfActive, maxNum: strongSelf.server.activeTaskMaxNum)
                    })
                    strongSelf.server.tellWaiting(callback: {tasks in
                        updateTasksMenuItems(menuItem: strongSelf, tasks: tasks, startIndexInMenu: startIndexOfWaiting, maxNum: strongSelf.server.waitingTaskMaxNum)
                    })
                    strongSelf.server.tellStopped(callback: {tasks in
                        updateTasksMenuItems(menuItem: strongSelf, tasks: tasks, startIndexInMenu: startIndexOfStopped, maxNum: strongSelf.server.stoppedTaskMaxNum)
                    })
            }
            }
        }
        timer?.activate()
    }
    
    deinit {
        timer?.cancel()
    }
}
