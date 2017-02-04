//
//  AMM.swift
//  AMM
//
//  Created by Sinkerine on 26/01/2017.
//  Copyright © 2017 sinkerine. All rights reserved.
//

import Foundation

protocol ServerProfileManagerDelegate: class{
    func onServerProfilesUpdate(withServerProfiles servers: [ServerProfile])
}

class ServerProfileManager: NSObject {
    static let instance: ServerProfileManager = ServerProfileManager()
    var servers: [ServerProfile] = []
    weak var delegate: ServerProfileManagerDelegate? = nil
    
    fileprivate override init() {
        super.init()
        loadPref()
    }
    
    func copyServers() -> [ServerProfile] {
        return servers.map({server in
            server.copy() as! ServerProfile
        })
    }
    
    func savePref() {
        let defaults = UserDefaults.standard
        var profiles = [AnyObject]()
        for server in servers {
            if server.isValid() {
                let profile = server.toDictionary()
                profiles.append(profile as AnyObject)
            }
        }
        defaults.set(profiles, forKey: "serverProfiles")
    }
    
    func loadPref() {
        let defaults = UserDefaults.standard
        servers.removeAll()
        if let profiles = defaults.array(forKey: "serverProfiles") {
            for profile in profiles {
                let server = ServerProfile.fromDictionary(profile as! [String : Any?])
                servers.append(server)
            }
        }
        delegate?.onServerProfilesUpdate(withServerProfiles: copyServers())
    }
    
}
