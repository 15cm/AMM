//
//  PreferencesWindowController.swift
//  AMM
//
//  Created by Sinkerine on 01/02/2017.
//  Copyright © 2017 sinkerine. All rights reserved.
//

import Cocoa

class PreferencesWindowController: NSWindowController, NSWindowDelegate, NSTableViewDataSource {
    let profileManager = ServerProfileManager.instance
    let tableViewDragType = "amm.serverprofile"
    
    @IBOutlet weak var profileTableView: NSTableView!
    @IBOutlet weak var protocolPopUpButton: NSPopUpButton!
    @IBOutlet weak var serverTableScrollView: NSScrollView!
    
    override var windowNibName: String? {
        return "PreferencesWindowController"
    }
    
    @IBOutlet var arrayController: ServerProfileArrayController!
    
    override func windowDidLoad() {
        super.windowDidLoad()

        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
        serverTableScrollView.borderType = .noBorder
        // Init NSPopUpButton of protocols
        protocolPopUpButton.addItems(withTitles: Aria2Protocols.allValues.map({$0.rawValue}))
        if !profileManager.servers.isEmpty {
            let protocolOfSelection = (arrayController.selection as AnyObject).value(forKey: "protocolRawValue") as! String?
            protocolPopUpButton.selectItem(withTitle: protocolOfSelection!)
        }
    }
    
    override func awakeFromNib() {
        profileTableView.dataSource = self
        profileTableView.register(forDraggedTypes: [tableViewDragType])
    }

    func reloadProfiles() {
        profileManager.loadPref()
        arrayController.content = profileManager.servers
    }
    
    @IBAction func okClicked(_ sender: Any) {
        profileManager.savePref()
        window?.performClose(self)
    }
    
    @IBAction func cancelClicked(_ sender: Any) {
        window?.performClose(self)
    }
    
    func windowShouldClose(_ sender: Any) -> Bool {
        reloadProfiles()
        return true
    }
    
    // Drag & Drop to reorder rows
    func tableView(_ tableView: NSTableView, writeRowsWith rowIndexes: IndexSet, to pboard: NSPasteboard) -> Bool {
        let data = NSKeyedArchiver.archivedData(withRootObject: rowIndexes)
        pboard.declareTypes([tableViewDragType], owner: self)
        pboard.setData(data, forType: tableViewDragType)
        return true
    }
    
    func tableView(_ tableView: NSTableView, validateDrop info: NSDraggingInfo, proposedRow row: Int, proposedDropOperation dropOperation: NSTableViewDropOperation) -> NSDragOperation {
        if dropOperation == .above {
            return .move
        }
        return NSDragOperation()
    }
    
    func tableView(_ tableView: NSTableView, acceptDrop info: NSDraggingInfo, row: Int, dropOperation: NSTableViewDropOperation) -> Bool {
        let pbboard = info.draggingPasteboard()
        if let indexesData = pbboard.data(forType: tableViewDragType) {
            let oldIndexes: IndexSet = NSKeyedUnarchiver.unarchiveObject(with: indexesData) as! IndexSet
            var profilesToMove:[ServerProfile] = []
            var offset = 0
            for index in oldIndexes {
                profilesToMove.append(profileManager.servers[index])
                if index < row {
                    offset -= 1
                }
            }
            arrayController.remove(atArrangedObjectIndexes: oldIndexes)
            arrayController.insert(contentsOf: profilesToMove, atArrangedObjectIndexes: IndexSet((row + offset)..<(row + offset + profilesToMove.count)))
            return true
        }
        return false
    }
}
