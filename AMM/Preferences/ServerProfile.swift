//
//  ServerProfile.swift
//  AMM
//
//  Created by Sinkerine on 29/01/2017.
//  Copyright © 2017 sinkerine. All rights reserved.
//

import Foundation
import SwiftyJSON

class ServerProfile: NSObject, NSCopying, NSCoding {
    var uuid: String
    var aria2: Aria2
    var ptclRawValue: String? {
        didSet {
            aria2.ptcl = Aria2Protocols(rawValue: ptclRawValue!)!
        }
    }
    // Workaournd for enum KVO binding
    var remark: String
    var globalStatRefreshInterval: Double
    var taskStatRefreshInterval: Double
    var activeTaskTotal: Int
    var waitingTaskTotal: Int
    var stoppedTaskTotal: Int
    var taskStartNotiEnabled: Bool
    var taskPauseNotiEnabled: Bool
    var taskCompleteNotiEnabled: Bool
    dynamic var isDefaultServer: Bool
    var timer: DispatchSourceTimer?
    
    init?(uuid: String, aria2: Aria2?,
         remark: String, globalStatRefreshInterval gsri: Double,
         taskStatRefreshInterval tsri: Double, activeTaskTotal atTotal: Int,
         waitingTaskTotal wtTotal: Int, stoppedTaskTotal stTotal: Int,
         taskStartNotiEnabled startNotiEnabled: Bool, taskPauseNotiEnabled pauseNotiEnabled: Bool,
         taskCompleteNotiEnabled completeNotiEnabled: Bool, isDefaultServer isDefault: Bool
        ) {
        guard let aria2 = aria2 else {
            return nil
        }
        self.uuid = uuid
        self.aria2 = aria2
        self.ptclRawValue = aria2.ptcl.rawValue
        self.remark = remark
        self.globalStatRefreshInterval = gsri
        self.taskStatRefreshInterval = tsri
        self.activeTaskTotal = atTotal
        self.waitingTaskTotal = wtTotal
        self.stoppedTaskTotal = stTotal
        self.taskStartNotiEnabled = startNotiEnabled
        self.taskPauseNotiEnabled = pauseNotiEnabled
        self.taskCompleteNotiEnabled = completeNotiEnabled
        self.isDefaultServer = isDefault
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.uuid = aDecoder.decodeObject(forKey: "id") as! String
        self.aria2 = (aDecoder.decodeObject(forKey: "aria2") as? Aria2)!
        self.ptclRawValue = aria2.ptcl.rawValue
        self.remark = aDecoder.decodeObject(forKey: "remark") as! String
        self.globalStatRefreshInterval = aDecoder.decodeDouble(forKey: "globalStatRefreshInterval")
        self.taskStatRefreshInterval = Double(aDecoder.decodeDouble(forKey: "taskStatRefreshInterval"))
        self.activeTaskTotal = Int(aDecoder.decodeInt64(forKey: "activeTaskMaxNum"))
        self.waitingTaskTotal = Int(aDecoder.decodeInt64(forKey: "waitingTaskMaxNum"))
        self.stoppedTaskTotal = Int(aDecoder.decodeInt64(forKey: "stoppedTaskMaxNum"))
        self.taskStartNotiEnabled = aDecoder.containsValue(forKey: "notiOnTaskStartEnabled") ? aDecoder.decodeBool(forKey: "notiOnTaskStartEnabled") : false
        self.taskPauseNotiEnabled = aDecoder.containsValue(forKey: "notiOnTaskPauseEnabled") ? aDecoder.decodeBool(forKey: "notiOnTaskPauseEnabled") : false
        self.taskCompleteNotiEnabled = aDecoder.containsValue(forKey: "notiOnTaskCompleteEnabled") ? aDecoder.decodeBool(forKey: "notiOnTaskCompleteEnabled") : false
        self.isDefaultServer = aDecoder.containsValue(forKey: "isDefaultServer") ? aDecoder.decodeBool(forKey: "isDefaultServer") : false
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(uuid, forKey: "id")
        aCoder.encode(aria2, forKey: "aria2")
        aCoder.encode(remark, forKey: "remark")
        aCoder.encode(globalStatRefreshInterval, forKey: "globalStatRefreshInterval")
        aCoder.encode(taskStatRefreshInterval, forKey: "taskStatRefreshInterval")
        aCoder.encode(activeTaskTotal, forKey: "activeTaskMaxNum")
        aCoder.encode(waitingTaskTotal, forKey: "waitingTaskMaxNum")
        aCoder.encode(stoppedTaskTotal, forKey: "stoppedTaskMaxNum")
        aCoder.encode(taskStartNotiEnabled, forKey: "notiOnTaskStartEnabled")
        aCoder.encode(taskPauseNotiEnabled, forKey: "notiOnTaskPauseEnabled")
        aCoder.encode(taskCompleteNotiEnabled, forKey: "notiOnTaskCompleteEnabled")
        aCoder.encode(isDefaultServer, forKey: "isDefaultServer")
    }
    
