//
//  Aria2.swift
//  AMM
//
//  Created by Sinkerine on 26/01/2017.
//  Copyright © 2017 sinkerine. All rights reserved.
//

import Foundation
import SwiftyJSON
import Starscream

protocol Aria2NotificationDelegate: class{
    func onNotificationReceived(notificationType type: Aria2Notifications?, gids: [String])
}

class Aria2: NSObject, NSCopying, NSCoding {
    var ptcl: Aria2Protocols
    var host: String
    var port: Int
    var path: String
    var rpc: URL
    var secret: String
    var socket: WebSocket
    var status: Aria2ConnectionStatus = .disconnected
    fileprivate var callbacks: [String:Aria2RpcCallback]  = [:] // { uuid: callback }
    weak var notificationDelegate: Aria2NotificationDelegate?
    
    fileprivate class Aria2RpcCallback {
        var method: Aria2Methods
        var callbackTasks: (([Aria2Task]) -> Void)?
        var callbackTask: ((Aria2Task) -> Void)?
        var callbackStat: ((Aria2Stat) -> Void)?
        var callbackRaw: ((JSON) -> Void)?
        
        init(forMethod method: Aria2Methods) {
            self.method = method
        }
        
        init(forMethod method: Aria2Methods, callback cb: (([Aria2Task]) -> Void)?) {
            self.method = method
            self.callbackTasks = cb
        }
        
        init(forMethod method: Aria2Methods, callback cb: ((Aria2Task) -> Void)?) {
            self.method = method
            self.callbackTask = cb
        }
        
        init(forMethod method: Aria2Methods, callback cb: ((Aria2Stat) -> Void)?) {
            self.method = method
            self.callbackStat = cb
        }
        
        init(forMethod method: Aria2Methods, callback cb: ((JSON) -> Void)?) {
            self.method = method
            self.callbackRaw = cb
        }
        
        
        func exec(_ arg: [Aria2Task]?) {
            if (arg != nil) {
                self.callbackTasks?(arg!)
            }
        }
        
        func exec(_ arg: Aria2Task?) {
            if (arg != nil) {
                self.callbackTask?(arg!)
            }
        }
        
        func exec(_ arg: Aria2Stat?) {
            if (arg != nil) {
                self.callbackStat?(arg!)
            }
        }
        
        func exec(_ arg: JSON?) {
            if(arg != nil) {
                self.callbackRaw?(arg!)
            }
        }
    }
    
    init?(ptcl: Aria2Protocols,host: String, port: Int, path: String, secret: String? = nil) {
        self.ptcl = ptcl
        self.host = host
        self.port = port
        self.path = path
        var rpcPtcl: String
        switch ptcl {
        case .ws:
            rpcPtcl = "ws"
        case .wss:
            rpcPtcl = "wss"
        case .wssSelfSigned:
            rpcPtcl = "wss"
        }
        guard let rpc = URL(string: "\(rpcPtcl)://\(host):\(port)\(path)") else {
            return nil
        }
        self.socket = WebSocket(url: rpc)
        if ptcl == .wssSelfSigned {
            self.socket.disableSSLCertValidation = true
        }
        self.rpc = rpc
        self.secret = secret ?? ""
        super.init()
        self.socket.delegate = self
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        var ptcl:Aria2Protocols
        if let ptclObj = aDecoder.decodeObject(forKey: "protocol") {
            ptcl = Aria2Protocols(rawValue: ptclObj as! String)!
        } else {
            ptcl = AMMDefault.ptcl
        }
        let host = aDecoder.decodeObject(forKey: "host") as! String
        let port = Int(aDecoder.decodeInt64(forKey: "port"))
        let path = aDecoder.decodeObject(forKey: "path") as! String
        let secret = aDecoder.decodeObject(forKey: "secret") as! String
        self.init(ptcl: ptcl, host: host, port: port, path: path, secret: secret)
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(ptcl.rawValue, forKey: "protocol")
        aCoder.encode(host, forKey: "host")
        aCoder.encode(port, forKey: "port")
        aCoder.encode(path, forKey: "path")
        aCoder.encode(secret, forKey: "secret")
    }
    
    func copy(with zone: NSZone? = nil) -> Any {
        return Aria2(ptcl: ptcl, host: host, port: port, path: path, secret: secret) as Any
    }
    
    // Call method via rpc and register callback
    fileprivate func call(withParams params: [Any]?, callback cb: Aria2RpcCallback) {
        let id = NSUUID()
        let uuidStr = id.uuidString
        objc_sync_enter(self.callbacks)
        callbacks[uuidStr] = cb
        objc_sync_exit(self.callbacks)
        call(forMethod: cb.method, withParams: params, withID: id)
    }
    
    fileprivate func call(forMethod method: Aria2Methods, withParams params: [Any]?, withID id: NSUUID) {
        let dataObj: [String: Any] = [
            "jsonrpc": "2.0",
            "id": id.uuidString,
            "method": "aria2.\(method.rawValue)",
            "params": ["token:\(secret)"] + (params ?? [])
        ]
        guard let dataJSONStr = JSON(dataObj).rawString() else {
            return
        }
        socket.write(data: dataJSONStr.data(using: .utf8)!)
    }
    
