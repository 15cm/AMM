//
//  AMMServer.swift
//  AMM
//
//  Created by Sinkerine on 29/01/2017.
//  Copyright © 2017 sinkerine. All rights reserved.
//

import Foundation

class AMMServer {
    var aria2: Aria2?
    var remark: String
    var refreshInterval: Int
    var activeTaskMaxNum: Int
    var waitingTaskMaxNum: Int
    var stoppedTaskMaxNum: Int
    
    init(host: String, port: Int,
         path: String, secret: String?,
         remark: String, taskStatRefreshInterval ri: Int,
         activeTaskMaxNum atMaxNum: Int, waitingTaskMaxNum wtMaxNum: Int,
         stoppedTaskMaxNum stMaxNum: Int
        ) {
        self.aria2 = Aria2(host: host, port: port, path: path, secret: secret)
        self.remark = remark
        self.refreshInterval = ri
        self.activeTaskMaxNum = atMaxNum
        self.waitingTaskMaxNum = wtMaxNum
        self.stoppedTaskMaxNum = stMaxNum
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
}
