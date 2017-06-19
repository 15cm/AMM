//
//  AMMPreferencesTests.swift
//  AMM
//
//  Created by Sinkerine on 19/02/2017.
//  Copyright © 2017 sinkerine. All rights reserved.
//

import XCTest
@testable import AMM

class AMMPreferencesTests: XCTestCase {
    let preferences = AMMPreferences.instance

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        let servers: [ServerProfile] = [
            ServerProfile(uuid: NSUUID().uuidString, aria2: Aria2(ptcl: .ws, host: "host1", port: 1111, path: "/jsonrpc")!, remark: "test1", globalStatRefreshInterval: 1, taskStatRefreshInterval: 1, activeTaskTotal: 5, waitingTaskTotal: 5, stoppedTaskTotal: 5, taskStartNotiEnabled: false, taskPauseNotiEnabled: false, taskCompleteNotiEnabled: false)!,
            ServerProfile(uuid: NSUUID().uuidString, aria2: Aria2(ptcl: .ws, host: "host2", port: 1111, path: "/jsonrpc")!, remark: "test2", globalStatRefreshInterval: 1, taskStatRefreshInterval: 1, activeTaskTotal: 5, waitingTaskTotal: 5, stoppedTaskTotal: 5, taskStartNotiEnabled: false, taskPauseNotiEnabled: false, taskCompleteNotiEnabled: false)!
        ]
        preferences.reset()
        assert(preferences.servers.count == 0)
        preferences.servers = servers
        preferences.save()
        preferences.load()
        assert(preferences.servers.count == 2)
        assert(preferences.servers[0].aria2.host == "host1" &&
            preferences.servers[1].aria2.host == "host2"
        )
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
