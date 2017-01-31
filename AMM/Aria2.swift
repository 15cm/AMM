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


class Aria2{
    var rpc: URL
    var secret: String
    var socket: WebSocket
    var status: Aria2ConnectionStatus = .disconnected
    // { uuid: callback }
    var callbacks: [String:Aria2RpcCallback]  = [:]
    
    class Aria2RpcCallback {
        var method: Aria2Methods
        var callbackTasks: (([Aria2Task]) -> Void)? = nil
        var callbackStat: ((Int) -> Void)? = nil
        
        init(forMethod method: Aria2Methods, callback cb: @escaping ([Aria2Task]) -> Void) {
            self.method = method
            self.callbackTasks = cb
        }
        
        init(forMethod method: Aria2Methods, callback cb: @escaping (Int) -> Void) {
            self.method = method
            self.callbackStat = cb
        }
        
        func exec(_ arg: [Aria2Task]?) -> Void {
            if (arg != nil) {
                self.callbackTasks?(arg!)
            }
        }
        
        func exec(_ arg: Int) -> Void {
            self.callbackStat?(arg)
        }
    }
    
    init?(host: String, port: Int, path: String, secret: String? = nil) {
        guard let rpc = URL(string: "ws://\(host):\(port)/\(path)") else {
            return nil
        }
        self.socket = WebSocket(url: rpc)
        self.rpc = rpc
        self.secret = secret ?? ""
        self.socket.delegate = self
    }
    
    // Call method via rpc and register callback
    func call(withParams params: [Any]?, callback cb: Aria2RpcCallback) {
        let id = NSUUID()
        callbacks[id.uuidString] = cb
        call(forMethod: cb.method, withParams: params, withID: id)
    }
    
    func call(forMethod method: Aria2Methods, withParams params: [Any]?, withID id: NSUUID) {
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
        self.socket.connect()
    }
    
    // disconnect Aria2
    func disconnect() {
        self.socket.disconnect()
        self.status = .disconnected
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
        print("Aria2 connected at: \(rpc)")
    }
    
    public func websocketDidDisconnect(socket: WebSocket, error: NSError?) {
        print("Websocket disconnected: \(error)")
    }
    
    public func websocketDidReceiveData(socket: WebSocket, data: Data) {
        print(data)
    }
    
    public func websocketDidReceiveMessage(socket: WebSocket, text: String) {
        let res = JSON(data: text.data(using: .utf8)!)
        if res["error"]["message"] == "Unauthorized" {
            self.status = .unauthorized
        } else {
            self.status = .connected
        }
//        let method = 
//        if res["method"].stringValue == ""aria2.onDownloadStart" || res["]
        if let method = res["method"].string {
           // Notification
        } else {
            let id = res["id"].stringValue
            if let callback = callbacks[id] {
                switch callback.method {
                case .tellActive:
                    callback.exec(Aria2.getTasks(fromResponse: res))
                case .tellWaiting:
                    callback.exec(Aria2.getTasks(fromResponse: res))
                case .tellStopped:
                    callback.exec(Aria2.getTasks(fromResponse: res))
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
