//
//  Aria2Constants.swift
//  AMM
//
//  Created by Sinkerine on 26/01/2017.
//  Copyright © 2017 sinkerine. All rights reserved.
//

import Foundation

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
}

public enum Aria2TaskStatus: String {
    case unknown
    case active
    case paused
    case waiting
    case complete
    case stopped
    case error
}
