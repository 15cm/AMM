//
//  AMMServer.swift
//  AMM
//
//  Created by Sinkerine on 29/01/2017.
//  Copyright © 2017 sinkerine. All rights reserved.
//

import Foundation

class ServerProfile: NSObject, NSCopying {
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
    var connectTimer: DispatchSourceTimer?
    
    override init() {
        uuid = NSUUID().uuidString
        aria2 = Aria2(protocol: defaultProtocol, host: defaultHost, port: defaultPort, path: defaultPath)
        protocolRawValue = aria2?.proto.rawValue
        remark = "Untitled"
        globalStatRefreshInterval = defaultGlobalStatRefreshInterval
        taskStatRefreshInterval = defaultTaskStatRefreshInterval
        activeTaskMaxNum = defaultActiveTaskMaxNum
        waitingTaskMaxNum = defaultWaitingTaskMaxNum
        stoppedTaskMaxNum = defaultStoppedTaskMaxNum
    }
    
    init(uuid: String, protocol proto: Aria2Protocols,
         host: String, port: Int,
         path: String, secret: String?,
         remark: String, globalStatRefreshInterval gsri: Double,
         taskStatRefreshInterval tsri: Double, activeTaskMaxNum atMaxNum: Int,
         waitingTaskMaxNum wtMaxNum: Int, stoppedTaskMaxNum stMaxNum: Int
        ) {
        self.uuid = uuid
        self.aria2 = Aria2(protocol: proto, host: host, port: port, path: path, secret: secret)
        self.protocolRawValue = aria2?.proto.rawValue
        self.remark = remark
        self.globalStatRefreshInterval = gsri
        self.taskStatRefreshInterval = tsri
        self.activeTaskMaxNum = atMaxNum
        self.waitingTaskMaxNum = wtMaxNum
        self.stoppedTaskMaxNum = stMaxNum
        super.init()
    }
    init(uuid: String, aria2: Aria2,
         remark: String, globalStatRefreshInterval gsri: Double,
         taskStatRefreshInterval tsri: Double, activeTaskMaxNum atMaxNum: Int,
         waitingTaskMaxNum wtMaxNum: Int, stoppedTaskMaxNum stMaxNum: Int
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
        super.init()
    }
    
    func copy(with zone: NSZone? = nil) -> Any {
        return ServerProfile(uuid: uuid, aria2: aria2?.copy() as! Aria2, remark: remark, globalStatRefreshInterval: globalStatRefreshInterval, taskStatRefreshInterval: taskStatRefreshInterval, activeTaskMaxNum: activeTaskMaxNum, waitingTaskMaxNum: waitingTaskMaxNum, stoppedTaskMaxNum: stoppedTaskMaxNum) as Any
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
    
    // get global status
    func getGlobalStat(callback cb: @escaping (Aria2Stat) -> Void) {
        self.aria2?.getGlobalStat(callback: cb)
    }
    
    // get active tasks
    func tellActive(callback cb: @escaping ([Aria2Task]) -> Void) {
        self.aria2?.tellActive(callback: cb)
    }
    
    // get waiting tasks
    func tellWaiting(callback cb: @escaping ([Aria2Task]) -> Void) {
        self.aria2?.tellWaiting(offset: -1, num: self.waitingTaskMaxNum, callback: cb)
    }
    
    // get stopped tasks
    func tellStopped(callback cb: @escaping ([Aria2Task]) -> Void) {
        self.aria2?.tellStopped(offset: -1, num: self.stoppedTaskMaxNum, callback: cb)
    }
    
    func toDictionary() -> [String:AnyObject] {
        var d = [String:AnyObject]()
        d["id"] = uuid as AnyObject?
        d["protocol"] = aria2?.proto.rawValue as AnyObject?
        d["host"] = aria2?.host as AnyObject?
        d["port"] = aria2?.port as AnyObject?
        d["path"] = aria2?.path as AnyObject?
        d["secret"] = aria2?.secret as AnyObject?
        d["remark"] = remark as AnyObject?
        d["globalStatRefreshInterval"] = NSNumber(value: globalStatRefreshInterval)
        d["taskStatRefreshInterval"] = NSNumber(value: taskStatRefreshInterval)
        d["activeTaskMaxNum"] = NSNumber(value: activeTaskMaxNum)
        d["waitingTaskMaxNum"] = NSNumber(value: waitingTaskMaxNum)
        d["stoppedTaskMaxNum"] = NSNumber(value: stoppedTaskMaxNum)
        return d
    }
    
    static func fromDictionary(_ data: [String:Any?]) -> ServerProfile {
        let id = data["id"] as! String
        // Compatable for versions before v0.13
        var proto: Aria2Protocols
        if let protocolObj = data["protocol"] {
            proto = Aria2Protocols(rawValue: protocolObj as! String)!
        } else {
            proto = defaultProtocol
        }
        let host = data["host"] as! String
        let port = data["port"] as! Int
        let path = data["path"] as! String
        let secret = data["secret"] as! String
        let remark = data["remark"] as! String
        let gsri = data["globalStatRefreshInterval"] as! Double
        let tsri = data["taskStatRefreshInterval"] as! Double
        let activeTaskMaxNum = data["activeTaskMaxNum"] as! Int
        let waitingTaskMaxNum = data["waitingTaskMaxNum"] as! Int
        let stoppedTaskMaxNum = data["stoppedTaskMaxNum"] as! Int
        return ServerProfile(uuid: id, protocol: proto, host: host, port: port, path: path, secret: secret, remark: remark, globalStatRefreshInterval: gsri, taskStatRefreshInterval: tsri, activeTaskMaxNum: activeTaskMaxNum, waitingTaskMaxNum: waitingTaskMaxNum, stoppedTaskMaxNum: stoppedTaskMaxNum)
    }
    
    func isValid() -> Bool {
        return true
    }
}
