//
//  AboutViewÇontroller.swift
//  AMM
//
//  Created by Sinkerine on 19/02/2017.
//  Copyright © 2017 sinkerine. All rights reserved.
//

import Cocoa

class AboutViewController: NSViewController {
    let infoDictionary = Bundle.main.infoDictionary!

    @IBOutlet weak var appName: NSTextField! {
        didSet {
           appName.stringValue = infoDictionary["CFBundleName"] as! String
        }
    }
    @IBOutlet weak var appVersionBuild: NSTextField! {
        didSet {
            let version = infoDictionary["CFBundleShortVersionString"] as! String
            let build = infoDictionary["CFBundleVersion"] as! String
            appVersionBuild.stringValue = "v\(version) (Build \(build))"
        }
    }
    @IBOutlet weak var appSource: NSTextField! {
        didSet {
            let sourceRTFPath = Bundle.main.path(forResource: "Source", ofType: "rtf")
            do {
                if let path = sourceRTFPath {
                    let data = try Data(contentsOf: URL(fileURLWithPath: path))
                    appSource.attributedStringValue = NSAttributedString(rtf: data, documentAttributes: nil)!
                }
            } catch {
                print(error)
            }
        }
    }
    @IBOutlet weak var contactMe: NSTextField! {
        didSet {
            do {
                let contactRTFPath = Bundle.main.path(forResource: "Contact", ofType: "rtf")
                if let path = contactRTFPath {
                    let data = try Data(contentsOf: URL(fileURLWithPath: path))
                    contactMe.attributedStringValue = NSAttributedString(rtf: data, documentAttributes: nil)!
                }
            } catch {
                print(error)
            }
        }
    }
    @IBOutlet weak var copyright: NSTextField! {
        didSet {
            copyright.stringValue = infoDictionary["NSHumanReadableCopyright"] as! String
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
}
