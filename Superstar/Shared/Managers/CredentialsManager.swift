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
    
    @Published var keyID: String = ""
    @Published var issuerId: String = ""
    @Published var privateKey: String = ""
    
    func updateInKeychain(key: String, value: String) {
        do  {
            try keychain.set(value, key: key)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func saveCredentials() {
        updateInKeychain(key: "keyId", value: keyID)
        updateInKeychain(key: "issuerId", value: issuerId)
        updateInKeychain(key: "privateKey", value: privateKey)
    }
    
    
    @Published var configuration = APIConfiguration(issuerID: "", privateKeyID: "", privateKey: "")
    
    init() {
        self.keyID = keychain["keyId"] ?? ""
        self.issuerId = keychain["issuerId"] ?? ""
        self.privateKey = keychain["privateKey"] ?? ""
    
        let twanKey = privateKey.replacingOccurrences(of: "-----BEGIN PRIVATE KEY-----", with: "").replacingOccurrences(of: "-----END PRIVATE KEY-----", with: "").replacingOccurrences(of: "\n", with: "")
        self.configuration = APIConfiguration(issuerID: issuerId, privateKeyID: keyID, privateKey: twanKey)
        
        
        guard let key = defaults.string(forKey: "keyId"), let issuer = defaults.string(forKey: "issuerId"), let privateKeyString = defaults.string(forKey: "privateKey") else { return }
            
        if !key.isEmpty || !issuer.isEmpty || !privateKeyString.isEmpty {
            print("one of these is not empty")
            self.convertToKeychain()
        }
    }
    
    func convertToKeychain() {
        saveCredentials()
        removeUserDefaults()
    }
    
    func removeUserDefaults() {
        defaults.removeObject(forKey: "keyId")
        defaults.removeObject(forKey: "issuerId")
        defaults.removeObject(forKey: "privateKey")
    }
    
    //    let configuration = APIConfiguration(issuerID: "<YOUR ISSUER ID>", privateKeyID: "<YOUR PRIVATE KEY ID>", privateKey: "<YOUR PRIVATE KEY>")
    
    func allCredentialsAvailable() -> Bool {
        //        print(keyID)
        //        print(keyID.isEmpty)
        //        print(!keyID.isEmpty && !issuerId.isEmpty && !privateKey.isEmpty && (privateKey.count == 252 || privateKey.count == 257))
        return !keyID.isEmpty && !issuerId.isEmpty && !privateKey.isEmpty && (privateKey.count == 252 || privateKey.count == 257)
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
