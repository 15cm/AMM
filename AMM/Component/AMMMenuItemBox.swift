//
//  MenuItemBox.swift
//  AMM
//
//  Created by Sinkerine on 02/02/2017.
//  Copyright © 2017 sinkerine. All rights reserved.
//

import Cocoa

class AMMMenuItemBox: NSBox {

    override func draw(_ dirtyRect: NSRect) {

        // Drawing code here.
        if let isHighlighted = enclosingMenuItem?.isHighlighted {
            if isHighlighted {
                highlight()
            } else {
                noHighlight()
            }
        } else {
            noHighlight()
        }
        NSRectFill(dirtyRect)
        super.draw(dirtyRect)
    }
    
    func highlight() {
        NSColor(calibratedRed: 0, green: 128, blue: 255, alpha: 0.1).setFill()
    }
    
    func noHighlight() {
         NSColor(calibratedRed: 0, green: 0, blue: 0, alpha: 0).setFill()
    }
}
