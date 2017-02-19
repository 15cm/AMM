//
//  MenuItemBox.swift
//  AMM
//
//  Created by Sinkerine on 02/02/2017.
//  Copyright © 2017 sinkerine. All rights reserved.
//

import Cocoa

class AMMMenuItemBox: NSBox, AMMHighlightable {
    var normalBackgroundColor: NSColor? = nil

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
    
    override func awakeFromNib() {
        normalBackgroundColor = self.fillColor
        self.borderWidth = 0.5
    }
    
    func highlight() {
        self.fillColor = AMMHighLightColors.background.color()
    }
    
    func noHighlight() {
        self.fillColor = normalBackgroundColor!
    }
}
