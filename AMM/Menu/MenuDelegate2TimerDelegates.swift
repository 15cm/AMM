//
//  MenuDelegate2TimerDelegates.swift
//  AMM
//
//  Created by Sinkerine on 5/6/18.
//  Copyright © 2018 sinkerine. All rights reserved.
//

import Foundation
import Cocoa

@objc protocol TimerDelegate {
    func startTimer()
    func stopTimer()
}

class MenuDelegate2TimerDelegates: NSObject, MenuDelegateMapper {
    var delegates = NSHashTable<TimerDelegate>.weakObjects()
    
    func addDelegate(delegate: TimerDelegate) {
        delegates.add(delegate)
    }
    
    func removeDelegate(delegate: TimerDelegate) {
        delegates.remove(delegate)
    }
    
    func menuWillOpen(_ menu: NSMenu) {
        for delegate in delegates.allObjects {
            delegate.startTimer()
        }
    }
    
    func menuDidClose(_ menu: NSMenu) {
        for delegate in delegates.allObjects {
            delegate.stopTimer()
        }
    }
}
