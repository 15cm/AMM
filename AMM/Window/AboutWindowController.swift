//
//  AboutWindowController.swift
//  AMM
//
//  Created by Sinkerine on 03/02/2017.
//  Copyright © 2017 sinkerine. All rights reserved.
//

import Cocoa

extension NSMutableAttributedString {
    func setAsLink(textToLink: String, url: String) -> Bool {
        let sRange = self.mutableString.range(of: textToLink)
        if sRange.location != NSNotFound {
            self.addAttribute(NSLinkAttributeName, value: url, range: sRange)
            return true
        }
        return false
    }
}

class AboutWindowController: NSWindowController {
    

    @IBOutlet weak var versionBuild: NSTextField!
    @IBOutlet weak var appName: NSTextField!
    @IBOutlet weak var appSource: NSTextField!
    @IBOutlet weak var contactMe: NSTextField!
    @IBOutlet weak var appCopyright: NSTextField!
    
    override func windowDidLoad() {
        super.windowDidLoad()

        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
        let infoDictionary = Bundle.main.infoDictionary!
        
        let version = infoDictionary["CFBundleShortVersionString"] as! String
        let name = infoDictionary["CFBundleName"] as! String
        let build = infoDictionary["CFBundleVersion"] as! String
        let copyright = infoDictionary["NSHumanReadableCopyright"] as! String
        
        versionBuild.stringValue = "v\(version) (Build \(build))"
        appName.stringValue = name
        appCopyright.stringValue = copyright
        
        let sourceRTFPath = Bundle.main.path(forResource: "Source", ofType: "rtf")
        let contactRTFPath = Bundle.main.path(forResource: "Contact", ofType: "rtf")
        do {
            if let path = sourceRTFPath {
                let data = try Data(contentsOf: URL(fileURLWithPath: path))
                appSource.attributedStringValue = NSAttributedString(rtf: data, documentAttributes: nil)!
            }
            if let path = contactRTFPath {
                let data = try Data(contentsOf: URL(fileURLWithPath: path))
                contactMe.attributedStringValue = NSAttributedString(rtf: data, documentAttributes: nil)!
            }
        } catch {
            print(error)
        }
    }
}
