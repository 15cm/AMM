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
    var servers: [ServerProfile] = []
    var darkModeEnabled: Bool = false
    
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
        Defaults[.servers] = self.servers
        Defaults[.darkModeEnabled] = self.darkModeEnabled
        Defaults.synchronize()
    }
    
    func load() {
        servers = Defaults[.servers]
        darkModeEnabled = Defaults[.darkModeEnabled]
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