    // connect Aria2
    func connect() {
        status = .connecting
        socket.connect()
    }
    
    // disconnect Aria2
    func disconnect() {
        socket.disconnect()
    }
    
    func getGlobalStat(callback cb: ((Aria2Stat) -> Void)?) {
        call(withParams: nil, callback: Aria2RpcCallback(forMethod: .getGlobalStat, callback: cb))
    }
    
    // get active tasks
    func tellActive(callback cb: (([Aria2Task]) -> Void)?) {
        call(withParams: [AMMDefault.aria2TaskSpecificKeys], callback: Aria2RpcCallback(forMethod: .tellActive, callback: cb))
    }
    
    // get waiting tasks
    func tellWaiting(offset: Int?, num: Int, callback cb: (([Aria2Task]) -> Void)?) {
        call(withParams: [offset ?? -1, num, AMMDefault.aria2TaskSpecificKeys], callback: Aria2RpcCallback(forMethod: .tellWaiting, callback: cb))
    }
    
    // get stopped tasks
    func tellStopped(offset: Int?, num: Int, callback cb: (([Aria2Task]) -> Void)?) {
        call(withParams: [offset ?? -1, num, AMMDefault.aria2TaskSpecificKeys], callback: Aria2RpcCallback(forMethod: .tellStopped, callback: cb))
    }
    
    // get a task specified by gid
    func tellStatus(gid: String, callback cb: ((Aria2Task) -> Void)?) {
        call(withParams: [gid, AMMDefault.aria2TaskSpecificKeys], callback: Aria2RpcCallback(forMethod: .tellStatus, callback: cb))
    }
    
    // Create download tasks by urls
    func addUri(url: [String], callback cb: ((JSON) -> Void)?) {
        call(withParams: [url], callback: Aria2RpcCallback(forMethod: .addUri, callback: cb))
    }
    
    // Control tasks
    func pause(gid: String) {
        call(withParams: [gid], callback: Aria2RpcCallback(forMethod: .pause))
    }
    
    func unpause(gid: String) {
        call(withParams: [gid], callback: Aria2RpcCallback(forMethod: .unpause))
    }
    
    func stop(gid: String) {
        call(withParams: [gid], callback: Aria2RpcCallback(forMethod: .remove))
    }
    
    func remove(gid: String) {
        call(withParams: [gid], callback: Aria2RpcCallback(forMethod: .removeDownloadResult))
    }
    
    deinit {
        disconnect()
    }
}

// Helper functions
extension Aria2 {
    static func getTasks(fromResponse res: JSON) -> [Aria2Task]? {
        if let tasks = res["result"].array {
            return tasks.map({ task in
                Aria2Task(json: task)
            })
        } else {
            return nil
        }
    }
    
    static func getTask(fromResponse res: JSON) -> Aria2Task? {
        return Aria2Task(json: res["result"])
    }
    
    static func getStat(fromResponse res: JSON) -> Aria2Stat? {
        if let stat = res["result"].dictionary {
            return Aria2Stat(downloadSpeed: Int((stat["downloadSpeed"]?.stringValue)!)!, uploadSpeed: Int((stat["uploadSpeed"]?.stringValue)!)!)
        } else {
            return nil
        }
    }
    
    class func getReadable(length: Int) -> String {
        let length = Double(length)
        if (length >= 1e9) {
            return String(format: "%5.1f GB", length / 1e9)
        } else if (length >= 1e6) {
            return String(format: "%5.1f MB", length / 1e6)
        } else if(length >= 1e3) {
            return String(format: "%5.1f KB", length / 1e3)
        } else {
            return String(format: "%5.1f  B", length)
        }
    }
}

/**
 web socket delegate
 */
extension Aria2: WebSocketDelegate {
    public func websocketDidConnect(socket: WebSocket) {
        status = .connected
        print("Aria2 connected at: \(rpc)")
    }
    
    public func websocketDidDisconnect(socket: WebSocket, error: NSError?) {
        status =  .disconnected
        print("Aria2 at \(rpc) disconnected: \(String(describing: error))")
    }
    
    public func websocketDidReceiveData(socket: WebSocket, data: Data) {
    }
    
    public func websocketDidReceiveMessage(socket: WebSocket, text: String) {
        let res = JSON(data: text.data(using: .utf8)!)
        if let method = res["method"].string, let params = res["params"].array {
           // Notification
            let gids = params.flatMap({param in return param["gid"].string})
            self.notificationDelegate?.onNotificationReceived(notificationType: Aria2Notifications(rawValue: method), gids: gids)
        } else {
            let id = res["id"].stringValue
            if let callback = callbacks[id] {
                switch callback.method {
                case .getGlobalStat:
                    callback.exec(Aria2.getStat(fromResponse: res))
                case .tellActive:
                    fallthrough
                case .tellWaiting:
                    fallthrough
                case .tellStopped:
                    callback.exec(Aria2.getTasks(fromResponse: res))
                    break
                case .tellStatus:
                    callback.exec(Aria2.getTask(fromResponse: res))
                    break
                case .addUri:
                    callback.exec(res)
                default:
                    break
                }
                callbacks.removeValue(forKey: id)
            } else {
                print("Callback \(id) not found!")
            }
        }
    }
}
