//
//  TranslationPreferencesScreen.swift
//  Superstar (macOS)
//
//  Created by Jordi Bruin on 27/09/2022.
//

import SwiftUI

struct TranslationPreferencesScreen: View {
    
    @StateObject var credentials = CredentialsManager.shared
    
    var body: some View {
        VStack {
            Text("Deep L")
            Text("Add your (free) DeepL API key to enable automatic translation in Superstar.")
            
            deepLKeyTextField
            
            Button {
                credentials.saveDeepLKey()
            } label: {
                Text("Save")
            }

        }
        .padding(.vertical, 40)
        
    }
    
    var deepLKeyTextField: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Deep L API Key")
                .font(.system(.title3, design: .rounded))
                .bold()
            TextField("API Key", text: $credentials.deepLAPIKey)
                .frame(width: 300)
        }
        .onChange(of: credentials.deepLAPIKey, perform: { newValue in
            if newValue.isEmpty {
                print("translation API empty!")
                credentials.saveDeepLKey()
            }
        })
    }
}

struct TranslationPreferencesScreen_Previews: PreviewProvider {
    static var previews: some View {
        TranslationPreferencesScreen()
    }
}
