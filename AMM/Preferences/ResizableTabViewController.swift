//
//  AutoResizeTabViewController.swift
//  AMM
//
//  Created by Sinkerine on 03/03/2017.
//  Copyright © 2017 sinkerine. All rights reserved.
//

import Cocoa

class ResizableTabViewController: NSTabViewController {
    
    var tabViewSizeDic = [String: NSSize]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    override func tabView(_ tabView: NSTabView, willSelect tabViewItem: NSTabViewItem?) {
        super.tabView(tabView, willSelect: tabViewItem)
        if let newItem = tabViewItem {
            tabViewSizeDic[newItem.label] = tabViewSizeDic[newItem.label] ?? newItem.view?.frame.size
        }
    }
    
    override func tabView(_ tabView: NSTabView, didSelect tabViewItem: NSTabViewItem?) {
        super.tabView(tabView, didSelect: tabViewItem)
        if let newItem = tabViewItem {
            resizeWith(tabViewItem: newItem)
        }
    }
    
    private func resizeWith(tabViewItem item: NSTabViewItem) {
        if let window = self.view.window, let contentSize = tabViewSizeDic[item.label] {
            let newWindowSize = window.frameRect(forContentRect: NSRect(origin: CGPoint.zero, size: contentSize)).size
            
            var frame = window.frame
            frame.origin.y = frame.origin.y + (frame.size.height - newWindowSize.height)
            frame.size = newWindowSize
            
            window.setFrame(frame, display: true, animate: true)
        }
    }
}
