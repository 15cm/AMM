//
//  AMMServerMenuItem.swift
//  AMM
//
//  Created by Sinkerine on 29/01/2017.
//  Copyright © 2017 sinkerine. All rights reserved.
//

import Cocoa

class ServerProfileMenuItem: NSMenuItem, Aria2NotificationDelegate {
    let pref = AMMPreferences.instance
    var server: ServerProfile
    var viewController: ServerProfileMenuItemViewController?
    var notificationsShouldHandle = Set<Aria2Notifications>()
    var timer: DispatchSourceTimer?
    var startIndexOfActive: Int
    init(_ profile: ServerProfile) {
        server = profile
        server.startConnectTimer()
        viewController = ServerProfileMenuItemViewController(nibName: "ServerProfileMenuItemViewController", bundle: nil)
        viewController?.server = server
        startIndexOfActive = pref.controlModeEnabled ? 2 : 1 // Set beginning offset of task menu items
        super.init(title: server.remark, action: nil, keyEquivalent: "")
        self.view = viewController?.view
        
        // Listen for aria2 notification
        if server.notiOnTaskStartEnabled { notificationsShouldHandle.insert(.onDownloadStart) }
        if server.notiOnTaskPauseEnabled { notificationsShouldHandle.insert(.onDownloadPause) }
        if server.notiOnTaskCompleteEnabled { notificationsShouldHandle.insert(.onDownloadComplete) }
        server.registerNofificationDelegate(delegate: self)
        
        submenu = NSMenu(title: "Tasks")
        // Init control menu
        if pref.controlModeEnabled {
            let controlMenuItem = NSMenuItem(title: "Control", action: nil, keyEquivalent: "")
            controlMenuItem.submenu = NSMenu(title: "Control")
            controlMenuItem.submenu?.addItem(ActionMenuItem(title: "Add URLs from Clipboard (Each URL on a seperate line)", action: #selector(ServerProfileMenuItem.addUriFromClipboard), keyEquivalent: "", target: self))
            submenu?.addItem(controlMenuItem)
        }
        
        // Init fixed task menu items
        submenu?.addItem(TaskMenuItemSeperator(name: "Active"))
        for _ in 1...server.activeTaskMaxNum {
            if(pref.controlModeEnabled) {
                submenu?.addItem(ActiveTaskMenuItem(server: server))
            } else {
                submenu?.addItem(TaskMenuItem(server: server))
            }
        }
        submenu?.addItem(TaskMenuItemSeperator(name: "Waiting"))
        for _ in 1...server.waitingTaskMaxNum {
            if(pref.controlModeEnabled) {
                submenu?.addItem(WaitingTaskMenuItem(server: server))
            } else {
                submenu?.addItem(TaskMenuItem(server: server))
            }
        }
        submenu?.addItem(TaskMenuItemSeperator(name: "Stopped"))
        for _ in 1...server.stoppedTaskMaxNum {
            if(pref.controlModeEnabled) {
                submenu?.addItem(StoppedTaskMenuItem(server: server))
            } else {
                submenu?.addItem(TaskMenuItem(server: server))
            }
        }
        
        // Fetch tasks loop
        startTimer()
    }
    
    required init(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func startTimer()  {
        let queue = DispatchQueue.global()
        timer = DispatchSource.makeTimerSource(flags: .strict, queue: queue)
        timer?.scheduleRepeating(deadline: .now(), interval: self.server.taskStatRefreshInterval)
        timer?.setEventHandler {
            [unowned self] in
            DispatchQueue.main.async {
                if self.server.aria2?.status == .connected {
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
                    let startIndexOfWaiting = self.startIndexOfActive + self.server.activeTaskMaxNum + 1
                    let startIndexOfStopped = startIndexOfWaiting + self.server.waitingTaskMaxNum + 1
                    self.server.tellActive(callback: {[unowned self] tasks in
                        updateTasksMenuItems(menuItem: self, tasks: tasks, startIndexInMenu: self.startIndexOfActive, maxNum: self.server.activeTaskMaxNum)
                    })
                    self.server.tellWaiting(callback: {[unowned self] tasks in
                        updateTasksMenuItems(menuItem: self, tasks: tasks, startIndexInMenu: startIndexOfWaiting, maxNum: self.server.waitingTaskMaxNum)
                    })
                    self.server.tellStopped(callback: {[unowned self] tasks in
                        updateTasksMenuItems(menuItem: self, tasks: tasks, startIndexInMenu: startIndexOfStopped, maxNum: self.server.stoppedTaskMaxNum)
                    })
                }
            }
        }
        if #available(OSX 10.12, *) {
            timer?.activate()
        } else {
            // Fallback on earlier versions
            timer?.resume()
        }
    }
    
    func onNotificationReceived(notificationType type: Aria2Notifications?, gids: [String]) {
        if let _type = type, notificationsShouldHandle.contains(_type) {
            for gid in gids {
                let noti = NSUserNotification()
                noti.title = server.remark
                if _type == .onDownloadStart {
                    server.tellStatus(gid: gid, callback: {task in
                        noti.informativeText = "\(!task.title.isEmpty ? task.title : task.gid) \(_type.toString())."
                        NSUserNotificationCenter.default.deliver(noti)
                    })
                }
            }
        }
    }
    
    func addUriFromClipboard() {
        let urlText = NSPasteboard.general().string(forType: NSPasteboardTypeString)
        let urls = urlText?.components(separatedBy: "\n").filter({!$0.isEmpty}).map({$0.trimmingCharacters(in: [" "])})
        if let urls = urls {
            for url in urls {
                server.addUri(url: [url], callback: {res in
                    if let errorMsg = res["error"]["message"].string {
                        let noti = NSUserNotification()
                        noti.title = self.server.remark
                        noti.informativeText = "Error: \(errorMsg)"
                        NSUserNotificationCenter.default.deliver(noti)
                    }
                })
            }
        }
    }
}