    convenience override init() {
        self.init(uuid: NSUUID().uuidString,
                  aria2: Aria2(ptcl: AMMDefault.ptcl, host: AMMDefault.host, port: AMMDefault.port, path: AMMDefault.path),
                  remark: AMMDefault.remark, globalStatRefreshInterval: AMMDefault.globalStatRefreshInterval,
                  taskStatRefreshInterval: AMMDefault.taskStatRefreshInterval, activeTaskTotal: AMMDefault.activeTaskTotal,
                  waitingTaskTotal: AMMDefault.waitingTaskTotal, stoppedTaskTotal: AMMDefault.stoppedTaskTotal,
                  taskStartNotiEnabled: false, taskPauseNotiEnabled: false, taskCompleteNotiEnabled: false, isDefaultServer: false)!
    }
    
    func copy(with zone: NSZone? = nil) -> Any {
        return ServerProfile(uuid: uuid, aria2: aria2.copy() as? Aria2, remark: remark,
                             globalStatRefreshInterval: globalStatRefreshInterval, taskStatRefreshInterval: taskStatRefreshInterval,
                             activeTaskTotal: activeTaskTotal, waitingTaskTotal: waitingTaskTotal, stoppedTaskTotal: stoppedTaskTotal,
                             taskStartNotiEnabled: taskStartNotiEnabled, taskPauseNotiEnabled: taskPauseNotiEnabled,
                             taskCompleteNotiEnabled: taskCompleteNotiEnabled, isDefaultServer: isDefaultServer) as Any
    }
    
    func runTimer() {
        let queue = DispatchQueue.global()
        timer = DispatchSource.makeTimerSource(flags: .strict, queue: queue)
        timer?.setEventHandler {
            [weak self] in
            if let strongSelf = self {
                if strongSelf.aria2.status != .connected {
                    strongSelf.aria2.connect()
                }
            }
        }
        timer?.scheduleRepeating(deadline: .now(), interval: AMMDefault.connectionCheckInterval)
        if #available(OSX 10.12, *) {
            timer?.activate()
        } else {
            // Fallback on earlier versions
            timer?.resume()
        }
    }
    
    func getGlobalStat(callback cb: ((Aria2Stat) -> Void)?) {
        aria2.getGlobalStat(callback: cb)
    }
    
    func tellActive(callback cb: (([Aria2Task]) -> Void)?) {
        aria2.tellActive(callback: cb)
    }
    
    func tellWaiting(callback cb: (([Aria2Task]) -> Void)?) {
        aria2.tellWaiting(offset: -1, num: self.waitingTaskTotal, callback: cb)
    }
    
    func tellStopped(callback cb: (([Aria2Task]) -> Void)?) {
        aria2.tellStopped(offset: -1, num: self.stoppedTaskTotal, callback: cb)
    }
    
    func tellStatus(gid: String, callback cb: ((Aria2Task) -> Void)?) {
        aria2.tellStatus(gid: gid, callback: cb)
    }
    
    func addUri(url: [String]?, callback cb: ((JSON) -> Void)?) {
        if let url = url {
            aria2.addUri(url: url, callback: cb)
        }
    }
    
    func pause(gid: String) {
        aria2.pause(gid: gid)
    }
    
    func unpause(gid: String) {
        aria2.unpause(gid: gid)
    }
    
    func stop(gid: String) {
        aria2.stop(gid: gid)
    }
    
    func remove(gid: String) {
        aria2.remove(gid: gid)
    }
    
    func registerNotificationDelegate(delegate: Aria2NotificationDelegate) {
        self.aria2.notificationDelegate = delegate
    }
    
    func isValid() -> Bool {
        return true
    }
}
