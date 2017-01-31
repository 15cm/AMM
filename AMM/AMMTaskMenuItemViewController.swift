//
//  AMMTaskMenuItemViewController.swift
//  AMM
//
//  Created by Sinkerine on 30/01/2017.
//  Copyright © 2017 sinkerine. All rights reserved.
//

import Cocoa

class AMMTaskMenuItemViewController: NSViewController {

    var task: Aria2Task = Aria2Task()
    
    init() {
        super.init(nibName: "AMMTaskMenuItemViewController", bundle: nil)!
    }
    
    init?(task: Aria2Task) {
        self.task = task
        super.init(nibName: "AMMTaskMenuItemViewController", bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
}

// KVO bindings
extension AMMTaskMenuItemViewController {
    dynamic var taskStatusIcon: NSImage {
        switch task.status {
        case .active:
            return #imageLiteral(resourceName: "fa-download")
        case .paused:
            return #imageLiteral(resourceName: "fa-pause")
        case .complete:
            return #imageLiteral(resourceName: "fa-check")
        case .stopped:
            return #imageLiteral(resourceName: "fa-stop")
        case .error:
            return #imageLiteral(resourceName: "iconmoon-cross")
        case .unknown:
            return #imageLiteral(resourceName: "fa-question")
        default:
            return #imageLiteral(resourceName: "fa-question")
        }
    }
    dynamic class func keyPathsForValuesAffectingTaskStatusIcon() -> Set<String> {
        return Set(["task.statusRawValue"])
    }
    
    dynamic var percentage: Double {
        return task.totalLength == 0 ? 0 : Double(task.completedLength) / Double(task.totalLength) * 100
    }
    dynamic class func keyPathsForValuesAffectingPercentage() -> Set<String> {
        return Set(["task.completedLength", "task.totalLength"])
    }
    
    dynamic var downloadSpeedReadable: String {
       return Aria2.getReadable(length: task.downloadSpeed) + "/s"
    }
    dynamic class func keyPathsForValuesAffectingDownloadSpeedReadable() -> Set<String> {
        return Set(["task.downloadSpeed"])
    }
    
    dynamic var uploadSpeedReadable: String {
       return Aria2.getReadable(length: task.uploadSpeed) + "/s"
    }
    dynamic class func keyPathsForValuesAffectingUploadSpeedReadable() -> Set<String> {
        return Set(["task.uploadSpeed"])
    }
    
    dynamic var totalLengthReadable: String {
        return Aria2.getReadable(length: task.totalLength)
    }
    dynamic class func keyPathsForValuesAffectingTotalLengthReadable() -> Set<String> {
        return Set(["task.totalLength"])
    }
}
