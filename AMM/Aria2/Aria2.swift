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


class Aria2: NSObject, NSCopying, NSCoding {
    var proto: Aria2Protocols
    var host: String
    var port: Int
    var path: String
    var rpc: URL
    var secret: String
    var socket: WebSocket
    var status: Aria2ConnectionStatus = .disconnected
    // { uuid: callback }
    fileprivate var callbacks: [String:Aria2RpcCallback]  = [:]
    
    fileprivate class Aria2RpcCallback {
        var method: Aria2Methods
        var callbackTasks: (([Aria2Task]) -> Void)? = nil
        var callbackStat: ((Aria2Stat) -> Void)? = nil
        
        init(forMethod method: Aria2Methods, callback cb: @escaping ([Aria2Task]) -> Void) {
            self.method = method
            self.callbackTasks = cb
        }
        
        init(forMethod method: Aria2Methods, callback cb: @escaping (Aria2Stat) -> Void) {
            self.method = method
            self.callbackStat = cb
        }
        
        func exec(_ arg: [Aria2Task]?) -> Void {
            if (arg != nil) {
                self.callbackTasks?(arg!)
            }
        }
        
        func exec(_ arg: Aria2Stat?) -> Void {
            if (arg != nil) {
                self.callbackStat?(arg!)
            }
        }
    }
    
    init?(protocol proto: Aria2Protocols,host: String, port: Int, path: String, secret: String? = nil) {
        self.proto = proto
        self.host = host
        self.port = port
        self.path = path
        var rpcProtocol: String
        switch proto {
        case .ws:
            rpcProtocol = "ws"
        case .wss:
            rpcProtocol = "wss"
        case .wssSelfSigned:
            rpcProtocol = "wss"
        }
        guard let rpc = URL(string: "\(rpcProtocol)://\(host):\(port)\(path)") else {
            return nil
        }
        self.socket = WebSocket(url: rpc)
        if proto == .wssSelfSigned {
            self.socket.disableSSLCertValidation = true
        }
        self.rpc = rpc
        self.secret = secret ?? ""
        super.init()
        self.socket.delegate = self
    }
    
    convenience override init() {
        self.init(protocol: defaultProtocol, host: defaultHost, port: defaultPort, path: defaultPath, secret: nil)!
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        let proto: Aria2Protocols
        if let protoObj = aDecoder.decodeObject(forKey: "protocol") {
            proto = Aria2Protocols(rawValue: protoObj as! String)!
        } else {
            proto = defaultProtocol
        }
        let host = aDecoder.decodeObject(forKey: "host") as! String
        let port = Int(aDecoder.decodeInt64(forKey: "port"))
        let path = aDecoder.decodeObject(forKey: "path") as! String
        let secret = aDecoder.decodeObject(forKey: "secret") as! String
        self.init(protocol: proto, host: host, port: port, path: path, secret: secret)
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(proto.rawValue, forKey: "protocol")
        aCoder.encode(host, forKey: "host")
        aCoder.encode(port, forKey: "port")
        aCoder.encode(path, forKey: "path")
        aCoder.encode(secret, forKey: "secret")
    }
    
    func copy(with zone: NSZone? = nil) -> Any {
        return Aria2(protocol: proto, host: host, port: port, path: path, secret: secret) as Any
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
    
    func getGlobalStat(callback cb: @escaping (Aria2Stat) -> Void) {
        call(withParams: nil, callback: Aria2RpcCallback(forMethod: .getGlobalStat, callback: cb))
    }
    
    // get active tasks
    func tellActive(callback cb: @escaping ([Aria2Task]) -> Void) {
        call(withParams: nil, callback: Aria2RpcCallback(forMethod: .tellActive, callback: cb))
    }
    
    // get waiting tasks
    func tellWaiting(offset: Int?, num: Int, callback cb: @escaping ([Aria2Task]) -> Void) {
        call(withParams: [offset ?? -1, num], callback: Aria2RpcCallback(forMethod: .tellWaiting, callback: cb))
    }
    
    // get stopped tasks
    func tellStopped(offset: Int?, num: Int, callback cb: @escaping ([Aria2Task]) -> Void) {
        call(withParams: [offset ?? -1, num], callback: Aria2RpcCallback(forMethod: .tellStopped, callback: cb))
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
        print("Aria2 at \(rpc) disconnected: \(error)")
    }
    
    public func websocketDidReceiveData(socket: WebSocket, data: Data) {
    }
    
    public func websocketDidReceiveMessage(socket: WebSocket, text: String) {
        let res = JSON(data: text.data(using: .utf8)!)
        if let method = res["method"].string {
           // Notification
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
                }
                callbacks.removeValue(forKey: id)
            } else {
                print("Callback \(id) not found!")
            }
        }
    }
}
