
//
//  AMMConstants.swift
//  AMM
//
//  Created by Sinkerine on 26/01/2017.
//  Copyright © 2017 sinkerine. All rights reserved.
//

import Cocoa

struct AMMDefault {
    static let ptcl = Aria2Protocols.ws
    static let host = "localhost"
    static let port = 6800
    static let path = "/jsonrpc"
    static let remark = "Untitled Server"
    static let globalStatRefreshInterval: Double = 0.5
    static let taskStatRefreshInterval: Double = 2
    static let activeTaskTotal = 5
    static let waitingTaskTotal = 5
    static let stoppedTaskTotal = 5
    static let connectionCheckInterval: Double = 5
    static let aria2TaskSpecificKeys = [
        "gid",
        "status",
        "bittorrent",
        "files",
        "totalLength",
        "downloadSpeed",
        "uploadSpeed",
        "completedLength"
    ]
}

enum AMMHighLightColors {
    case text, background
    
    func color() -> NSColor {
        switch self {
        case .text:
            return NSColor.white
        case .background:
            return NSColor(calibratedRed: 0, green: 128 / 255, blue: 1, alpha: 0.5)
        }
    }
}

