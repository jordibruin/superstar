//
//  SettingsSheet.swift
//  Superstar (macOS)
//
//  Created by Jordi Bruin on 17/07/2022.
//

import SwiftUI

struct SettingsSheet: View {
    
    @Environment(\.dismiss) var dismiss
    
    @ObservedObject var appsManager: AppsManager
    
    var body: some View {
        
        VStack {
            Spacer()
            Button {
                Task {
                    await appsManager.getIcons()
                }
            } label: {
                Text("Get icons")
            }
            
            Spacer()
            HStack {
                Spacer()
                Button {
                    dismiss()
                } label: {
                    Text("Close")
                }
            }
        }
        .background(
            Color.gray.opacity(0.2)
        )
        .frame(width: 400, height: 400)
    }
}

//struct SettingsSheet_Previews: PreviewProvider {
//    static var previews: some View {
//        SettingsSheet()
//    }
//}
