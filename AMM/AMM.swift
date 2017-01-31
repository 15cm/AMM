//
//  AMM.swift
//  AMM
//
//  Created by Sinkerine on 26/01/2017.
//  Copyright © 2017 sinkerine. All rights reserved.
//

import Foundation

class AMM {
    var servers: [AMMServer]
    
    init(servers: [AMMServer]) {
        self.servers = servers
        for server in servers {
            server.aria2?.connect()
        }
    }
}
