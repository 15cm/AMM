//
//  AMMTextField.swift
//  AMM
//
//  Created by Sinkerine on 04/02/2017.
//  Copyright © 2017 sinkerine. All rights reserved.
//

import Cocoa

class AMMTextField: NSTextField {
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
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
        let cmd = NSEventModifierFlags.command.rawValue
        if event.type == NSEventType.keyDown {
            switch (event.modifierFlags.rawValue & NSEventModifierFlags.deviceIndependentFlagsMask.rawValue)  {
            case cmd:
                switch event.charactersIgnoringModifiers! {
                case "a":
                    NSApp.sendAction(#selector(NSText.selectAll(_:)), to: nil, from: self)
                    Swift.print("A")
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
    
}
