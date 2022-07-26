//
//  IAPManager.swift
//  Superstar (macOS)
//
//  Created by Jordi Bruin on 26/07/2022.
//

import Foundation
import AppStoreConnect_Swift_SDK
import SwiftUI

class IAPManager: ObservableObject {
    
    static let shared = IAPManager()
    
    @Published var proUser = false
    @Published var freeAppId: String = "" {
        didSet {
            freeAppIdStorage = freeAppId
        }
    }
    
    @AppStorage("freeAppIdStorage") var freeAppIdStorage: String = ""
    
    
    init() {
        freeAppId = freeAppIdStorage
    }
    
    func togglePayStatus() {
        proUser.toggle()
    }
}
