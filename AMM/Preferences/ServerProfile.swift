//
//  ServerProfile.swift
//  AMM
//
//  Created by Sinkerine on 29/01/2017.
//  Copyright © 2017 sinkerine. All rights reserved.
//

fileprivate enum SerializationKeys {
     static let uuid = "id"
     static let aria2 = "aria2"
     static let remark = "remark"
     static let globalStatRefreshInterval = "globalStatRefreshInterval"
     static let taskStatRefreshInterval = "taskStatRefreshInterval"
     static let activeTaskTotal = "activeTaskMaxNum"
     static let waitingTaskTotal = "waitingTaskMaxNum"
     static let stoppedTaskTotal = "stoppedTaskMaxNum"
     static let taskStartNotiEnabled = "taskStartNotiEnabled"
     static let taskPauseNotiEnabled = "taskPauseNotiEnabled"
     static let taskCompleteNotiEnabled = "taskCompleteNotiEnabled"
     static let isDefaultServer = "isDefaultServer"
}

import Foundation
import SwiftyJSON

@objcMembers
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
    
    var connectCounter: Int = 0
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
        self.uuid = aDecoder.decodeObject(forKey: SerializationKeys.uuid) as! String
        self.aria2 = (aDecoder.decodeObject(forKey: SerializationKeys.aria2) as? Aria2)!
        self.ptclRawValue = aria2.ptcl.rawValue
        self.remark = aDecoder.decodeObject(forKey: SerializationKeys.remark) as! String
        self.globalStatRefreshInterval = aDecoder.decodeDouble(forKey: SerializationKeys.globalStatRefreshInterval)
        self.taskStatRefreshInterval = Double(aDecoder.decodeDouble(forKey: SerializationKeys.taskStatRefreshInterval))
        self.activeTaskTotal = Int(aDecoder.decodeInt64(forKey: SerializationKeys.activeTaskTotal))
        self.waitingTaskTotal = Int(aDecoder.decodeInt64(forKey: SerializationKeys.waitingTaskTotal))
        self.stoppedTaskTotal = Int(aDecoder.decodeInt64(forKey: SerializationKeys.stoppedTaskTotal))
        // Default value for parameters in new versions
        self.taskStartNotiEnabled = aDecoder.containsValue(forKey: SerializationKeys.taskStartNotiEnabled) ?
            aDecoder.decodeBool(forKey: SerializationKeys.taskStartNotiEnabled) : false
        self.taskPauseNotiEnabled = aDecoder.containsValue(forKey: SerializationKeys.taskPauseNotiEnabled) ?
            aDecoder.decodeBool(forKey: SerializationKeys.taskPauseNotiEnabled) : false
        self.taskCompleteNotiEnabled = aDecoder.containsValue(forKey: SerializationKeys.taskCompleteNotiEnabled) ?
            aDecoder.decodeBool(forKey: SerializationKeys.taskCompleteNotiEnabled) : false
        self.isDefaultServer = aDecoder.containsValue(forKey: SerializationKeys.isDefaultServer) ?
            aDecoder.decodeBool(forKey: SerializationKeys.isDefaultServer) : false
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(uuid, forKey: SerializationKeys.uuid)
        aCoder.encode(aria2, forKey: SerializationKeys.aria2)
        aCoder.encode(remark, forKey: SerializationKeys.remark)
        aCoder.encode(globalStatRefreshInterval, forKey: SerializationKeys.globalStatRefreshInterval)
        aCoder.encode(taskStatRefreshInterval, forKey: SerializationKeys.taskStatRefreshInterval)
        aCoder.encode(activeTaskTotal, forKey: SerializationKeys.activeTaskTotal)
        aCoder.encode(waitingTaskTotal, forKey: SerializationKeys.waitingTaskTotal)
        aCoder.encode(stoppedTaskTotal, forKey: SerializationKeys.stoppedTaskTotal)
        aCoder.encode(taskStartNotiEnabled, forKey: SerializationKeys.taskStartNotiEnabled)
        aCoder.encode(taskPauseNotiEnabled, forKey: SerializationKeys.taskPauseNotiEnabled)
        aCoder.encode(taskCompleteNotiEnabled, forKey: SerializationKeys.taskCompleteNotiEnabled)
        aCoder.encode(isDefaultServer, forKey: SerializationKeys.isDefaultServer)
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
        let pref = AMMPreferences.instance
        timer?.setEventHandler {
            [weak self] in
            if let strongSelf = self {
                if strongSelf.aria2.status != .connected {
                    strongSelf.aria2.connect()
                    if(pref.connectionRetryLimit > 0) {
                        strongSelf.connectCounter += 1
                        if(strongSelf.connectCounter >= pref.connectionRetryLimit) {
                            strongSelf.aria2.disconnect()
                            strongSelf.timer?.cancel()
                        }
                    }
                } else {
                    strongSelf.connectCounter = 0
                }
            }
        }
        timer?.schedule(deadline: .now(), repeating: Double(pref.connectionCheckInterval))
        if #available(OSX 10.12, *) {
            timer?.activate()
        } else {
            // Fallback on earlier versions
            timer?.resume()
        }
    }
    
    func getGlobalStat(callback cb: ((Aria2Stat) -> Void)?) {
        let wrappedCallback = cb.map({ cb -> Aria2RpcCallback in
            { res in
                if let stat = Aria2.getStat(fromResponse: res) {
                    cb(stat)
                }
            }
        })
        aria2.getGlobalStat(callback: wrappedCallback)
    }
    
    func tellActive(callback cb: (([Aria2Task]) -> Void)?) {
        let wrappedCallback = cb.map({ cb -> Aria2RpcCallback in
            { res in
                if let tasks = Aria2.getTasks(fromResponse: res) {
                    cb(tasks)
                }
            }
        })
        aria2.tellActive(callback: wrappedCallback)
    }
    
    func tellWaiting(callback cb: (([Aria2Task]) -> Void)?) {
        let wrappedCallback = cb.map({ cb -> Aria2RpcCallback in
            { res in
                if let tasks = Aria2.getTasks(fromResponse: res) {
                    cb(tasks)
                }
            }
        })
        aria2.tellWaiting(
            offset: -1,
            num: self.waitingTaskTotal,
            callback: wrappedCallback
        )
    }
    
    func tellStopped(callback cb: (([Aria2Task]) -> Void)?) {
        let wrappedCallback = cb.map({ cb -> Aria2RpcCallback in
            { res in
                if let tasks = Aria2.getTasks(fromResponse: res) {
                    cb (tasks)
                }
            }
        })
        aria2.tellStopped(
            offset: -1,
            num: self.stoppedTaskTotal,
            callback: wrappedCallback
        )
    }
    
    func tellStatus(gid: String, callback cb: ((Aria2Task) -> Void)?) {
        let wrappedCallback = cb.map({ cb -> Aria2RpcCallback in
            { res in
                if let task = Aria2.getTask(fromResponse: res) {
                    cb (task)
                }
            }
        })
        aria2.tellStatus(gid: gid, callback: wrappedCallback)
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
