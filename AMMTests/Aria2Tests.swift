//
//  Aria2Test.swift
//  AMM
//
//  Created by Sinkerine on 28/01/2017.
//  Copyright © 2017 sinkerine. All rights reserved.
//

import XCTest
@testable import AMM

class Aria2Tests: XCTestCase {
    let aria2 = Aria2(host: "localhost", port: 6800, path: "jsonrpc", secret: "15cm")

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
        aria2?.connect()
        sleep(1)
        aria2?.tellStopped(offset: -1, num: 10, callback: {tasks in
            for task in tasks {
                print(task.title)
            }
        })
        sleep(1)
        aria2?.disconnect()
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
