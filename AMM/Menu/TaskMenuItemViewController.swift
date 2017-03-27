//
//  AMMTaskMenuItemViewController.swift
//  AMM
//
//  Created by Sinkerine on 30/01/2017.
//  Copyright © 2017 sinkerine. All rights reserved.
//

import Cocoa

class TaskMenuItemViewController: NSViewController {
    var task: Aria2Task = Aria2Task()
    
    @IBOutlet var viewDark: NSView!
    
    init() {
        super.init(nibName: "TaskMenuItemViewController", bundle: nil)!
    }
    
    init?(task: Aria2Task) {
        self.task = task
        super.init(nibName: "TaskMenuItemViewController", bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        if AMMPreferences.instance.darkModeEnabled {
            self.view = viewDark
        }
        super.viewDidLoad()
        // Do view setup here.
    }
}

// KVO bindings
extension Aria2Task {
    dynamic var statusIcon: NSImage {
        switch status {
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
    dynamic class func keyPathsForValuesAffectingStatusIcon() -> Set<String> {
        return Set(["statusRawValue"])
    }
    
    dynamic var percentage: Double {
        return totalLength == 0 ? 0 : Double(completedLength) / Double(totalLength) * 100
    }
    dynamic class func keyPathsForValuesAffectingPercentage() -> Set<String> {
        return Set(["completedLength", "totalLength"])
    }
    
    dynamic var downloadSpeedReadable: String {
        return Aria2.getReadable(length: downloadSpeed) + "/s"
    }
    dynamic class func keyPathsForValuesAffectingDownloadSpeedReadable() -> Set<String> {
        return Set(["downloadSpeed"])
    }
    
    dynamic var uploadSpeedReadable: String {
        return Aria2.getReadable(length: uploadSpeed) + "/s"
    }
    dynamic class func keyPathsForValuesAffectingUploadSpeedReadable() -> Set<String> {
        return Set(["uploadSpeed"])
    }
    
    dynamic var totalLengthReadable: String {
        return Aria2.getReadable(length: totalLength)
    }
    dynamic class func keyPathsForValuesAffectingTotalLengthReadable() -> Set<String> {
        return Set(["totalLength"])
    }
}
