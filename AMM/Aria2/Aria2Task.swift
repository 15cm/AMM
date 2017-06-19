//
//  Aria2Task.swift
//  AMM
//
//  Created by Sinkerine on 26/01/2017.
//  Copyright © 2017 sinkerine. All rights reserved.
//

import Foundation
import SwiftyJSON

class Aria2Task: NSObject{
    dynamic var gid: String = ""
    var status: Aria2TaskStatus = .unknown {
        didSet {
            self.statusRawValue = self.status.rawValue
        }
    }
    dynamic var statusRawValue: String = "unknown" // Workaround for enum KVO
    dynamic var title: String = ""
    dynamic var downloadSpeed: Int = 0
    dynamic var uploadSpeed: Int = 0
    dynamic var totalLength: Int = 0
    dynamic var completedLength: Int = 0
    var files: [Aria2File] = []
    
    struct Aria2File {
        var path: String
        var size: Int
        
        init(path: String, size: Int) {
            self.path = path
            self.size = size
        }
    }
    
    override init() {
        super.init()
    }
    
    // init with task json
    init(json: JSON) {
        gid = json["gid"].stringValue
        status = Aria2TaskStatus(rawValue: json["status"].stringValue) ?? .unknown
        if let taskTitle = json["bittorrent"]["info"]["name"].string {
            title = taskTitle
        } else if let firstFileTitle = json["files"][0]["path"].string{
            title = firstFileTitle.components(separatedBy: "/").last!
        } else {
            title = "Unknown"
        }
        downloadSpeed = Int(json["downloadSpeed"].stringValue) ?? 0
        uploadSpeed = Int(json["uploadSpeed"].stringValue) ?? 0
        totalLength = Int(json["totalLength"].stringValue) ?? 0
        completedLength = Int(json["completedLength"].stringValue) ?? 0
        for (_, fileJSON) in json["files"] {
            files.append(Aria2File(path: fileJSON["path"].stringValue, size: Int(fileJSON["length"].stringValue) ?? 0))
        }
    }
    
    func replace(fromTask task: Aria2Task) {
        gid = task.gid
        status = task.status
        title = task.title
        downloadSpeed = task.downloadSpeed
        uploadSpeed = task.uploadSpeed
        totalLength = task.totalLength
        completedLength = task.completedLength
        files = task.files
    }
}
