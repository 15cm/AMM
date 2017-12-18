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
        server.runTimer()
        viewController = ServerProfileMenuItemViewController(nibName: NSNib.Name(rawValue: "ServerProfileMenuItemViewController"), bundle: nil)
        viewController?.server = server
        startIndexOfActive = pref.controlModeEnabled ? 2 : 1 // Set beginning offset of task menu items
        super.init(title: server.remark, action: nil, keyEquivalent: "")
        self.view = viewController?.view
        
        // Listen for aria2 notification
        if server.taskStartNotiEnabled { notificationsShouldHandle.insert(.onDownloadStart) }
        if server.taskPauseNotiEnabled { notificationsShouldHandle.insert(.onDownloadPause) }
        if server.taskCompleteNotiEnabled { notificationsShouldHandle.insert(.onDownloadComplete) }
        server.registerNotificationDelegate(delegate: self)
        
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
        for _ in 1...server.activeTaskTotal {
            if(pref.controlModeEnabled) {
                submenu?.addItem(ActiveTaskMenuItem(server: server))
            } else {
                submenu?.addItem(TaskMenuItem())
            }
        }
        submenu?.addItem(TaskMenuItemSeperator(name: "Waiting"))
        for _ in 1...server.waitingTaskTotal {
            if(pref.controlModeEnabled) {
                submenu?.addItem(WaitingTaskMenuItem(server: server))
            } else {
                submenu?.addItem(TaskMenuItem())
            }
        }
        submenu?.addItem(TaskMenuItemSeperator(name: "Stopped"))
        for _ in 1...server.stoppedTaskTotal {
            if(pref.controlModeEnabled) {
                submenu?.addItem(StoppedTaskMenuItem(server: server))
            } else {
                submenu?.addItem(TaskMenuItem())
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
        timer?.schedule(deadline: .now(), repeating: self.server.taskStatRefreshInterval)
        timer?.setEventHandler {
            [weak self] in
            if let strongSelf = self {
                DispatchQueue.main.async {
                    if strongSelf.server.aria2.status == .connected {
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
                        let startIndexOfWaiting = strongSelf.startIndexOfActive + strongSelf.server.activeTaskTotal + 1
                        let startIndexOfStopped = startIndexOfWaiting + strongSelf.server.waitingTaskTotal + 1
                        strongSelf.server.tellActive(callback: {
                            tasks in
                            updateTasksMenuItems(menuItem: strongSelf, tasks: tasks, startIndexInMenu: strongSelf.startIndexOfActive, maxNum: strongSelf.server.activeTaskTotal)
                        })
                        strongSelf.server.tellWaiting(callback: {
                            tasks in
                            updateTasksMenuItems(menuItem: strongSelf, tasks: tasks, startIndexInMenu: startIndexOfWaiting, maxNum: strongSelf.server.waitingTaskTotal)
                        })
                        strongSelf.server.tellStopped(callback: {
                            tasks in
                            updateTasksMenuItems(menuItem: strongSelf, tasks: tasks, startIndexInMenu: startIndexOfStopped, maxNum: strongSelf.server.stoppedTaskTotal)
                        })
                    }
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
                server.tellStatus(gid: gid, callback: {[unowned self] task in
                    showNotification(self.server.remark,  "\(!task.title.isEmpty ? task.title : task.gid) \(_type.toString()).")
                })
            }
        }
    }
    
    @objc func addUriFromClipboard() {
        let urlText = NSPasteboard.general.string(forType: NSPasteboard.PasteboardType.string)
        let urls = urlText?.components(separatedBy: "\n").filter({!$0.isEmpty}).map({$0.trimmingCharacters(in: [" "])})
        if let urls = urls {
            for url in urls {
                server.addUri(url: [url], callback: {[unowned self] res in
                    if let errorMsg = res["error"]["message"].string {
                        showNotification(self.server.remark, "Error: \(errorMsg)")
                    }
                })
            }
        }
    }
}
