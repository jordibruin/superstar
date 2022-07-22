//
//  AddCredentialsView.swift
//  🌟 Superstar
//
//  Created by Jordi Bruin on 17/07/2022.
//

import SwiftUI

struct AddCredentialsView: View {
    
    @Environment(\.dismiss) var dismiss
    
    @State var p8Hovered = false
    
    @StateObject var credentials = CredentialsManager.shared
    
    var body: some View {
        VStack(alignment: .leading) {
            title
            keyId
            issuerId
            privateKey
            Spacer()
            footer
        }
        .padding()
        .background(
            background
        )
        .onDrop(of: [.fileURL], isTargeted: $p8Hovered) { providers in
            handleExternalFileDrop(providers: providers)
        }
        .overlay(
            ZStack {
                Color.white.opacity(0.2)
                Text(p8Hovered ? "Drop P8 file here" : "")
                    .font(.system(.title, design: .rounded))
            }
                .opacity(p8Hovered ? 1 : 0)
        )
    }
    
    var background: some View {
        Color.gray.opacity(0.2)
    }
    
    var title: some View {
        VStack(alignment: .leading) {
            Text("You need to add some API stuff")
            
                .font(.system(.title3, design: .rounded))
                .bold()
            Text("Go to https://appstoreconnect.apple.com/access/api and create a new API key.\nMake sure to give the key Admin access (I've filed a FB to also allow users to make a Customer Support role. \nOnce you've made the key copy the keyID and the issuerID as well.")
                .font(.system(.caption, design: .rounded))
        }
    }
    
    var footer: some View {
        HStack {
            Spacer()
            Button {
                credentials.clearAllCredentials()
            } label: {
                Text("Clear Credentials")
            }
            Button {
                dismiss()
            } label: {
                Text("Save Credentials")
            }
        }
    }
    
    var keyId: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("keyId")
                .font(.system(.title3, design: .rounded))
                .bold()
            TextField("keyId", text: $credentials.keyID)
                .frame(width: 100)
        }
    }
    
    var issuerId: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("issuerId")
                .font(.system(.title3, design: .rounded))
                .bold()
            TextField("issuerId", text: $credentials.issuerId)
                .frame(width: 200)
        }
    }
    
    var privateKey: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Private Key")
                .font(.system(.title3, design: .rounded))
                .bold()
            Text("After downloading your private key, drag and drop the .p8 file containing the private key onto this window.")
                .font(.caption)
            
            Color(.controlBackgroundColor)
                .frame(width: 300, height: 100)
                .overlay(
                    Text(credentials.privateKey)
                )
                .overlay(
                    Text("Drop p8 file here")
                        .opacity(credentials.privateKey.isEmpty ? 1 : 0)
                )
        }
    }
    
    func handleExternalFileDrop(providers: [NSItemProvider]) -> Bool {
        if let provider = providers.first(where: { $0.canLoadObject(ofClass: URL.self) } ) {
            let _ = provider.loadObject(ofClass: URL.self) { object, error in
                if let url = object {
                    print(url)
                    
                    if let data = try? Data(contentsOf: url) {
                        if let string = String(data: data, encoding: .utf8) {
                            
                            if string.prefix(27) == "-----BEGIN PRIVATE KEY-----" {
                                print("begins with correct stuff")
                            }
                            
                            if string.count == 257 {
                                print("count checks out")
                            }
                            
                            DispatchQueue.main.async(execute: {
                                CredentialsManager.shared.privateKey = string
                            })
                        }
                    }
                    
                }
            }
            return true
        }
        return false
    }
}

struct AddCredentialsView_Previews: PreviewProvider {
    static var previews: some View {
        AddCredentialsView()
    }
}
