//
//  AMMTextField.swift
//  AMM
//
//  Created by Sinkerine on 04/02/2017.
//  Copyright © 2017 sinkerine. All rights reserved.
//

import Cocoa

class AMMTextField: NSTextField, AMMHighlightable {
    var normalTextColor:NSColor?
    
    override func draw(_ dirtyRect: NSRect) {
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

        // Drawing code here.
    }
    
    override func awakeFromNib() {
        normalTextColor = self.textColor
    }
    
    override var acceptsFirstResponder: Bool {
        return true
    }

    override func becomeFirstResponder() -> Bool {
        return true
    }
    
    override func resignFirstResponder() -> Bool {
        return true
    }
    
    override func performKeyEquivalent(with event: NSEvent) -> Bool {
        let cmd = NSEvent.ModifierFlags.command.rawValue
        if event.type == NSEvent.EventType.keyDown {
            switch (event.modifierFlags.rawValue & NSEvent.ModifierFlags.deviceIndependentFlagsMask.rawValue)  {
            case cmd:
                switch event.charactersIgnoringModifiers! {
                case "a":
                    NSApp.sendAction(#selector(NSText.selectAll(_:)), to: nil, from: self)
                    return true
                case "c":
                    NSApp.sendAction(#selector(NSText.copy(_:)), to: nil, from: self)
                    return true
                case "v":
                    NSApp.sendAction(#selector(NSText.paste(_:)), to: nil, from: self)
                    return true
                case "x":
                    NSApp.sendAction(#selector(NSText.cut(_:)), to: nil, from: self)
                    return true
                default:
                    break
                }
            default:
                break
            }
        }
        return super.performKeyEquivalent(with: event)
    }
    
    func highlight() {
        textColor = AMMHighLightColors.text.color()
    }
    
    func noHighlight() {
        textColor = normalTextColor
    }
}
