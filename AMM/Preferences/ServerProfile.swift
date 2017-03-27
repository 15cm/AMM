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
    var aria2: Aria2?
    var protocolRawValue: String? {
        didSet {
            aria2?.proto = Aria2Protocols(rawValue: protocolRawValue!)!
        }
    }
    // Workaournd for enum KVO binding
    var remark: String
    var globalStatRefreshInterval: Double
    var taskStatRefreshInterval: Double
    var activeTaskMaxNum: Int
    var waitingTaskMaxNum: Int
    var stoppedTaskMaxNum: Int
    var notiOnTaskStartEnabled: Bool
    var notiOnTaskPauseEnabled: Bool
    var notiOnTaskCompleteEnabled: Bool
    var connectTimer: DispatchSourceTimer?
    
    init(uuid: String, aria2: Aria2,
         remark: String, globalStatRefreshInterval gsri: Double,
         taskStatRefreshInterval tsri: Double, activeTaskMaxNum atMaxNum: Int,
         waitingTaskMaxNum wtMaxNum: Int, stoppedTaskMaxNum stMaxNum: Int,
         notiOnTaskStartEnabled notiStart: Bool, notiOnTaskPauseEnabled notiPause: Bool,
         notiOnTaskCompleteEnabled notiComplete: Bool
        ) {
        self.uuid = uuid
        self.aria2 = aria2
        self.protocolRawValue = aria2.proto.rawValue
        self.remark = remark
        self.globalStatRefreshInterval = gsri
        self.taskStatRefreshInterval = tsri
        self.activeTaskMaxNum = atMaxNum
        self.waitingTaskMaxNum = wtMaxNum
        self.stoppedTaskMaxNum = stMaxNum
        self.notiOnTaskStartEnabled = notiStart
        self.notiOnTaskPauseEnabled = notiPause
        self.notiOnTaskCompleteEnabled = notiComplete
    }
    
    convenience override init() {
        self.init(uuid: NSUUID().uuidString, aria2: Aria2(),
                  remark: defaultRemark, globalStatRefreshInterval: defaultGlobalStatRefreshInterval,
                  taskStatRefreshInterval: defaultTaskStatRefreshInterval, activeTaskMaxNum: defaultActiveTaskMaxNum,
                  waitingTaskMaxNum: defaultWaitingTaskMaxNum, stoppedTaskMaxNum: defaultStoppedTaskMaxNum,
                  notiOnTaskStartEnabled: false, notiOnTaskPauseEnabled: false, notiOnTaskCompleteEnabled: false)
    }
    
    convenience init?(uuid: String, protocol proto: Aria2Protocols,
         host: String, port: Int,
         path: String, secret: String?,
         remark: String, globalStatRefreshInterval gsri: Double,
         taskStatRefreshInterval tsri: Double, activeTaskMaxNum atMaxNum: Int,
         waitingTaskMaxNum wtMaxNum: Int, stoppedTaskMaxNum stMaxNum: Int,
         notiOnTaskStartEnabled notiStart: Bool, notiOnTaskPauseEnabled notiPause: Bool,
         notiOnTaskCompleteEnabled notiComplete: Bool
        ) {
        if let aria2 = Aria2(protocol: proto, host: host, port: port, path: path, secret: secret) {
            self.init(uuid: uuid, aria2: aria2,
                remark: remark, globalStatRefreshInterval: gsri,
                taskStatRefreshInterval: tsri, activeTaskMaxNum: atMaxNum,
                waitingTaskMaxNum: wtMaxNum, stoppedTaskMaxNum: stMaxNum,
                notiOnTaskStartEnabled: notiStart, notiOnTaskPauseEnabled: notiPause, notiOnTaskCompleteEnabled: notiComplete)
        } else {
            return nil
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        uuid = aDecoder.decodeObject(forKey: "id") as! String
        aria2 = aDecoder.decodeObject(forKey: "aria2") as? Aria2
        protocolRawValue = aria2?.proto.rawValue
        remark = aDecoder.decodeObject(forKey: "remark") as! String
        globalStatRefreshInterval = aDecoder.decodeDouble(forKey: "globalStatRefreshInterval")
        taskStatRefreshInterval = Double(aDecoder.decodeDouble(forKey: "taskStatRefreshInterval"))
        activeTaskMaxNum = Int(aDecoder.decodeInt64(forKey: "activeTaskMaxNum"))
        waitingTaskMaxNum = Int(aDecoder.decodeInt64(forKey: "waitingTaskMaxNum"))
        stoppedTaskMaxNum = Int(aDecoder.decodeInt64(forKey: "stoppedTaskMaxNum"))
        notiOnTaskStartEnabled = aDecoder.containsValue(forKey: "notiOnTaskStartEnabled") ? aDecoder.decodeBool(forKey: "notiOnTaskStartEnabled") : false
        notiOnTaskPauseEnabled = aDecoder.containsValue(forKey: "notiOnTaskPauseEnabled") ? aDecoder.decodeBool(forKey: "notiOnTaskPauseEnabled") : false
        notiOnTaskCompleteEnabled = aDecoder.containsValue(forKey: "notiOnTaskCompleteEnabled") ? aDecoder.decodeBool(forKey: "notiOnTaskCompleteEnabled") : false
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(uuid, forKey: "id")
        aCoder.encode(aria2, forKey: "aria2")
        aCoder.encode(remark, forKey: "remark")
        aCoder.encode(globalStatRefreshInterval, forKey: "globalStatRefreshInterval")
        aCoder.encode(taskStatRefreshInterval, forKey: "taskStatRefreshInterval")
        aCoder.encode(activeTaskMaxNum, forKey: "activeTaskMaxNum")
        aCoder.encode(waitingTaskMaxNum, forKey: "waitingTaskMaxNum")
        aCoder.encode(stoppedTaskMaxNum, forKey: "stoppedTaskMaxNum")
        aCoder.encode(notiOnTaskStartEnabled, forKey: "notiOnTaskStartEnabled")
        aCoder.encode(notiOnTaskPauseEnabled, forKey: "notiOnTaskPauseEnabled")
        aCoder.encode(notiOnTaskCompleteEnabled, forKey: "notiOnTaskCompleteEnabled")
    }
    
    func copy(with zone: NSZone? = nil) -> Any {
        return ServerProfile(uuid: uuid, aria2: aria2?.copy() as! Aria2, remark: remark,
                             globalStatRefreshInterval: globalStatRefreshInterval, taskStatRefreshInterval: taskStatRefreshInterval,
                             activeTaskMaxNum: activeTaskMaxNum, waitingTaskMaxNum: waitingTaskMaxNum, stoppedTaskMaxNum: stoppedTaskMaxNum,
                             notiOnTaskStartEnabled: notiOnTaskStartEnabled, notiOnTaskPauseEnabled: notiOnTaskPauseEnabled, notiOnTaskCompleteEnabled: notiOnTaskCompleteEnabled) as Any
    }
    
    func startConnectTimer() {
        connectTimer?.cancel()
        connectTimer = DispatchSource.makeTimerSource()
        connectTimer?.scheduleRepeating(deadline: .now(), interval: 5)
        connectTimer?.setEventHandler {
            [weak self] in
            if let strongSelf = self {
                if strongSelf.aria2?.status != .connected {
                    strongSelf.aria2?.connect()
                }
            }
        }
        if #available(OSX 10.12, *) {
            connectTimer?.activate()
        } else {
            // Fallback on earlier versions
            connectTimer?.resume()
        }
    }
    func getGlobalStat(callback cb: @escaping (Aria2Stat) -> Void) {
        aria2?.getGlobalStat(callback: cb)
    }
    
    func tellActive(callback cb: @escaping ([Aria2Task]) -> Void) {
        aria2?.tellActive(callback: cb)
    }
    
    func tellWaiting(callback cb: @escaping ([Aria2Task]) -> Void) {
        aria2?.tellWaiting(offset: -1, num: self.waitingTaskMaxNum, callback: cb)
    }
    
    func tellStopped(callback cb: @escaping ([Aria2Task]) -> Void) {
        aria2?.tellStopped(offset: -1, num: self.stoppedTaskMaxNum, callback: cb)
    }
    
    func tellStatus(gid: String, callback cb: @escaping (Aria2Task) -> Void) {
        aria2?.tellStatus(gid: gid, callback: cb)
    }
    
    func addUri(url: [String]?, callback cb: @escaping (JSON) -> Void) {
        if let url = url {
            aria2?.addUri(url: url, callback: cb)
        }
    }
    
    func pause(gid: String) {
        aria2?.pause(gid: gid)
    }
    
    func unpause(gid: String) {
        aria2?.unpause(gid: gid)
    }
    
    func stop(gid: String) {
        aria2?.stop(gid: gid)
    }
    
    func remove(gid: String) {
        aria2?.remove(gid: gid)
    }
    
    func registerNofificationDelegate(delegate: Aria2NotificationDelegate) {
        self.aria2?.notificationDelegate = delegate
    }
    
    func isValid() -> Bool {
        return true
    }
}
