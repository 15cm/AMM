//
//  ServerProfileArrayController.swift
//  AMM
//
//  Created by Sinkerine on 01/02/2017.
//  Copyright © 2017 sinkerine. All rights reserved.
//

import Cocoa

class ServerProfileArrayController: NSArrayController {
    override func addObject(_ object: Any) {
        super.addObject(ServerProfile())
    }
}
