//
//  Aria2Constants.swift
//  AMM
//
//  Created by Sinkerine on 26/01/2017.
//  Copyright © 2017 sinkerine. All rights reserved.
//

import Foundation

public enum Aria2Protocols: String {
    case ws
    case wss
    case wssSelfSigned = "wss self-signed"
    static let allValues = [ws, wss, wssSelfSigned]
}

public enum Aria2ConnectionStatus: String{
    case connecting
    case connected
    case disconnected
    case unauthorized
}

public enum Aria2Methods: String{
    case getGlobalStat
    case tellActive
    case tellWaiting
    case tellStopped
    case tellStatus
    case addUri
    case pause
    case unpause
    case remove
    case removeDownloadResult
}

public enum Aria2TaskStatus: String {
    case unknown
    case active
    case paused
    case waiting
    case complete
    case stopped = "removed"
    case error
}

public enum Aria2Notifications: String {
    case onDownloadStart = "aria2.onDownloadStart"
    case onDownloadPause = "aria2.onDownloadPause"
    case onDownloadComplete = "aria2.onDownloadComplete"
    
    func toString() -> String {
        switch self {
        case .onDownloadStart:
            return "started"
        case .onDownloadPause:
            return "paused"
        case .onDownloadComplete:
            return "completed"
        }
    }
}
