//
//  MenuItemBox.swift
//  AMM
//
//  Created by Sinkerine on 02/02/2017.
//  Copyright © 2017 sinkerine. All rights reserved.
//

import Cocoa

class MenuItemBox: NSBox {

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
        super.draw(dirtyRect)
    }
    
    func highlight() {
        fillColor = NSColor(calibratedRed: 0, green: 128, blue: 255, alpha: 0.2)
    }
    
    func noHighlight() {
        fillColor = NSColor(calibratedRed: 0, green: 0, blue: 0, alpha: 0)
    }
}
