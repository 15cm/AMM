//
//  TaskMenuItemSeperator.swift
//  AMM
//
//  Created by Sinkerine on 03/02/2017.
//  Copyright © 2017 sinkerine. All rights reserved.
//

import Cocoa

class TaskMenuItemSeperator: NSMenuItem {
    var viewController: TaskMenuItemSeperatorViewController? = nil
    init(name: String) {
        viewController = TaskMenuItemSeperatorViewController(nibName: NSNib.Name(rawValue: "TaskMenuItemSeperatorViewController"), bundle: nil)
        viewController?.name = name
        super.init(title: name, action: nil, keyEquivalent: "")
        self.view = viewController?.view
    }
    
    required init(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
