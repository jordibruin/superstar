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
    @AppStorage("pendingPublications") var pendingPublications: [String] = []
    
    var body: some View {
        
        VStack(alignment: .leading) {
            header
            
            VStack(alignment: .leading, spacing: 20) {
                fetchIcons
                removePending
                Spacer()
            }
            
        }
        .padding(12)
        .background(
            Color.gray.opacity(0.05)
        )
        .frame(width: 300, height: 300)
    }
    
    var header: some View {
        HStack {
            Text("Settings")
                .font(.system(.title, design: .rounded))
                .bold()
            
            Spacer()
            
            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.title2)
                    .opacity(0.7)
            }
            .buttonStyle(.plain)
        }
        .padding(.top, 4)
    }
    var fetchIcons: some View {
        VStack(alignment: .leading) {
            Button {
                Task {
                    await appsManager.getIcons()
                }
            } label: {
                Label("Fetch Icons", systemImage: "paintbrush.fill")
                    .font(.system(.body, design: .rounded))
            }
            Text("Retrieve the latest icons for your apps")
                .font(.system(.caption, design: .rounded))
        }
    }
    
    var removePending: some View {
        VStack(alignment: .leading) {
        Button {
            pendingPublications.removeAll()
        } label: {
            Label("Clear pending responses", systemImage: "arrowshape.turn.up.left.2.circle.fill")
                .font(.system(.body, design: .rounded))
        }
            Text("When you respond to a review, its ID is saved locally so that it can be hidden while it's being reviewed by Apple. You can reset the cache, but be aware that this will cause you to see reviews that you have already responded to which are in still in review.")
                .font(.system(.caption, design: .rounded))
        }
    }
}

struct SettingsSheet_Previews: PreviewProvider {
    static var previews: some View {
        SettingsSheet(appsManager: AppsManager())
    }
}
