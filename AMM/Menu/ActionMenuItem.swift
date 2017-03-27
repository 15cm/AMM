//
//  ActionMenuItem.swift
//  AMM
//
//  Created by Sinkerine on 27/03/2017.
//  Copyright © 2017 sinkerine. All rights reserved.
//

import Cocoa

class ActionMenuItem: NSMenuItem {
    init(title string: String, action selector: Selector?, keyEquivalent charCode: String, target: AnyObject?) {
        super.init(title: string, action: selector, keyEquivalent: charCode)
        self.target = target
    }
    
    required init(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
