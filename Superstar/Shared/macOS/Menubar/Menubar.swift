//
//  Menubar.swift
//  Superstar (iOS)
//
//  Created by Jordi Bruin on 17/07/2022.
//

import SwiftUI
import Foundation
import AppKit

class StatusBarDelegate: NSObject, NSApplicationDelegate {
    
    var popover: NSPopover!
    
    var statusBarItem: NSStatusItem!
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Create the SwiftUI view that provides the window contents.
        let contentView = ContentView()
        
        // Create the popover
        let popover = NSPopover()
//        popover.contentSize = NSSize(width: 250)
        popover.behavior = .transient
        popover.contentViewController = NSHostingController(rootView: contentView)
        popover.becomeFirstResponder()
        self.popover = popover
        
        // Create the status item
        self.statusBarItem = NSStatusBar.system.statusItem(withLength: CGFloat(NSStatusItem.variableLength))
        
        if let button = self.statusBarItem.button {
            button.title = "🌟"
            button.action = #selector(togglePopover(_:))
            button.toolTip = "Open Superstar"
        }
    }
    
    @objc func togglePopover(_ sender: AnyObject?) {
        if let button = self.statusBarItem.button {
            if self.popover.isShown {
                self.popover.performClose(sender)
            } else {
                self.popover.show(relativeTo: button.bounds, of: button, preferredEdge: NSRectEdge.minY)
                NSApplication.shared.activate(ignoringOtherApps: true)
            }
        }
    }
}


