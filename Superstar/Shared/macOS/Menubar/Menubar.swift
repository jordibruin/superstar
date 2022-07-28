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
    
    @AppStorage("menuBarVisible") var menuBarVisible: Bool = true
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Create the SwiftUI view that provides the window contents.
        let contentView = MenuBarView()
        
        // Create the popover
        let popover = NSPopover()
        popover.behavior = .transient
        popover.contentViewController = NSHostingController(rootView: contentView)
        popover.becomeFirstResponder()
        self.popover = popover
        
        // Create the status item
        if menuBarVisible {
            createMenuBarItem()
        }
        
        setupNotification()
    }
    
    func createMenuBarItem() {
        self.statusBarItem = NSStatusBar.system.statusItem(withLength: CGFloat(NSStatusItem.variableLength))
        if let button = self.statusBarItem.button {
            if let image = NSImage(named: "menubar") {
                image.isTemplate = true
                button.image = image//.withSymbolConfiguration(config)
//                button.image.symbolRenderingMode(.template)
                    
            }
                                   
            button.action = #selector(togglePopover(_:))
            button.toolTip = "Open Superstar"
        }
    }
    
    func setupNotification() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(changeMenu),
            name: Notification.Name.init("changeMenu"),
            object: nil
        )
    }
    
    @objc func changeMenu(notification: Notification) {
        if let menuBarVisible = notification.userInfo?["menuBarVisible"] as? Bool {
            if menuBarVisible {
                createMenuBarItem()
            } else {
                statusBarItem = nil
            }
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
