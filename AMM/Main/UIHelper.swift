//
//  UIHelper.swift
//  AMM
//
//  Created by Sinkerine on 22/08/2017.
//  Copyright © 2017 sinkerine. All rights reserved.
//

import Foundation
import Cocoa

func showAlert(_ title: String, _ msg: String) {
    let alert = NSAlert()
    alert.messageText = title
    alert.informativeText = msg
    alert.runModal()
}

func confirmAlert(_ title: String, _ msg: String) -> Bool {
    let alert = NSAlert()
    alert.messageText = title
    alert.informativeText = msg
    alert.addButton(withTitle: "OK")
    alert.addButton(withTitle: "Cancel")
    return alert.runModal() == NSAlertFirstButtonReturn
}

func showNotification(_ title: String?, _ msg: String?) {
    let noti = NSUserNotification()
    noti.title = title
    noti.informativeText = msg
    NSUserNotificationCenter.default.deliver(noti)
}
