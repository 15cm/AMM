//
//  Aria2Stat.swift
//  AMM
//
//  Created by Sinkerine on 02/02/2017.
//  Copyright © 2017 sinkerine. All rights reserved.
//

import Foundation

class Aria2Stat {
    var downloadSpeed: Int
    var uploadSpeed: Int
    init(downloadSpeed: Int, uploadSpeed: Int) {
        self.downloadSpeed = downloadSpeed
        self.uploadSpeed = uploadSpeed
    }
}
