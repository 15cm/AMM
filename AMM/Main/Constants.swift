
//
//  AMMConstants.swift
//  AMM
//
//  Created by Sinkerine on 26/01/2017.
//  Copyright © 2017 sinkerine. All rights reserved.
//

import Cocoa

let defaultProtocol = Aria2Protocols.ws
let defaultHost = "localhost"
let defaultPort = 6800
let defaultPath = "/jsonrpc"
let defaultRemark = "Untitled Server"
let defaultGlobalStatRefreshInterval: Double = 1
let defaultTaskStatRefreshInterval: Double = 1
let defaultActiveTaskMaxNum = 5
let defaultWaitingTaskMaxNum = 5
let defaultStoppedTaskMaxNum = 5

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

