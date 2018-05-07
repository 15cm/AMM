//
//  MenuDelegateMapper.swift
//  AMM
//
//  Created by Sinkerine on 5/6/18.
//  Copyright © 2018 sinkerine. All rights reserved.
//

import Foundation
import Cocoa

protocol MenuDelegateMapper: NSMenuDelegate {
    associatedtype T
    func addDelegate(delegate: T)
    func removeDelegate(delegate: T)
}
