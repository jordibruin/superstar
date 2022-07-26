//
//  Supernova.swift
//  Superstar (macOS)
//
//  Created by Jordi Bruin on 26/07/2022.
//

import SwiftUI


struct Supernova: View {
    
    @EnvironmentObject var iapManager: IAPManager
    @EnvironmentObject var appsManager: AppsManager
    
    
    
    var body: some View {
        VStack {
            Text("Paid user?")
                .font(.system(.title, design: .rounded))
                .bold()
            
            Text("\(iapManager.proUser ? "true" : "False")")
                .font(.system(.title2, design: .rounded))
            
            Picker(selection: $iapManager.freeAppId) {
                ForEach(appsManager.foundApps, id:\.id) { app in
                    Text(app.attributes?.name ?? "")
                        .tag(app.id)
                }
            } label: {
                Text("Select free app")
            }
            .frame(width: 240)
            .labelsHidden()

            
            VStack(alignment: .leading) {
                Text("Benefits")
                    .bold()
                Text("Respond to all your reviews")
                Text("Unlimited Response Suggestions")
                Text("Import Response Suggestions")
                Text("Auto Reply")
                Text("Multiple App Store Connect Accounts")
                Text("Hide Apps")
                Text("Menu bar app")
            }
            .font(.system(.title3, design: .rounded))
            
            Button {
                iapManager.togglePayStatus()
            } label: {
                Text("Change pro status")
            }

        }
    }
}

struct Supernova_Previews: PreviewProvider {
    static var previews: some View {
        Supernova()
    }
}
