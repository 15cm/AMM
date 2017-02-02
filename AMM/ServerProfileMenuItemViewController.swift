//
//  ServerProfileMenuItemViewController.swift
//  AMM
//
//  Created by Sinkerine on 02/02/2017.
//  Copyright © 2017 sinkerine. All rights reserved.
//

import Cocoa

class ServerProfileMenuItemViewController: NSViewController {
    var server: ServerProfile? = nil
    dynamic var status: String? = nil
    dynamic var downloadSpeed: String? = nil
    dynamic var uploadSpeed: String? = nil
    var timer: DispatchSourceTimer?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        startTimer()
    }
    
    func startTimer(){
        timer?.cancel()
        timer = DispatchSource.makeTimerSource()
        timer?.scheduleRepeating(deadline: .now(), interval: (self.server?.globalStatRefreshInterval)!)
        timer?.setEventHandler {
            [weak self] in
            if let strongSelf = self {
                strongSelf.status = strongSelf.server?.aria2?.status.rawValue
                if strongSelf.server?.aria2?.status == .connected {
                    strongSelf.server?.getGlobalStat(callback: {stat in
                        strongSelf.downloadSpeed = Aria2.getReadable(length: stat.downloadSpeed) + "/s"
                        strongSelf.uploadSpeed = Aria2.getReadable(length: stat.uploadSpeed) + "/s"
                    })
                }
            }
        }
        timer?.activate()
    }
}
