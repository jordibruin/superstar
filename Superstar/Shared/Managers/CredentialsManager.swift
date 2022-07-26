//
//  CredentialsManager.swift
//  🌟 Superstar
//
//  Created by Jordi Bruin on 17/07/2022.
//

import Foundation
import SwiftUI
import AppStoreConnect_Swift_SDK
import KeychainAccess
import EncryptedAppStorage

class CredentialsManager: ObservableObject {
    
    let keychain = Keychain(service: "com.goodsnooze.superstar")
    let defaults = UserDefaults.standard
    
    static let shared = CredentialsManager()
    
    @Published var configurationReady = false
    
    @Published var keyID: String = ""
    @Published var issuerId: String = ""
    @Published var privateKey: String = ""
    
    @Published var savedInKeychain = false
    @Published var configuration = APIConfiguration(issuerID: "", privateKeyID: "", privateKey: "")
    
    init() {
        guard let key = defaults.string(forKey: "keyId"), let issuer = defaults.string(forKey: "issuerId"), let privateKeyString = defaults.string(forKey: "privateKey") else {
            setupPublishersFromKeychain()
            
            return
        }
        
        print("keys still in user defaults")
        if !key.isEmpty || !issuer.isEmpty || !privateKeyString.isEmpty {
            print("one of these is not empty")
            self.convertToKeychain()
        }
    }
    
    func updateInKeychain(key: String, value: String) {
        do  {
            try keychain.set(value, key: key)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    
    
    func setupPublishersFromKeychain() {
        self.keyID = keychain["keyId"] ?? ""
        self.issuerId = keychain["issuerId"] ?? ""
        self.privateKey = keychain["privateKey"] ?? ""
        let twanKey = privateKey.replacingOccurrences(of: "-----BEGIN PRIVATE KEY-----", with: "").replacingOccurrences(of: "-----END PRIVATE KEY-----", with: "").replacingOccurrences(of: "\n", with: "")
        self.configuration = APIConfiguration(issuerID: issuerId, privateKeyID: keyID, privateKey: twanKey)
        configurationReady = true
    }
    
    func convertToKeychain() {
        print("convert to keychain")
        saveCredentials()
        removeUserDefaults()
        setupPublishersFromKeychain()
    }
    
    func saveCredentials() {
        updateInKeychain(key: "keyId", value: keyID)
        updateInKeychain(key: "issuerId", value: issuerId)
        updateInKeychain(key: "privateKey", value: privateKey)
        
        savedInKeychain = true
        setupPublishersFromKeychain()
    }
    
    func removeUserDefaults() {
        defaults.removeObject(forKey: "keyId")
        defaults.removeObject(forKey: "issuerId")
        defaults.removeObject(forKey: "privateKey")
    }
    
    
    func allCredentialsAvailable() -> Bool {
        //        print(keyID)
        //        print(keyID.isEmpty)
        //        print(!keyID.isEmpty && !issuerId.isEmpty && !privateKey.isEmpty && (privateKey.count == 252 || privateKey.count == 257))
        
        let keychainKeyId = keychain["keyId"] ?? ""
        let keychainissuerId = keychain["issuerId"] ?? ""
        let keychainprivateKey = keychain["privateKey"] ?? ""
        
        return !keyID.isEmpty && !issuerId.isEmpty && !privateKey.isEmpty && (privateKey.count == 252 || privateKey.count == 257) && !keychainKeyId.isEmpty && !keychainissuerId.isEmpty && !keychainprivateKey.isEmpty
    }
    
    func clearAllCredentials() {
        do {
            try keychain.removeAll()
        } catch {
            print(error.localizedDescription)
        }
        
        keyID = ""
        issuerId = ""
        privateKey = ""
    }
    
    //    func getJWT() -> JWT? {
    //        var formattedKey = ""
    //
    //        if privateKey.count == 252 {
    //            print("add the newlines")
    //
    //            let removed = privateKey.replacingOccurrences(of: "-----BEGIN PRIVATE KEY-----", with: "").replacingOccurrences(of: "-----END PRIVATE KEY-----", with: "")
    //
    //            let begin = "-----BEGIN PRIVATE KEY-----\n"
    //            let middle = removed.inserting(separator: "\n", every: 64)
    //            let end = "\n-----END PRIVATE KEY-----"
    //
    //            formattedKey = begin + middle + end
    //        } else {
    //            formattedKey = privateKey
    //        }
    //
    //        do {
    //            return try JWT(
    //                keyId: keyID,
    //                issuerId: issuerId,
    //                privateKey: formattedKey
    //            )
    //        } catch {
    //            print(error.localizedDescription)
    //            return nil
    //        }
    //    }
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
