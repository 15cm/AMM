//
//  AMMPreferences.swift
//  AMM
//
//  Created by Sinkerine on 26/01/2017.
//  Copyright © 2017 sinkerine. All rights reserved.
//

import Foundation
import SwiftyUserDefaults

protocol AMMPreferencesDelegate: class{
    func onServerProfilesUpdate(withServerProfiles servers: [ServerProfile])
}

class AMMPreferences: NSObject {
    static let instance: AMMPreferences = AMMPreferences()
    weak var delegate: AMMPreferencesDelegate? = nil
    @objc var servers: [ServerProfile] = []
    @objc var darkModeEnabled: Bool = false
    @objc var controlModeEnabled: Bool = false
    @objc var connectionCheckInterval: Int = AMMDefault.connectionCheckInterval
    @objc var connectionRetryLimit: Int = AMMDefault.connectionRetryLimit
    
    fileprivate override init() {
        super.init()
        load()
    }
    
    func copyServers() -> [ServerProfile] {
        return servers.map({server in
            server.copy() as! ServerProfile
        })
    }
    
    func save() {
        Defaults[.servers] = servers
        Defaults[.darkModeEnabled] = darkModeEnabled
        Defaults[.controlModeEnabled] = controlModeEnabled
        Defaults[.connectionCheckInterval] = connectionCheckInterval
        Defaults[.connectionRetryLimit] = connectionRetryLimit
        Defaults.synchronize()
    }
    
    func load() {
        servers = Defaults[.servers]
        darkModeEnabled = Defaults[.darkModeEnabled]
        controlModeEnabled = Defaults[.controlModeEnabled]
        connectionCheckInterval = Defaults[.connectionCheckInterval]
        connectionRetryLimit = Defaults[.connectionRetryLimit]
        delegate?.onServerProfilesUpdate(withServerProfiles: copyServers())
    }
    
    func reset() {
        Defaults.removeAll()
        load()
    }
}

extension DefaultsKeys {
    static let servers = DefaultsKey<[ServerProfile]>("servers")
    static let darkModeEnabled = DefaultsKey<Bool>("darkModeEnabled")
    static let controlModeEnabled = DefaultsKey<Bool>("controlModeEnabled")
    static let connectionCheckInterval = DefaultsKey<Int>("connectionCheckInterval")
    static let connectionRetryLimit = DefaultsKey<Int>("connectionRetryLimit")
}

extension UserDefaults {
    subscript(key: DefaultsKey<[ServerProfile]>) -> [ServerProfile] {
        get {
            return unarchive(key) ?? [ServerProfile]()
        }
        set {
            archive(key, newValue)
        }
    }
}
