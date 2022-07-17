//
//  CredentialsManager.swift
//  🌟 Superstar
//
//  Created by Jordi Bruin on 17/07/2022.
//

import Foundation
import SwiftUI
import Bagbutik

class CredentialsManager: ObservableObject {
    @AppStorage("keyID") var keyIDStorage: String = ""
    @AppStorage("issuerID") var issuerIDStorage: String = ""
    @AppStorage("privateKey") var privateKeyStorage: String = ""
    
    @Published var keyID: String = "" {
        didSet {
            keyIDStorage = keyID
        }
    }
    
    @Published var issuerId: String = "" {
        didSet {
            issuerIDStorage = issuerId
        }
    }
    
    @Published var privateKey: String = "" {
        didSet {
            privateKeyStorage = privateKey
        }
    }
    
    init() {
        self.keyID = keyIDStorage
        self.issuerId = issuerIDStorage
        self.privateKey = privateKeyStorage
    }
    static let shared = CredentialsManager()
    
    @Published var updatedCredentials: UUID = UUID()
    
    func allCredentialsAvailable() -> Bool {
        return !keyID.isEmpty && !issuerId.isEmpty && !privateKey.isEmpty && privateKey.count == 252 || privateKey.count == 257
    }
    
    func getJWT() -> JWT? {
        var formattedKey = ""
        
        if privateKey.count == 252 {
            print("add the newlines")
            
            let removed = privateKey.replacingOccurrences(of: "-----BEGIN PRIVATE KEY-----", with: "").replacingOccurrences(of: "-----END PRIVATE KEY-----", with: "")
            
            let begin = "-----BEGIN PRIVATE KEY-----\n"
            let middle = removed.inserting(separator: "\n", every: 64)
            let end = "\n-----END PRIVATE KEY-----"
            
            formattedKey = begin + middle + end
        } else {
            print("ready to go")
            formattedKey = privateKey
        }
        
        do {
            return try JWT(
                keyId: keyID,
                issuerId: issuerId,
                privateKey: formattedKey
            )
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }
}

extension String {
    func inserting(separator: String, every n: Int) -> String {
        var result: String = ""
        let characters = Array(self)
        stride(from: 0, to: characters.count, by: n).forEach {
            result += String(characters[$0..<min($0+n, characters.count)])
            if $0+n < characters.count {
                result += separator
            }
        }
        return result
    }
}
