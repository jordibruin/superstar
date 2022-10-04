//
//  SettingsSheet.swift
//  Superstar (macOS)
//
//  Created by Jordi Bruin on 17/07/2022.
//

import SwiftUI

struct SettingsSheet: View {
    
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var appsManager: AppsManager
    @AppStorage("pendingPublications") var pendingPublications: [String] = []
    
    @AppStorage("menuBarVisible") var menuBarVisible: Bool = true
    @AppStorage("onlyShowSuggestionsPerApp") var onlyShowSuggestionsPerApp: Bool = true
    
    @AppStorage("venturaMode") var venturaMode: Bool = true
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            fetchIcons
            removeCacheIcons
            removePending
            showHiddenApps
            menuBarToggle
            onlyShowSuggestionsPerAppView
            favoriteAppPicker
            //            venturaModeView
            Spacer()
        }
        .frame(minWidth: 700)
        .frame(height: 600)
        .padding(12)
        .toolbar(content: {
            //            ToolbarItem(content: {
            //                Text("Settings")
            //                .font(.title2)
            //                .bold()
            //            })
            Text("")
        })
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
        .padding(.top, 8)
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
                .font(.system(.body, design: .rounded))
        }
    }
    
    var removeCacheIcons: some View {
        VStack(alignment: .leading) {
            Button {
                appsManager.removeCachedIcons()
            } label: {
                Label("Remove Icons Cache", systemImage: "trash.slash.circle.fill")
                    .font(.system(.body, design: .rounded))
            }
            Text("Remove the cached icons")
                .font(.system(.body, design: .rounded))
        }
    }
    
    @AppStorage("hiddenAppIds") var hiddenAppIds: [String] = []
    
    var showHiddenApps: some View {
        VStack(alignment: .leading) {
            Button {
                hiddenAppIds.removeAll()
            } label: {
                Label("Show hidden apps", systemImage: "eye.slash.fill")
                    .font(.system(.body, design: .rounded))
            }
            
        }
    }
    
    var venturaModeView: some View {
        VStack(alignment: .leading) {
            Toggle(isOn: $venturaMode) {
                Text("Ventura Mode")
                    .font(.system(.body, design: .rounded))
            }
            Text("Turn this on if you're on Ventura/")
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
            Text("When you respond to a review, its ID is saved locally so that it can be hidden while it's being reviewed by Apple. You can reset the cache, but be aware that this will cause you to see reviews that you have already responded to which are still in review.")
                .font(.system(.body, design: .rounded))
        }
    }
    
    var menuBarToggle: some View {
        VStack(alignment: .leading) {
            Toggle(isOn: $menuBarVisible) {
                Text("Show Menu Bar icon")
                    .font(.system(.body, design: .rounded))
            }
            .onChange(of: menuBarVisible) { menuBarVisible in
                updateMenuBar()
            }
        }
    }
    
    var onlyShowSuggestionsPerAppView: some View {
        VStack(alignment: .leading) {
            Toggle(isOn: $onlyShowSuggestionsPerApp) {
                Text("Only show suggestions for selected app")
                    .font(.system(.body, design: .rounded))
            }
            Text("Only show suggestions for the app that you currently have selected. This will also show response suggestions that are not linked to an app.")
                .font(.system(.body, design: .rounded))
        }
    }
    
    @AppStorage("favoriteAppId") var favoriteAppId: String = ""
    
    var favoriteAppPicker: some View {
        VStack(alignment: .leading) {
            Text("Favorite app")
                .font(.system(.title3, design: .rounded))
                .bold()
            
            Picker(selection: $favoriteAppId) {
                Text("None")
                    .tag("")
                
                ForEach(appsManager.foundApps, id: \.id) { app in
                    if !hiddenAppIds.contains(app.id) {
                        Text(app.attributes?.name ?? "No Name")
                            .tag(app.id)
                    }
                }
            } label: {
                Text("Link to App")
            }
            .labelsHidden()
            .frame(width: 250)
            
            Text("Automatically show reviews for your favorite app once apps are loaded")
                .font(.system(.body, design: .rounded))
        }
    }
    
    func updateMenuBar() {
        NotificationCenter.default.post(
            name: Notification.Name.init("changeMenu"),
            object: "Object",
            userInfo: ["menuBarVisible": menuBarVisible]
        )
    }
    
}

//struct SettingsSheet_Previews: PreviewProvider {
//    static var previews: some View {
//        SettingsSheet(appsManager: AppsManager())
//    }
//}
