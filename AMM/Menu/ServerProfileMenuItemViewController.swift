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

    @IBOutlet var viewDark: NSView!
    
    override func viewDidLoad() {
        if AMMPreferences.instance.darkModeEnabled {
            self.view = viewDark
        }
        super.viewDidLoad()
        // Do view setup here.
        startTimer()
    }
    
    func startTimer(){
        timer?.cancel()
        let queue = DispatchQueue.global()
        timer = DispatchSource.makeTimerSource(flags: .strict, queue: queue)
        timer?.scheduleRepeating(deadline: .now(), interval: (self.server?.globalStatRefreshInterval)!)
        timer?.setEventHandler {
            DispatchQueue.main.async {
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
        }
        if #available(OSX 10.12, *) {
            timer?.activate()
        } else {
            // Fallback on earlier versions
            timer?.resume()
        }
    }
}
